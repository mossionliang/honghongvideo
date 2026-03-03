//
//  RRDramaCell.m
//  redredvideo
//

#import "RRDramaCell.h"
#import "RRDramaModel.h"
#import <SDWebImage/SDWebImage.h>

#pragma mark - RRDramaVerticalCell

@interface RRDramaVerticalCell ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UIView *vipBadge;

@end

@implementation RRDramaVerticalCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.contentView.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.15 alpha:1.0];
    self.contentView.layer.cornerRadius = 8;
    self.contentView.clipsToBounds = YES;
    
    // 封面
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.contentView addSubview:self.coverImageView];
    
    // 评分
    self.scoreLabel = [[UILabel alloc] init];
    self.scoreLabel.textColor = [UIColor colorWithRed:1.0 green:0.85 blue:0.3 alpha:1.0];
    self.scoreLabel.font = [UIFont boldSystemFontOfSize:11];
    self.scoreLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreLabel.layer.cornerRadius = 4;
    self.scoreLabel.clipsToBounds = YES;
    [self.contentView addSubview:self.scoreLabel];
    
    // VIP标记
    self.vipBadge = [[UIView alloc] init];
    self.vipBadge.backgroundColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0];
    self.vipBadge.layer.cornerRadius = 3;
    self.vipBadge.hidden = YES;
    [self.contentView addSubview:self.vipBadge];
    
    UILabel *vipLabel = [[UILabel alloc] init];
    vipLabel.text = @"VIP";
    vipLabel.textColor = [UIColor whiteColor];
    vipLabel.font = [UIFont boldSystemFontOfSize:9];
    vipLabel.tag = 100;
    [self.vipBadge addSubview:vipLabel];
    
    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.titleLabel.numberOfLines = 1;
    [self.contentView addSubview:self.titleLabel];
    
    // 信息（集数/热度）
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    self.infoLabel.font = [UIFont systemFontOfSize:11];
    [self.contentView addSubview:self.infoLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = self.contentView.bounds.size.width;
    CGFloat coverH = w * 1.35; // 竖版封面比例
    
    self.coverImageView.frame = CGRectMake(0, 0, w, coverH);
    self.scoreLabel.frame = CGRectMake(w - 38, 6, 34, 18);
    self.vipBadge.frame = CGRectMake(6, 6, 28, 16);
    
    UILabel *vipLabel = [self.vipBadge viewWithTag:100];
    vipLabel.frame = CGRectMake(4, 1, 20, 14);
    
    self.titleLabel.frame = CGRectMake(6, coverH + 6, w - 12, 18);
    self.infoLabel.frame = CGRectMake(6, coverH + 24, w - 12, 16);
}

- (void)configureWithModel:(RRDramaModel *)model {
    self.titleLabel.text = model.title;
    self.scoreLabel.text = [NSString stringWithFormat:@"%.1f", model.score];
    self.vipBadge.hidden = !model.isVip;
    
    if (model.isFinished) {
        self.infoLabel.text = [NSString stringWithFormat:@"全%ld集 · %@", (long)model.totalEpisodes, [self formatCount:model.playCount]];
    } else {
        self.infoLabel.text = [NSString stringWithFormat:@"更新至%ld集 · %@", (long)model.updateEpisode, [self formatCount:model.playCount]];
    }
    
    // 加载封面图
    if (model.coverUrl.length > 0) {
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.coverUrl]
                               placeholderImage:nil
                                        options:SDWebImageRetryFailed];
    } else {
        self.coverImageView.image = nil;
        NSArray *colors = @[
            [UIColor colorWithRed:0.6 green:0.2 blue:0.3 alpha:1.0],
            [UIColor colorWithRed:0.2 green:0.3 blue:0.5 alpha:1.0],
            [UIColor colorWithRed:0.3 green:0.2 blue:0.5 alpha:1.0],
        ];
        self.coverImageView.backgroundColor = colors[arc4random_uniform((uint32_t)colors.count)];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.coverImageView sd_cancelCurrentImageLoad];
    self.coverImageView.image = nil;
}

- (NSString *)formatCount:(NSInteger)count {
    if (count >= 100000000) {
        return [NSString stringWithFormat:@"%.1f亿播放", count / 100000000.0];
    } else if (count >= 10000) {
        return [NSString stringWithFormat:@"%.1f万播放", count / 10000.0];
    }
    return [NSString stringWithFormat:@"%ld播放", (long)count];
}

@end

#pragma mark - RRDramaHorizontalCell

@interface RRDramaHorizontalCell ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tagLabel;

@end

