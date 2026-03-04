//
//  RRHomeViewController.m
//  redredvideo
//
//  首页 - 沉浸式视频流（类抖音，通过API加载数据）
//

#import "RRHomeViewController.h"
#import "RRVideoModel.h"
#import "RRDramaModel.h"
#import "RRPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "RRVideoOverlayView.h"
#import "RRSeekBar.h"
#import "RRNetworkManager.h"
#import <MJRefresh/MJRefresh.h>
#import "RRPlayerMenuView.h"
#import <Photos/Photos.h>
#import "RRScreenCastView.h"
#import "RRScreenCastControlViewController.h"
#import "RRNavigationHelper.h"
#import "RRDramaDetailViewController.h"
#import "RRDramaDetailViewController.h"
#import <Masonry/Masonry.h>
@class RRHomeFeedCell;

/// 预加载窗口（前后各N个）
static const NSInteger kPreloadWindow = 2;
/// 触发加载更多的阈值
static const NSInteger kLoadMoreThreshold = 3;
/// 每页加载数量
static const NSInteger kPageSize = 10;

#pragma mark - RRHomeFeedCell

@protocol RRHomeFeedCellDelegate <NSObject>
- (void)homeFeedCellDidTapViewFullDrama:(RRHomeFeedCell *)cell;
- (void)homeFeedCellDidFinishPlaying:(RRHomeFeedCell *)cell;
@end

@interface RRHomeFeedCell : UICollectionViewCell <RRPlayerViewDelegate, RRVideoOverlayViewDelegate, RRSeekBarDelegate, RRPlayerMenuViewDelegate, RRScreenCastViewDelegate>

@property (nonatomic, weak) id<RRHomeFeedCellDelegate> delegate;
@property (nonatomic, strong) RRPlayerView *playerView;
@property (nonatomic, strong) RRVideoOverlayView *overlayView;
@property (nonatomic, strong) RRSeekBar *seekBar;
@property (nonatomic, strong) UIButton *viewFullDramaButton; // 观看完整短剧按钮
@property (nonatomic, strong) RRVideoModel *videoModel;
@property (nonatomic, assign) BOOL hasPreloaded;
@property (nonatomic, assign) BOOL hasStarted; // 是否已经开始播放过
@property (nonatomic, assign) float currentSpeed;

- (void)configureWithModel:(RRVideoModel *)model;
- (void)startPlaying;
- (void)stopPlaying;
- (void)pausePlaying;
- (void)resumePlaying;
- (void)preload;

@end

@implementation RRHomeFeedCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.currentSpeed = 1.0;
        
        self.playerView = [[RRPlayerView alloc] initWithFrame:self.contentView.bounds];
        self.playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.playerView.delegate = self;
        [self.contentView addSubview:self.playerView];
        
        self.overlayView = [[RRVideoOverlayView alloc] initWithFrame:self.contentView.bounds];
        self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.overlayView.delegate = self;
        [self.contentView addSubview:self.overlayView];
        
        // 可拖动进度条
        self.seekBar = [[RRSeekBar alloc] initWithFrame:CGRectZero];
        self.seekBar.delegate = self;
        [self.contentView addSubview:self.seekBar];
        
        // 观看完整短剧按钮
        self.viewFullDramaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.viewFullDramaButton.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        [self.viewFullDramaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.viewFullDramaButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.viewFullDramaButton addTarget:self action:@selector(viewFullDramaButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.viewFullDramaButton.hidden = YES; // 默认隐藏
        [self.contentView addSubview:self.viewFullDramaButton];
        
        // 添加播放图标
        UIImageView *playIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"play.fill"]];
        playIcon.tintColor = [UIColor whiteColor];
        playIcon.tag = 999;
        [self.viewFullDramaButton addSubview:playIcon];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 观看完整短剧按钮：左右间距0，底部间距0，高度50，无圆角
    [self.viewFullDramaButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(50);
    }];
    
    // 进度条：左右间距20，底部间距0（和按钮在同一水平位置），高度5，在按钮上层
    [self.seekBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(5);
    }];
    
    // 确保进度条在按钮上层
    [self.contentView bringSubviewToFront:self.seekBar];
    
    // 播放图标布局
    UIImageView *playIcon = [self.viewFullDramaButton viewWithTag:999];
    if (playIcon) {
        [playIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.viewFullDramaButton).offset(15);
            make.centerY.equalTo(self.viewFullDramaButton);
            make.width.height.mas_equalTo(16);
        }];
    }
}

