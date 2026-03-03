//
//  RRPlayerMenuView.m
//  redredvideo
//
//  白色列表式底部弹窗（参考抖音/快手风格）
//  功能行：倍速（内联速度选择）、保存到相册、投屏
//

#import "RRPlayerMenuView.h"

/// 圆角值
static CGFloat const kCornerRadius = 14.0;
/// 行高
static CGFloat const kRowHeight = 56.0;
/// 速度选项药丸高度
static CGFloat const kPillHeight = 32.0;

#pragma mark - RRPlayerMenuView

@interface RRPlayerMenuView ()

@property (nonatomic, strong) UIView *dimView;         // 半透明遮罩
@property (nonatomic, strong) UIView *containerView;   // 白色容器
@property (nonatomic, strong) UIView *handleBar;       // 顶部拖拽条

// 行
@property (nonatomic, strong) UIView *speedRow;
@property (nonatomic, strong) UIView *saveRow;
@property (nonatomic, strong) UIView *castRow;

// 倍速药丸按钮
@property (nonatomic, strong) NSArray<UIButton *> *speedButtons;
@property (nonatomic, strong) NSArray<NSNumber *> *speedValues;

@end

@implementation RRPlayerMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _currentSpeed = 1.0;
        _speedValues = @[@0.75, @1.0, @1.25, @1.5, @2.0, @3.0];
    }
    return self;
}

#pragma mark - Show / Dismiss

- (void)showInView:(UIView *)view {
    self.frame = view.bounds;
    [view addSubview:self];

    // 遮罩
    self.dimView = [[UIView alloc] initWithFrame:self.bounds];
    self.dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    self.dimView.alpha = 0;
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.dimView addGestureRecognizer:dismissTap];
    [self addSubview:self.dimView];

    // 容器
    CGFloat screenW = self.bounds.size.width;
    // 3 行 + 顶部把手 + 底部安全区
    CGFloat safeBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeBottom = view.safeAreaInsets.bottom;
    }
    CGFloat containerH = 20 + kRowHeight * 3 + 12 + safeBottom; // 把手20 + 3行 + 底部间距
    CGFloat containerY = self.bounds.size.height; // 初始在屏幕外

    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, containerY, screenW, containerH)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    // 顶部圆角
    self.containerView.layer.cornerRadius = kCornerRadius;
    self.containerView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.containerView.clipsToBounds = YES;
    [self addSubview:self.containerView];

    // 顶部把手条
    self.handleBar = [[UIView alloc] initWithFrame:CGRectMake((screenW - 36) / 2, 8, 36, 4)];
    self.handleBar.backgroundColor = [UIColor colorWithWhite:0.82 alpha:1.0];
    self.handleBar.layer.cornerRadius = 2;
    [self.containerView addSubview:self.handleBar];

    // 构建行
    [self buildSpeedRow];
    [self buildSaveRow];
    [self buildCastRow];

    // 分隔线
    [self addSeparatorAtY:20 + kRowHeight inContainer:self.containerView];
    [self addSeparatorAtY:20 + kRowHeight * 2 inContainer:self.containerView];

    // 弹出动画
    CGFloat targetY = self.bounds.size.height - containerH;
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
    CGFloat screenW = self.bounds.size.width;
    CGFloat containerH = self.containerView.bounds.size.height;

    [UIView animateWithDuration:0.25
                     animations:^{
        self.dimView.alpha = 0;
        self.containerView.frame = CGRectMake(0, self.bounds.size.height, screenW, containerH);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(playerMenuDidDismiss)]) {
            [self.delegate playerMenuDidDismiss];
        }
    }];
}

#pragma mark - Build Rows

/// 第1行：倍速 — 左侧图标+文字，右侧药丸按钮组
- (void)buildSpeedRow {
    CGFloat screenW = self.bounds.size.width;
    CGFloat rowY = 20;
    self.speedRow = [[UIView alloc] initWithFrame:CGRectMake(0, rowY, screenW, kRowHeight)];
    [self.containerView addSubview:self.speedRow];

    // 图标
    UIImageView *icon = [self iconViewWithSystemName:@"speedometer"];
    icon.frame = CGRectMake(16, (kRowHeight - 24) / 2, 24, 24);
    [self.speedRow addSubview:icon];

    // "倍速" 文字
    UILabel *label = [self rowLabelWithText:@"倍速"];
    label.frame = CGRectMake(48, 0, 50, kRowHeight);
    [self.speedRow addSubview:label];

    // 药丸按钮组
    NSArray *titles = @[@"0.75x", @"1x", @"1.25x", @"1.5x", @"2x", @"3x"];
    CGFloat pillW = 48;
    CGFloat pillSpacing = 6;
    CGFloat totalPillW = titles.count * pillW + (titles.count - 1) * pillSpacing;
    CGFloat pillStartX = screenW - totalPillW - 16;
    CGFloat pillY = (kRowHeight - kPillHeight) / 2;

    NSMutableArray *buttons = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(pillStartX + i * (pillW + pillSpacing), pillY, pillW, kPillHeight);
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        btn.layer.cornerRadius = kPillHeight / 2;
        btn.tag = i;
        [btn addTarget:self action:@selector(speedTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.speedRow addSubview:btn];
        [buttons addObject:btn];
    }
    self.speedButtons = buttons;
    [self refreshSpeedSelection];
}

