//
//  RRCategoryBarView.m
//  redredvideo
//

#import "RRCategoryBarView.h"
#import "RRDramaModel.h"

@interface RRCategoryBarView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation RRCategoryBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 12;
    layout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
    layout.itemSize = CGSizeMake(64, 80);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CategoryCell"];
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

- (void)setCategories:(NSArray<RRCategoryModel *> *)categories {
    _categories = categories;
    [self.collectionView reloadData];
}

- (void)setSelectedCategoryId:(NSString *)selectedCategoryId {
    _selectedCategoryId = selectedCategoryId;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell" forIndexPath:indexPath];
    
    // 清除旧内容
    for (UIView *sub in cell.contentView.subviews) {
        [sub removeFromSuperview];
    }
    
    RRCategoryModel *cat = self.categories[indexPath.item];
    
    // 判断是否选中
    BOOL isSelected = NO;
    if (self.selectedCategoryId == nil || [self.selectedCategoryId isEqualToString:@"0"]) {
        // 未选择或选择"全部"，默认选中第一个（全部）
        isSelected = (indexPath.item == 0);
    } else {
        isSelected = [cat.categoryId isEqualToString:self.selectedCategoryId];
    }
    
    // 图标容器（圆形背景）
    UIView *iconBg = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 44, 44)];
    if (isSelected) {
        iconBg.backgroundColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0];
    } else {
        iconBg.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.2 alpha:1.0];
    }
    iconBg.layer.cornerRadius = 22;
    [cell.contentView addSubview:iconBg];
    
    // 图标 Emoji
    UILabel *iconLabel = [[UILabel alloc] initWithFrame:iconBg.bounds];
    iconLabel.textAlignment = NSTextAlignmentCenter;
    iconLabel.font = [UIFont systemFontOfSize:22];
    
    // 根据分类名设置对应emoji
    NSDictionary *emojiMap = @{
        @"甜宠": @"💕", @"逆袭": @"🔥", @"悬疑": @"🔍",
        @"都市": @"🏙️", @"古装": @"👘", @"奇幻": @"✨",
        @"搞笑": @"😂", @"虐恋": @"💔", @"穿越": @"⏳",
        @"战神": @"⚔️", @"全部": @"📋"
    };
    iconLabel.text = emojiMap[cat.name] ?: @"🎬";
    [iconBg addSubview:iconLabel];
    
    // 分类名
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 64, 20)];
    nameLabel.text = cat.name;
    if (isSelected) {
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:12];
    } else {
        nameLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        nameLabel.font = [UIFont systemFontOfSize:12];
    }
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:nameLabel];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RRCategoryModel *cat = self.categories[indexPath.item];
    if ([self.delegate respondsToSelector:@selector(categoryBarView:didSelectCategory:)]) {
        [self.delegate categoryBarView:self didSelectCategory:cat];
    }
}

@end
