//
//  RRScreenCastControlViewController.m
//  redredvideo
//
//  投屏控制页面：完整的播放控制功能
//

#import "RRScreenCastControlViewController.h"
#import "RRScreenCastManager.h"
#import "RRScreenCastView.h"
#import "RREpisodePanelView.h"
#import "RRScreenCastFloatingButton.h"
#import <Masonry/Masonry.h>

static RRScreenCastControlViewController *_currentInstance = nil;

@interface RRScreenCastControlViewController () <RRScreenCastManagerDelegate, RRScreenCastViewDelegate, RREpisodePanelViewDelegate>

@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *videoURL;
@property (nonatomic, copy) NSString *videoTitle;

// 剧集列表（用于自动连播）
@property (nonatomic, strong) NSArray<NSDictionary *> *episodes;
@property (nonatomic, assign) NSInteger currentEpisodeIndex;
@property (nonatomic, copy) NSString *dramaTitle;

// UI 组件
@property (nonatomic, strong) UILabel *deviceLabel;
@property (nonatomic, strong) UIView *statusDot;
@property (nonatomic, strong) UIButton *switchDeviceButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) UIButton *backwardButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *speedButton;
@property (nonatomic, strong) UISwitch *autoPlaySwitch;
@property (nonatomic, strong) UIButton *disconnectButton;
@property (nonatomic, strong) UIButton *episodeButton;

// 播放状态
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) CGFloat currentSpeed;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval totalTime;

@end

@implementation RRScreenCastControlViewController

+ (instancetype)currentInstance {
    return _currentInstance;
}

- (instancetype)initWithDeviceName:(NSString *)deviceName videoURL:(NSString *)videoURL videoTitle:(NSString *)title {
    self = [super init];
    if (self) {
        _deviceName = deviceName;
        _videoURL = videoURL;
        _videoTitle = title;
        _currentSpeed = 1.0;
        _isPlaying = YES;
        _currentEpisodeIndex = -1; // 单个视频，没有剧集列表
    }
    return self;
}