/// 第2行：保存到相册
- (void)buildSaveRow {
    CGFloat screenW = self.bounds.size.width;
    CGFloat rowY = 20 + kRowHeight;
    self.saveRow = [[UIView alloc] initWithFrame:CGRectMake(0, rowY, screenW, kRowHeight)];
    [self.containerView addSubview:self.saveRow];

    UIImageView *icon = [self iconViewWithSystemName:@"square.and.arrow.down"];
    icon.frame = CGRectMake(16, (kRowHeight - 24) / 2, 24, 24);
    [self.saveRow addSubview:icon];

    UILabel *label = [self rowLabelWithText:@"保存到相册"];
    label.frame = CGRectMake(48, 0, 120, kRowHeight);
    [self.saveRow addSubview:label];

    // 箭头
    UIImageView *arrow = [self arrowView];
    arrow.frame = CGRectMake(screenW - 30, (kRowHeight - 16) / 2, 16, 16);
    [self.saveRow addSubview:arrow];

    // 点击
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveTapped)];
    [self.saveRow addGestureRecognizer:tap];
}

/// 第3行：投屏
- (void)buildCastRow {
    CGFloat screenW = self.bounds.size.width;
    CGFloat rowY = 20 + kRowHeight * 2;
    self.castRow = [[UIView alloc] initWithFrame:CGRectMake(0, rowY, screenW, kRowHeight)];
    [self.containerView addSubview:self.castRow];

    UIImageView *icon = [self iconViewWithSystemName:@"tv"];
    icon.frame = CGRectMake(16, (kRowHeight - 24) / 2, 24, 24);
    [self.castRow addSubview:icon];

    UILabel *label = [self rowLabelWithText:@"投屏"];
    label.frame = CGRectMake(48, 0, 80, kRowHeight);
    [self.castRow addSubview:label];

    UIImageView *arrow = [self arrowView];
    arrow.frame = CGRectMake(screenW - 30, (kRowHeight - 16) / 2, 16, 16);
    [self.castRow addSubview:arrow];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(castTapped)];
    [self.castRow addGestureRecognizer:tap];
}

#pragma mark - Speed Selection

- (void)speedTapped:(UIButton *)sender {
    float speed = [self.speedValues[sender.tag] floatValue];
    self.currentSpeed = speed;
    [self refreshSpeedSelection];

    if ([self.delegate respondsToSelector:@selector(playerMenuDidSelectSpeed:)]) {
        [self.delegate playerMenuDidSelectSpeed:speed];
    }
}

- (void)refreshSpeedSelection {
    UIColor *selectedBg = [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
    UIColor *normalBg  = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];

    for (NSInteger i = 0; i < self.speedButtons.count; i++) {
        UIButton *btn = self.speedButtons[i];
        float speed = [self.speedValues[i] floatValue];
        BOOL selected = (fabsf(speed - self.currentSpeed) < 0.01);

        btn.backgroundColor = selected ? selectedBg : normalBg;
        [btn setTitleColor:selected ? [UIColor whiteColor] : [UIColor colorWithWhite:0.3 alpha:1.0]
                  forState:UIControlStateNormal];
    }
}

#pragma mark - Row Tap Actions

- (void)saveTapped {
    // 行按压高亮
    [self flashRow:self.saveRow];
    if ([self.delegate respondsToSelector:@selector(playerMenuDidTapSaveToAlbum)]) {
        [self.delegate playerMenuDidTapSaveToAlbum];
    }
    [self dismiss];
}

- (void)castTapped {
    [self flashRow:self.castRow];
    if ([self.delegate respondsToSelector:@selector(playerMenuDidTapScreenCast)]) {
        [self.delegate playerMenuDidTapScreenCast];
    }
    [self dismiss];
}

- (void)flashRow:(UIView *)row {
    UIView *highlight = [[UIView alloc] initWithFrame:row.bounds];
    highlight.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [row insertSubview:highlight atIndex:0];
    [UIView animateWithDuration:0.2 animations:^{
        highlight.alpha = 0;
    } completion:^(BOOL finished) {
        [highlight removeFromSuperview];
    }];
}

#pragma mark - Helpers

- (UIImageView *)iconViewWithSystemName:(NSString *)name {
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIFontWeightMedium];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:name withConfiguration:config]];
    iv.tintColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    iv.contentMode = UIViewContentModeCenter;
    return iv;
}

- (UILabel *)rowLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    return label;
}

- (UIImageView *)arrowView {
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:13 weight:UIFontWeightMedium];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right" withConfiguration:config]];
    iv.tintColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    iv.contentMode = UIViewContentModeCenter;
    return iv;
}

- (void)addSeparatorAtY:(CGFloat)y inContainer:(UIView *)container {
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(48, y, container.bounds.size.width - 48, 0.5)];
    sep.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    [container addSubview:sep];
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
