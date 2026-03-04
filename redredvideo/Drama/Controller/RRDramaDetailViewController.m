//
//  RRDramaDetailViewController.m
//  redredvideo
//
//  剧集详情页：全屏竖版播放 + 底部选集栏 + 上拉选集面板
//  参考：红果短剧样式
//

#import "RRDramaDetailViewController.h"
#import "RRPlayerView.h"
#import "RRNetworkManager.h"
#import "RRSeekBar.h"
#import <SDWebImage/SDWebImage.h>
#import "RRPlayerMenuView.h"
#import <Photos/Photos.h>
#import "RRScreenCastView.h"
#import "RRScreenCastControlViewController.h"
#import "RRNavigationHelper.h"
#import "RRNetworkManager.h"
#import "RREpisodeSelectCell.h"
#import "RRDramaEpisodeCell.h"

/// 预加载窗口（前后各N个）
static const NSInteger kPreloadWindow = 2;

#pragma mark - RRDramaDetailViewController

@interface RRDramaDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RRDramaEpisodeCellDelegate, RRPlayerMenuViewDelegate, RRScreenCastViewDelegate>

// 播放器集合视图（全屏，每个 cell 是一集）
@property (nonatomic, strong) UICollectionView *collectionView;

// 顶部导航
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *episodeTitleLabel;
@property (nonatomic, strong) UIButton *speedButton;

// 选集面板（底部弹出）
@property (nonatomic, strong) UIView *panelOverlay;
@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) UIImageView *panelCoverImage;
@property (nonatomic, strong) UILabel *panelTitleLabel;
@property (nonatomic, strong) UILabel *panelInfoLabel;
@property (nonatomic, strong) UIScrollView *rangeScrollView;
@property (nonatomic, strong) UICollectionView *episodeCollectionView;
@property (nonatomic, strong) UIButton *favoriteButton;

// 数据
@property (nonatomic, strong) NSDictionary *dramaData;
@property (nonatomic, strong) NSArray *episodes;
@property (nonatomic, assign) NSInteger currentEpisodeIndex;
@property (nonatomic, assign) NSInteger currentRangeIndex;
@property (nonatomic, strong) NSArray<NSArray *> *episodeRanges; // 分组后的分集
@property (nonatomic, strong) NSMutableArray<UIButton *> *rangeButtons;
@property (nonatomic, assign) float currentSpeed;
@property (nonatomic, assign) BOOL isScreenCasting; // 是否正在投屏
@property (nonatomic, strong) NSString *bottomBarText; // 底部栏文本

// 失败页面
@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIButton *retryButton;

@end

static const NSInteger kEpisodesPerRange = 30;

@implementation RRDramaDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    self.currentEpisodeIndex = -1;
    self.currentRangeIndex = 0;
    self.episodes = @[];
    self.rangeButtons = [NSMutableArray array];
    self.currentSpeed = 1.0;
    
    [self setupCollectionView];
    [self setupTopNav];
    [self setupEpisodePanel];
    [self setupErrorView];
    [self setupNetworkMonitoring];
    [self fetchDramaDetail];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    // 从投屏控制页面返回时，恢复播放
    if (self.isScreenCasting) {
        [self resumeVideoAtIndex:self.currentEpisodeIndex];
        NSLog(@"[短剧详情] 从投屏控制页面返回，恢复播放");
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 如果是去投屏控制页面，不停止播放
    // 如果是返回首页等其他页面，停止播放并重置投屏标志
    if (!self.isScreenCasting) {
        [self stopVideoAtIndex:self.currentEpisodeIndex];
    } else {
        // 检查是否是真正退出（返回首页），而不是去投屏控制页面
        // 通过检查 navigationController 的 viewControllers 数组
        if (self.navigationController && 
            ![self.navigationController.viewControllers containsObject:self]) {
            // 正在被 pop 出栈，说明是真正退出
            [self stopVideoAtIndex:self.currentEpisodeIndex];
            self.isScreenCasting = NO;
            NSLog(@"[短剧详情] 退出页面，停止播放并重置投屏标志");
        }
    }
    
    self.navigationController.navigationBarHidden = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
- (BOOL)prefersStatusBarHidden { return NO; }

#pragma mark - Setup

- (void)setupCollectionView {
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, w, h) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    [self.collectionView registerClass:[RRDramaEpisodeCell class] forCellWithReuseIdentifier:@"EpisodeCell"];
    [self.view addSubview:self.collectionView];
}

