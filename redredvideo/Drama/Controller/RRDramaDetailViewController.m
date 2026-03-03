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

#pragma mark - RRDramaDetailViewController

@interface RRDramaDetailViewController () <RRPlayerViewDelegate, RRSeekBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, RRPlayerMenuViewDelegate, RRScreenCastViewDelegate>

// 播放器（全屏）
@property (nonatomic, strong) RRPlayerView *playerView;
@property (nonatomic, strong) RRSeekBar *seekBar;

// 顶部导航
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *episodeTitleLabel;
@property (nonatomic, strong) UIButton *speedButton;

// 底部选集栏
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UILabel *bottomBarLabel;
@property (nonatomic, strong) UIButton *bottomBarExpandBtn;
@property (nonatomic, strong) UIButton *nextEpisodeBtn;

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
    
    [self setupPlayer];
    [self setupTopNav];
    [self setupBottomBar];
    [self setupEpisodePanel];
    [self fetchDramaDetail];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.playerView stop];
    self.navigationController.navigationBarHidden = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
- (BOOL)prefersStatusBarHidden { return NO; }

#pragma mark - Setup

- (void)setupPlayer {
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    
    self.playerView = [[RRPlayerView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.playerView.delegate = self;
    [self.view addSubview:self.playerView];
    
    // 进度条在底部栏上方
    self.seekBar = [[RRSeekBar alloc] initWithFrame:CGRectZero];
    self.seekBar.delegate = self;
    [self.view addSubview:self.seekBar];
}

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

- (void)setupBottomBar {
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    CGFloat barH = 50;
    CGFloat safeBottom = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom;
    
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, h - barH - safeBottom, w, barH + safeBottom)];
    self.bottomBar.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    
    // 选集信息
    self.bottomBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, w - 100, barH)];
    self.bottomBarLabel.text = @"选集 · 加载中...";
    self.bottomBarLabel.textColor = [UIColor whiteColor];
    self.bottomBarLabel.font = [UIFont systemFontOfSize:14];
    [self.bottomBar addSubview:self.bottomBarLabel];
    
    // 展开按钮
    self.bottomBarExpandBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.bottomBarExpandBtn.frame = CGRectMake(w - 90, 0, 44, barH);
    UIImage *expandImg = [UIImage systemImageNamed:@"chevron.up"];
    [self.bottomBarExpandBtn setImage:expandImg forState:UIControlStateNormal];
    self.bottomBarExpandBtn.tintColor = [UIColor whiteColor];
    [self.bottomBarExpandBtn addTarget:self action:@selector(showEpisodePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.bottomBarExpandBtn];
    
    // 下一集按钮
    self.nextEpisodeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nextEpisodeBtn.frame = CGRectMake(w - 50, 0, 44, barH);
    UIImage *nextImg = [UIImage systemImageNamed:@"forward.end.fill"];
    [self.nextEpisodeBtn setImage:nextImg forState:UIControlStateNormal];
    self.nextEpisodeBtn.tintColor = [UIColor whiteColor];
    [self.nextEpisodeBtn addTarget:self action:@selector(playNextEpisode) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.nextEpisodeBtn];
    
    // 点击整个底部栏也展开
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEpisodePanel)];
    [self.bottomBar addGestureRecognizer:tap];
    
    [self.view addSubview:self.bottomBar];
    
    // seekBar 在底部栏上方
    CGFloat seekY = self.bottomBar.frame.origin.y - 16;
    self.seekBar.frame = CGRectMake(10, seekY, w - 20, 16);
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

#pragma mark - API

