//
//  RRAPIManager.h
//  redredvideo
//
//  网络请求管理器（基于 AFNetworking）
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RRAPISuccess)(NSDictionary *responseDict);
typedef void(^RRAPIFailure)(NSError *error);

@interface RRAPIManager : NSObject

+ (instancetype)shared;

/// 服务器基地址（默认 http://localhost:3000）
@property (nonatomic, copy) NSString *baseURL;

/// GET 请求
- (void)GET:(NSString *)path
     params:(nullable NSDictionary *)params
    success:(RRAPISuccess)success
    failure:(RRAPIFailure)failure;

/// POST 请求
- (void)POST:(NSString *)path
      params:(nullable NSDictionary *)params
     success:(RRAPISuccess)success
     failure:(RRAPIFailure)failure;

#pragma mark - 业务接口

/// 首页视频流
- (void)fetchFeedWithPage:(NSInteger)page
                 pageSize:(NSInteger)pageSize
                     seed:(uint32_t)seed
                  success:(RRAPISuccess)success
                  failure:(RRAPIFailure)failure;

@end

NS_ASSUME_NONNULL_END