- (void)configureWithModel:(RRVideoModel *)model {
    self.videoModel = model;
    self.hasPreloaded = NO;
    self.hasStarted = NO;
    [self.overlayView configureWithModel:model];
    self.seekBar.progress = 0;
    self.seekBar.bufferProgress = 0;
    
    // 如果有剧集信息且总集数大于1，显示"观看完整短剧"按钮
    if (model.dramaId > 0 && model.totalEpisodes > 1) {
        NSString *buttonTitle = [NSString stringWithFormat:@"  观看完整短剧·全%ld集", (long)model.totalEpisodes];
        [self.viewFullDramaButton setTitle:buttonTitle forState:UIControlStateNormal];
        self.viewFullDramaButton.hidden = NO;
    } else {
        self.viewFullDramaButton.hidden = YES;
    }
}

- (void)startPlaying {
    if (self.videoModel.videoUrl.length == 0) return;
    NSURL *url = [NSURL URLWithString:self.videoModel.videoUrl];
    [self.playerView loadVideoWithURL:url];
    self.hasStarted = YES;
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
    self.hasStarted = NO;
}

- (void)pausePlaying {
    [self.playerView pause];
}

- (void)resumePlaying {
    [self.playerView play];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.playerView stop];
    self.seekBar.progress = 0;
    self.seekBar.bufferProgress = 0;
    self.hasPreloaded = NO;
    self.hasStarted = NO;
}

- (void)viewFullDramaButtonTapped {
    if ([self.delegate respondsToSelector:@selector(homeFeedCellDidTapViewFullDrama:)]) {
        [self.delegate homeFeedCellDidTapViewFullDrama:self];
    }
}

#pragma mark - RRPlayerViewDelegate

- (void)playerViewDidTap:(id)playerView {}

- (void)playerViewDidLongPress:(id)playerView {
    UIView *rootView = self.window.rootViewController.view ?: self.window;
    if (!rootView) return;
    
    RRPlayerMenuView *menu = [[RRPlayerMenuView alloc] init];
    menu.delegate = self;
    menu.currentSpeed = self.currentSpeed;
    [menu showInView:rootView];
}

- (void)playerView:(id)playerView playProgress:(float)progress currentTime:(NSTimeInterval)current totalTime:(NSTimeInterval)total {
    self.seekBar.progress = progress;
}

- (void)playerView:(id)playerView bufferProgress:(float)progress {
    self.seekBar.bufferProgress = progress;
}

- (void)playerView:(id)playerView stateChanged:(RRPlayerState)state {
    if (state == RRPlayerStateError) {
        self.overlayView.hidden = YES;
    } else if (state == RRPlayerStatePlaying) {
        self.overlayView.hidden = NO;
    }
}

- (void)playerViewDidFinishPlaying:(id)playerView {
    // 视频播放完成，通知 delegate
    if ([self.delegate respondsToSelector:@selector(homeFeedCellDidFinishPlaying:)]) {
        [self.delegate homeFeedCellDidFinishPlaying:self];
    }
}

- (void)playerView:(id)playerView isLoading:(BOOL)loading {
    self.seekBar.isLoading = loading;
}

#pragma mark - RRVideoOverlayViewDelegate

- (void)overlayViewDidTapLike:(id)overlayView {}
- (void)overlayViewDidTapComment:(id)overlayView {}
- (void)overlayViewDidTapShare:(id)overlayView {}

#pragma mark - RRSeekBarDelegate

- (void)seekBarDidBeginDragging:(id)seekBar {
    [self.playerView pause];
}

- (void)seekBar:(id)seekBar didSeekToProgress:(float)progress {}

- (void)seekBar:(id)seekBar didEndSeekAtProgress:(float)progress {
    NSTimeInterval total = self.playerView.totalTime;
    if (total > 0) {
        CMTime targetTime = CMTimeMakeWithSeconds(total * progress, NSEC_PER_SEC);
        [self.playerView seekToTime:targetTime];
    }
    [self.playerView play];
}

