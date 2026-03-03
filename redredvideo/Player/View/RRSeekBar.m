//
//  RRSeekBar.m
//  redredvideo
//

#import "RRSeekBar.h"

static const CGFloat kNormalHeight = 3.0;
static const CGFloat kExpandedHeight = 6.0;
static const CGFloat kThumbSize = 12.0;

@interface RRSeekBar ()

@property (nonatomic, strong) UIView *trackView;      // 底部轨道
@property (nonatomic, strong) UIView *bufferView;     // 缓冲进度
@property (nonatomic, strong) UIView *progressView;   // 播放进度
@property (nonatomic, strong) UIView *thumbView;      // 拖动圆点
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) CGFloat currentBarHeight;

@end

@implementation RRSeekBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.currentBarHeight = kNormalHeight;
        [self setupUI];
        [self setupGestures];
    }
    return self;
}

- (void)setupUI {
    // 底部轨道（灰色）
    self.trackView = [[UIView alloc] init];
    self.trackView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.trackView.layer.cornerRadius = kNormalHeight / 2;
    [self addSubview:self.trackView];
    
    // 缓冲进度（浅灰）
    self.bufferView = [[UIView alloc] init];
    self.bufferView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    self.bufferView.layer.cornerRadius = kNormalHeight / 2;
    [self addSubview:self.bufferView];
    
    // 播放进度（红色）
    self.progressView = [[UIView alloc] init];
    self.progressView.backgroundColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0];
    self.progressView.layer.cornerRadius = kNormalHeight / 2;
    [self addSubview:self.progressView];
    
    // 拖动圆点（默认隐藏，按下时显示）
    self.thumbView = [[UIView alloc] init];
    self.thumbView.backgroundColor = [UIColor whiteColor];
    self.thumbView.layer.cornerRadius = kThumbSize / 2;
    self.thumbView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.thumbView.layer.shadowOffset = CGSizeMake(0, 1);
    self.thumbView.layer.shadowOpacity = 0.3;
    self.thumbView.layer.shadowRadius = 2;
    self.thumbView.hidden = YES;
    self.thumbView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [self addSubview:self.thumbView];
}

- (void)setupGestures {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.05; // 快速响应
    [self addGestureRecognizer:longPress];
    
    [pan requireGestureRecognizerToFail:tap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateBarLayout];
}

- (void)updateBarLayout {
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat barH = self.currentBarHeight;
    CGFloat barY = (h - barH) / 2;
    
    self.trackView.frame = CGRectMake(0, barY, w, barH);
    self.trackView.layer.cornerRadius = barH / 2;
    
    CGFloat bufferW = w * self.bufferProgress;
    self.bufferView.frame = CGRectMake(0, barY, bufferW, barH);
    self.bufferView.layer.cornerRadius = barH / 2;
    
    CGFloat progressW = w * self.progress;
    self.progressView.frame = CGRectMake(0, barY, progressW, barH);
    self.progressView.layer.cornerRadius = barH / 2;
    
    // 圆点在进度条末端
    CGFloat thumbX = progressW - kThumbSize / 2;
    thumbX = MAX(-kThumbSize / 2, MIN(thumbX, w - kThumbSize / 2));
    self.thumbView.frame = CGRectMake(thumbX, (h - kThumbSize) / 2, kThumbSize, kThumbSize);
}

#pragma mark - Setters

- (void)setProgress:(float)progress {
    if (self.isDragging) return; // 拖动中不接受外部更新
    _progress = MAX(0, MIN(1, progress));
    [self updateBarLayout];
}

- (void)setBufferProgress:(float)bufferProgress {
    _bufferProgress = MAX(0, MIN(1, bufferProgress));
    [self updateBarLayout];
}

#pragma mark - Expand / Collapse

- (void)expandBar {
    self.thumbView.hidden = NO;
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
        self.currentBarHeight = kExpandedHeight;
        self.thumbView.transform = CGAffineTransformIdentity;
        [self updateBarLayout];
    } completion:nil];
}

- (void)collapseBar {
    [UIView animateWithDuration:0.25 animations:^{
        self.currentBarHeight = kNormalHeight;
        self.thumbView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [self updateBarLayout];
    } completion:^(BOOL finished) {
        self.thumbView.hidden = YES;
    }];
}

#pragma mark - Gestures

- (float)progressForLocation:(CGPoint)location {
    CGFloat x = location.x;
    float p = x / self.bounds.size.width;
    return MAX(0, MIN(1, p));
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    CGPoint loc = [gesture locationInView:self];
    float p = [self progressForLocation:loc];
    _progress = p;
    [self updateBarLayout];
    
    // 短暂展示圆点
    [self expandBar];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.isDragging) {
            [self collapseBar];
        }
    });
    
    if ([self.delegate respondsToSelector:@selector(seekBar:didEndSeekAtProgress:)]) {
        [self.delegate seekBar:self didEndSeekAtProgress:p];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint loc = [gesture locationInView:self];
    float p = [self progressForLocation:loc];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.isDragging = YES;
            [self expandBar];
            if ([self.delegate respondsToSelector:@selector(seekBarDidBeginDragging:)]) {
                [self.delegate seekBarDidBeginDragging:self];
            }
            // fall through
        case UIGestureRecognizerStateChanged:
            _progress = p;
            [self updateBarLayout];
            if ([self.delegate respondsToSelector:@selector(seekBar:didSeekToProgress:)]) {
                [self.delegate seekBar:self didSeekToProgress:p];
            }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.isDragging = NO;
            [self collapseBar];
            if ([self.delegate respondsToSelector:@selector(seekBar:didEndSeekAtProgress:)]) {
                [self.delegate seekBar:self didEndSeekAtProgress:p];
            }
            break;
        default:
            break;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (!self.isDragging) {
            [self expandBar];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (!self.isDragging) {
            [self collapseBar];
        }
    }
}

// 扩大触摸区域
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect hitArea = CGRectInset(self.bounds, 0, -15);
    return CGRectContainsPoint(hitArea, point);
}

@end
