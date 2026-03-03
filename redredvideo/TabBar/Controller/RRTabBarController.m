//
//  RRTabBarController.m
//  redredvideo
//
//  自定义TabBar - 抖音风格（半透明背景，4个等分Tab）
//

#import "RRTabBarController.h"
#import "RRSkitsViewController.h"
#import "RRHomeViewController.h"

@interface RRCustomTabBar : UIView

@property (nonatomic, strong) NSArray<UIButton *> *tabButtons;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) void(^onTabSelected)(NSInteger index);

- (void)setupWithItems:(NSArray<NSDictionary *> *)items;

@end

@implementation RRCustomTabBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bgView = [[UIView alloc] init];
        self.bgView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.07 alpha:0.92];
        [self addSubview:self.bgView];
        
        UIView *topLine = [[UIView alloc] init];
        topLine.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        topLine.tag = 100;
        [self addSubview:topLine];
    }
    return self;
}

- (void)setupWithItems:(NSArray<NSDictionary *> *)items {
    NSMutableArray *buttons = [NSMutableArray array];
    
    for (NSInteger i = 0; i < items.count; i++) {
        NSDictionary *item = items[i];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        [btn addTarget:self action:@selector(tabTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *iconName = item[@"icon"];
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIFontWeightMedium];
        UIImage *icon = [UIImage systemImageNamed:iconName withConfiguration:config];
        
        UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
        iconView.contentMode = UIViewContentModeCenter;
        iconView.tag = 200 + i;
        iconView.tintColor = (i == 0) ? [UIColor whiteColor] : [UIColor colorWithWhite:0.5 alpha:1.0];
        [btn addSubview:iconView];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = item[@"title"];
        label.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 300 + i;
        label.textColor = (i == 0) ? [UIColor whiteColor] : [UIColor colorWithWhite:0.5 alpha:1.0];
        [btn addSubview:label];
        
        [self addSubview:btn];
        [buttons addObject:btn];
    }
    
    self.tabButtons = [buttons copy];
    self.selectedIndex = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat safeBottom = 34;
    CGFloat barH = h - safeBottom;
    
    self.bgView.frame = self.bounds;
    
    UIView *topLine = [self viewWithTag:100];
    topLine.frame = CGRectMake(0, 0, w, 0.5);
    
    // 4等分
    CGFloat slotW = w / self.tabButtons.count;
    
    for (NSInteger i = 0; i < self.tabButtons.count; i++) {
        UIButton *btn = self.tabButtons[i];
        btn.frame = CGRectMake(i * slotW, 0, slotW, barH);
        
        UIImageView *iconView = [btn viewWithTag:200 + i];
        iconView.frame = CGRectMake((slotW - 28) / 2, 6, 28, 28);
        
        UILabel *label = [btn viewWithTag:300 + i];
        label.frame = CGRectMake(0, 34, slotW, 14);
    }
}

- (void)tabTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    if (index == self.selectedIndex) return;
    
    [self updateSelectedIndex:index];
    
    if (self.onTabSelected) {
        self.onTabSelected(index);
    }
}

- (void)updateSelectedIndex:(NSInteger)index {
    for (NSInteger i = 0; i < self.tabButtons.count; i++) {
        UIButton *btn = self.tabButtons[i];
        UIImageView *iconView = [btn viewWithTag:200 + i];
        UILabel *label = [btn viewWithTag:300 + i];
        
        BOOL selected = (i == index);
        UIColor *color = selected ? [UIColor whiteColor] : [UIColor colorWithWhite:0.5 alpha:1.0];
        iconView.tintColor = color;
        label.textColor = color;
        
        if (selected) {
            [UIView animateWithDuration:0.15 animations:^{
                iconView.transform = CGAffineTransformMakeScale(1.15, 1.15);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    iconView.transform = CGAffineTransformIdentity;
                }];
            }];
        }
    }
    
    self.selectedIndex = index;
}

@end

#pragma mark - RRTabBarController

@interface RRTabBarController () <UINavigationControllerDelegate>

@property (nonatomic, strong) RRCustomTabBar *customTabBar;

@end

@implementation RRTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.hidden = YES;
    
    [self setupChildControllers];
    [self setupCustomTabBar];
}

- (void)setupChildControllers {
    RRHomeViewController *homeVC = [[RRHomeViewController alloc] init];
    UINavigationController *homeNav = [self wrapInNav:homeVC];
    
    RRSkitsViewController *skitsVC = [[RRSkitsViewController alloc] init];
    UINavigationController *skitsNav = [self wrapInNav:skitsVC];
    
    UIViewController *followVC = [[UIViewController alloc] init];
    followVC.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.08 alpha:1.0];
    followVC.navigationItem.title = @"追剧";
    UINavigationController *followNav = [self wrapInNav:followVC];
    
    UIViewController *profileVC = [[UIViewController alloc] init];
    profileVC.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.08 alpha:1.0];
    profileVC.navigationItem.title = @"我的";
    UINavigationController *profileNav = [self wrapInNav:profileVC];
    
    self.viewControllers = @[homeNav, skitsNav, followNav, profileNav];
}

- (UINavigationController *)wrapInNav:(UIViewController *)vc {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.delegate = self;
    
    UINavigationBarAppearance *navAppearance = [[UINavigationBarAppearance alloc] init];
    [navAppearance configureWithOpaqueBackground];
    navAppearance.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.1 alpha:1.0];
    navAppearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    navAppearance.largeTitleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    nav.navigationBar.standardAppearance = navAppearance;
    nav.navigationBar.scrollEdgeAppearance = navAppearance;
    
    return nav;
}

- (void)setupCustomTabBar {
    CGFloat tabBarH = 83;
    self.customTabBar = [[RRCustomTabBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - tabBarH, self.view.bounds.size.width, tabBarH)];
    self.customTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self.customTabBar setupWithItems:@[
        @{@"title": @"首页", @"icon": @"house.fill"},
        @{@"title": @"短剧", @"icon": @"play.rectangle.fill"},
        @{@"title": @"追剧", @"icon": @"heart.fill"},
        @{@"title": @"我的", @"icon": @"person.fill"},
    ]];
    
    __weak typeof(self) weakSelf = self;
    self.customTabBar.onTabSelected = ^(NSInteger index) {
        weakSelf.selectedIndex = index;
    };
    
    [self.view addSubview:self.customTabBar];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    BOOL isRoot = (viewController == navigationController.viewControllers.firstObject);
    [UIView animateWithDuration:0.25 animations:^{
        self.customTabBar.alpha = isRoot ? 1.0 : 0.0;
    }];
    self.customTabBar.hidden = NO;
    self.customTabBar.userInteractionEnabled = isRoot;
}

@end
