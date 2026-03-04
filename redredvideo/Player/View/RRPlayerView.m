//
//  RRPlayerView.m
//  redredvideo
//
//  增强版播放器：预加载、缓冲监控、网络重试、进度回调
//

#import "RRPlayerView.h"
#import <KTVHTTPCache/KTVHTTPCache.h>

static void *kStatusContext = &kStatusContext;
static void *kBufferContext = &kBufferContext;
static void *kBufferEmptyContext = &kBufferEmptyContext;
static void *kBufferFullContext = &kBufferFullContext;

@interface RRPlayerView ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIImageView *pauseIcon;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, assign) RRPlayerState state;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, assign) BOOL isPreloadMode;
@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, assign) BOOL tapLocked; // 防抖锁
@property (nonatomic, assign) BOOL longPressActive; // 长按进行中标记
@property (nonatomic, assign) float playbackRate; // 当前播放速率

@end

@implementation RRPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.state = RRPlayerStateIdle;
        self.retryCount = 0;
        self.playbackRate = 1.0;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 预先创建 playerLayer，避免后续创建时闪烁
    self.playerLayer = [AVPlayerLayer layer];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.playerLayer.frame = self.bounds;
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    // Loading
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingView.color = [UIColor whiteColor];
    self.loadingView.hidesWhenStopped = YES;
    [self addSubview:self.loadingView];
    
    // 暂停图标
    self.pauseIcon = [[UIImageView alloc] init];
    UIImageSymbolConfiguration *pauseConfig = [UIImageSymbolConfiguration configurationWithPointSize:50 weight:UIFontWeightRegular];
    self.pauseIcon.image = [UIImage systemImageNamed:@"play.fill" withConfiguration:pauseConfig];
    self.pauseIcon.tintColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.pauseIcon.contentMode = UIViewContentModeCenter;
    self.pauseIcon.hidden = YES;
    self.pauseIcon.alpha = 0;
    [self addSubview:self.pauseIcon];
    
    // 错误提示
    self.errorLabel = [[UILabel alloc] init];
    self.errorLabel.text = @"视频加载失败";
    self.errorLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    self.errorLabel.font = [UIFont systemFontOfSize:14];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.hidden = YES;
    [self addSubview:self.errorLabel];
    
    // 重试按钮
    self.retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.retryButton setTitle:@"点击重试" forState:UIControlStateNormal];
    [self.retryButton setTitleColor:[UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0] forState:UIControlStateNormal];
    self.retryButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.retryButton.layer.cornerRadius = 18;
    self.retryButton.layer.borderWidth = 1;
    self.retryButton.layer.borderColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:0.6].CGColor;
    self.retryButton.hidden = YES;
    [self.retryButton addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.retryButton];
    
    // 长按手势（2秒）— 必须在 tap 之前添加
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 2.0;
    longPress.allowableMovement = 20; // 允许轻微移动
    [self addGestureRecognizer:longPress];
    
    // 点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat cx = w / 2;
    CGFloat cy = h / 2;
    
    self.playerLayer.frame = self.bounds;
    self.loadingView.center = CGPointMake(cx, cy);
    self.pauseIcon.frame = CGRectMake(cx - 40, cy - 40, 80, 80);
    self.errorLabel.frame = CGRectMake(20, cy - 40, w - 40, 20);
    self.retryButton.frame = CGRectMake(cx - 60, cy - 5, 120, 36);
}

- (void)dealloc {
    [self cleanup];
}

#pragma mark - State Management

- (void)updateState:(RRPlayerState)newState {
    if (self.state == newState) return;
    self.state = newState;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新UI
        self.errorLabel.hidden = (newState != RRPlayerStateError);
        self.retryButton.hidden = (newState != RRPlayerStateError);
        
        // 错误状态时把提示放到最上层
        if (newState == RRPlayerStateError) {
            [self bringSubviewToFront:self.errorLabel];
            [self bringSubviewToFront:self.retryButton];
        }
        
        if (newState == RRPlayerStateLoading || newState == RRPlayerStateBuffering) {
            // 不显示菊花转 loading，改为在进度条上显示加载动画
            // [self.loadingView startAnimating];
            
            // 通知代理显示加载动画
            if ([self.delegate respondsToSelector:@selector(playerView:isLoading:)]) {
                [self.delegate playerView:self isLoading:YES];
            }
        } else {
            [self.loadingView stopAnimating];
            
            // 通知代理隐藏加载动画
            if ([self.delegate respondsToSelector:@selector(playerView:isLoading:)]) {
                [self.delegate playerView:self isLoading:NO];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(playerView:stateChanged:)]) {
            [self.delegate playerView:self stateChanged:newState];
        }
    });
}

#pragma mark - Public

- (void)loadVideoWithURL:(NSURL *)url {
    self.isPreloadMode = NO;
    self.retryCount = 0;
    [self setupPlayerWithURL:url];
}