// 移除手势滑动，改用 UICollectionView 滚动

- (void)setupTopNav {
    CGFloat safeTop = 50;
    
    // 返回按钮
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(8, safeTop, 44, 44);
    UIImage *chevron = [UIImage systemImageNamed:@"chevron.left" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium]];
    [self.backButton setImage:chevron forState:UIControlStateNormal];
    self.backButton.tintColor = [UIColor whiteColor];
    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    // 当前集标题
    self.episodeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, safeTop, 150, 44)];
    self.episodeTitleLabel.text = @"第1集";
    self.episodeTitleLabel.textColor = [UIColor whiteColor];
    self.episodeTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.episodeTitleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.episodeTitleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    self.episodeTitleLabel.layer.shadowOpacity = 0.5;
    self.episodeTitleLabel.layer.shadowRadius = 2;
    [self.view addSubview:self.episodeTitleLabel];
}

- (void)setupEpisodePanel {
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    CGFloat panelH = h * 0.65;
    
    // 遮罩
    self.panelOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.panelOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.panelOverlay.hidden = YES;
    self.panelOverlay.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEpisodePanel)];
    [self.panelOverlay addGestureRecognizer:tap];
    [self.view addSubview:self.panelOverlay];
    
    // 面板
    self.panelView = [[UIView alloc] initWithFrame:CGRectMake(0, h, w, panelH)];
    self.panelView.backgroundColor = [UIColor whiteColor];
    self.panelView.layer.cornerRadius = 16;
    self.panelView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.panelView.clipsToBounds = YES;
    [self.view addSubview:self.panelView];
    
    CGFloat y = 16;
    
    // 顶部拖拽指示条
    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake((w - 40) / 2, 8, 40, 4)];
    handle.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    handle.layer.cornerRadius = 2;
    [self.panelView addSubview:handle];
    y = 24;
    
    // 封面 + 标题行
    self.panelCoverImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, y, 50, 66)];
    self.panelCoverImage.contentMode = UIViewContentModeScaleAspectFill;
    self.panelCoverImage.clipsToBounds = YES;
    self.panelCoverImage.layer.cornerRadius = 6;
    self.panelCoverImage.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.panelView addSubview:self.panelCoverImage];
    
    self.panelTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(76, y + 8, w - 100, 24)];
    self.panelTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.panelTitleLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [self.panelView addSubview:self.panelTitleLabel];
    
    self.panelInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(76, y + 34, w - 100, 18)];
    self.panelInfoLabel.font = [UIFont systemFontOfSize:13];
    self.panelInfoLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self.panelView addSubview:self.panelInfoLabel];
    y += 80;
    
    // 选集标题
    UILabel *selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, y, 60, 30)];
    selectLabel.text = @"选集";
    selectLabel.font = [UIFont boldSystemFontOfSize:16];
    selectLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [self.panelView addSubview:selectLabel];
    y += 36;
    
    // 范围选择滚动条
    self.rangeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, w, 36)];
    self.rangeScrollView.showsHorizontalScrollIndicator = NO;
    self.rangeScrollView.contentInset = UIEdgeInsetsMake(0, 16, 0, 16);
    [self.panelView addSubview:self.rangeScrollView];
    y += 42;
    
    // 分集网格
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 8;
    layout.sectionInset = UIEdgeInsetsMake(0, 16, 20, 16);
    
    CGFloat gridH = panelH - y - 70; // 底部留给收藏按钮
    self.episodeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, y, w, gridH) collectionViewLayout:layout];
    self.episodeCollectionView.backgroundColor = [UIColor whiteColor];
    self.episodeCollectionView.delegate = self;
    self.episodeCollectionView.dataSource = self;
    [self.episodeCollectionView registerClass:[RREpisodeSelectCell class] forCellWithReuseIdentifier:@"EpCell"];
    [self.panelView addSubview:self.episodeCollectionView];
    
    // 收藏按钮
    CGFloat btnW = w * 0.55;
    self.favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.favoriteButton.frame = CGRectMake((w - btnW) / 2, panelH - 60, btnW, 44);
    self.favoriteButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0];
    self.favoriteButton.layer.cornerRadius = 22;
    [self.favoriteButton setTitle:@"☆ 收藏" forState:UIControlStateNormal];
    [self.favoriteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.favoriteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.panelView addSubview:self.favoriteButton];
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
    self.errorLabel.text = @"加载失败";
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
    [self.retryButton addTarget:self action:@selector(retryLoad) forControlEvents:UIControlEventTouchUpInside];
    [self.errorView addSubview:self.retryButton];
}