- (instancetype)initWithDeviceName:(NSString *)deviceName episodes:(NSArray<NSDictionary *> *)episodes currentIndex:(NSInteger)currentIndex dramaTitle:(NSString *)dramaTitle {
    self = [super init];
    if (self) {
        _deviceName = deviceName;
        _episodes = episodes;
        _currentEpisodeIndex = currentIndex;
        _dramaTitle = dramaTitle;
        _currentSpeed = 1.0;
        _isPlaying = YES;
        
        // 从当前集数获取视频信息
        if (currentIndex >= 0 && currentIndex < episodes.count) {
            NSDictionary *ep = episodes[currentIndex];
            NSString *videoUrl = ep[@"video_url"] ?: @"";
            
            // 如果是相对路径，拼接 baseURL
            if (videoUrl.length > 0 && ![videoUrl hasPrefix:@"http"]) {
                videoUrl = [NSString stringWithFormat:@"http://192.168.4.157:3000%@", videoUrl];
            }
            
            _videoURL = videoUrl;
            NSString *episodeNum = ep[@"episode_number"] ?: @"";
            _videoTitle = [NSString stringWithFormat:@"%@ 第%@集", dramaTitle ?: @"", episodeNum];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 保存当前实例
    _currentInstance = self;
    
    // 深色背景
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.title = @"投屏控制";
    
    // 确保导航栏显示
    self.navigationController.navigationBarHidden = NO;
    
    [self setupUI];
    
    // 设置 delegate 接收播放状态回调
    [RRScreenCastManager shared].delegate = self;
    
    // 推送视频
    if (self.videoURL.length > 0) {
        [[RRScreenCastManager shared] playVideoWithURL:self.videoURL title:self.videoTitle];
    }
}

- (void)dealloc {
    // 清除实例引用
    if (_currentInstance == self) {
        _currentInstance = nil;
    }
    NSLog(@"[投屏控制] dealloc");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 确保导航栏显示
    self.navigationController.navigationBarHidden = NO;
    
    // 进入投屏控制页面时，隐藏悬浮按钮
    [[RRScreenCastFloatingButton sharedButton] hide];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 离开投屏控制页面时，显示悬浮按钮
    // 但需要检查是否还在投屏状态
    if ([RRScreenCastManager shared].isConnected) {
        [[RRScreenCastFloatingButton sharedButton] show];
    }
}

- (void)setupUI {
    CGFloat padding = 20;
    
    // 设备信息卡片
    UIView *deviceCard = [[UIView alloc] init];
    deviceCard.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    deviceCard.layer.cornerRadius = 12;
    [self.view addSubview:deviceCard];
    
    [deviceCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        make.left.equalTo(self.view).offset(padding);
        make.right.equalTo(self.view).offset(-padding);
        make.height.mas_equalTo(60);
    }];
    
    // 绿点
    self.statusDot = [[UIView alloc] init];
    self.statusDot.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.3 alpha:1.0];
    self.statusDot.layer.cornerRadius = 4;
    [deviceCard addSubview:self.statusDot];
    
    [self.statusDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(deviceCard).offset(16);
        make.centerY.equalTo(deviceCard);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
    
    // 设备名
    self.deviceLabel = [[UILabel alloc] init];
    self.deviceLabel.text = self.deviceName;
    self.deviceLabel.textColor = [UIColor whiteColor];
    self.deviceLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [deviceCard addSubview:self.deviceLabel];
    
    [self.deviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.statusDot.mas_right).offset(8);
        make.centerY.equalTo(deviceCard);
        make.right.lessThanOrEqualTo(deviceCard).offset(-100);
    }];
    
    // 切换设备按钮
    self.switchDeviceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.switchDeviceButton setTitle:@"切换设备" forState:UIControlStateNormal];
    self.switchDeviceButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.switchDeviceButton addTarget:self action:@selector(switchDevice) forControlEvents:UIControlEventTouchUpInside];
    [deviceCard addSubview:self.switchDeviceButton];
    
    [self.switchDeviceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(deviceCard).offset(-16);
        make.centerY.equalTo(deviceCard);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(30);
    }];
    
    // 视频标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.videoTitle ?: @"正在投屏";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    [self.view addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(deviceCard.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(padding);
        make.right.equalTo(self.view).offset(-padding);
    }];
    
    // 简介
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.text = @"正在电视上播放";
    self.descLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    self.descLabel.font = [UIFont systemFontOfSize:14];
    self.descLabel.numberOfLines = 2;
    [self.view addSubview:self.descLabel];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(padding);
        make.right.equalTo(self.view).offset(-padding);
    }];
    
    // 选集按钮（只在有剧集列表时显示）
    if (self.episodes && self.episodes.count > 0) {
        self.episodeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        NSString *episodeText = [NSString stringWithFormat:@"选集 (%ld/%lu)", (long)(self.currentEpisodeIndex + 1), (unsigned long)self.episodes.count];
        [self.episodeButton setTitle:episodeText forState:UIControlStateNormal];
        self.episodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        self.episodeButton.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
        self.episodeButton.tintColor = [UIColor whiteColor];
        self.episodeButton.layer.cornerRadius = 6;
        self.episodeButton.contentEdgeInsets = UIEdgeInsetsMake(6, 12, 6, 12);
        [self.episodeButton addTarget:self action:@selector(showEpisodeList) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.episodeButton];
        
        [self.episodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.descLabel.mas_bottom).offset(15);
            make.left.equalTo(self.view).offset(padding);
            make.height.mas_equalTo(32);
        }];
    }
    
    // 进度条的约束需要根据是否有选集按钮来调整
    UIView *progressTopView = self.episodeButton ?: self.descLabel;
    CGFloat progressTopOffset = self.episodeButton ? 20 : 30;
    
    // 进度条
    self.progressSlider = [[UISlider alloc] init];
    self.progressSlider.minimumValue = 0;
    self.progressSlider.maximumValue = 1.0;
    self.progressSlider.value = 0;
    self.progressSlider.minimumTrackTintColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    self.progressSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    
    // 自定义滑块：小圆点
    CGFloat thumbSize = 12;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(thumbSize, thumbSize), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, thumbSize, thumbSize));
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.progressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.progressSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
    [self.progressSlider addTarget:self action:@selector(progressChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.progressSlider];
    
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progressTopView.mas_bottom).offset(progressTopOffset);
        make.left.equalTo(self.view).offset(padding);
        make.right.equalTo(self.view).offset(-padding);
        make.height.mas_equalTo(30);
    }];
    
    // 时间标签
    self.currentTimeLabel = [[UILabel alloc] init];
    self.currentTimeLabel.text = @"00:00";
    self.currentTimeLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    self.currentTimeLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.currentTimeLabel];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressSlider.mas_bottom).offset(5);
        make.left.equalTo(self.view).offset(padding);
    }];
    
    self.totalTimeLabel = [[UILabel alloc] init];
    self.totalTimeLabel.text = @"00:00";
    self.totalTimeLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:12];
    self.totalTimeLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.totalTimeLabel];
    
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressSlider.mas_bottom).offset(5);
        make.right.equalTo(self.view).offset(-padding);
    }];
    
    // 播放控制按钮容器
    UIView *controlsContainer = [[UIView alloc] init];
    [self.view addSubview:controlsContainer];
    
    [controlsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.currentTimeLabel.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    // 快退
    self.backwardButton = [self createControlButton:@"gobackward.15"];
    [self.backwardButton addTarget:self action:@selector(backward) forControlEvents:UIControlEventTouchUpInside];
    [controlsContainer addSubview:self.backwardButton];
    
    [self.backwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(controlsContainer);
        make.centerY.equalTo(controlsContainer);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    // 播放/暂停
    self.playPauseButton = [self createControlButton:@"pause.fill"];
    [self.playPauseButton addTarget:self action:@selector(togglePlayPause) forControlEvents:UIControlEventTouchUpInside];
    [controlsContainer addSubview:self.playPauseButton];
    
    [self.playPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backwardButton.mas_right).offset(30);
        make.centerY.equalTo(controlsContainer);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    // 快进
    self.forwardButton = [self createControlButton:@"goforward.15"];
    [self.forwardButton addTarget:self action:@selector(forward) forControlEvents:UIControlEventTouchUpInside];
    [controlsContainer addSubview:self.forwardButton];
    
    [self.forwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playPauseButton.mas_right).offset(30);
        make.right.equalTo(controlsContainer);
        make.centerY.equalTo(controlsContainer);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    // 倍速按钮
    self.speedButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.speedButton setTitle:@"倍速 1.0x" forState:UIControlStateNormal];
    self.speedButton.titleLabel.font = [UIFont systemFontOfSize:15];
    self.speedButton.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    self.speedButton.tintColor = [UIColor whiteColor];
    self.speedButton.layer.cornerRadius = 8;
    [self.speedButton addTarget:self action:@selector(changeSpeed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.speedButton];
    
    [self.speedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlsContainer.mas_bottom).offset(30);
        make.left.equalTo(self.view).offset(padding);
        make.right.equalTo(self.view.mas_centerX).offset(-5);
        make.height.mas_equalTo(44);
    }];
    
    // 自动连播容器
    UIView *autoPlayContainer = [[UIView alloc] init];
    autoPlayContainer.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    autoPlayContainer.layer.cornerRadius = 8;
    [self.view addSubview:autoPlayContainer];
    
    [autoPlayContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlsContainer.mas_bottom).offset(30);
        make.left.equalTo(self.view.mas_centerX).offset(5);
        make.right.equalTo(self.view).offset(-padding);
        make.height.mas_equalTo(44);
    }];
    
    UILabel *autoPlayLabel = [[UILabel alloc] init];
    autoPlayLabel.text = @"自动连播";
    autoPlayLabel.textColor = [UIColor whiteColor];
    autoPlayLabel.font = [UIFont systemFontOfSize:15];
    [autoPlayContainer addSubview:autoPlayLabel];
    
    [autoPlayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(autoPlayContainer).offset(15);
        make.centerY.equalTo(autoPlayContainer);
    }];
    
    self.autoPlaySwitch = [[UISwitch alloc] init];
    self.autoPlaySwitch.on = YES; // 默认开启
    [autoPlayContainer addSubview:self.autoPlaySwitch];
    
    [self.autoPlaySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(autoPlayContainer).offset(-15);
        make.centerY.equalTo(autoPlayContainer);
    }];
    
    // 结束投屏按钮
    self.disconnectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.disconnectButton setTitle:@"结束投屏" forState:UIControlStateNormal];
    self.disconnectButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.disconnectButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:0.2];
    self.disconnectButton.tintColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0];
    self.disconnectButton.layer.cornerRadius = 8;
    [self.disconnectButton addTarget:self action:@selector(disconnect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.disconnectButton];
    
    [self.disconnectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.speedButton.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(padding);
        make.right.equalTo(self.view).offset(-padding);
        make.height.mas_equalTo(44);
    }];
}