- (void)preloadVideoWithURL:(NSURL *)url {
    self.isPreloadMode = YES;
    self.retryCount = 0;
    [self setupPlayerWithURL:url];
}

- (void)setupPlayerWithURL:(NSURL *)url {
    self.currentURL = url;
    [self updateState:RRPlayerStateLoading];
    
    // 隐藏 playerLayer，避免显示黑屏或旧画面
    self.playerLayer.opacity = 0;
    
    // 通过 KTVHTTPCache 代理URL（边播边缓存）
    NSURL *proxyURL = [KTVHTTPCache proxyURLWithOriginalURL:url];
    NSLog(@"[RRPlayerView] 原始URL: %@", url);
    NSLog(@"[RRPlayerView] 代理URL: %@", proxyURL);
    
    // 创建带缓冲配置的 PlayerItem
    AVPlayerItem *newItem = [AVPlayerItem playerItemWithURL:proxyURL];
    newItem.preferredForwardBufferDuration = 5.0; // 预缓冲5秒
    
    AVPlayer *newPlayer = [AVPlayer playerWithPlayerItem:newItem];
    newPlayer.automaticallyWaitsToMinimizeStalling = YES;
    
    // 先设置新的 player，避免黑屏或显示旧画面
    self.playerLayer.player = newPlayer;
    
    // 然后清理旧的资源
    [self cleanup];
    
    // 保存新的 player 和 item
    self.player = newPlayer;
    self.playerItem = newItem;
    
    // KVO 观察
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusContext];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:kBufferContext];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:kBufferEmptyContext];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:kBufferFullContext];
    
    // 播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    // 播放失败通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidFail:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:self.playerItem];
    
    // 进度监控（每0.5秒回调一次）
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC)
                                                                 queue:dispatch_get_main_queue()
                                                            usingBlock:^(CMTime time) {
        [weakSelf handleTimeUpdate:time];
    }];
}

- (void)play {
    if (self.state == RRPlayerStateError) return;
    [self.player play];
    if (self.playbackRate != 1.0) {
        self.player.rate = self.playbackRate;
    }
    self.isPlaying = YES;
    [self updateState:RRPlayerStatePlaying];
    [self hidePauseIcon];
    
    // 显示 playerLayer（视频开始播放）
    self.playerLayer.opacity = 1.0;
}

- (void)pause {
    [self.player pause];
    self.isPlaying = NO;
    [self updateState:RRPlayerStatePaused];
    [self showPauseIcon];
}

- (void)stop {
    [self cleanup];
    self.isPlaying = NO;
    self.longPressActive = NO;
    [self updateState:RRPlayerStateIdle];
}

- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

- (void)seekToTime:(CMTime)time {
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)setRate:(float)rate {
    self.playbackRate = rate;
    if (self.isPlaying) {
        self.player.rate = rate;
    }
}

- (void)retry {
    if (self.currentURL) {
        // 手动重试：重置计数器，重新开始
        self.retryCount = 0;
        self.isPreloadMode = NO;
        [self setupPlayerWithURL:self.currentURL];
    }
}

- (NSTimeInterval)currentTime {
    if (self.player) {
        return CMTimeGetSeconds(self.player.currentTime);
    }
    return 0;
}

- (NSTimeInterval)totalTime {
    if (self.playerItem) {
        CMTime duration = self.playerItem.duration;
        if (CMTIME_IS_VALID(duration) && !CMTIME_IS_INDEFINITE(duration)) {
            return CMTimeGetSeconds(duration);
        }
    }
    return 0;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == kStatusContext) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case AVPlayerItemStatusReadyToPlay:
                    if (!self.isPreloadMode) {
                        [self play];
                    } else {
                        [self updateState:RRPlayerStatePaused];
                    }
                    break;
                case AVPlayerItemStatusFailed:
                    NSLog(@"播放失败: %@", self.playerItem.error.localizedDescription);
                    [self handlePlaybackError];
                    break;
                default:
                    break;
            }
        });
    }
    else if (context == kBufferContext) {
        [self handleBufferUpdate];
    }
    else if (context == kBufferEmptyContext) {
        if (self.playerItem.playbackBufferEmpty && self.state == RRPlayerStatePlaying) {
            [self updateState:RRPlayerStateBuffering];
        }
    }
    else if (context == kBufferFullContext) {
        if (self.playerItem.playbackLikelyToKeepUp && self.state == RRPlayerStateBuffering) {
            [self play];
        }
    }
}

#pragma mark - Progress

- (void)handleTimeUpdate:(CMTime)time {
    NSTimeInterval current = CMTimeGetSeconds(time);
    NSTimeInterval total = self.totalTime;
    
    if (total > 0 && [self.delegate respondsToSelector:@selector(playerView:playProgress:currentTime:totalTime:)]) {
        float progress = current / total;
        [self.delegate playerView:self playProgress:progress currentTime:current totalTime:total];
    }
}

