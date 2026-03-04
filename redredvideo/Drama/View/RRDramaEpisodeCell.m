//
//  RRDramaEpisodeCell.m
//  redredvideo
//
//  剧集播放 Cell - 每个 cell 包含一个播放器
//

#import "RRDramaEpisodeCell.h"
#import "RRPlayerView.h"
#import "RRSeekBar.h"
#import <AVFoundation/AVFoundation.h>

@interface RRDramaEpisodeCell () <RRPlayerViewDelegate, RRSeekBarDelegate>

@property (nonatomic, strong) RRPlayerView *playerView;
@property (nonatomic, strong) RRSeekBar *seekBar;
@property (nonatomic, strong) NSString *videoURL;

// 底部选集栏
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UILabel *bottomBarLabel;
@property (nonatomic, strong) UIButton *bottomBarExpandBtn;
@property (nonatomic, strong) UIButton *nextEpisodeBtn;

@end

@implementation RRDramaEpisodeCell

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
        
        // 底部选集栏
        [self setupBottomBar];
        
        // 进度条
        self.seekBar = [[RRSeekBar alloc] initWithFrame:CGRectZero];
        self.seekBar.delegate = self;
        [self.contentView addSubview:self.seekBar];
    }
    return self;
}

- (void)setupBottomBar {
    CGFloat barH = 50;
    CGFloat safeBottom = 34; // 假设的安全区域底部高度
    
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomBar.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    [self.contentView addSubview:self.bottomBar];
    
    // 选集信息
    self.bottomBarLabel = [[UILabel alloc] init];
    self.bottomBarLabel.text = @"选集";
    self.bottomBarLabel.textColor = [UIColor whiteColor];
    self.bottomBarLabel.font = [UIFont systemFontOfSize:14];
    [self.bottomBar addSubview:self.bottomBarLabel];
    
    // 展开按钮
    self.bottomBarExpandBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *expandImg = [UIImage systemImageNamed:@"chevron.up"];
    [self.bottomBarExpandBtn setImage:expandImg forState:UIControlStateNormal];
    self.bottomBarExpandBtn.tintColor = [UIColor whiteColor];
    [self.bottomBarExpandBtn addTarget:self action:@selector(expandButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.bottomBarExpandBtn];
    
    // 下一集按钮
    self.nextEpisodeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *nextImg = [UIImage systemImageNamed:@"forward.end.fill"];
    [self.nextEpisodeBtn setImage:nextImg forState:UIControlStateNormal];
    self.nextEpisodeBtn.tintColor = [UIColor whiteColor];
    [self.nextEpisodeBtn addTarget:self action:@selector(nextEpisodeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.nextEpisodeBtn];
    
    // 点击整个底部栏也展开
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandButtonTapped)];
    [self.bottomBar addGestureRecognizer:tap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = self.contentView.bounds.size.width;
    CGFloat h = self.contentView.bounds.size.height;
    CGFloat barH = 50;
    CGFloat safeBottom = 34; // 假设的安全区域底部高度
    
    // 底部栏
    self.bottomBar.frame = CGRectMake(0, h - barH - safeBottom, w, barH + safeBottom);
    
    // 底部栏内部布局
    self.bottomBarLabel.frame = CGRectMake(16, 0, w - 100, barH);
    self.bottomBarExpandBtn.frame = CGRectMake(w - 90, 0, 44, barH);
    self.nextEpisodeBtn.frame = CGRectMake(w - 50, 0, 44, barH);
    
    // 进度条：在底部栏上方
    CGFloat seekY = self.bottomBar.frame.origin.y - 10;
    self.seekBar.frame = CGRectMake(20, seekY, w - 40, 5);
    
    // 播放器：从顶部到进度条
    self.playerView.frame = CGRectMake(0, 0, w, seekY);
}

- (void)configureWithEpisode:(NSDictionary *)episode baseURL:(NSString *)baseURL {
    self.episode = episode;
    self.hasPreloaded = NO;
    self.hasStarted = NO;
    self.seekBar.progress = 0;
    self.seekBar.bufferProgress = 0;
    
    // 构建完整视频URL
    NSString *videoUrl = episode[@"video_url"] ?: @"";
    if (videoUrl.length > 0) {
        if (![videoUrl hasPrefix:@"http"]) {
            videoUrl = [NSString stringWithFormat:@"%@%@", baseURL, videoUrl];
        }
        self.videoURL = videoUrl;
    } else {
        self.videoURL = nil;
    }
}

- (void)configureBottomBarWithText:(NSString *)text showNextButton:(BOOL)showNext {
    self.bottomBarLabel.text = text;
    self.nextEpisodeBtn.hidden = !showNext;
}

- (void)expandButtonTapped {
    if ([self.delegate respondsToSelector:@selector(episodeCellDidTapEpisodePanel:)]) {
        [self.delegate episodeCellDidTapEpisodePanel:self];
    }
}

- (void)nextEpisodeButtonTapped {
    if ([self.delegate respondsToSelector:@selector(episodeCellDidTapNextEpisode:)]) {
        [self.delegate episodeCellDidTapNextEpisode:self];
    }
}

- (void)startPlaying {
    if (self.videoURL.length == 0) return;
    NSURL *url = [NSURL URLWithString:self.videoURL];
    [self.playerView loadVideoWithURL:url];
    self.hasStarted = YES;
}

- (void)preload {
    if (self.hasPreloaded || self.videoURL.length == 0) return;
    self.hasPreloaded = YES;
    NSURL *url = [NSURL URLWithString:self.videoURL];
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

- (void)setPlaybackSpeed:(float)speed {
    self.currentSpeed = speed;
    [self.playerView setRate:speed];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.playerView stop];
    self.seekBar.progress = 0;
    self.seekBar.bufferProgress = 0;
    self.hasPreloaded = NO;
    self.hasStarted = NO;
    self.videoURL = nil;
}

#pragma mark - RRPlayerViewDelegate

- (void)playerViewDidTap:(id)playerView {
    // 点击播放器区域不做处理，避免干扰底部栏和面板
}

- (void)playerViewDidLongPress:(id)playerView {
    if ([self.delegate respondsToSelector:@selector(episodeCellDidLongPress:)]) {
        [self.delegate episodeCellDidLongPress:self];
    }
}

- (void)playerViewDidFinishPlaying:(id)playerView {
    if ([self.delegate respondsToSelector:@selector(episodeCell:didFinishPlaying:)]) {
        [self.delegate episodeCell:self didFinishPlaying:self.episode];
    }
}

- (void)playerView:(id)playerView playProgress:(float)progress currentTime:(NSTimeInterval)current totalTime:(NSTimeInterval)total {
    self.seekBar.progress = progress;
}

- (void)playerView:(id)playerView bufferProgress:(float)progress {
    self.seekBar.bufferProgress = progress;
}

- (void)playerView:(id)playerView stateChanged:(RRPlayerState)state {
    // 可以在这里处理播放状态变化
}

#pragma mark - RRSeekBarDelegate

- (void)seekBarDidBeginDragging:(id)seekBar {
    [self.playerView pause];
}

- (void)seekBar:(id)seekBar didSeekToProgress:(float)progress {
    // 拖动中
}

- (void)seekBar:(id)seekBar didEndSeekAtProgress:(float)progress {
    NSTimeInterval total = self.playerView.totalTime;
    if (total > 0) {
        CMTime targetTime = CMTimeMakeWithSeconds(total * progress, NSEC_PER_SEC);
        [self.playerView seekToTime:targetTime];
    }
    [self.playerView play];
}

@end