- (void)setupNetworkMonitoring {
    // 定时检查网络状态（如果当前显示错误页面）
    [self scheduleNetworkCheck];
}

- (void)scheduleNetworkCheck {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        // 如果当前显示错误页面，尝试重新请求
        if (!self.errorView.hidden) {
            NSLog(@"[DramaDetail] 定时检查网络，尝试重新加载");
            [self retryLoad];
        } else if (!self.errorView.hidden) {
            // 继续检查
            [self scheduleNetworkCheck];
        }
    });
}

- (void)retryLoad {
    self.errorView.hidden = YES;
    [self fetchDramaDetail];
}

#pragma mark - API

- (void)fetchDramaDetail {
    NSString *path = [NSString stringWithFormat:@"/api/dramas/%@", self.dramaId];
    
    [[RRNetworkManager shared] GET:path params:nil success:^(NSDictionary *responseDict) {
        NSDictionary *data = responseDict[@"data"];
        if (!data) return;
        
        self.dramaData = data;
        self.episodes = data[@"episodes"] ?: @[];
        
        // 保存底部栏文本
        NSInteger totalEp = [data[@"total_episodes"] integerValue];
        NSInteger freeEp = [data[@"free_episodes"] integerValue];
        NSString *freeText = freeEp >= totalEp ? @"免费观看" : [NSString stringWithFormat:@"前%ld集免费", (long)freeEp];
        self.bottomBarText = [NSString stringWithFormat:@"选集 · 全%ld集 · %@", (long)totalEp, freeText];
        
        // 更新面板
        self.panelTitleLabel.text = data[@"title"] ?: @"";
        self.panelInfoLabel.text = [NSString stringWithFormat:@"已完结 共%ld集", (long)totalEp];
        
        // 封面
        NSString *cover = data[@"cover_url"] ?: @"";
        if (cover.length > 0) {
            NSString *fullCover = [cover hasPrefix:@"http"] ? cover : [NSString stringWithFormat:@"%@%@", [RRNetworkManager shared].baseURL, cover];
            [self.panelCoverImage sd_setImageWithURL:[NSURL URLWithString:fullCover]];
        }
        
        // 构建分集范围
        [self buildEpisodeRanges];
        [self.episodeCollectionView reloadData];
        
        // 重新加载播放器集合视图
        [self.collectionView reloadData];
        
        // 隐藏错误页面
        self.errorView.hidden = YES;
        
        // 自动播放指定集数（默认第一集）
        if (self.episodes.count > 0) {
            NSInteger startIndex = self.startEpisodeIndex;
            // 确保索引有效
            if (startIndex < 0 || startIndex >= self.episodes.count) {
                startIndex = 0;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self playEpisodeAtIndex:startIndex];
                [self preloadAroundIndex:startIndex];
            });
        }
        
    } failure:^(NSError *error) {
        NSLog(@"[DramaDetail] 加载失败: %@", error.localizedDescription);
        self.errorView.hidden = NO;
    }];
}