#pragma mark - RRPlayerMenuViewDelegate

- (void)playerMenuDidSelectSpeed:(float)speed {
    self.currentSpeed = speed;
    [self.playerView setRate:speed];
    [self showToast:[NSString stringWithFormat:@"播放速度: %.2gx", speed]];
}

- (void)playerMenuDidTapSaveToAlbum {
    if (!self.videoModel.videoUrl.length) return;
    
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

- (void)playerMenuDidDismiss {}

- (void)downloadAndSaveVideo {
    [self showToast:@"正在保存..."];
    NSURL *videoURL = [NSURL URLWithString:self.videoModel.videoUrl];
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:videoURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !location) { [self showToast:@"保存失败"]; return; }
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"redred_%@.mp4", @((NSInteger)[[NSDate date] timeIntervalSince1970])]];
            NSURL *tempURL = [NSURL fileURLWithPath:tempPath];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:tempURL error:nil];
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:tempURL];
            } completionHandler:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showToast:success ? @"已保存到相册 ✓" : @"保存失败"];
                    [[NSFileManager defaultManager] removeItemAtURL:tempURL error:nil];
                });
            }];
        });
    }];
    [task resume];
}

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
    toast.frame = CGRectMake((rootView.bounds.size.width - toastW) / 2, rootView.bounds.size.height * 0.4, toastW, 40);
    toast.alpha = 0;
    [rootView addSubview:toast];
    [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 1.0; } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:1.5 options:0 animations:^{ toast.alpha = 0; } completion:^(BOOL finished) {
            [toast removeFromSuperview];
        }];
    }];
}

@end

#pragma mark - RRHomeViewController

@interface RRHomeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RRPlayerViewDelegate, RRPlayerMenuViewDelegate, RRHomeFeedCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<RRVideoModel *> *videoList;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) uint32_t feedSeed;       // 随机种子，保证翻页不重复
@property (nonatomic, strong) UILabel *networkBanner;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UIView *errorView;       // 失败页面
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIButton *retryButton;

@end

@implementation RRHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.currentIndex = 0;
    self.currentPage = 1;
    self.isLoadingMore = NO;
    self.hasMore = YES;
    self.feedSeed = arc4random();  // 每次启动/刷新生成新种子
    
    self.navigationController.navigationBarHidden = YES;
    
    self.videoList = [NSMutableArray array];
    
    [self setupCollectionView];
    [self setupNetworkBanner];
    [self setupLoadingIndicator];
    [self setupErrorView];
    [self setupNotifications];
    [self setupNetworkMonitoring];
    
    // 从 API 加载首页数据
    [self loadFeedFromAPI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    if (self.videoList.count > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 检查当前 cell 是否已经开始播放过
            RRHomeFeedCell *cell = (RRHomeFeedCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
            if (cell && cell.hasStarted) {
                // 如果已经开始播放过，只需要恢复播放
                [self resumeVideoAtIndex:self.currentIndex];
            } else {
                // 如果还没有开始播放，开始播放
                [self playVideoAtIndex:self.currentIndex];
            }
            [self preloadAroundIndex:self.currentIndex];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 暂停播放而不是停止，保留播放进度
    [self pauseVideoAtIndex:self.currentIndex];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self releaseDistantPlayers];
}

#pragma mark - Setup

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    CGFloat tabBarH = 83;
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - tabBarH);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    [self.collectionView registerClass:[RRHomeFeedCell class] forCellWithReuseIdentifier:@"FeedCell"];
    [self.view addSubview:self.collectionView];
    
    // 下拉刷新
    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshFeed];
    }];
}

- (void)setupNetworkBanner {
    self.networkBanner = [[UILabel alloc] init];
    self.networkBanner.text = @"  ⚠️ 网络连接已断开";
    self.networkBanner.textColor = [UIColor whiteColor];
    self.networkBanner.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.networkBanner.backgroundColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:0.9];
    self.networkBanner.layer.cornerRadius = 16;
    self.networkBanner.clipsToBounds = YES;
    self.networkBanner.textAlignment = NSTextAlignmentCenter;
    self.networkBanner.hidden = YES;
    
    self.networkBanner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.networkBanner];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.networkBanner.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8],
        [self.networkBanner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.networkBanner.widthAnchor constraintEqualToConstant:200],
        [self.networkBanner.heightAnchor constraintEqualToConstant:32],
    ]];
}

