//
//  RRBannerView.m
//  redredvideo
//

#import "RRBannerView.h"
#import "RRDramaModel.h"
#import <SDWebImage/SDWebImage.h>

@interface RRBannerView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation RRBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.1 alpha:1.0];
    
    // ScrollView
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.layer.cornerRadius = 12;
    self.scrollView.clipsToBounds = YES;
    [self addSubview:self.scrollView];
    
    // PageControl
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    [self addSubview:self.pageControl];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat padding = 16;
    CGFloat scrollW = self.bounds.size.width - padding * 2;
    CGFloat scrollH = self.bounds.size.height - 20;
    
    self.scrollView.frame = CGRectMake(padding, 0, scrollW, scrollH);
    self.pageControl.frame = CGRectMake(0, scrollH, self.bounds.size.width, 20);
    
    [self reloadBanners];
}

- (void)setBanners:(NSArray<RRBannerModel *> *)banners {
    _banners = banners;
    self.pageControl.numberOfPages = banners.count;
    self.pageControl.currentPage = 0;
    [self reloadBanners];
}

- (void)reloadBanners {
    // 移除旧的子视图
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    CGFloat w = self.scrollView.bounds.size.width;
    CGFloat h = self.scrollView.bounds.size.height;
    
    if (w <= 0 || h <= 0) return;
    
    for (NSInteger i = 0; i < self.banners.count; i++) {
        RRBannerModel *banner = self.banners[i];
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(i * w, 0, w, h)];
        
        // 封面图
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:container.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        if (banner.imageUrl.length > 0) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:banner.imageUrl]
                         placeholderImage:nil
                                  options:SDWebImageRetryFailed];
        } else {
            NSArray *colors = @[
                [UIColor colorWithRed:0.8 green:0.2 blue:0.3 alpha:1.0],
                [UIColor colorWithRed:0.3 green:0.15 blue:0.4 alpha:1.0],
                [UIColor colorWithRed:0.15 green:0.3 blue:0.5 alpha:1.0],
            ];
            imageView.backgroundColor = colors[i % colors.count];
        }
        [container addSubview:imageView];
        
        // 底部渐变遮罩（让文字更清晰）
        UIView *gradientOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, h * 0.5, w, h * 0.5)];
        gradientOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [container addSubview:gradientOverlay];
        
        // 标题
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = banner.title;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.numberOfLines = 2;
        titleLabel.frame = CGRectMake(16, h - 60, w - 32, 50);
        titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
        titleLabel.shadowOffset = CGSizeMake(1, 1);
        [container addSubview:titleLabel];
        
        // 点击手势
        container.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
        [container addGestureRecognizer:tap];
        
        [self.scrollView addSubview:container];
    }
    
    self.scrollView.contentSize = CGSizeMake(w * self.banners.count, h);
}

- (void)bannerTapped:(UITapGestureRecognizer *)tap {
    NSInteger index = tap.view.tag;
    if ([self.delegate respondsToSelector:@selector(bannerView:didSelectAtIndex:)]) {
        [self.delegate bannerView:self didSelectAtIndex:index];
    }
}

#pragma mark - Auto Scroll

- (void)startAutoScroll {
    [self stopAutoScroll];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(autoScrollNext) userInfo:nil repeats:YES];
}

- (void)stopAutoScroll {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)autoScrollNext {
    CGFloat w = self.scrollView.bounds.size.width;
    if (w <= 0 || self.banners.count == 0) return;
    
    NSInteger currentPage = (NSInteger)(self.scrollView.contentOffset.x / w);
    NSInteger nextPage = (currentPage + 1) % self.banners.count;
    [self.scrollView setContentOffset:CGPointMake(nextPage * w, 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat w = scrollView.bounds.size.width;
    if (w <= 0) return;
    NSInteger page = (NSInteger)((scrollView.contentOffset.x + w * 0.5) / w);
    self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopAutoScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self startAutoScroll];
}

@end