- (UIButton *)createControlButton:(NSString *)iconName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:24 weight:UIFontWeightMedium];
    UIImage *icon = [UIImage systemImageNamed:iconName withConfiguration:config];
    [btn setImage:icon forState:UIControlStateNormal];
    btn.tintColor = [UIColor whiteColor];
    return btn;
}


#pragma mark - Actions

- (void)switchDevice {
    NSLog(@"[投屏控制] 切换设备");
    
    // 显示设备选择弹窗
    RRScreenCastView *castView = [[RRScreenCastView alloc] init];
    castView.delegate = self;
    [castView showInView:self.view videoURL:self.videoURL videoTitle:self.videoTitle];
}

- (void)showEpisodeList {
    if (!self.episodes || self.episodes.count == 0) return;
    
    // 获取封面URL（如果有的话，从第一集或者剧集数据中获取）
    NSString *coverURL = @""; // 可以从剧集数据中获取
    
    RREpisodePanelView *panel = [[RREpisodePanelView alloc] initWithEpisodes:self.episodes 
                                                                 currentIndex:self.currentEpisodeIndex 
                                                                   dramaTitle:self.dramaTitle 
                                                                     coverURL:coverURL];
    panel.delegate = self;
    [panel showInView:self.view];
}

- (void)playEpisodeAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.episodes.count) return;
    
    self.currentEpisodeIndex = index;
    NSDictionary *ep = self.episodes[index];
    
    NSString *videoUrl = ep[@"video_url"] ?: @"";
    if (videoUrl.length == 0) {
        NSLog(@"[投屏控制] 视频URL为空");
        return;
    }
    
    // 如果是相对路径，拼接 baseURL
    if (![videoUrl hasPrefix:@"http"]) {
        videoUrl = [NSString stringWithFormat:@"http://192.168.4.157:3000%@", videoUrl];
    }
    
    NSString *episodeNum = ep[@"episode_number"] ?: @"";
    NSString *title = [NSString stringWithFormat:@"%@ 第%@集", self.dramaTitle ?: @"", episodeNum];
    
    // 更新 UI
    self.videoURL = videoUrl;
    self.videoTitle = title;
    self.titleLabel.text = title;
    
    // 更新选集按钮文字
    NSString *episodeText = [NSString stringWithFormat:@"选集 (%ld/%lu)", (long)(index + 1), (unsigned long)self.episodes.count];
    [self.episodeButton setTitle:episodeText forState:UIControlStateNormal];
    
    // 推送新集数
    [[RRScreenCastManager shared] playVideoWithURL:videoUrl title:title];
    
    NSLog(@"[投屏控制] 切换到第%@集", episodeNum);
}