- (void)setupLoadingIndicator {
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.color = [UIColor whiteColor];
    self.loadingIndicator.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2 - 40);
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];
}

- (void)setupErrorView {
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    
    self.errorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.errorView.backgroundColor = [UIColor blackColor];
    self.errorView.hidden = YES;
    [self.view addSubview:self.errorView];
    
    // 错误图标
    UIImageView *errorIcon = [[UIImageView alloc] init];
    UIImage *icon = [UIImage systemImageNamed:@"wifi.slash" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:60 weight:UIFontWeightLight]];
    errorIcon.image = icon;
    errorIcon.tintColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    errorIcon.frame = CGRectMake((w - 80) / 2, h / 2 - 120, 80, 80);
    [self.errorView addSubview:errorIcon];
    
    // 错误文字
    self.errorLabel = [[UILabel alloc] init];
    self.errorLabel.text = @"网络连接失败";
    self.errorLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    self.errorLabel.font = [UIFont systemFontOfSize:16];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.frame = CGRectMake(20, h / 2 - 20, w - 40, 24);
    [self.errorView addSubview:self.errorLabel];
    
    // 重试按钮
    self.retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.retryButton setTitle:@"点击重试" forState:UIControlStateNormal];
    [self.retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.retryButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.retryButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0];
    self.retryButton.layer.cornerRadius = 22;
    self.retryButton.frame = CGRectMake((w - 120) / 2, h / 2 + 20, 120, 44);
    [self.retryButton addTarget:self action:@selector(retryLoadFeed) forControlEvents:UIControlEventTouchUpInside];
    [self.errorView addSubview:self.retryButton];
}

- (void)setupNetworkMonitoring {
    // 使用 SCNetworkReachability 监听网络状态变化（兼容性更好）
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __weak typeof(self) weakSelf = self;
    
    // 每5秒检查一次网络状态（如果当前显示错误页面）
    [self scheduleNetworkCheck];
}

- (void)scheduleNetworkCheck {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        // 如果当前显示错误页面，尝试重新请求
        if (!self.errorView.hidden && self.videoList.count == 0) {
            NSLog(@"[Feed] 定时检查网络，尝试重新加载");
            [self retryLoadFeed];
        } else if (!self.errorView.hidden) {
            // 继续检查
            [self scheduleNetworkCheck];
        }
    });
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)retryLoadFeed {
    self.errorView.hidden = YES;
    self.currentPage = 1;
    self.feedSeed = arc4random();
    [self.videoList removeAllObjects];
    [self.collectionView reloadData];
    [self loadFeedFromAPI];
}

#pragma mark - API 数据加载

- (void)loadFeedFromAPI {
    [self.loadingIndicator startAnimating];
    
    NSDictionary *params = @{
        @"page": @(self.currentPage),
        @"pageSize": @(kPageSize),
        @"seed": @(self.feedSeed),
    };
    
    __weak typeof(self) weakSelf = self;
    [[RRNetworkManager shared] GET:@"/api/dramas/feed/videos" params:params success:^(NSDictionary *resp) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        [self.loadingIndicator stopAnimating];
        
        NSInteger code = [resp[@"code"] integerValue];
        if (code != 0) {
            NSLog(@"[Feed] API error code: %ld", (long)code);
            // API 返回错误码，显示错误页面
            if (self.videoList.count == 0) {
                self.errorView.hidden = NO;
            }
            [self.loadingIndicator stopAnimating];
            return;
        }
        
        NSDictionary *data = resp[@"data"];
        NSArray *list = data[@"list"];
        self.hasMore = [data[@"hasMore"] boolValue];
        
        NSString *baseURL = [RRNetworkManager shared].baseURL;
        NSMutableArray *newVideos = [NSMutableArray array];
        for (NSDictionary *dict in list) {
            RRVideoModel *model = [RRVideoModel modelWithFeedDict:dict baseURL:baseURL];
            [newVideos addObject:model];
        }
        
        if (newVideos.count > 0) {
            NSInteger oldCount = self.videoList.count;
            [self.videoList addObjectsFromArray:newVideos];
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (NSInteger i = oldCount; i < self.videoList.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
            
            // 首次加载，自动播放第一个
            if (oldCount == 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self playVideoAtIndex:0];
                    [self preloadAroundIndex:0];
                });
            }
        }
        
        self.isLoadingMore = NO;
        self.networkBanner.hidden = YES;
        self.errorView.hidden = YES;
        
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        [self.loadingIndicator stopAnimating];
        self.isLoadingMore = NO;
        
        NSLog(@"[Feed] Network error: %@", error.localizedDescription);
        
        // 首次加载失败，显示错误页面
        if (self.videoList.count == 0) {
            self.errorView.hidden = NO;
        } else {
            // 加载更多失败，显示网络提示
            [self showNetworkError];
        }
    }];
}

