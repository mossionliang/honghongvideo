//
//  RREpisodePanelView.m
//  redredvideo
//
//  选集面板：从底部弹出的选集选择面板
//

#import "RREpisodePanelView.h"
#import "RREpisodeSelectCell.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>

@interface RREpisodePanelView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray<NSDictionary *> *episodes;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy) NSString *dramaTitle;
@property (nonatomic, copy) NSString *coverURL;

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation RREpisodePanelView

- (instancetype)initWithEpisodes:(NSArray<NSDictionary *> *)episodes 
                    currentIndex:(NSInteger)currentIndex
                      dramaTitle:(NSString *)dramaTitle
                       coverURL:(NSString *)coverURL {
    self = [super init];
    if (self) {
        _episodes = episodes;
        _currentIndex = currentIndex;
        _dramaTitle = dramaTitle;
        _coverURL = coverURL;
    }
    return self;
}

- (void)showInView:(UIView *)view {
    self.frame = view.bounds;
    [view addSubview:self];
    
    [self setupUI];
    
    // 动画显示
    self.overlayView.alpha = 0;
    CGFloat panelH = self.bounds.size.height * 0.65;
    self.panelView.transform = CGAffineTransformMakeTranslation(0, panelH);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.overlayView.alpha = 1.0;
        self.panelView.transform = CGAffineTransformIdentity;
    }];
}

- (void)hide {
    CGFloat panelH = self.bounds.size.height * 0.65;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.overlayView.alpha = 0;
        self.panelView.transform = CGAffineTransformMakeTranslation(0, panelH);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setupUI {
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat panelH = h * 0.65;
    
    // 遮罩
    self.overlayView = [[UIView alloc] init];
    self.overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.overlayView addGestureRecognizer:tap];
    [self addSubview:self.overlayView];
    
    [self.overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // 面板
    self.panelView = [[UIView alloc] init];
    self.panelView.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    self.panelView.layer.cornerRadius = 16;
    self.panelView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.panelView.clipsToBounds = YES;
    [self addSubview:self.panelView];
    
    [self.panelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(panelH);
    }];
    
    // 顶部拖拽指示条
    UIView *handle = [[UIView alloc] init];
    handle.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    handle.layer.cornerRadius = 2;
    [self.panelView addSubview:handle];
    
    [handle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.panelView).offset(8);
        make.centerX.equalTo(self.panelView);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(4);
    }];
    
    // 封面
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.layer.cornerRadius = 6;
    self.coverImageView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.panelView addSubview:self.coverImageView];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.panelView).offset(16);
        make.top.equalTo(handle.mas_bottom).offset(16);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(66);
    }];
    
    if (self.coverURL.length > 0) {
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.coverURL]];
    }
    
    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.dramaTitle;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.panelView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(10);
        make.top.equalTo(self.coverImageView).offset(8);
        make.right.equalTo(self.panelView).offset(-16);
    }];
    
    // 信息
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.text = [NSString stringWithFormat:@"共%lu集", (unsigned long)self.episodes.count];
    self.infoLabel.font = [UIFont systemFontOfSize:13];
    self.infoLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    [self.panelView addSubview:self.infoLabel];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(6);
    }];
    
    // 选集标题
    UILabel *selectLabel = [[UILabel alloc] init];
    selectLabel.text = @"选集";
    selectLabel.font = [UIFont boldSystemFontOfSize:16];
    selectLabel.textColor = [UIColor whiteColor];
    [self.panelView addSubview:selectLabel];
    
    [selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.panelView).offset(16);
        make.top.equalTo(self.coverImageView.mas_bottom).offset(16);
    }];
    
    // 分集网格
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 8;
    layout.sectionInset = UIEdgeInsetsMake(0, 16, 20, 16);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[RREpisodeSelectCell class] forCellWithReuseIdentifier:@"EpCell"];
    [self.panelView addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.panelView);
        make.top.equalTo(selectLabel.mas_bottom).offset(12);
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.episodes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RREpisodeSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EpCell" forIndexPath:indexPath];
    
    NSDictionary *ep = self.episodes[indexPath.item];
    id episodeNumObj = ep[@"episode_number"];
    NSString *episodeNum = nil;
    
    if ([episodeNumObj isKindOfClass:[NSString class]]) {
        episodeNum = episodeNumObj;
    } else if ([episodeNumObj isKindOfClass:[NSNumber class]]) {
        episodeNum = [episodeNumObj stringValue];
    } else {
        episodeNum = [NSString stringWithFormat:@"%ld", (long)(indexPath.item + 1)];
    }
    
    cell.numberLabel.text = episodeNum;
    cell.playingIcon.hidden = YES; // 投屏控制页面不显示播放图标
    
    BOOL isCurrent = (indexPath.item == self.currentIndex);
    if (isCurrent) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
        cell.numberLabel.textColor = [UIColor whiteColor];
        cell.contentView.layer.borderWidth = 0;
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        cell.numberLabel.textColor = [UIColor whiteColor];
        cell.contentView.layer.borderWidth = 0;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = (self.bounds.size.width - 16 * 2 - 8 * 4) / 5.0;
    return CGSizeMake(w, 40);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(episodePanelDidSelectEpisodeAtIndex:)]) {
        [self.delegate episodePanelDidSelectEpisodeAtIndex:indexPath.item];
    }
    
    [self hide];
}

@end
