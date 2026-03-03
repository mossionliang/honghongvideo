//
//  RRDramaModel.h
//  redredvideo
//
//  短剧数据模型
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 短剧模型
@interface RRDramaModel : NSObject

@property (nonatomic, copy) NSString *dramaId;          // 短剧ID
@property (nonatomic, copy) NSString *title;             // 剧名
@property (nonatomic, copy) NSString *coverUrl;          // 竖版封面图URL（3:4）
@property (nonatomic, copy) NSString *bannerUrl;         // 横版封面图URL（16:9）
@property (nonatomic, copy) NSString *desc;              // 简介
@property (nonatomic, copy) NSString *category;          // 分类（甜宠/逆袭/悬疑等）
@property (nonatomic, copy) NSString *licenseNo;         // 备案号/许可证号
@property (nonatomic, copy) NSString *copyrightOwner;    // 版权方
@property (nonatomic, copy) NSArray<NSString *> *tags;   // 标签
@property (nonatomic, copy) NSArray<NSString *> *actors;  // 演员
@property (nonatomic, assign) NSInteger totalEpisodes;    // 总集数
@property (nonatomic, assign) NSInteger updateEpisode;    // 更新到第几集
@property (nonatomic, assign) CGFloat score;              // 评分 (0-10)
@property (nonatomic, assign) NSInteger hotCount;         // 热度值
@property (nonatomic, assign) NSInteger playCount;        // 播放量
@property (nonatomic, assign) BOOL isVip;                 // 是否VIP专享
@property (nonatomic, assign) BOOL isFree;                // 是否免费
@property (nonatomic, assign) BOOL isFinished;            // 是否完结

+ (instancetype)modelWithDict:(NSDictionary *)dict;

/// 从后台 API /api/dramas 返回的数据解析
+ (instancetype)modelWithAPIDict:(NSDictionary *)dict baseURL:(NSString *)baseURL;

/// 批量解析
+ (NSArray<RRDramaModel *> *)modelsFromAPIList:(NSArray<NSDictionary *> *)list baseURL:(NSString *)baseURL;

@end

/// Banner模型
@interface RRBannerModel : NSObject

@property (nonatomic, copy) NSString *bannerId;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger sortOrder;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end

/// 分类模型
@interface RRCategoryModel : NSObject

@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, assign) NSInteger sortOrder;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end

/// 首页板块模型（推荐/热播/新上线等）
@interface RRSkitsSectionModel : NSObject

@property (nonatomic, copy) NSString *sectionId;
@property (nonatomic, copy) NSString *sectionTitle;       // 板块标题：热播榜/新上线/猜你喜欢
@property (nonatomic, copy) NSString *sectionType;        // 板块类型：banner/category/horizontal/vertical/rank
@property (nonatomic, copy) NSArray<RRDramaModel *> *dramas;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