- (void)showNetworkError {
    self.networkBanner.hidden = NO;
    // 3秒后自动隐藏
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.networkBanner.hidden = YES;
    });
}

#pragma mark - 下拉刷新

- (void)refreshFeed {
    // 停止当前播放
    [self stopVideoAtIndex:self.currentIndex];
    
    // 重置状态
    self.currentPage = 1;
    self.currentIndex = 0;
    self.hasMore = YES;
    self.feedSeed = arc4random(); // 新种子 = 新的随机序列
    [self.videoList removeAllObjects];
    [self.collectionView reloadData];
    
    // 重新加载
    NSDictionary *params = @{
        @"page": @(1),
        @"pageSize": @(kPageSize),
        @"seed": @(self.feedSeed),
    };
    
    __weak typeof(self) weakSelf = self;
    [[RRNetworkManager shared] GET:@"/api/dramas/feed/videos" params:params success:^(NSDictionary *resp) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        [self.collectionView.mj_header endRefreshing];
        
        NSDictionary *data = resp[@"data"];
        NSArray *list = data[@"list"];
        self.hasMore = [data[@"hasMore"] boolValue];
        
        NSString *baseURL = [RRNetworkManager shared].baseURL;
        for (NSDictionary *dict in list) {
            [self.videoList addObject:[RRVideoModel modelWithFeedDict:dict baseURL:baseURL]];
        }
        
        [self.collectionView reloadData];
        
        if (self.videoList.count > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self playVideoAtIndex:0];
                [self preloadAroundIndex:0];
            });
        }
        
        self.networkBanner.hidden = YES;
        
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.collectionView.mj_header endRefreshing];
        
        if (self.videoList.count == 0) {
            // 刷新失败且没有数据，显示错误页面
            self.errorView.hidden = NO;
        } else {
            // 刷新失败但有旧数据，显示网络提示
            [self showNetworkError];
        }
    }];
}

#pragma mark - Video Control

- (void)playVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.videoList.count) return;
    RRHomeFeedCell *cell = (RRHomeFeedCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    [cell startPlaying];
}

- (void)stopVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.videoList.count) return;
    RRHomeFeedCell *cell = (RRHomeFeedCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    [cell stopPlaying];
}

- (void)pauseVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.videoList.count) return;
    RRHomeFeedCell *cell = (RRHomeFeedCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    [cell pausePlaying];
}

- (void)resumeVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.videoList.count) return;
    RRHomeFeedCell *cell = (RRHomeFeedCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    [cell resumePlaying];
}