@implementation RRDramaHorizontalCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.contentView.layer.cornerRadius = 8;
    self.contentView.clipsToBounds = YES;
    
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.contentView addSubview:self.coverImageView];
    
    // 底部渐变遮罩
    UIView *gradient = [[UIView alloc] init];
    gradient.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    gradient.tag = 200;
    [self.contentView addSubview:gradient];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    self.titleLabel.numberOfLines = 1;
    [self.contentView addSubview:self.titleLabel];
    
    self.tagLabel = [[UILabel alloc] init];
    self.tagLabel.textColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0];
    self.tagLabel.font = [UIFont systemFontOfSize:10];
    self.tagLabel.backgroundColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:0.15];
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
    self.tagLabel.layer.cornerRadius = 3;
    self.tagLabel.clipsToBounds = YES;
    [self.contentView addSubview:self.tagLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = self.contentView.bounds.size.width;
    CGFloat h = self.contentView.bounds.size.height;
    
    self.coverImageView.frame = self.contentView.bounds;
    
    UIView *gradient = [self.contentView viewWithTag:200];
    gradient.frame = CGRectMake(0, h - 50, w, 50);
    
    self.titleLabel.frame = CGRectMake(8, h - 40, w - 16, 18);
    self.tagLabel.frame = CGRectMake(8, h - 20, 40, 16);
}

- (void)configureWithModel:(RRDramaModel *)model {
    self.titleLabel.text = model.title;
    self.tagLabel.text = model.category;
    [self.tagLabel sizeToFit];
    CGRect f = self.tagLabel.frame;
    f.size.width += 12;
    f.size.height = 16;
    self.tagLabel.frame = f;
    
    // 加载封面图
    if (model.coverUrl.length > 0) {
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.coverUrl]
                               placeholderImage:nil
                                        options:SDWebImageRetryFailed];
    } else {
        self.coverImageView.image = nil;
        NSArray *colors = @[
            [UIColor colorWithRed:0.5 green:0.15 blue:0.25 alpha:1.0],
            [UIColor colorWithRed:0.15 green:0.25 blue:0.45 alpha:1.0],
            [UIColor colorWithRed:0.25 green:0.15 blue:0.45 alpha:1.0],
        ];
        self.coverImageView.backgroundColor = colors[arc4random_uniform((uint32_t)colors.count)];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.coverImageView sd_cancelCurrentImageLoad];
    self.coverImageView.image = nil;
}

@end

@interface RRDramaRankCell ()

@property (nonatomic, strong) UILabel *rankLabel;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *hotLabel;

@end

@implementation RRDramaRankCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 排名
    self.rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 20, 30, 30)];
    self.rankLabel.font = [UIFont boldSystemFontOfSize:18];
    self.rankLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.rankLabel];
    
    // 封面
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 8, 54, 72)];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.layer.cornerRadius = 6;
    self.coverImageView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.contentView addSubview:self.coverImageView];
    
    // 标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(114, 12, 200, 20)];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [self.contentView addSubview:self.titleLabel];
    
    // 描述
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(114, 34, 200, 16)];
    self.descLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    self.descLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.descLabel];
    
    // 热度
    self.hotLabel = [[UILabel alloc] initWithFrame:CGRectMake(114, 54, 200, 16)];
    self.hotLabel.textColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:0.8];
    self.hotLabel.font = [UIFont systemFontOfSize:11];
    [self.contentView addSubview:self.hotLabel];
}

- (void)configureWithModel:(RRDramaModel *)model rank:(NSInteger)rank {
    self.titleLabel.text = model.title;
    self.descLabel.text = [NSString stringWithFormat:@"%@ · 全%ld集", model.category, (long)model.totalEpisodes];
    self.hotLabel.text = [NSString stringWithFormat:@"🔥 热度 %ld", (long)model.hotCount];
    
    // 排名样式
    if (rank <= 3) {
        NSArray *colors = @[
            [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0],  // 第1
            [UIColor colorWithRed:1.0 green:0.6 blue:0.2 alpha:1.0],  // 第2
            [UIColor colorWithRed:1.0 green:0.85 blue:0.3 alpha:1.0], // 第3
        ];
        self.rankLabel.textColor = colors[rank - 1];
    } else {
        self.rankLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    }
    self.rankLabel.text = [NSString stringWithFormat:@"%ld", (long)rank];
    
    // 加载封面图
    if (model.coverUrl.length > 0) {
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.coverUrl]
                               placeholderImage:nil
                                        options:SDWebImageRetryFailed];
    } else {
        self.coverImageView.image = nil;
        NSArray *colors = @[
            [UIColor colorWithRed:0.5 green:0.15 blue:0.25 alpha:1.0],
            [UIColor colorWithRed:0.15 green:0.25 blue:0.45 alpha:1.0],
            [UIColor colorWithRed:0.25 green:0.15 blue:0.45 alpha:1.0],
        ];
        self.coverImageView.backgroundColor = colors[arc4random_uniform((uint32_t)colors.count)];
    }
}

@end