- (void)buildEpisodeRanges {
    NSMutableArray *ranges = [NSMutableArray array];
    NSInteger total = self.episodes.count;
    
    for (NSInteger i = 0; i < total; i += kEpisodesPerRange) {
        NSInteger end = MIN(i + kEpisodesPerRange, total);
        NSRange range = NSMakeRange(i, end - i);
        [ranges addObject:[self.episodes subarrayWithRange:range]];
    }
    self.episodeRanges = [ranges copy];
    
    // 清除旧按钮
    for (UIButton *btn in self.rangeButtons) [btn removeFromSuperview];
    [self.rangeButtons removeAllObjects];
    
    CGFloat x = 0;
    for (NSInteger i = 0; i < ranges.count; i++) {
        NSInteger start = i * kEpisodesPerRange + 1;
        NSInteger end = MIN((i + 1) * kEpisodesPerRange, total);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *title = [NSString stringWithFormat:@"%ld-%ld", (long)start, (long)end];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        btn.tag = i;
        [btn addTarget:self action:@selector(rangeTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat btnW = [title sizeWithAttributes:@{NSFontAttributeName: btn.titleLabel.font}].width + 24;
        btn.frame = CGRectMake(x, 0, btnW, 32);
        btn.layer.cornerRadius = 16;
        
        if (i == self.currentRangeIndex) {
            btn.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            btn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
            [btn setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateNormal];
        }
        
        [self.rangeScrollView addSubview:btn];
        [self.rangeButtons addObject:btn];
        x += btnW + 10;
    }
    self.rangeScrollView.contentSize = CGSizeMake(x, 32);
    
    // 只有一组时隐藏范围选择
    self.rangeScrollView.hidden = (ranges.count <= 1);
}

#pragma mark - 播放

- (void)playEpisodeAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.episodes.count) return;
    
    // 先停止当前播放的视频
    if (self.currentEpisodeIndex >= 0 && self.currentEpisodeIndex != index) {
        [self stopVideoAtIndex:self.currentEpisodeIndex];
    }
    
    self.currentEpisodeIndex = index;
    
    // 确定在哪个 range
    self.currentRangeIndex = index / kEpisodesPerRange;
    [self updateRangeButtons];
    [self.episodeCollectionView reloadData];
    
    // 滚动到指定集
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] 
                                 atScrollPosition:UICollectionViewScrollPositionCenteredVertically 
                                         animated:NO];
    
    // 更新标题
    NSDictionary *ep = self.episodes[index];
    NSInteger epNum = [ep[@"episode_number"] integerValue];
    self.episodeTitleLabel.text = [NSString stringWithFormat:@"第%ld集", (long)epNum];
    
    // 开始播放
    RRDramaEpisodeCell *cell = (RRDramaEpisodeCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (cell) {
        [cell startPlaying];
        [cell setPlaybackSpeed:self.currentSpeed];
    }
}

- (void)stopVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.episodes.count) return;
    RRDramaEpisodeCell *cell = (RRDramaEpisodeCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    [cell stopPlaying];
}

- (void)pauseVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.episodes.count) return;
    RRDramaEpisodeCell *cell = (RRDramaEpisodeCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    [cell pausePlaying];
}

- (void)resumeVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.episodes.count) return;
    RRDramaEpisodeCell *cell = (RRDramaEpisodeCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    [cell resumePlaying];
}

- (void)preloadAroundIndex:(NSInteger)index {
    // 预加载前后各 kPreloadWindow 个视频
    for (NSInteger i = index - kPreloadWindow; i <= index + kPreloadWindow; i++) {
        if (i < 0 || i >= (NSInteger)self.episodes.count || i == index) continue;
        
        // 强制创建 cell（如果还没创建）并预加载
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        // 检查 cell 是否已经存在
        RRDramaEpisodeCell *cell = (RRDramaEpisodeCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            // cell 已存在，直接预加载
            if (!cell.hasPreloaded) {
                [cell preload];
            }
        } else {
            // cell 还不存在，通过 cellForItemAtIndexPath: 强制创建
            // 注意：这里不能直接调用 cellForItemAtIndexPath:，因为会导致布局问题
            // 改为在 scrollViewDidScroll 中提前触发预加载
        }
    }
}

