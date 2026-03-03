//
//  RRScreenCastFloatingButton.m
//  redredvideo
//
//  投屏悬浮按钮：可拖动，自动吸附边缘
//

#import "RRScreenCastFloatingButton.h"
#import "RRScreenCastControlViewController.h"
#import "RRNavigationHelper.h"

@interface RRScreenCastFloatingButton ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *tvIconView;
@property (nonatomic, strong) UIView *statusDot;
@property (nonatomic, assign) CGPoint lastPosition;

@end

@implementation RRScreenCastFloatingButton

+ (instancetype)sharedButton {
    static RRScreenCastFloatingButton *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RRScreenCastFloatingButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupGestures];
    }
    return self;
}

- (void)setupUI {
    // 容器背景
    self.containerView = [[UIView alloc] initWithFrame:self.bounds];
    self.containerView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
    self.containerView.layer.cornerRadius = 10;
    self.containerView.clipsToBounds = YES;
    [self addSubview:self.containerView];
    
    // TV 图标
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:24 weight:UIFontWeightRegular];
    UIImage *tvIcon = [UIImage systemImageNamed:@"tv" withConfiguration:config];
    self.tvIconView = [[UIImageView alloc] initWithImage:tvIcon];
    self.tvIconView.tintColor = [UIColor whiteColor];
    self.tvIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.tvIconView.frame = CGRectMake(13, 13, 24, 24);
    [self.containerView addSubview:self.tvIconView];
    
    // 绿色状态点
    self.statusDot = [[UIView alloc] initWithFrame:CGRectMake(36, 6, 8, 8)];
    self.statusDot.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.3 alpha:1.0];
    self.statusDot.layer.cornerRadius = 4;
    [self.containerView addSubview:self.statusDot];
    
    // 阴影
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowRadius = 4;
}

- (void)setupGestures {
    // 拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
    
    // 点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tap];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.lastPosition = self.center;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint newCenter = CGPointMake(self.lastPosition.x + translation.x, 
                                       self.lastPosition.y + translation.y);
        
        // 限制在屏幕范围内
        CGFloat minX = self.bounds.size.width / 2;
        CGFloat maxX = self.superview.bounds.size.width - self.bounds.size.width / 2;
        CGFloat minY = self.bounds.size.height / 2 + 44; // 状态栏高度
        CGFloat maxY = self.superview.bounds.size.height - self.bounds.size.height / 2 - 34; // 底部安全区
        
        newCenter.x = MAX(minX, MIN(maxX, newCenter.x));
        newCenter.y = MAX(minY, MIN(maxY, newCenter.y));
        
        self.center = newCenter;
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        // 自动吸附到最近的边缘
        [self snapToEdge];
    }
}

- (void)snapToEdge {
    CGFloat screenWidth = self.superview.bounds.size.width;
    CGFloat currentX = self.center.x;
    
    // 判断靠近左边还是右边
    CGFloat targetX;
    if (currentX < screenWidth / 2) {
        // 吸附到左边（完全贴边）
        targetX = self.bounds.size.width / 2;
    } else {
        // 吸附到右边（完全贴边）
        targetX = screenWidth - self.bounds.size.width / 2;
    }
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.center = CGPointMake(targetX, self.center.y);
    } completion:nil];
}

- (void)handleTap {
    NSLog(@"[悬浮按钮] 点击，进入投屏控制页面");
    
    // 获取当前的投屏控制页面实例
    RRScreenCastControlViewController *controlVC = [RRScreenCastControlViewController currentInstance];
    
    if (controlVC) {
        // 获取当前的 navigationController
        UINavigationController *currentNav = [RRNavigationHelper currentNavigationController];
        
        if (!currentNav) {
            NSLog(@"[悬浮按钮] 没有找到 navigationController");
            return;
        }
        
        // 检查 controlVC 是否在当前导航栈中
        if ([currentNav.viewControllers containsObject:controlVC]) {
            // 在导航栈中，直接 pop 回去
            [currentNav popToViewController:controlVC animated:YES];
            NSLog(@"[悬浮按钮] 返回到已存在的投屏控制页面");
        } else {
            // 不在导航栈中，重新 push
            [currentNav pushViewController:controlVC animated:YES];
            NSLog(@"[悬浮按钮] 重新 push 投屏控制页面");
        }
    } else {
        // 如果实例不存在，说明已经被销毁了，隐藏按钮
        [self hide];
        NSLog(@"[悬浮按钮] 投屏控制页面已销毁，隐藏按钮");
    }
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
    if (!self.superview) {
        [keyWindow addSubview:self];
        
        // 初始位置：右边中间（完全贴边）
        CGFloat screenWidth = keyWindow.bounds.size.width;
        CGFloat screenHeight = keyWindow.bounds.size.height;
        self.center = CGPointMake(screenWidth - self.bounds.size.width / 2, 
                                 screenHeight / 2);
    }
    
    self.hidden = NO;
    self.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }];
    
    NSLog(@"[悬浮按钮] 显示");
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
    }];
    
    NSLog(@"[悬浮按钮] 隐藏");
}

@end
