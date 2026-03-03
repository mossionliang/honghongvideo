//
//  RRScreenCastManager.m
//  redredvideo
//
//  投屏管理器：搜索 → 连接 → 推送视频
//

#import "RRScreenCastManager.h"

@interface RRScreenCastManager () <LBLelinkBrowserDelegate, LBLelinkConnectionDelegate, LBLelinkPlayerDelegate>

@property (nonatomic, strong) LBLelinkBrowser *browser;
@property (nonatomic, strong) LBLelinkConnection *connection;
@property (nonatomic, strong) LBLelinkPlayer *player;
@property (nonatomic, strong) NSArray<LBLelinkService *> *services;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, strong) LBLelinkService *connectedService;

@end

@implementation RRScreenCastManager

+ (instancetype)shared {
    static RRScreenCastManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RRScreenCastManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _services = @[];
        _isConnected = NO;
        
        // 初始化搜索器
        _browser = [[LBLelinkBrowser alloc] init];
        _browser.delegate = self;
        
        // 初始化连接
        _connection = [[LBLelinkConnection alloc] init];
        _connection.delegate = self;
        
        // 初始化播放器
        _player = [[LBLelinkPlayer alloc] initWithConnection:_connection];
        _player.delegate = self;
    }
    return self;
}

#pragma mark - Public

- (void)startSearch {
    NSLog(@"[投屏] 开始搜索设备");
    [self.browser searchForLelinkService];
}

- (void)stopSearch {
    [self.browser stop];
}

- (void)connectToService:(LBLelinkService *)service {
    NSLog(@"[投屏] 正在连接: %@", service.lelinkServiceName);
    
    // 如果已经连接了其他设备，先断开
    if (self.isConnected) {
        NSLog(@"[投屏] 检测到已连接设备，先断开旧连接");
        [self.player stop];
        [self.connection disConnect];
        self.isConnected = NO;
        self.connectedService = nil;
    }
    
    [self.connection connectToLelinkService:service];
}

- (void)disconnect {
    [self.player stop];
    [self.connection disConnect];
    self.isConnected = NO;
    self.connectedService = nil;
}

- (void)playVideoWithURL:(NSString *)urlString title:(NSString *)title {
    NSLog(@"[投屏] playVideoWithURL 被调用");
    NSLog(@"[投屏] isConnected: %d", self.isConnected);
    NSLog(@"[投屏] videoURL: %@", urlString);
    NSLog(@"[投屏] player.lelinkConnection: %@", self.player.lelinkConnection);
    
    if (!self.isConnected) {
        NSLog(@"[投屏] 未连接设备");
        return;
    }
    
    if (urlString.length == 0) {
        NSLog(@"[投屏] 视频URL为空");
        return;
    }
    
    // 确保 player 的 connection 已设置
    if (!self.player.lelinkConnection) {
        NSLog(@"[投屏] 警告：player.lelinkConnection 为空，重新设置");
        self.player.lelinkConnection = self.connection;
    }
    
    LBLelinkPlayerItem *item = [[LBLelinkPlayerItem alloc] init];
    item.mediaType = LBLelinkMediaTypeVideoOnline;
    item.mediaURLString = urlString;
    if (title.length > 0) {
        item.mediaName = title;
    }
    
    NSLog(@"[投屏] 开始推送视频: %@", urlString);
    [self.player playWithItem:item];
}

- (void)pause {
    [self.player pause];
}

- (void)resume {
    [self.player resumePlay];
}

- (void)stop {
    [self.player stop];
}

- (void)seekTo:(NSInteger)seconds {
    [self.player seekTo:seconds];
    NSLog(@"[投屏] 跳转到: %ld 秒", (long)seconds);
}

- (void)setPlaySpeed:(CGFloat)speed {
    LBPlaySpeedRateType rateType = [self.player playSpeedRateTypeWithRate:speed];
    [self.player setPlaySpeedWithRate:rateType];
    NSLog(@"[投屏] 设置倍速: %.2fx", speed);
}

#pragma mark - LBLelinkBrowserDelegate