- (void)releaseDistantPlayers {
    for (RRDramaEpisodeCell *cell in self.collectionView.visibleCells) {
        NSIndexPath *ip = [self.collectionView indexPathForCell:cell];
        if (ip && labs(ip.item - self.currentEpisodeIndex) > kPreloadWindow) {
            [cell stopPlaying];
        }
    }
}

/// 预缓存指定集（提前下载部分数据）- 保留用于兼容
- (void)precacheEpisodeAtIndex:(NSInteger)index {
    // 现在由 preloadAroundIndex 处理
}

- (void)playNextEpisode {
    if (self.currentEpisodeIndex + 1 < (NSInteger)self.episodes.count) {
        // 还有下一集，播放下一集
        [self playEpisodeAtIndex:self.currentEpisodeIndex + 1];
    } else {
        // 已经是最后一集，重新从第一集开始播放
        [self playEpisodeAtIndex:0];
    }
}

- (void)updateRangeButtons {
    for (NSInteger i = 0; i < self.rangeButtons.count; i++) {
        UIButton *btn = self.rangeButtons[i];
        if (i == self.currentRangeIndex) {
            btn.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            btn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
            [btn setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - 面板动画

- (void)showEpisodePanel {
    CGFloat h = self.view.bounds.size.height;
    CGFloat panelH = h * 0.65;
    
    self.panelOverlay.hidden = NO;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.panelOverlay.alpha = 1;
        self.panelView.frame = CGRectMake(0, h - panelH, self.view.bounds.size.width, panelH);
    } completion:nil];
}

- (void)hideEpisodePanel {
    CGFloat h = self.view.bounds.size.height;
    CGFloat panelH = h * 0.65;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.panelOverlay.alpha = 0;
        self.panelView.frame = CGRectMake(0, h, self.view.bounds.size.width, panelH);
    } completion:^(BOOL finished) {
        self.panelOverlay.hidden = YES;
    }];
}

#pragma mark - Actions

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rangeTapped:(UIButton *)sender {
    self.currentRangeIndex = sender.tag;
    [self updateRangeButtons];
    [self.episodeCollectionView reloadData];
    [self.episodeCollectionView setContentOffset:CGPointZero animated:NO];
}

