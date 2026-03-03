//
//  RRPlayerViewController.m
//  redredvideo
//
//  沉浸式视频播放控制器（增强版）
//
//  设计思路：
//  1. 预加载策略：当前视频播放时，预加载前后各1个视频
//  2. 内存管理：只保持3个PlayerView活跃（当前+前后各1），其余释放
//  3. 网络处理：监控网络状态，断网时暂停并提示，恢复后自动重试
//  4. 分页加载：快到列表末尾时自动请求加载更多
//  5. 播放器复用：Cell复用时正确停止/启动播放
//

#import "RRPlayerViewController.h"
#import "RRVideoModel.h"
#import "RRPlayerView.h"
#import "RRVideoOverlayView.h"
#import "RRPlayerMenuView.h"
#import <Photos/Photos.h>
#import "RRScreenCastView.h"
#import "RRScreenCastControlViewController.h"
#import "RRNavigationHelper.h"
@class RRPlayerCell;

/// 预加载窗口大小（当前位置前后各N个）
static const NSInteger kPreloadWindow = 1;
/// 触发加载更多的阈值（距离末尾N个时触发）
static const NSInteger kLoadMoreThreshold = 3;
/// 每页加载数量
static const NSInteger kPageSize = 10;

#pragma mark - RRPlayerCell

@interface RRPlayerCell : UICollectionViewCell <RRPlayerViewDelegate, RRVideoOverlayViewDelegate, RRPlayerMenuViewDelegate, RRScreenCastViewDelegate>

@property (nonatomic, strong) RRPlayerView *playerView;
@property (nonatomic, strong) RRVideoOverlayView *overlayView;
@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic, strong) UIProgressView *bufferBar;
@property (nonatomic, strong) RRVideoModel *videoModel;
@property (nonatomic, assign) BOOL hasPreloaded;
@property (nonatomic, assign) float currentSpeed;

- (void)configureWithModel:(RRVideoModel *)model;
- (void)startPlaying;
- (void)stopPlaying;
- (void)preload;

@end

@implementation RRPlayerCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.currentSpeed = 1.0;
        
        // 播放器
        self.playerView = [[RRPlayerView alloc] initWithFrame:self.contentView.bounds];
        self.playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.playerView.delegate = self;
        [self.contentView addSubview:self.playerView];
        
        // 覆盖层
        self.overlayView = [[RRVideoOverlayView alloc] initWithFrame:self.contentView.bounds];
        self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.overlayView.delegate = self;
        [self.contentView addSubview:self.overlayView];
        
        // 缓冲进度条（灰色底）
        self.bufferBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.bufferBar.progressTintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        self.bufferBar.trackTintColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        self.bufferBar.progress = 0;
        [self.contentView addSubview:self.bufferBar];
        
        // 播放进度条（红色）
        self.progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressBar.progressTintColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0];
        self.progressBar.trackTintColor = [UIColor clearColor];
        self.progressBar.progress = 0;
        [self.contentView addSubview:self.progressBar];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.contentView.bounds.size.width;
    CGFloat h = self.contentView.bounds.size.height;
    CGFloat barY = h - 50; // TabBar上方
    self.bufferBar.frame = CGRectMake(0, barY, w, 2);
    self.progressBar.frame = CGRectMake(0, barY, w, 2);
}

- (void)configureWithModel:(RRVideoModel *)model {
    self.videoModel = model;
    self.hasPreloaded = NO;
    [self.overlayView configureWithModel:model];
    self.progressBar.progress = 0;
    self.bufferBar.progress = 0;
}

- (void)startPlaying {
    if (self.videoModel.videoUrl.length == 0) return;
    NSURL *url = [NSURL URLWithString:self.videoModel.videoUrl];
    [self.playerView loadVideoWithURL:url];
}

- (void)preload {
    if (self.hasPreloaded || self.videoModel.videoUrl.length == 0) return;
    self.hasPreloaded = YES;
    NSURL *url = [NSURL URLWithString:self.videoModel.videoUrl];
    [self.playerView preloadVideoWithURL:url];
}

- (void)stopPlaying {
    [self.playerView stop];
    self.hasPreloaded = NO;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.playerView stop];
    self.progressBar.progress = 0;
    self.bufferBar.progress = 0;
    self.hasPreloaded = NO;
}

#pragma mark - RRPlayerViewDelegate

- (void)playerViewDidTap:(id)playerView {
    // 暂停/播放由 PlayerView 处理
}

