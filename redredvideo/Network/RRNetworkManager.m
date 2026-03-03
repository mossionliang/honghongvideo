//
//  RRNetworkManager.m
//  redredvideo
//
//  网络请求管理器 - 基于 AFNetworking
//

#import "RRNetworkManager.h"
#import <AFNetworking/AFNetworking.h>

@interface RRNetworkManager ()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@end

@implementation RRNetworkManager

+ (instancetype)shared {
    static RRNetworkManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RRNetworkManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 默认本地服务器地址
        _baseURL = @"http://192.168.4.157:3000";
        
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        // 允许接收各类 content-type
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
            @"application/json", @"text/json", @"text/plain", @"text/html", nil];
        // 超时
        _manager.requestSerializer.timeoutInterval = 15;
    }
    return self;
}

- (NSString *)fullURLWithPath:(NSString *)path {
    if ([path hasPrefix:@"http"]) return path;
    return [NSString stringWithFormat:@"%@%@", self.baseURL, path];
}

#pragma mark - GET

- (void)GET:(NSString *)path
     params:(NSDictionary *)params
    success:(RRNetSuccess)success
    failure:(RRNetFailure)failure {
    
    NSString *url = [self fullURLWithPath:path];
    [self.manager GET:url parameters:params headers:nil progress:nil
              success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            success(responseObject);
        } else {
            success(@{@"data": responseObject ?: @{}});
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[RRNetwork] GET %@ failed: %@", path, error.localizedDescription);
        failure(error);
    }];
}

#pragma mark - POST

- (void)POST:(NSString *)path
      params:(NSDictionary *)params
     success:(RRNetSuccess)success
     failure:(RRNetFailure)failure {
    
    NSString *url = [self fullURLWithPath:path];
    [self.manager POST:url parameters:params headers:nil progress:nil
               success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            success(responseObject);
        } else {
            success(@{@"data": responseObject ?: @{}});
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[RRNetwork] POST %@ failed: %@", path, error.localizedDescription);
        failure(error);
    }];
}

#pragma mark - Upload

- (void)upload:(NSString *)path
        params:(NSDictionary *)params
      fileData:(NSData *)fileData
      fileName:(NSString *)fileName
      mimeType:(NSString *)mimeType
     fileField:(NSString *)fileField
       success:(RRNetSuccess)success
       failure:(RRNetFailure)failure {
    
    NSString *url = [self fullURLWithPath:path];
    // 上传用 form-data
    AFHTTPSessionManager *uploadManager = [AFHTTPSessionManager manager];
    uploadManager.responseSerializer = [AFJSONResponseSerializer serializer];
    uploadManager.responseSerializer.acceptableContentTypes = self.manager.responseSerializer.acceptableContentTypes;
    
    [uploadManager POST:url parameters:params headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:fileData name:fileField fileName:fileName mimeType:mimeType];
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            success(responseObject);
        } else {
            success(@{@"data": responseObject ?: @{}});
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[RRNetwork] Upload %@ failed: %@", path, error.localizedDescription);
        failure(error);
    }];
}

@end
