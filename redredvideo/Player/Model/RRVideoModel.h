//
//  RRVideoModel.h
//  redredvideo
//
//  视频播放数据模型
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRVideoModel : NSObject

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *videoUrl;       // 视频播放地址
@property (nonatomic, copy) NSString *coverUrl;       // 封面图
@property (nonatomic, copy) NSString *author;         // 作者/来源
@property (nonatomic, copy) NSString *desc;           // 描述
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) NSInteger shareCount;

// API 扩展字段
@property (nonatomic, copy) NSString *dramaTitle;     // 所属剧集名
@property (nonatomic, assign) NSInteger dramaId;      // 剧集ID
@property (nonatomic, assign) NSInteger episodeNumber; // 第几集
@property (nonatomic, assign) NSInteger totalEpisodes; // 总集数
@property (nonatomic, copy) NSString *dramaCover;     // 剧集封面

+ (instancetype)modelWithDict:(NSDictionary *)dict;

/// 从 API feed 数据解析
+ (instancetype)modelWithFeedDict:(NSDictionary *)dict baseURL:(NSString *)baseURL;

/// 批量解析
+ (NSArray<RRVideoModel *> *)modelsFromFeedList:(NSArray<NSDictionary *> *)list baseURL:(NSString *)baseURL;

/// 测试用视频数据
+ (NSArray<RRVideoModel *> *)mockVideos;

@end

NS_ASSUME_NONNULL_END