- (void)playerViewDidLongPress:(id)playerView {
    // 长按弹出菜单
    UIView *rootView = self.window.rootViewController.view ?: self.window;
    if (!rootView) return;
    
    RRPlayerMenuView *menu = [[RRPlayerMenuView alloc] init];
    menu.delegate = self;
    menu.currentSpeed = self.currentSpeed;
    [menu showInView:rootView];
}

- (void)playerViewDidFinishPlaying:(id)playerView {
    // 循环播放由 PlayerView 处理
}

- (void)playerView:(id)playerView playProgress:(float)progress currentTime:(NSTimeInterval)current totalTime:(NSTimeInterval)total {
    self.progressBar.progress = progress;
}

- (void)playerView:(id)playerView bufferProgress:(float)progress {
    self.bufferBar.progress = progress;
}

- (void)playerView:(id)playerView stateChanged:(RRPlayerState)state {
    if (state == RRPlayerStateError) {
        self.overlayView.hidden = YES;
    } else if (state == RRPlayerStatePlaying) {
        self.overlayView.hidden = NO;
    }
}

#pragma mark - RRVideoOverlayViewDelegate

- (void)overlayViewDidTapLike:(id)overlayView {
    NSLog(@"点赞: %@", self.videoModel.title);
}

- (void)overlayViewDidTapComment:(id)overlayView {
    NSLog(@"评论: %@", self.videoModel.title);
}

- (void)overlayViewDidTapShare:(id)overlayView {
    NSLog(@"分享: %@", self.videoModel.title);
}

#pragma mark - RRPlayerMenuViewDelegate

- (void)playerMenuDidSelectSpeed:(float)speed {
    self.currentSpeed = speed;
    [self.playerView setRate:speed];
    
    // Toast提示
    NSString *speedText = [NSString stringWithFormat:@"播放速度: %.2gx", speed];
    [self showToast:speedText];
}

- (void)playerMenuDidTapSaveToAlbum {
    if (!self.videoModel.videoUrl.length) return;
    
    // 请求相册权限
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
                [self downloadAndSaveVideo];
            } else {
                [self showToast:@"请在设置中允许访问相册"];
            }
        });
    }];
}

- (void)playerMenuDidTapScreenCast {
    if (!self.videoModel.videoUrl.length) return;
    
    UIView *rootView = self.window.rootViewController.view ?: self.contentView;
    RRScreenCastView *castView = [[RRScreenCastView alloc] init];
    castView.delegate = self;
    [castView showInView:rootView videoURL:self.videoModel.videoUrl videoTitle:self.videoModel.title];
}

#pragma mark - RRScreenCastViewDelegate

- (void)screenCastViewDidConnect:(NSString *)deviceName videoURL:(NSString *)videoURL videoTitle:(NSString *)title {
    RRScreenCastControlViewController *controlVC = [[RRScreenCastControlViewController alloc] initWithDeviceName:deviceName videoURL:videoURL videoTitle:title];
    
    UINavigationController *nav = [RRNavigationHelper currentNavigationController];
    if (nav) {
        [nav pushViewController:controlVC animated:YES];
    } else {
        // 如果没有 navigationController，用 present
        UINavigationController *newNav = [[UINavigationController alloc] initWithRootViewController:controlVC];
        newNav.modalPresentationStyle = UIModalPresentationFullScreen;
        UIViewController *currentVC = [RRNavigationHelper currentViewController];
        [currentVC presentViewController:newNav animated:YES completion:nil];
    }
}

- (void)playerMenuDidDismiss {
    // 菜单关闭
}

#pragma mark - Save Video Helper

- (void)downloadAndSaveVideo {
    [self showToast:@"正在保存..."];
    
    NSURL *videoURL = [NSURL URLWithString:self.videoModel.videoUrl];
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:videoURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !location) {
                [self showToast:@"保存失败"];
                return;
            }
            
            // 移动到临时目录（带.mp4后缀）
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"redred_%@.mp4", @((NSInteger)[[NSDate date] timeIntervalSince1970])]];
            NSURL *tempURL = [NSURL fileURLWithPath:tempPath];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:tempURL error:nil];
            
            // 保存到相册
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:tempURL];
            } completionHandler:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        [self showToast:@"已保存到相册 ✓"];
                    } else {
                        [self showToast:@"保存失败"];
                    }
                    // 清理临时文件
                    [[NSFileManager defaultManager] removeItemAtURL:tempURL error:nil];
                });
            }];
        });
    }];
    [task resume];
}

#pragma mark - Toast