- (void)togglePlayPause {
    self.isPlaying = !self.isPlaying;
    
    if (self.isPlaying) {
        [[RRScreenCastManager shared] resume];
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:24 weight:UIFontWeightMedium];
        [self.playPauseButton setImage:[UIImage systemImageNamed:@"pause.fill" withConfiguration:config] forState:UIControlStateNormal];
    } else {
        [[RRScreenCastManager shared] pause];
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:24 weight:UIFontWeightMedium];
        [self.playPauseButton setImage:[UIImage systemImageNamed:@"play.fill" withConfiguration:config] forState:UIControlStateNormal];
    }
}

- (void)backward {
    // 快退15秒
    NSInteger targetTime = MAX(0, (NSInteger)self.currentTime - 15);
    [[RRScreenCastManager shared] seekTo:targetTime];
    NSLog(@"[投屏控制] 快退15秒 -> %ld", (long)targetTime);
}

- (void)forward {
    // 快进15秒
    NSInteger targetTime = MIN((NSInteger)self.totalTime, (NSInteger)self.currentTime + 15);
    [[RRScreenCastManager shared] seekTo:targetTime];
    NSLog(@"[投屏控制] 快进15秒 -> %ld", (long)targetTime);
}

- (void)progressChanged:(UISlider *)slider {
    // 拖动进度条
    NSInteger targetTime = (NSInteger)(slider.value * self.totalTime);
    [[RRScreenCastManager shared] seekTo:targetTime];
    NSLog(@"[投屏控制] 拖动进度条 -> %ld", (long)targetTime);
}

