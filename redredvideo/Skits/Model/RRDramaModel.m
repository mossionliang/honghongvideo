//
//  RRDramaModel.m
//  redredvideo
//

#import "RRDramaModel.h"

@implementation RRDramaModel

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    RRDramaModel *model = [[RRDramaModel alloc] init];
    model.dramaId = dict[@"drama_id"] ?: @"";
    model.title = dict[@"title"] ?: @"";
    model.coverUrl = dict[@"cover_url"] ?: @"";
    model.desc = dict[@"desc"] ?: @"";
    model.category = dict[@"category"] ?: @"";
    model.licenseNo = dict[@"license_no"] ?: @"";
    model.copyrightOwner = dict[@"copyright_owner"] ?: @"";
    model.tags = dict[@"tags"] ?: @[];
    model.actors = dict[@"actors"] ?: @[];
    model.totalEpisodes = [dict[@"total_episodes"] integerValue];
    model.updateEpisode = [dict[@"update_episode"] integerValue];
    model.score = [dict[@"score"] floatValue];
    model.hotCount = [dict[@"hot_count"] integerValue];
    model.playCount = [dict[@"play_count"] integerValue];
    model.isVip = [dict[@"is_vip"] isKindOfClass:[NSNumber class]] ? [dict[@"is_vip"] boolValue] : NO;
    model.isFree = [dict[@"is_free"] isKindOfClass:[NSNumber class]] ? [dict[@"is_free"] boolValue] : NO;
    model.isFinished = [dict[@"is_finished"] isKindOfClass:[NSNumber class]] ? [dict[@"is_finished"] boolValue] : NO;
    return model;
}

+ (instancetype)modelWithAPIDict:(NSDictionary *)dict baseURL:(NSString *)baseURL {
    RRDramaModel *model = [[RRDramaModel alloc] init];
    model.dramaId = [NSString stringWithFormat:@"%@", dict[@"id"] ?: @""];
    model.title = dict[@"title"] ?: @"";
    
    // 封面：相对路径拼接 baseURL
    NSString *cover = dict[@"cover_url"] ?: @"";
    if (cover.length > 0 && ![cover hasPrefix:@"http"]) {
        model.coverUrl = [NSString stringWithFormat:@"%@%@", baseURL, cover];
    } else {
        model.coverUrl = cover;
    }
    
    // 横版封面（Banner用）
    NSString *banner = dict[@"banner_url"] ?: @"";
    if (banner.length > 0 && ![banner hasPrefix:@"http"]) {
        model.bannerUrl = [NSString stringWithFormat:@"%@%@", baseURL, banner];
    } else {
        model.bannerUrl = banner;
    }
    
    model.desc = dict[@"description"] ?: @"";
    model.category = dict[@"category_name"] ?: @"";
    model.totalEpisodes = [dict[@"total_episodes"] integerValue];
    model.updateEpisode = model.totalEpisodes; // API暂无更新集数字段，默认全部
    model.score = [dict[@"rating"] floatValue];
    model.playCount = [dict[@"play_count"] integerValue];
    model.hotCount = [dict[@"like_count"] integerValue];
    model.isVip = [dict[@"vip_free"] boolValue];
    model.isFree = [dict[@"price_per_episode"] floatValue] == 0;
    model.isFinished = YES; // 短剧默认完结
    
    // tags
    id tags = dict[@"tags"];
    if ([tags isKindOfClass:[NSArray class]]) {
        model.tags = tags;
    } else {
        model.tags = @[];
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