- (void)fetchDramaDetail {
    NSString *path = [NSString stringWithFormat:@"/api/dramas/%@", self.dramaId];
    
    [[RRNetworkManager shared] GET:path params:nil success:^(NSDictionary *responseDict) {
        NSDictionary *data = responseDict[@"data"];
        if (!data) return;
        
        self.dramaData = data;
        self.episodes = data[@"episodes"] ?: @[];
        
        // 更新底部栏
        NSInteger totalEp = [data[@"total_episodes"] integerValue];
        NSInteger freeEp = [data[@"free_episodes"] integerValue];
        NSString *freeText = freeEp >= totalEp ? @"免费观看" : [NSString stringWithFormat:@"前%ld集免费", (long)freeEp];
        self.bottomBarLabel.text = [NSString stringWithFormat:@"选集 · 全%ld集 · %@", (long)totalEp, freeText];
        
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
        
        // 自动播放第一集
        if (self.episodes.count > 0) {
            [self playEpisodeAtIndex:0];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"[DramaDetail] 加载失败: %@", error.localizedDescription);
        self.bottomBarLabel.text = @"加载失败，点击重试";
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
    
    self.currentEpisodeIndex = index;
    
    // 确定在哪个 range
    self.currentRangeIndex = index / kEpisodesPerRange;
    [self updateRangeButtons];
    [self.episodeCollectionView reloadData];
    
    // 获取视频URL
    NSDictionary *ep = self.episodes[index];
    NSString *videoUrl = ep[@"video_url"] ?: @"";
    NSInteger epNum = [ep[@"episode_number"] integerValue];
    
    self.episodeTitleLabel.text = [NSString stringWithFormat:@"第%ld集", (long)epNum];
    
    if (videoUrl.length == 0) return;
    
    if (![videoUrl hasPrefix:@"http"]) {
        videoUrl = [NSString stringWithFormat:@"%@%@", [RRNetworkManager shared].baseURL, videoUrl];
    }
    
    NSURL *url = [NSURL URLWithString:videoUrl];
    if (url) {
        [self.playerView loadVideoWithURL:url];
    }
    
    // 预缓存下一集
    [self precacheEpisodeAtIndex:index + 1];
}

/// 预缓存指定集（提前下载部分数据）
- (void)precacheEpisodeAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.episodes.count) return;
    
    NSDictionary *ep = self.episodes[index];
    NSString *videoUrl = ep[@"video_url"] ?: @"";
    if (videoUrl.length == 0) return;
    
    if (![videoUrl hasPrefix:@"http"]) {
        videoUrl = [NSString stringWithFormat:@"%@%@", [RRNetworkManager shared].baseURL, videoUrl];
    }
    
    NSURL *url = [NSURL URLWithString:videoUrl];
    if (url) {
        [RRPlayerView precacheURL:url];
    }
}

- (void)playNextEpisode {
    if (self.currentEpisodeIndex + 1 < (NSInteger)self.episodes.count) {
        [self playEpisodeAtIndex:self.currentEpisodeIndex + 1];
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

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.currentRangeIndex < (NSInteger)self.episodeRanges.count) {
        return self.episodeRanges[self.currentRangeIndex].count;
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RREpisodeSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EpCell" forIndexPath:indexPath];
    
    NSInteger globalIndex = self.currentRangeIndex * kEpisodesPerRange + indexPath.item;
    if (globalIndex < (NSInteger)self.episodes.count) {
        NSDictionary *ep = self.episodes[globalIndex];
        NSInteger epNum = [ep[@"episode_number"] integerValue];
        BOOL isPlaying = (globalIndex == self.currentEpisodeIndex);
        BOOL isFree = [ep[@"is_free"] boolValue];
        [cell configureWithNumber:epNum isPlaying:isPlaying isFree:isFree];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = (collectionView.bounds.size.width - 32 - 40) / 6.0; // 6列
    return CGSizeMake(w, 44);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger globalIndex = self.currentRangeIndex * kEpisodesPerRange + indexPath.item;
    [self playEpisodeAtIndex:globalIndex];
    
    // 0.5秒后关闭面板
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideEpisodePanel];
    });
}

#pragma mark - RRPlayerViewDelegate

- (void)playerViewDidTap:(id)playerView {}

- (void)playerViewDidLongPress:(id)playerView {
    RRPlayerMenuView *menu = [[RRPlayerMenuView alloc] init];
    menu.delegate = self;
    menu.currentSpeed = self.currentSpeed;
    [menu showInView:self.view];
}

- (void)playerViewDidFinishPlaying:(id)playerView {
    [self playNextEpisode];
}

- (void)playerView:(id)playerView playProgress:(float)progress currentTime:(NSTimeInterval)current totalTime:(NSTimeInterval)total {
    self.seekBar.progress = progress;
}

- (void)playerView:(id)playerView bufferProgress:(float)progress {
    self.seekBar.bufferProgress = progress;
}

- (void)playerView:(id)playerView stateChanged:(RRPlayerState)state {}

#pragma mark - RRSeekBarDelegate

- (void)seekBarDidBeginDragging:(id)seekBar { [self.playerView pause]; }
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