- (void)lelinkBrowser:(LBLelinkBrowser *)browser permissionsPolicyDenied:(LBLelinkSystemPermissionsType)systemPermissionsType {
    NSLog(@"[投屏] 权限被拒绝: %lu", (unsigned long)systemPermissionsType);
}

- (void)lelinkBrowser:(LBLelinkBrowser *)browser didFindLelinkServices:(NSArray<LBLelinkService *> *)services {
    self.services = services ?: @[];
    NSLog(@"[投屏] 发现 %lu 台设备", (unsigned long)self.services.count);
    
    if ([self.delegate respondsToSelector:@selector(screenCastDidUpdateServices:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate screenCastDidUpdateServices:self.services];
        });
    }
}

- (void)lelinkBrowser:(LBLelinkBrowser *)browser onError:(NSError *)error {
    NSLog(@"[投屏] 搜索出错: %@", error);
}

#pragma mark - LBLelinkConnectionDelegate

- (void)lelinkConnectionDidStartRetryConnect:(LBLelinkConnection *)connection {
    NSLog(@"[投屏] 正在重连...");
}

- (void)lelinkConnection:(LBLelinkConnection *)connection didConnectToService:(LBLelinkService *)service {
    NSLog(@"[投屏] 已连接: %@", service.lelinkServiceName);
    
    // 如果是切换设备（之前已经有连接过），重新创建 player 实例
    if (self.connectedService && ![self.connectedService.lelinkServiceName isEqualToString:service.lelinkServiceName]) {
        NSLog(@"[投屏] 检测到切换设备，重新创建 player 实例");
        self.player = [[LBLelinkPlayer alloc] initWithConnection:connection];
        self.player.delegate = self;
    }
    
    self.isConnected = YES;
    self.connectedService = service;
    
    // 确保 player 使用的是已连接的 connection
    self.player.lelinkConnection = connection;
    NSLog(@"[投屏] 已更新 player 的 connection: %@", connection);
    NSLog(@"[投屏] player 实例: %@", self.player);
    NSLog(@"[投屏] player.delegate: %@", self.player.delegate);
    
    if ([self.delegate respondsToSelector:@selector(screenCastDidConnect:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate screenCastDidConnect:service];
        });
    }
}

- (void)lelinkConnection:(LBLelinkConnection *)connection disConnectToService:(LBLelinkService *)service {
    NSLog(@"[投屏] 已断开: %@", service.lelinkServiceName);
    self.isConnected = NO;
    self.connectedService = nil;
    
    if ([self.delegate respondsToSelector:@selector(screenCastDidDisconnect:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate screenCastDidDisconnect:service];
        });
    }
}

- (void)lelinkConnection:(LBLelinkConnection *)connection onError:(NSError *)error {
    NSLog(@"[投屏] 连接出错: %@", error);
    self.isConnected = NO;
    
    if ([self.delegate respondsToSelector:@selector(screenCastDidFailWithError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate screenCastDidFailWithError:error];
        });
    }
}

#pragma mark - LBLelinkPlayerDelegate

- (void)lelinkPlayer:(LBLelinkPlayer *)player playStatus:(LBLelinkPlayStatus)playStatus {
    NSLog(@"[投屏] 播放状态: %lu", (unsigned long)playStatus);
    
    if ([self.delegate respondsToSelector:@selector(screenCastPlayStatusChanged:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate screenCastPlayStatusChanged:playStatus];
        });
    }
}

- (void)lelinkPlayer:(LBLelinkPlayer *)player onError:(NSError *)error {
    NSLog(@"[投屏] 播放出错: %@", error);
}

- (void)lelinkPlayer:(LBLelinkPlayer *)player progressInfo:(LBLelinkProgressInfo *)progressInfo {
    // 投屏播放进度回调
    NSTimeInterval currentTime = progressInfo.currentTime;
    NSTimeInterval totalTime = progressInfo.duration;
    
    NSLog(@"[投屏] 进度更新: %.1f / %.1f", currentTime, totalTime);
    
    if ([self.delegate respondsToSelector:@selector(screenCastProgressUpdated:totalTime:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate screenCastProgressUpdated:currentTime totalTime:totalTime];
        });
    }
}

@end
