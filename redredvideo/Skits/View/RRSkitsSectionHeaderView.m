//
//  RRSkitsSectionHeaderView.m
//  redredvideo
//

#import "RRSkitsSectionHeaderView.h"

@interface RRSkitsSectionHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *moreButton;

@end

@implementation RRSkitsSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self addSubview:self.titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(16, 8, 200, 28);
    self.moreButton.frame = CGRectMake(self.bounds.size.width - 80, 8, 64, 28);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)moreButtonTapped {
    if (self.moreTapped) {
        self.moreTapped();
    }
}

@end