- (void)showToast:(NSString *)text {
    UILabel *toast = [[UILabel alloc] init];
    toast.text = text;
    toast.textColor = [UIColor whiteColor];
    toast.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    toast.textAlignment = NSTextAlignmentCenter;
    toast.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    toast.layer.cornerRadius = 20;
    toast.clipsToBounds = YES;
    
    UIView *rootView = self.window.rootViewController.view ?: self.contentView;
    [toast sizeToFit];
    CGFloat toastW = toast.bounds.size.width + 40;
    CGFloat toastH = 40;
    toast.frame = CGRectMake((rootView.bounds.size.width - toastW) / 2,
                             rootView.bounds.size.height * 0.4,
                             toastW, toastH);
    toast.alpha = 0;
    [rootView addSubview:toast];
    
    [UIView animateWithDuration:0.3 animations:^{
        toast.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:1.5 options:0 animations:^{
            toast.alpha = 0;
        } completion:^(BOOL finished) {
            [toast removeFromSuperview];
        }];
    }];
}

@end

#pragma mark - RRPlayerViewController

@interface RRPlayerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RRPlayerViewDelegate, RRPlayerMenuViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<RRVideoModel *> *videoList; // 可变数组，支持追加
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UILabel *networkStatusLabel; // 网络状态提示

@end

@implementation RRPlayerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.currentIndex = self.startIndex;
    self.currentPage = 1;
    self.isLoadingMore = NO;
    
    // 初始化可变视频列表
    self.videoList = [NSMutableArray arrayWithArray:self.videos ?: @[]];
    
    [self setupCollectionView];
    [self setupCloseButton];
    [self setupNetworkStatusLabel];
    [self setupNetworkMonitor];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 滚动到起始位置
    if (self.startIndex > 0 && self.startIndex < self.videoList.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.startIndex inSection:0]
                                   atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                           animated:NO];
    }
    
    // 延迟播放（等布局完成）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playVideoAtIndex:self.currentIndex];
        [self preloadVideosAroundIndex:self.currentIndex];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self stopAllVideos];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // 内存警告：停止非当前的所有播放器
    [self releaseDistantPlayers];
}

#pragma mark - Setup

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    // 预取
    self.collectionView.prefetchingEnabled = YES;
    
    [self.collectionView registerClass:[RRPlayerCell class] forCellWithReuseIdentifier:@"PlayerCell"];
    [self.view addSubview:self.collectionView];
}

- (void)setupCloseButton {
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIFontWeightBold];
    [self.closeButton setImage:[UIImage systemImageNamed:@"xmark" withConfiguration:config] forState:UIControlStateNormal];
    self.closeButton.tintColor = [UIColor whiteColor];
    self.closeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.closeButton.layer.cornerRadius = 18;
    [self.closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.closeButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.closeButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8],
        [self.closeButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:16],
        [self.closeButton.widthAnchor constraintEqualToConstant:36],
        [self.closeButton.heightAnchor constraintEqualToConstant:36],
    ]];
}

- (void)setupNetworkStatusLabel {
    self.networkStatusLabel = [[UILabel alloc] init];
    self.networkStatusLabel.text = @"⚠️ 网络连接已断开";
    self.networkStatusLabel.textColor = [UIColor whiteColor];
    self.networkStatusLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.networkStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.networkStatusLabel.backgroundColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:0.9];
    self.networkStatusLabel.layer.cornerRadius = 16;
    self.networkStatusLabel.clipsToBounds = YES;
    self.networkStatusLabel.hidden = YES;
    
    self.networkStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.networkStatusLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.networkStatusLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8],
        [self.networkStatusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.networkStatusLabel.widthAnchor constraintEqualToConstant:200],
        [self.networkStatusLabel.heightAnchor constraintEqualToConstant:32],
    ]];
}

- (void)setupNetworkMonitor {
    // 监听网络状态变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkDidChange:)
                                                 name:@"RRNetworkStatusChanged"
                                               object:nil];
    
    // App 回到前台时恢复播放
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    // App 进入后台时暂停
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

#pragma mark - Video Control

- (void)playVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.videoList.count) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    RRPlayerCell *cell = (RRPlayerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        [cell startPlaying];
    }
}

- (void)stopVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.videoList.count) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    RRPlayerCell *cell = (RRPlayerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        [cell stopPlaying];
    }
}

- (void)stopAllVideos {
    for (RRPlayerCell *cell in self.collectionView.visibleCells) {
        [cell stopPlaying];
    }
}

/// 预加载当前位置前后的视频
- (void)preloadVideosAroundIndex:(NSInteger)index {
    for (NSInteger i = index - kPreloadWindow; i <= index + kPreloadWindow; i++) {
        if (i < 0 || i >= self.videoList.count || i == index) continue;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        RRPlayerCell *cell = (RRPlayerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell && !cell.hasPreloaded) {
            [cell preload];
        }
    }
}

