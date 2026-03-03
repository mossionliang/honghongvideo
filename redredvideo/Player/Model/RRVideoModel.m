//
//  RRVideoModel.m
//  redredvideo
//
//  视频数据模型 - 支持 API 和 Mock 数据
//

#import "RRVideoModel.h"

@implementation RRVideoModel

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    RRVideoModel *model = [[RRVideoModel alloc] init];
    model.videoId = [NSString stringWithFormat:@"%@", dict[@"video_id"] ?: dict[@"id"] ?: @""];
    model.title = dict[@"title"] ?: @"";
    model.videoUrl = dict[@"video_url"] ?: @"";
    model.coverUrl = dict[@"cover_url"] ?: @"";
    model.author = dict[@"author"] ?: @"";
    model.desc = dict[@"desc"] ?: dict[@"description"] ?: @"";
    model.likeCount = [dict[@"like_count"] integerValue];
    model.commentCount = [dict[@"comment_count"] integerValue];
    model.shareCount = [dict[@"share_count"] integerValue];
    return model;
}

+ (instancetype)modelWithFeedDict:(NSDictionary *)dict baseURL:(NSString *)baseURL {
    RRVideoModel *model = [[RRVideoModel alloc] init];
    
    model.videoId = [NSString stringWithFormat:@"%@", dict[@"id"] ?: @""];
    model.dramaId = [dict[@"drama_id"] integerValue];
    model.episodeNumber = [dict[@"episode_number"] integerValue];
    model.totalEpisodes = [dict[@"total_episodes"] integerValue];
    model.dramaTitle = dict[@"drama_title"] ?: @"";
    model.dramaCover = dict[@"drama_cover"] ?: @"";
    
    // 标题：优先用 "剧名 · 第N集"
    NSString *epTitle = dict[@"title"] ?: @"";
    if (model.dramaTitle.length > 0) {
        model.title = [NSString stringWithFormat:@"%@ · %@", model.dramaTitle, epTitle];
    } else {
        model.title = epTitle;
    }
    
    // 视频地址：本地上传的用相对路径，需要拼上 baseURL
    NSString *videoUrl = dict[@"video_url"] ?: @"";
    if (videoUrl.length > 0 && ![videoUrl hasPrefix:@"http"]) {
        model.videoUrl = [NSString stringWithFormat:@"%@%@", baseURL, videoUrl];
    } else {
        model.videoUrl = videoUrl;
    }
    
    // 封面同理
    NSString *coverUrl = dict[@"cover_url"] ?: @"";
    if (coverUrl.length > 0 && ![coverUrl hasPrefix:@"http"]) {
        model.coverUrl = [NSString stringWithFormat:@"%@%@", baseURL, coverUrl];
    } else {
        model.coverUrl = coverUrl;
    }
    
    model.author = dict[@"author"] ?: @"";
    model.desc = dict[@"description"] ?: @"";
    model.likeCount = [dict[@"like_count"] integerValue];
    model.commentCount = arc4random_uniform(5000); // API暂无评论数，随机生成
    model.shareCount = arc4random_uniform(2000);
    
    return model;
}

+ (NSArray<RRVideoModel *> *)modelsFromFeedList:(NSArray<NSDictionary *> *)list baseURL:(NSString *)baseURL {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:list.count];
    for (NSDictionary *dict in list) {
        [models addObject:[RRVideoModel modelWithFeedDict:dict baseURL:baseURL]];
    }
    return [models copy];
}

+ (NSArray<RRVideoModel *> *)mockVideos {
    NSArray *data = @[
        @{
            @"video_id": @"v001",
            @"title": @"西瓜播放器演示 - 360P",
            @"video_url": @"https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/mp4/xgplayer-demo-360p.mp4",
            @"author": @"西瓜视频",
            @"desc": @"字节跳动西瓜播放器官方演示视频",
            @"like_count": @(12800),
            @"comment_count": @(3200),
            @"share_count": @(890),
        },
        @{
            @"video_id": @"v002",
            @"title": @"海洋 - 自然风光",
            @"video_url": @"https://vjs.zencdn.net/v/oceans.mp4",
            @"author": @"VideoJS",
            @"desc": @"壮观的海洋自然风光展示",
            @"like_count": @(15600),
            @"comment_count": @(4200),
            @"share_count": @(1200),
        },
    ];
    
    NSMutableArray *videos = [NSMutableArray array];
    for (NSDictionary *d in data) {
        [videos addObject:[RRVideoModel modelWithDict:d]];
    }
    return [videos copy];
}

@end