- (void)changeSpeed {
    // 循环切换倍速：1.0x → 1.25x → 1.5x → 2.0x → 1.0x
    if (self.currentSpeed == 1.0) {
        self.currentSpeed = 1.25;
    } else if (self.currentSpeed == 1.25) {
        self.currentSpeed = 1.5;
    } else if (self.currentSpeed == 1.5) {
        self.currentSpeed = 2.0;
    } else {
        self.currentSpeed = 1.0;
    }
    
    [self.speedButton setTitle:[NSString stringWithFormat:@"倍速 %.2fx", self.currentSpeed] forState:UIControlStateNormal];
    
    // 调用 LBLelinkPlayer 的倍速接口
    [[RRScreenCastManager shared] setPlaySpeed:self.currentSpeed];
    NSLog(@"[投屏控制] 切换倍速: %.2fx", self.currentSpeed);
}

- (void)disconnect {
    [[RRScreenCastManager shared] disconnect];
    
    // 断开连接时隐藏悬浮按钮
    [[RRScreenCastFloatingButton sharedButton] hide];
    
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - RRScreenCastManagerDelegate

- (void)screenCastPlayStatusChanged:(LBLelinkPlayStatus)status {
    NSLog(@"[投屏控制] 播放状态变化: %lu", (unsigned long)status);
    
    // 根据状态更新 UI
    switch (status) {
        case LBLelinkPlayStatusPlaying:
            self.isPlaying = YES;
            break;
        case LBLelinkPlayStatusPause:
            self.isPlaying = NO;
            break;
        case LBLelinkPlayStatusStopped:
            self.isPlaying = NO;
            break;
        case LBLelinkPlayStatusCommpleted:
            NSLog(@"[投屏控制] 检测到播放完成，准备自动播放下一集");
            // 播放完成，自动播放下一集
            [self playNextEpisode];
            break;
        default:
            break;
    }
}

- (void)screenCastProgressUpdated:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    self.currentTime = currentTime;
    self.totalTime = totalTime;
    
    // 更新进度条
    if (totalTime > 0) {
        self.progressSlider.value = currentTime / totalTime;
    }
    
    // 更新时间标签
    self.currentTimeLabel.text = [self formatTime:currentTime];
    self.totalTimeLabel.text = [self formatTime:totalTime];
}

