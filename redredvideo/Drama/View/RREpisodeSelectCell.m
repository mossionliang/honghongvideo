//
//  RREpisodeSelectCell.m
//  redredvideo
//
//  选集Cell
//

#import "RREpisodeSelectCell.h"

@implementation RREpisodeSelectCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
        self.contentView.layer.cornerRadius = 6;
        self.contentView.clipsToBounds = YES;
        
        self.numberLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        self.numberLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        self.numberLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.numberLabel];
        
        self.playingIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"waveform"]];
        self.playingIcon.tintColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.2 alpha:1.0];
        self.playingIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.playingIcon.hidden = YES;
        [self.contentView addSubview:self.playingIcon];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.contentView.bounds.size.width;
    self.playingIcon.frame = CGRectMake(w - 18, 2, 14, 14);
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateStyle];
}

- (void)updateStyle {
    // 由外部通过 tag 控制
}

- (void)configureWithNumber:(NSInteger)number isPlaying:(BOOL)isPlaying isFree:(BOOL)isFree {
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)number];
    self.playingIcon.hidden = !isPlaying;
    
    if (isPlaying) {
        self.contentView.backgroundColor = [UIColor colorWithRed:1.0 green:0.95 blue:0.9 alpha:1.0];
        self.contentView.layer.borderWidth = 1.5;
        self.contentView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.2 alpha:1.0].CGColor;
        self.numberLabel.textColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.2 alpha:1.0];
    } else {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
        self.contentView.layer.borderWidth = 0;
        self.numberLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    }
}

@end