- (void)preloadAroundIndex:(NSInteger)index {
    for (NSInteger i = index - kPreloadWindow; i <= index + kPreloadWindow; i++) {
        if (i < 0 || i >= self.videoList.count || i == index) continue;
        RRHomeFeedCell *cell = (RRHomeFeedCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (cell && !cell.hasPreloaded) {
            [cell preload];
        }
    }
}

- (void)releaseDistantPlayers {
    for (RRHomeFeedCell *cell in self.collectionView.visibleCells) {
        NSIndexPath *ip = [self.collectionView indexPathForCell:cell];
        if (ip && labs(ip.item - self.currentIndex) > kPreloadWindow) {
            [cell stopPlaying];
        }
    }
}

#pragma mark - Load More

- (void)checkLoadMore {
    NSInteger remaining = self.videoList.count - self.currentIndex;
    if (remaining <= kLoadMoreThreshold && !self.isLoadingMore && self.hasMore) {
        [self loadMoreVideos];
    }
}

- (void)loadMoreVideos {
    self.isLoadingMore = YES;
    self.currentPage++;
    [self loadFeedFromAPI];
}

#pragma mark - App Lifecycle

- (void)appDidBecomeActive {
    if (self.tabBarController.selectedViewController == self.navigationController) {
        [self playVideoAtIndex:self.currentIndex];
    }
}

- (void)appDidEnterBackground {
    [self stopVideoAtIndex:self.currentIndex];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoList.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    RRHomeFeedCell *feedCell = (RRHomeFeedCell *)cell;
    
    // 如果是当前播放的 cell，开始播放
    if (indexPath.item == self.currentIndex) {
        if (!feedCell.hasStarted) {
            [feedCell startPlaying];
        }
    } else {
        // 如果是相邻的 cell，预加载
        NSInteger distance = labs(indexPath.item - self.currentIndex);
        if (distance <= kPreloadWindow && !feedCell.hasPreloaded && !feedCell.hasStarted) {
            [feedCell preload];
        }
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RRHomeFeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell configureWithModel:self.videoList[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageH = scrollView.bounds.size.height;
    if (pageH <= 0) return;
    
    // 计算当前滚动到的位置（可能在两个 cell 之间）
    CGFloat currentOffset = scrollView.contentOffset.y;
    NSInteger currentPage = (NSInteger)(currentOffset / pageH);
    NSInteger nextPage = currentPage + 1;
    
    // 预加载当前页和下一页的视频
    for (NSInteger i = currentPage - 1; i <= nextPage + 1; i++) {
        if (i < 0 || i >= self.videoList.count) continue;
        
        RRHomeFeedCell *cell = (RRHomeFeedCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (cell && !cell.hasPreloaded && !cell.hasStarted) {
            [cell preload];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageH = scrollView.bounds.size.height;
    if (pageH <= 0) return;
    
    NSInteger newIndex = (NSInteger)(scrollView.contentOffset.y / pageH + 0.5);
    newIndex = MAX(0, MIN(newIndex, (NSInteger)self.videoList.count - 1));
    
    if (newIndex != self.currentIndex) {
        [self stopVideoAtIndex:self.currentIndex];
        self.currentIndex = newIndex;
        
        // 播放新视频（willDisplayCell 会处理，这里不需要重复调用）
        // 但为了保险起见，检查一下 cell 是否已经开始播放
        RRHomeFeedCell *cell = (RRHomeFeedCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:newIndex inSection:0]];
        if (cell && !cell.hasStarted) {
            [cell startPlaying];
        }
        
        [self releaseDistantPlayers];
        [self checkLoadMore];
    }
}

#pragma mark - RRHomeFeedCellDelegate

- (void)homeFeedCellDidTapViewFullDrama:(RRHomeFeedCell *)cell {
    RRVideoModel *model = cell.videoModel;
    if (model.dramaId <= 0) return;
    
    NSLog(@"[首页] 点击观看完整短剧，dramaId: %ld", (long)model.dramaId);
    
    // 跳转到短剧详情页面
    RRDramaDetailViewController *detailVC = [[RRDramaDetailViewController alloc] init];
    detailVC.dramaId = [NSString stringWithFormat:@"%ld", (long)model.dramaId];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)homeFeedCellDidFinishPlaying:(RRHomeFeedCell *)cell {
    RRVideoModel *model = cell.videoModel;
    if (model.dramaId <= 0) return;
    
    // 检查是否有多集
    if (model.totalEpisodes > 1) {
        NSLog(@"[首页] 视频播放完成，自动跳转到剧集详情页，dramaId: %ld", (long)model.dramaId);
        
        // 停止当前播放的视频
        [cell stopPlaying];
        
        // 跳转到短剧详情页面，从第2集开始播放
        RRDramaDetailViewController *detailVC = [[RRDramaDetailViewController alloc] init];
        detailVC.dramaId = [NSString stringWithFormat:@"%ld", (long)model.dramaId];
        detailVC.startEpisodeIndex = 1; // 从第2集开始（索引从0开始）
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
