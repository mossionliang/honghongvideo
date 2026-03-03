//
//  RRAPIManager.m
//  redredvideo
//
//  网络请求管理器
//

#import "RRAPIManager.h"
#import <AFNetworking/AFNetworking.h>

@interface RRAPIManager ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end

@implementation RRAPIManager

+ (instancetype)shared {
    static RRAPIManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RRAPIManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _baseURL = @"http://192.168.4.157:3000";
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        // 超时
        _sessionManager.requestSerializer.timeoutInterval = 15;
    }
    return self;
}

- (NSString *)fullURL:(NSString *)path {
    if ([path hasPrefix:@"http"]) return path;
    return [NSString stringWithFormat:@"%@%@", self.baseURL, path];
}

- (void)GET:(NSString *)path
     params:(NSDictionary *)params
    success:(RRAPISuccess)success
    failure:(RRAPIFailure)failure {
    
    NSString *url = [self fullURL:path];
    [self.sessionManager GET:url parameters:params headers:nil progress:nil
        success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                success(responseObject);
            } else {
                success(@{@"data": responseObject ?: @{}});
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"[RRAPIManager] GET %@ failed: %@", path, error.localizedDescription);
            failure(error);
        }];
}

- (void)POST:(NSString *)path
      params:(NSDictionary *)params
     success:(RRAPISuccess)success
     failure:(RRAPIFailure)failure {
    
    NSString *url = [self fullURL:path];
    [self.sessionManager POST:url parameters:params headers:nil progress:nil
        success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                success(responseObject);
            } else {
                success(@{@"data": responseObject ?: @{}});
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"[RRAPIManager] POST %@ failed: %@", path, error.localizedDescription);
            failure(error);
        }];
}

#pragma mark - 业务接口

- (void)fetchFeedWithPage:(NSInteger)page
                 pageSize:(NSInteger)pageSize
                     seed:(uint32_t)seed
                  success:(RRAPISuccess)success
                  failure:(RRAPIFailure)failure {
    
    NSDictionary *params = @{
        @"page": @(page),
        @"pageSize": @(pageSize),
        @"seed": @(seed),
    };
    [self GET:@"/api/dramas/feed/videos" params:params success:success failure:failure];
}

@end
