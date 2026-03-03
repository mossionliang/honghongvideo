//
//  RRNetworkManager.h
//  redredvideo
//
//  网络请求管理器 - 基于 AFNetworking
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 请求成功回调
typedef void(^RRNetSuccess)(NSDictionary *responseDict);
/// 请求失败回调
typedef void(^RRNetFailure)(NSError *error);

@interface RRNetworkManager : NSObject

+ (instancetype)shared;

/// 服务器基础地址（默认 http://localhost:3000）
@property (nonatomic, copy) NSString *baseURL;

/// GET 请求
- (void)GET:(NSString *)path
     params:(nullable NSDictionary *)params
    success:(RRNetSuccess)success
    failure:(RRNetFailure)failure;

/// POST 请求（JSON body）
- (void)POST:(NSString *)path
      params:(nullable NSDictionary *)params
     success:(RRNetSuccess)success
     failure:(RRNetFailure)failure;

/// POST 上传文件
- (void)upload:(NSString *)path
        params:(nullable NSDictionary *)params
      fileData:(NSData *)fileData
      fileName:(NSString *)fileName
      mimeType:(NSString *)mimeType
      fileField:(NSString *)fileField
       success:(RRNetSuccess)success
       failure:(RRNetFailure)failure;

@end

NS_ASSUME_NONNULL_END