#pragma mark - UICollectionView (播放器)

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.collectionView) {
        return self.episodes.count;
    }
    // 选集面板
    if (self.currentRangeIndex < (NSInteger)self.episodeRanges.count) {
        return self.episodeRanges[self.currentRangeIndex].count;
    }
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView != self.collectionView) return;
    
    RRDramaEpisodeCell *episodeCell = (RRDramaEpisodeCell *)cell;
    
    // 如果是当前播放的 cell，开始播放
    if (indexPath.item == self.currentEpisodeIndex) {
        if (!episodeCell.hasStarted) {
            [episodeCell startPlaying];
            [episodeCell setPlaybackSpeed:self.currentSpeed];
        }
    } else {
        // 如果是相邻的 cell，预加载
        NSInteger distance = labs(indexPath.item - self.currentEpisodeIndex);
        if (distance <= kPreloadWindow && !episodeCell.hasPreloaded && !episodeCell.hasStarted) {
            [episodeCell preload];
        }
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        // 播放器 cell
        RRDramaEpisodeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EpisodeCell" forIndexPath:indexPath];
        cell.delegate = self;
        
        if (indexPath.item < (NSInteger)self.episodes.count) {
            NSDictionary *ep = self.episodes[indexPath.item];
            NSString *baseURL = [RRNetworkManager shared].baseURL;
            [cell configureWithEpisode:ep baseURL:baseURL];
            cell.currentSpeed = self.currentSpeed;
            
            // 配置底部栏
            BOOL showNext = (indexPath.item < (NSInteger)self.episodes.count - 1);
            [cell configureBottomBarWithText:self.bottomBarText ?: @"选集" showNextButton:showNext];
        }
        
        return cell;
    }
    
    // 选集面板 cell
    RREpisodeSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EpCell" forIndexPath:indexPath];
    
    NSInteger globalIndex = self.currentRangeIndex * kEpisodesPerRange + indexPath.item;
    if (globalIndex < (NSInteger)self.episodes.count) {
        NSDictionary *ep = self.episodes[globalIndex];
        NSInteger epNum = [ep[@"episode_number"] integerValue];
        BOOL isPlaying = (globalIndex == self.currentEpisodeIndex);
        BOOL isFree = [ep[@"is_free"] isKindOfClass:[NSNumber class]] ? [ep[@"is_free"] boolValue] : NO;
        [cell configureWithNumber:epNum isPlaying:isPlaying isFree:isFree];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        // 播放器 cell：全屏大小
        return self.collectionView.bounds.size;
    }
    // 选集面板 cell
    CGFloat w = (collectionView.bounds.size.width - 32 - 40) / 6.0; // 6列
    return CGSizeMake(w, 44);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        // 播放器 cell 点击不处理
        return;
    }
    
    // 选集面板点击
    NSInteger globalIndex = self.currentRangeIndex * kEpisodesPerRange + indexPath.item;
    [self playEpisodeAtIndex:globalIndex];
    
    // 0.5秒后关闭面板
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideEpisodePanel];
    });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) return;
    
    CGFloat pageH = scrollView.bounds.size.height;
    if (pageH <= 0) return;
    
    // 计算当前滚动到的位置（可能在两个 cell 之间）
    CGFloat currentOffset = scrollView.contentOffset.y;
    NSInteger currentPage = (NSInteger)(currentOffset / pageH);
    NSInteger nextPage = currentPage + 1;
    
    // 预加载当前页和下一页的视频
    for (NSInteger i = currentPage - 1; i <= nextPage + 1; i++) {
        if (i < 0 || i >= (NSInteger)self.episodes.count) continue;
        
        RRDramaEpisodeCell *cell = (RRDramaEpisodeCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (cell && !cell.hasPreloaded && !cell.hasStarted) {
            [cell preload];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) return;
    
    CGFloat pageH = scrollView.bounds.size.height;
    if (pageH <= 0) return;
    
    NSInteger newIndex = (NSInteger)(scrollView.contentOffset.y / pageH + 0.5);
    newIndex = MAX(0, MIN(newIndex, (NSInteger)self.episodes.count - 1));
    
    if (newIndex != self.currentEpisodeIndex) {
        [self stopVideoAtIndex:self.currentEpisodeIndex];
        self.currentEpisodeIndex = newIndex;
        
        // 更新标题
        NSDictionary *ep = self.episodes[newIndex];
        NSInteger epNum = [ep[@"episode_number"] integerValue];
        self.episodeTitleLabel.text = [NSString stringWithFormat:@"第%ld集", (long)epNum];
        
        // 更新选集面板
        self.currentRangeIndex = newIndex / kEpisodesPerRange;
        [self updateRangeButtons];
        [self.episodeCollectionView reloadData];
        
        // 播放新视频（willDisplayCell 会处理，这里不需要重复调用）
        // 但为了保险起见，检查一下 cell 是否已经开始播放
        RRDramaEpisodeCell *cell = (RRDramaEpisodeCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:newIndex inSection:0]];
        if (cell && !cell.hasStarted) {
            [cell startPlaying];
            [cell setPlaybackSpeed:self.currentSpeed];
        }
        
        [self releaseDistantPlayers];
    }
}

#pragma mark - RRDramaEpisodeCellDelegate

- (void)episodeCellDidLongPress:(RRDramaEpisodeCell *)cell {
    RRPlayerMenuView *menu = [[RRPlayerMenuView alloc] init];
    menu.delegate = self;
    menu.currentSpeed = self.currentSpeed;
    [menu showInView:self.view];
}

- (void)episodeCell:(RRDramaEpisodeCell *)cell didFinishPlaying:(NSDictionary *)episode {
    [self playNextEpisode];
}

- (void)episodeCellDidTapEpisodePanel:(RRDramaEpisodeCell *)cell {
    [self showEpisodePanel];
}

