//
//  RRScreenCastView.m
//  redredvideo
//
//  投屏设备选择弹窗：搜索设备列表 → 点击连接 → 推送视频
//

#import "RRScreenCastView.h"
#import "RRScreenCastManager.h"

#pragma mark - 设备Cell

@interface RRDeviceCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *tvIcon;
@property (nonatomic, strong) UIActivityIndicatorView *connecting;
@end

@implementation RRDeviceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        // TV图标
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIFontWeightMedium];
        self.tvIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"tv" withConfiguration:config]];
        self.tvIcon.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        self.tvIcon.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.tvIcon];
        
        // 设备名
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor colorWithWhite:0.15 alpha:1.0];
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.nameLabel];
        
        // 连接中指示器
        self.connecting = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        self.connecting.hidesWhenStopped = YES;
        [self.contentView addSubview:self.connecting];
        
        // 底部分隔线
        UIView *sep = [[UIView alloc] init];
        sep.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
        sep.tag = 999;
        [self.contentView addSubview:sep];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat h = self.contentView.bounds.size.height;
    CGFloat w = self.contentView.bounds.size.width;
    self.tvIcon.frame = CGRectMake(16, (h - 24) / 2, 24, 24);
    self.nameLabel.frame = CGRectMake(52, 0, w - 100, h);
    self.connecting.center = CGPointMake(w - 32, h / 2);
    UIView *sep = [self.contentView viewWithTag:999];
    sep.frame = CGRectMake(52, h - 0.5, w - 52, 0.5);
}

- (void)configureWithService:(LBLelinkService *)service isConnecting:(BOOL)connecting {
    self.nameLabel.text = service.lelinkServiceName ?: @"未知设备";
    if (connecting) {
        [self.connecting startAnimating];
    } else {
        [self.connecting stopAnimating];
    }
}

@end

#pragma mark - RRScreenCastView

@interface RRScreenCastView () <UITableViewDelegate, UITableViewDataSource, RRScreenCastManagerDelegate>

@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *searchingIndicator;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, copy) NSString *videoURL;
@property (nonatomic, copy) NSString *videoTitle;
@property (nonatomic, strong) NSArray<LBLelinkService *> *devices;
@property (nonatomic, assign) NSInteger connectingIndex; // 正在连接的设备索引，-1表示没有

@end

@implementation RRScreenCastView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _devices = @[];
        _connectingIndex = -1;
    }
    return self;
}

#pragma mark - Show / Dismiss

- (void)showInView:(UIView *)view videoURL:(NSString *)videoURL videoTitle:(NSString *)title {
    self.videoURL = videoURL;
    self.videoTitle = title;
    self.frame = view.bounds;
    [view addSubview:self];
    
    CGFloat screenW = self.bounds.size.width;
    CGFloat screenH = self.bounds.size.height;
    
    // 遮罩
    self.dimView = [[UIView alloc] initWithFrame:self.bounds];
    self.dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    self.dimView.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.dimView addGestureRecognizer:tap];
    [self addSubview:self.dimView];
    
    // 容器
    CGFloat safeBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeBottom = view.safeAreaInsets.bottom;
    }
    CGFloat containerH = 360 + safeBottom;
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, screenH, screenW, containerH)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 14;
    self.containerView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.containerView.clipsToBounds = YES;
    [self addSubview:self.containerView];
    
    // 顶部把手
    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake((screenW - 36) / 2, 8, 36, 4)];
    handle.backgroundColor = [UIColor colorWithWhite:0.82 alpha:1.0];
    handle.layer.cornerRadius = 2;
    [self.containerView addSubview:handle];
    
    // 标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 20, 200, 28)];
    self.titleLabel.text = @"选择投屏设备";
    self.titleLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    [self.containerView addSubview:self.titleLabel];
    
    // 关闭按钮
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIFontWeightMedium];
    [self.closeButton setImage:[UIImage systemImageNamed:@"xmark" withConfiguration:config] forState:UIControlStateNormal];
    self.closeButton.tintColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    self.closeButton.frame = CGRectMake(screenW - 44, 16, 36, 36);
    [self.closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.closeButton];
    
    // 搜索状态
    self.searchingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.searchingIndicator.frame = CGRectMake(screenW - 80, 22, 20, 20);
    [self.searchingIndicator startAnimating];
    [self.containerView addSubview:self.searchingIndicator];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 52, screenW - 32, 20)];
    self.statusLabel.text = @"正在搜索附近设备...";
    self.statusLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    self.statusLabel.font = [UIFont systemFontOfSize:13];
    [self.containerView addSubview:self.statusLabel];
    
    // 设备列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 78, screenW, containerH - 78 - safeBottom)
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 56;
    [self.tableView registerClass:[RRDeviceCell class] forCellReuseIdentifier:@"DeviceCell"];
    [self.containerView addSubview:self.tableView];
    
    // 开始搜索
    RRScreenCastManager *mgr = [RRScreenCastManager shared];
    mgr.delegate = self;
    [mgr startSearch];
    
    // 如果已有设备列表，先显示
    if (mgr.services.count > 0) {
        self.devices = mgr.services;
        [self updateStatus];
        [self.tableView reloadData];
    }
    
    // 弹出动画
    CGFloat targetY = screenH - containerH;
    [UIView animateWithDuration:0.35
                          delay:0
         usingSpringWithDamping:0.9
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.dimView.alpha = 1.0;
        self.containerView.frame = CGRectMake(0, targetY, screenW, containerH);
    } completion:nil];
}

