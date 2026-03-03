//
//  RRVideoOverlayView.m
//  redredvideo
//

#import "RRVideoOverlayView.h"
#import "RRVideoModel.h"

@interface RRVideoOverlayView ()

// 右侧互动按钮
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UILabel *likeLabel;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIButton *shareButton;

// 状态
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) NSInteger currentLikeCount;
@property (nonatomic, strong) UILabel *shareLabel;

// 底部信息
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation RRVideoOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self setupBottomInfo];
        [self setupRightButtons];
    }
    return self;
}

#pragma mark - Setup

- (void)setupBottomInfo {
    // 作者名
    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.textColor = [UIColor whiteColor];
    self.authorLabel.font = [UIFont boldSystemFontOfSize:16];
    self.authorLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.authorLabel.shadowOffset = CGSizeMake(1, 1);
    [self addSubview:self.authorLabel];
    
    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.titleLabel.shadowOffset = CGSizeMake(1, 1);
    [self addSubview:self.titleLabel];
    
    // 描述
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.textColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    self.descLabel.numberOfLines = 2;
    self.descLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.descLabel.shadowOffset = CGSizeMake(1, 1);
    [self addSubview:self.descLabel];
}

- (void)setupRightButtons {
    CGFloat btnSize = 44;
    
    // 点赞
    self.likeButton = [self createButtonWithSystemName:@"heart.fill" action:@selector(likeTapped)];
    self.likeLabel = [self createCountLabel];
    [self addSubview:self.likeButton];
    [self addSubview:self.likeLabel];
    
    // 评论
    self.commentButton = [self createButtonWithSystemName:@"bubble.right.fill" action:@selector(commentTapped)];
    self.commentLabel = [self createCountLabel];
    [self addSubview:self.commentButton];
    [self addSubview:self.commentLabel];
    
    // 分享
    self.shareButton = [self createButtonWithSystemName:@"arrowshape.turn.up.right.fill" action:@selector(shareTapped)];
    self.shareLabel = [self createCountLabel];
    [self addSubview:self.shareButton];
    [self addSubview:self.shareLabel];
}

- (UIButton *)createButtonWithSystemName:(NSString *)name action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:28 weight:UIFontWeightMedium];
    [btn setImage:[UIImage systemImageNamed:name withConfiguration:config] forState:UIControlStateNormal];
    btn.tintColor = [UIColor whiteColor];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    // 阴影效果
    btn.layer.shadowColor = [UIColor blackColor].CGColor;
    btn.layer.shadowOffset = CGSizeMake(0, 1);
    btn.layer.shadowOpacity = 0.5;
    btn.layer.shadowRadius = 2;
    
    return btn;
}

- (UILabel *)createCountLabel {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    label.shadowOffset = CGSizeMake(1, 1);
    return label;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat rightMargin = 12;
    CGFloat btnSize = 44;
    CGFloat btnSpacing = 64; // 按钮间距加大
    
    // 右侧按钮 — 最后一个按钮底部距底80pt
    CGFloat btnX = w - btnSize - rightMargin;
    CGFloat lastBtnBottom = h - 80;
    CGFloat btnStartY = lastBtnBottom - btnSpacing * 2 - btnSize - 18;
    
    self.likeButton.frame = CGRectMake(btnX, btnStartY, btnSize, btnSize);
    self.likeLabel.frame = CGRectMake(btnX, btnStartY + btnSize, btnSize, 18);
    
    self.commentButton.frame = CGRectMake(btnX, btnStartY + btnSpacing, btnSize, btnSize);
    self.commentLabel.frame = CGRectMake(btnX, btnStartY + btnSpacing + btnSize, btnSize, 18);
    
    self.shareButton.frame = CGRectMake(btnX, btnStartY + btnSpacing * 2, btnSize, btnSize);
    self.shareLabel.frame = CGRectMake(btnX, btnStartY + btnSpacing * 2 + btnSize, btnSize, 18);
    
    // 底部文字（往上移，避免被"观看完整短剧"按钮遮挡）
    CGFloat textMaxW = w - btnSize - rightMargin - 32;
    CGFloat bottomY = h - 140; // 给按钮留出空间（按钮高度40 + 间距）
    
    self.authorLabel.frame = CGRectMake(16, bottomY, textMaxW, 22);
    self.titleLabel.frame = CGRectMake(16, bottomY + 24, textMaxW, 20);
    self.descLabel.frame = CGRectMake(16, bottomY + 46, textMaxW, 36);
}

#pragma mark - Configure

- (void)configureWithModel:(RRVideoModel *)model {
    self.authorLabel.text = [NSString stringWithFormat:@"@%@", model.author];
    self.titleLabel.text = model.title;
    self.descLabel.text = model.desc;
    self.currentLikeCount = model.likeCount;
    self.isLiked = NO;
    self.likeButton.tintColor = [UIColor whiteColor];
    self.likeLabel.text = [self formatCount:model.likeCount];
    self.commentLabel.text = [self formatCount:model.commentCount];
    self.shareLabel.text = [self formatCount:model.shareCount];
}

- (NSString *)formatCount:(NSInteger)count {
    if (count >= 10000) {
        return [NSString stringWithFormat:@"%.1fw", count / 10000.0];
    }
    return [NSString stringWithFormat:@"%ld", (long)count];
}

#pragma mark - Actions

- (void)likeTapped {
    self.isLiked = !self.isLiked;
    
    if (self.isLiked) {
        self.currentLikeCount++;
        self.likeButton.tintColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0];
    } else {
        self.currentLikeCount--;
        self.likeButton.tintColor = [UIColor whiteColor];
    }
    
    self.likeLabel.text = [self formatCount:self.currentLikeCount];
    
    // 弹跳动画
    [UIView animateWithDuration:0.15 animations:^{
        self.likeButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.likeButton.transform = CGAffineTransformIdentity;
        }];
    }];
    
    if ([self.delegate respondsToSelector:@selector(overlayViewDidTapLike:)]) {
        [self.delegate overlayViewDidTapLike:self];
    }
}

- (void)commentTapped {
    if ([self.delegate respondsToSelector:@selector(overlayViewDidTapComment:)]) {
        [self.delegate overlayViewDidTapComment:self];
    }
}

- (void)shareTapped {
    if ([self.delegate respondsToSelector:@selector(overlayViewDidTapShare:)]) {
        [self.delegate overlayViewDidTapShare:self];
    }
}

// 只拦截按钮区域的点击，其余透传给底层PlayerView处理暂停/播放
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 检查按钮是否被点击
    NSArray *interactiveViews = @[
        self.likeButton, self.commentButton, self.shareButton
    ];
    for (UIView *view in interactiveViews) {
        CGPoint converted = [self convertPoint:point toView:view];
        // 扩大按钮点击区域
        CGRect hitRect = CGRectInset(view.bounds, -10, -10);
        if (CGRectContainsPoint(hitRect, converted)) {
            return view;
        }
    }
    // 其余区域透传
    return nil;
}

@end