- (void)episodeCellDidTapNextEpisode:(RRDramaEpisodeCell *)cell {
    [self playNextEpisode];
}

#pragma mark - UICollectionView (选集面板)

// 已移动到上面的 UICollectionView (播放器) 和 UICollectionView (选集面板) 部分

// RRPlayerViewDelegate 和 RRSeekBarDelegate 已移到 RRDramaEpisodeCell 中处理

#pragma mark - RRPlayerMenuViewDelegate

- (void)playerMenuDidSelectSpeed:(float)speed {
    self.currentSpeed = speed;
    
    // 更新当前播放的 cell 的速度
    RRDramaEpisodeCell *cell = (RRDramaEpisodeCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentEpisodeIndex inSection:0]];
    if (cell) {
        [cell setPlaybackSpeed:speed];
    }
    
    [self showToast:[NSString stringWithFormat:@"播放速度: %.2gx", speed]];
}

- (void)playerMenuDidTapSaveToAlbum {
    if (self.currentEpisodeIndex < 0 || self.currentEpisodeIndex >= (NSInteger)self.episodes.count) return;
    
    NSDictionary *ep = self.episodes[self.currentEpisodeIndex];
    NSString *videoUrl = ep[@"video_url"] ?: @"";
    if (videoUrl.length == 0) return;
    if (![videoUrl hasPrefix:@"http"]) {
        videoUrl = [NSString stringWithFormat:@"%@%@", [RRNetworkManager shared].baseURL, videoUrl];
    }
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
                [self downloadAndSaveVideoFromURL:videoUrl];
            } else {
                [self showToast:@"请在设置中允许访问相册"];
            }
        });
    }];
}

- (void)playerMenuDidTapScreenCast {
    if (self.currentEpisodeIndex < 0 || self.currentEpisodeIndex >= (NSInteger)self.episodes.count) return;
    
    NSDictionary *ep = self.episodes[self.currentEpisodeIndex];
    NSString *videoUrl = ep[@"video_url"] ?: @"";
    if (videoUrl.length == 0) return;
    if (![videoUrl hasPrefix:@"http"]) {
        videoUrl = [NSString stringWithFormat:@"%@%@", [RRNetworkManager shared].baseURL, videoUrl];
    }
    
    NSString *title = [NSString stringWithFormat:@"%@ 第%@集", self.dramaData[@"title"] ?: @"", ep[@"episode_number"] ?: @""];
    
    RRScreenCastView *castView = [[RRScreenCastView alloc] init];
    castView.delegate = self;
    [castView showInView:self.view videoURL:videoUrl videoTitle:title];
}

#pragma mark - RRScreenCastViewDelegate

- (void)screenCastViewDidConnect:(NSString *)deviceName videoURL:(NSString *)videoURL videoTitle:(NSString *)title {
    // 设置投屏标志
    self.isScreenCasting = YES;
    
    // 不暂停本地播放，投屏和本地播放独立
    
    // 传入剧集列表和当前集数
    NSString *dramaTitle = self.dramaData[@"title"] ?: @"";
    RRScreenCastControlViewController *controlVC = [[RRScreenCastControlViewController alloc] 
                                                     initWithDeviceName:deviceName 
                                                     episodes:self.episodes 
                                                     currentIndex:self.currentEpisodeIndex 
                                                     dramaTitle:dramaTitle];
    
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

- (void)downloadAndSaveVideoFromURL:(NSString *)urlString {
    [self showToast:@"正在保存..."];
    NSURL *videoURL = [NSURL URLWithString:urlString];
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
    [toast sizeToFit];
    CGFloat toastW = toast.bounds.size.width + 40;
    toast.frame = CGRectMake((self.view.bounds.size.width - toastW) / 2, self.view.bounds.size.height * 0.4, toastW, 40);
    toast.alpha = 0;
    [self.view addSubview:toast];
    [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 1.0; } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:1.5 options:0 animations:^{ toast.alpha = 0; } completion:^(BOOL finished) {
            [toast removeFromSuperview];
        }];
    }];
}

@end