- (void)handleBufferUpdate {
    NSArray *loadedRanges = self.playerItem.loadedTimeRanges;
    if (loadedRanges.count == 0) return;
    
    CMTimeRange range = [loadedRanges.firstObject CMTimeRangeValue];
    NSTimeInterval buffered = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
    NSTimeInterval total = self.totalTime;
    
    if (total > 0 && [self.delegate respondsToSelector:@selector(playerView:bufferProgress:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate playerView:self bufferProgress:buffered / total];
        });
    }
}

#pragma mark - Error Handling

- (void)handlePlaybackError {
    if (self.retryCount < 2) {
        // 自动重试（延迟1秒）
        self.retryCount++;
        NSLog(@"自动重试第%ld次", (long)self.retryCount);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.currentURL) {
                [self setupPlayerWithURL:self.currentURL];
            }
        });
    } else {
        [self updateState:RRPlayerStateError];
    }
}

#pragma mark - Notifications

- (void)playerDidFinish:(NSNotification *)notification {
    // 循环播放
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) [self.player play];
    }];
    
    if ([self.delegate respondsToSelector:@selector(playerViewDidFinishPlaying:)]) {
        [self.delegate playerViewDidFinishPlaying:self];
    }
}

- (void)playerDidFail:(NSNotification *)notification {
    [self handlePlaybackError];
}

#pragma mark - Gesture

- (void)handleTap {
    if (self.state == RRPlayerStateError) {
        [self retry];
        return;
    }
    
    // 长按刚结束时不触发单击（防止长按松手后误触发暂停/播放）
    if (self.longPressActive) return;
    
    // 防抖：快速连续点击不触发暂停/播放
    if (self.tapLocked) return;
    self.tapLocked = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tapLocked = NO;
    });
    
    if (self.isPlaying) {
        [self pause];
    } else {
        [self play];
    }
    
    if ([self.delegate respondsToSelector:@selector(playerViewDidTap:)]) {
        [self.delegate playerViewDidTap:self];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // 标记长按进行中
        self.longPressActive = YES;
        
        // 触觉反馈
        UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [feedback impactOccurred];
        
        // 通知代理弹出菜单
        if ([self.delegate respondsToSelector:@selector(playerViewDidLongPress:)]) {
            [self.delegate playerViewDidLongPress:self];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled ||
               gesture.state == UIGestureRecognizerStateFailed) {
        // 延迟重置标记，确保松手后的 tap 不会误触发
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.longPressActive = NO;
        });
    }
}

- (void)showPauseIcon {
    self.pauseIcon.hidden = NO;
    self.pauseIcon.transform = CGAffineTransformMakeScale(1.3, 1.3);
    [UIView animateWithDuration:0.2 animations:^{
        self.pauseIcon.alpha = 1.0;
        self.pauseIcon.transform = CGAffineTransformIdentity;
    }];
}

- (void)hidePauseIcon {
    [UIView animateWithDuration:0.2 animations:^{
        self.pauseIcon.alpha = 0;
    } completion:^(BOOL finished) {
        self.pauseIcon.hidden = YES;
    }];
}

#pragma mark - Cleanup

- (void)cleanup {
    if (self.player) {
        [self.player pause];
    }
    
    if (self.timeObserver && self.player) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    
    if (self.playerItem) {
        @try {
            [self.playerItem removeObserver:self forKeyPath:@"status" context:kStatusContext];
            [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:kBufferContext];
            [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:kBufferEmptyContext];
            [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:kBufferFullContext];
        } @catch (NSException *e) {}
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 不清空 playerLayer.player，因为在 setupPlayerWithURL 中已经设置了新的 player
    // 这样可以避免短暂的黑屏或显示旧画面
    self.player = nil;
    self.playerItem = nil;
}

+ (void)precacheURL:(NSURL *)url {
    if (!url) return;
    // KTVHTTPCache 预下载：请求代理URL触发缓存
    NSURLRequest *request = [NSURLRequest requestWithURL:[KTVHTTPCache proxyURLWithOriginalURL:url]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error && error.code != NSURLErrorCancelled) {
            NSLog(@"[预缓存] 失败: %@", error.localizedDescription);
        } else {
            NSLog(@"[预缓存] 完成: %@ (%.0fKB)", url.lastPathComponent, data.length / 1024.0);
        }
    }];
    [task resume];
    
    // 3秒后如果已下载超过1MB，取消剩余（只预缓存一部分）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (task.state == NSURLSessionTaskStateRunning && task.countOfBytesReceived > 1024 * 1024) {
            [task cancel];
            NSLog(@"[预缓存] 已缓存1MB+，停止: %@", url.lastPathComponent);
        }
    });
}

@end