- (void)screenCastDidDisconnect:(LBLelinkService *)service {
    NSLog(@"[投屏控制] 连接已断开");
    
    // 隐藏悬浮按钮
    [[RRScreenCastFloatingButton sharedButton] hide];
    
    // 自动退出页面
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)screenCastDidFailWithError:(NSError *)error {
    NSLog(@"[投屏控制] 连接失败: %@", error);
    
    // 更新UI显示连接失败
    self.deviceLabel.text = @"连接失败";
    self.statusDot.backgroundColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
    
    // 提示用户
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"连接失败" 
                                                                   message:@"无法连接到投屏设备，请重试" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)playNextEpisode {
    NSLog(@"[投屏控制] playNextEpisode 被调用");
    NSLog(@"[投屏控制] episodes.count: %lu", (unsigned long)self.episodes.count);
    NSLog(@"[投屏控制] autoPlaySwitch.isOn: %d", self.autoPlaySwitch.isOn);
    NSLog(@"[投屏控制] currentEpisodeIndex: %ld", (long)self.currentEpisodeIndex);
    
    // 如果没有剧集列表，不处理
    if (!self.episodes || self.episodes.count == 0) {
        NSLog(@"[投屏控制] 没有剧集列表，播放完成");
        return;
    }
    
    // 如果自动连播开关关闭，不处理
    if (!self.autoPlaySwitch.isOn) {
        NSLog(@"[投屏控制] 自动连播已关闭");
        return;
    }
    
    // 计算下一集索引
    NSInteger nextIndex = self.currentEpisodeIndex + 1;
    
    // 如果已经是最后一集，从第一集重新开始
    if (nextIndex >= self.episodes.count) {
        nextIndex = 0;
        NSLog(@"[投屏控制] 已播放完所有剧集，从第一集重新开始");
    }
    
    self.currentEpisodeIndex = nextIndex;
    NSDictionary *nextEp = self.episodes[nextIndex];
    
    NSString *videoUrl = nextEp[@"video_url"] ?: @"";
    if (videoUrl.length == 0) {
        NSLog(@"[投屏控制] 下一集视频URL为空");
        return;
    }
    
    // 如果是相对路径，拼接 baseURL
    if (![videoUrl hasPrefix:@"http"]) {
        // 需要导入 RRNetworkManager
        videoUrl = [NSString stringWithFormat:@"http://192.168.4.157:3000%@", videoUrl];
    }
    
    NSString *episodeNum = nextEp[@"episode_number"] ?: @"";
    NSString *title = [NSString stringWithFormat:@"%@ 第%@集", self.dramaTitle ?: @"", episodeNum];
    
    // 更新 UI
    self.videoURL = videoUrl;
    self.videoTitle = title;
    self.titleLabel.text = title;
    
    // 更新选集按钮
    if (self.episodeButton) {
        NSString *episodeText = [NSString stringWithFormat:@"选集 (%ld/%lu)", (long)(nextIndex + 1), (unsigned long)self.episodes.count];
        [self.episodeButton setTitle:episodeText forState:UIControlStateNormal];
        NSLog(@"[投屏控制] 已更新选集按钮: %@", episodeText);
    }
    
    // 推送下一集
    [[RRScreenCastManager shared] playVideoWithURL:videoUrl title:title];
    
    NSLog(@"[投屏控制] 自动播放下一集: 第%@集", episodeNum);
}

- (NSString *)formatTime:(NSTimeInterval)seconds {
    int mins = (int)seconds / 60;
    int secs = (int)seconds % 60;
    return [NSString stringWithFormat:@"%02d:%02d", mins, secs];
}

#pragma mark - RRScreenCastViewDelegate

- (void)screenCastViewDidConnect:(NSString *)deviceName videoURL:(NSString *)videoURL videoTitle:(NSString *)title {
    // 切换设备：先断开旧连接，然后连接新设备
    // 注意：RRScreenCastManager 在连接新设备时会自动断开旧连接
    
    // 更新设备名和状态
    self.deviceName = deviceName;
    self.deviceLabel.text = deviceName;
    self.statusDot.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.3 alpha:1.0]; // 恢复绿色
    
    // 重新设置 delegate 为当前控制页面（因为 RRScreenCastView 会覆盖 delegate）
    [RRScreenCastManager shared].delegate = self;
    NSLog(@"[投屏控制] 重新设置 delegate 为控制页面");
    
    // 推送当前视频到新设备（RRScreenCastManager 内部会先断开旧连接）
    [[RRScreenCastManager shared] playVideoWithURL:self.videoURL title:self.videoTitle];
    
    NSLog(@"[投屏控制] 已切换到设备: %@，并推送视频", deviceName);
}

#pragma mark - RREpisodePanelViewDelegate

- (void)episodePanelDidSelectEpisodeAtIndex:(NSInteger)index {
    [self playEpisodeAtIndex:index];
}

@end
