//
//  RRDramaModel.m
//  redredvideo
//

#import "RRDramaModel.h"

@implementation RRDramaModel

// MJExtension 属性映射
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"dramaId": @"id",
        @"desc": @"description",
        @"category": @"category_name",
        @"score": @"rating",
        @"hotCount": @"like_count",
        @"coverUrl": @"cover_url",
        @"bannerUrl": @"banner_url",
        @"totalEpisodes": @"total_episodes",
        @"playCount": @"play_count"
    };
}

// MJExtension 会自动处理 NULL 值，BOOL 类型默认为 NO，NSInteger 默认为 0

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    // 使用 MJExtension 自动转换，自动处理 NULL
    return [self mj_objectWithKeyValues:dict];
}

+ (instancetype)modelWithAPIDict:(NSDictionary *)dict baseURL:(NSString *)baseURL {
    // 使用 MJExtension 自动转换
    RRDramaModel *model = [self mj_objectWithKeyValues:dict];
    
    // 处理 URL 拼接
    if (model.coverUrl.length > 0 && ![model.coverUrl hasPrefix:@"http"]) {
        model.coverUrl = [NSString stringWithFormat:@"%@%@", baseURL, model.coverUrl];
    }
    
    if (model.bannerUrl.length > 0 && ![model.bannerUrl hasPrefix:@"http"]) {
        model.bannerUrl = [NSString stringWithFormat:@"%@%@", baseURL, model.bannerUrl];
    }
    
    // 特殊字段处理
    model.updateEpisode = model.totalEpisodes; // API暂无更新集数字段，默认全部
    model.isFree = [dict[@"price_per_episode"] floatValue] == 0;
    model.isFinished = YES; // 短剧默认完结
    
    // vip_free 字段映射到 isVip
    if ([dict[@"vip_free"] isKindOfClass:[NSNumber class]]) {
        model.isVip = [dict[@"vip_free"] boolValue];
    }
    
    return model;
}

+ (NSArray<RRDramaModel *> *)modelsFromAPIList:(NSArray<NSDictionary *> *)list baseURL:(NSString *)baseURL {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:list.count];
    for (NSDictionary *dict in list) {
        [models addObject:[RRDramaModel modelWithAPIDict:dict baseURL:baseURL]];
    }
    return [models copy];
}

@end

@implementation RRBannerModel

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    RRBannerModel *model = [[RRBannerModel alloc] init];
    model.bannerId = dict[@"banner_id"] ?: @"";
    model.imageUrl = dict[@"image_url"] ?: @"";
    model.linkUrl = dict[@"link_url"] ?: @"";
    model.title = dict[@"title"] ?: @"";
    model.sortOrder = [dict[@"sort_order"] integerValue];
    return model;
}

@end

@implementation RRCategoryModel

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    RRCategoryModel *model = [[RRCategoryModel alloc] init];
    model.categoryId = dict[@"category_id"] ?: @"";
    model.name = dict[@"name"] ?: @"";
    model.iconUrl = dict[@"icon_url"] ?: @"";
    model.sortOrder = [dict[@"sort_order"] integerValue];
    return model;
}

@end

@implementation RRSkitsSectionModel

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    RRSkitsSectionModel *model = [[RRSkitsSectionModel alloc] init];
    model.sectionId = dict[@"section_id"] ?: @"";
    model.sectionTitle = dict[@"section_title"] ?: @"";
    model.sectionType = dict[@"section_type"] ?: @"";
    
    NSMutableArray *dramas = [NSMutableArray array];
    for (NSDictionary *d in dict[@"dramas"]) {
        [dramas addObject:[RRDramaModel modelWithDict:d]];
    }
    model.dramas = [dramas copy];
    return model;
}

@end