- (void)dismiss {
    [[RRScreenCastManager shared] stopSearch];
    
    CGFloat screenW = self.bounds.size.width;
    CGFloat containerH = self.containerView.bounds.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.dimView.alpha = 0;
        self.containerView.frame = CGRectMake(0, self.bounds.size.height, screenW, containerH);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(screenCastViewDidDismiss)]) {
            [self.delegate screenCastViewDidDismiss];
        }
    }];
}

- (void)updateStatus {
    if (self.devices.count == 0) {
        self.statusLabel.text = @"正在搜索附近设备...";
        [self.searchingIndicator startAnimating];
    } else {
        self.statusLabel.text = [NSString stringWithFormat:@"发现 %lu 台设备", (unsigned long)self.devices.count];
        [self.searchingIndicator stopAnimating];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RRDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell" forIndexPath:indexPath];
    LBLelinkService *service = self.devices[indexPath.row];
    BOOL connecting = (indexPath.row == self.connectingIndex);
    [cell configureWithService:service isConnecting:connecting];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.connectingIndex >= 0) return; // 正在连接中，不允许重复点击
    
    self.connectingIndex = indexPath.row;
    [self.tableView reloadData];
    
    LBLelinkService *service = self.devices[indexPath.row];
    self.statusLabel.text = [NSString stringWithFormat:@"正在连接 %@...", service.lelinkServiceName];
    
    [[RRScreenCastManager shared] connectToService:service];
}

#pragma mark - RRScreenCastManagerDelegate

- (void)screenCastDidUpdateServices:(NSArray<LBLelinkService *> *)services {
    self.devices = services;
    [self updateStatus];
    [self.tableView reloadData];
}

- (void)screenCastDidConnect:(LBLelinkService *)service {
    self.statusLabel.text = [NSString stringWithFormat:@"已连接 %@", service.lelinkServiceName];
    self.connectingIndex = -1;
    [self.tableView reloadData];
    
    // 通知外部 push 到控制页面
    if ([self.delegate respondsToSelector:@selector(screenCastViewDidConnect:videoURL:videoTitle:)]) {
        [self.delegate screenCastViewDidConnect:service.lelinkServiceName videoURL:self.videoURL videoTitle:self.videoTitle];
    }
    
    // 0.3秒后关闭设备列表
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismiss];
    });
}

- (void)screenCastDidDisconnect:(LBLelinkService *)service {
    self.connectingIndex = -1;
    self.statusLabel.text = @"连接已断开";
    [self.tableView reloadData];
}

- (void)screenCastDidFailWithError:(NSError *)error {
    self.connectingIndex = -1;
    self.statusLabel.text = [NSString stringWithFormat:@"连接失败: %@", error.localizedDescription];
    [self.tableView reloadData];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self) {
        [self dismiss];
        return self;
    }
    return hit;
}

@end