/// 释放远离当前位置的播放器（内存管理）
- (void)releaseDistantPlayers {
    for (RRPlayerCell *cell in self.collectionView.visibleCells) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (indexPath && labs(indexPath.item - self.currentIndex) > kPreloadWindow) {
            [cell stopPlaying];
        }
    }
}

#pragma mark - Load More

- (void)checkAndLoadMoreIfNeeded {
    NSInteger remaining = self.videoList.count - self.currentIndex;
    
    if (remaining <= kLoadMoreThreshold && !self.isLoadingMore) {
        [self loadMoreVideos];
    }
}

- (void)loadMoreVideos {
    self.isLoadingMore = YES;
    self.currentPage++;
    
    NSLog(@"加载更多视频，第%ld页", (long)self.currentPage);
    
    // 模拟网络请求（实际应调用API）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 模拟返回数据：循环使用现有视频
        NSArray *mockVideos = [RRVideoModel mockVideos];
        NSMutableArray *newVideos = [NSMutableArray array];
        
        for (NSInteger i = 0; i < kPageSize && i < mockVideos.count; i++) {
            RRVideoModel *original = mockVideos[i % mockVideos.count];
            // 创建新的model，修改ID避免重复
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"video_id"] = [NSString stringWithFormat:@"v%03ld", (long)(self.videoList.count + i + 1)];
            dict[@"title"] = [NSString stringWithFormat:@"%@ (第%ld页)", original.title, (long)self.currentPage];
            dict[@"video_url"] = original.videoUrl;
            dict[@"author"] = original.author;
            dict[@"desc"] = original.desc;
            dict[@"like_count"] = @(arc4random_uniform(20000));
            dict[@"comment_count"] = @(arc4random_uniform(5000));
            dict[@"share_count"] = @(arc4random_uniform(2000));
            [newVideos addObject:[RRVideoModel modelWithDict:dict]];
        }
        
        if (newVideos.count > 0) {
            NSInteger oldCount = self.videoList.count;
            [self.videoList addObjectsFromArray:newVideos];
            
            // 批量插入新Cell
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (NSInteger i = oldCount; i < self.videoList.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
            
            NSLog(@"已加载%ld个新视频，总计%ld个", (long)newVideos.count, (long)self.videoList.count);
        }
        
        self.isLoadingMore = NO;
    });
}

#pragma mark - Network

- (void)networkDidChange:(NSNotification *)notification {
    BOOL isReachable = [notification.userInfo[@"reachable"] boolValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!isReachable) {
            self.networkStatusLabel.hidden = NO;
            // 暂停当前播放
            RRPlayerCell *cell = (RRPlayerCell *)[self.collectionView cellForItemAtIndexPath:
                                                  [NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
            [cell.playerView pause];
        } else {
            // 网络恢复，隐藏提示并恢复播放
            [UIView animateWithDuration:0.3 animations:^{
                self.networkStatusLabel.hidden = YES;
            }];
            [self playVideoAtIndex:self.currentIndex];
        }
    });
}

- (void)appDidBecomeActive {
    [self playVideoAtIndex:self.currentIndex];
}

- (void)appDidEnterBackground {
    [self stopVideoAtIndex:self.currentIndex];
}

#pragma mark - Actions

- (void)closeTapped {
    [self stopAllVideos];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RRPlayerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayerCell" forIndexPath:indexPath];
    [cell configureWithModel:self.videoList[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageHeight = scrollView.bounds.size.height;
    if (pageHeight <= 0) return;
    
    NSInteger newIndex = (NSInteger)(scrollView.contentOffset.y / pageHeight + 0.5);
    newIndex = MAX(0, MIN(newIndex, (NSInteger)self.videoList.count - 1));
    
    if (newIndex != self.currentIndex) {
        // 停止旧视频
        [self stopVideoAtIndex:self.currentIndex];
        
        // 更新索引
        self.currentIndex = newIndex;
        
        // 播放新视频
        [self playVideoAtIndex:newIndex];
        
        // 预加载前后视频
        [self preloadVideosAroundIndex:newIndex];
        
        // 释放远处的播放器
        [self releaseDistantPlayers];
        
        // 检查是否需要加载更多
        [self checkAndLoadMoreIfNeeded];
        
        NSLog(@"切换到视频 %ld/%ld: %@", (long)newIndex + 1, (long)self.videoList.count, self.videoList[newIndex].title);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
