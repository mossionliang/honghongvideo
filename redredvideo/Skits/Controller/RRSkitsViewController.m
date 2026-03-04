//
//  RRSkitsViewController.m
//  redredvideo
//
//  短剧控制器 - 短剧频道首页
//  数据来源：后台 API
//    - GET /api/dramas/meta/categories → 分类列表
//    - GET /api/dramas?category_id=X   → 剧集列表
//

#import "RRSkitsViewController.h"
#import "RRDramaModel.h"
#import "RRBannerView.h"
#import "RRCategoryBarView.h"
#import "RRDramaCell.h"
#import "RRSkitsSectionHeaderView.h"
#import "RRNetworkManager.h"
#import "RRDramaDetailViewController.h"
#import <MJRefresh/MJRefresh.h>

@interface RRSkitsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RRBannerViewDelegate, RRCategoryBarViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

// 数据源
@property (nonatomic, strong) NSArray<RRBannerModel *> *banners;
@property (nonatomic, strong) NSMutableArray<RRCategoryModel *> *categories;
@property (nonatomic, strong) NSMutableArray<RRDramaModel *> *dramaList;

// 分页 & 筛选
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy) NSString *selectedCategoryId;  // 当前选中分类，nil或"0"=全部

// 失败页面
@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIButton *retryButton;

@end

static NSString * const kVerticalCellId = @"VerticalCell";
static NSString * const kHorizontalCellId = @"HorizontalCell";
static NSString * const kHeaderId = @"SectionHeader";
static NSString * const kBannerCellId = @"BannerCell";
static NSString * const kCategoryCellId = @"CategoryCell";

@implementation RRSkitsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.08 alpha:1.0];
    
    self.dramaList = [NSMutableArray array];
    self.categories = [NSMutableArray array];
    self.currentPage = 1;
    self.hasMore = YES;
    self.isLoading = NO;
    self.selectedCategoryId = nil;
    
    [self setupNavigation];
    [self setupCollectionView];
    [self setupErrorView];
    [self setupNetworkMonitoring];
    
    // 加载分类 + 剧集
    [self fetchCategories];
    [self fetchDramas];
}

#pragma mark - Setup

- (void)setupNavigation {
    self.navigationItem.title = @"短剧";
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 12;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(0, 16, 20, 16);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    [self.collectionView registerClass:[RRDramaVerticalCell class] forCellWithReuseIdentifier:kVerticalCellId];
    [self.collectionView registerClass:[RRDramaHorizontalCell class] forCellWithReuseIdentifier:kHorizontalCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBannerCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCategoryCellId];
    [self.collectionView registerClass:[RRSkitsSectionHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kHeaderId];
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
    // 下拉刷新
    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshData];
    }];
    
    // 上拉加载更多
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMore];
    }];
    self.collectionView.mj_footer.hidden = YES;
}

- (void)setupErrorView {
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    
    self.errorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.errorView.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.08 alpha:1.0];
    self.errorView.hidden = YES;
    [self.view addSubview:self.errorView];
    
    // 错误图标
    UIImageView *errorIcon = [[UIImageView alloc] init];
    UIImage *icon = [UIImage systemImageNamed:@"wifi.slash" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:60 weight:UIFontWeightLight]];
    errorIcon.image = icon;
    errorIcon.tintColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    errorIcon.frame = CGRectMake((w - 80) / 2, h / 2 - 120, 80, 80);
    [self.errorView addSubview:errorIcon];
    
    // 错误文字
    self.errorLabel = [[UILabel alloc] init];
    self.errorLabel.text = @"网络连接失败";
    self.errorLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    self.errorLabel.font = [UIFont systemFontOfSize:16];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.frame = CGRectMake(20, h / 2 - 20, w - 40, 24);
    [self.errorView addSubview:self.errorLabel];
    
    // 重试按钮
    self.retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.retryButton setTitle:@"点击重试" forState:UIControlStateNormal];
    [self.retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.retryButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.retryButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0];
    self.retryButton.layer.cornerRadius = 22;
    self.retryButton.frame = CGRectMake((w - 120) / 2, h / 2 + 20, 120, 44);
    [self.retryButton addTarget:self action:@selector(retryLoad) forControlEvents:UIControlEventTouchUpInside];
    [self.errorView addSubview:self.retryButton];
}

- (void)setupNetworkMonitoring {
    // 定时检查网络状态（如果当前显示错误页面）
    [self scheduleNetworkCheck];
}

- (void)scheduleNetworkCheck {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        // 如果当前显示错误页面，尝试重新请求
        if (!self.errorView.hidden && self.dramaList.count == 0) {
            NSLog(@"[Skits] 定时检查网络，尝试重新加载");
            [self retryLoad];
        } else if (!self.errorView.hidden) {
            // 继续检查
            [self scheduleNetworkCheck];
        }
    });
}

- (void)retryLoad {
    self.errorView.hidden = YES;
    self.currentPage = 1;
    [self.dramaList removeAllObjects];
    [self.collectionView reloadData];
    [self fetchCategories];
    [self fetchDramas];
}

#pragma mark - API 请求

- (void)fetchCategories {
    [[RRNetworkManager shared] GET:@"/api/dramas/meta/categories"
                            params:nil
                           success:^(NSDictionary *responseDict) {
        NSArray *list = responseDict[@"data"];
        if (![list isKindOfClass:[NSArray class]]) return;
        
        [self.categories removeAllObjects];
        
        // 添加"全部"选项
        RRCategoryModel *allCat = [RRCategoryModel modelWithDict:@{
            @"category_id": @"0", @"name": @"全部"
        }];
        [self.categories addObject:allCat];
        
        // API 返回的分类
        for (NSDictionary *dict in list) {
            RRCategoryModel *cat = [RRCategoryModel modelWithDict:@{
                @"category_id": [NSString stringWithFormat:@"%@", dict[@"id"]],
                @"name": dict[@"name"] ?: @"",
                @"icon_url": dict[@"icon"] ?: @"",
            }];
            [self.categories addObject:cat];
        }
        
        // 刷新分类栏
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        
    } failure:^(NSError *error) {
        NSLog(@"[Skits] 加载分类失败: %@", error.localizedDescription);
    }];
}

- (void)fetchDramas {
    if (self.isLoading) return;
    self.isLoading = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page"] = @(self.currentPage);
    params[@"pageSize"] = @(20);
    
    if (self.selectedCategoryId && ![self.selectedCategoryId isEqualToString:@"0"]) {
        params[@"category_id"] = self.selectedCategoryId;
    }
    
    [[RRNetworkManager shared] GET:@"/api/dramas"
                            params:params
                           success:^(NSDictionary *responseDict) {
        self.isLoading = NO;
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        
        NSDictionary *data = responseDict[@"data"];
        NSArray *list = data[@"list"];
        NSInteger total = [data[@"total"] integerValue];
        
        if (![list isKindOfClass:[NSArray class]]) return;
        
        NSString *baseURL = [RRNetworkManager shared].baseURL;
        NSArray<RRDramaModel *> *newDramas = [RRDramaModel modelsFromAPIList:list baseURL:baseURL];
        
        if (self.currentPage == 1) {
            [self.dramaList removeAllObjects];
            [self.dramaList addObjectsFromArray:newDramas];
            
            [self.collectionView reloadData];
        } else {
            NSInteger oldCount = self.dramaList.count;
            [self.dramaList addObjectsFromArray:newDramas];
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (NSInteger i = oldCount; i < self.dramaList.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:1]];
            }
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
        }
        
        self.hasMore = self.dramaList.count < total;
        self.collectionView.mj_footer.hidden = !self.hasMore;
        if (!self.hasMore) {
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        }
        
        // 隐藏错误页面
        self.errorView.hidden = YES;
        
        NSLog(@"[Skits] 加载完成 page=%ld, 新增%lu, 总%lu/%ld",
              (long)self.currentPage, (unsigned long)newDramas.count,
              (unsigned long)self.dramaList.count, (long)total);
        
    } failure:^(NSError *error) {
        self.isLoading = NO;
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        NSLog(@"[Skits] 加载失败: %@", error.localizedDescription);
        
        // 首次加载失败，显示错误页面
        if (self.dramaList.count == 0) {
            self.errorView.hidden = NO;
        }
    }];
}

- (void)buildBannersFromDramas {
    NSMutableArray *bannerModels = [NSMutableArray array];
    NSArray *prefixes = @[@"🔥", @"✨", @"💕"];
    NSArray *suffixes = @[@"热播中", @"新上线", @"人气爆棚"];
    
    NSInteger count = MIN(3, self.dramaList.count);
    for (NSInteger i = 0; i < count; i++) {
        RRDramaModel *drama = self.dramaList[i];
        NSString *title = [NSString stringWithFormat:@"%@ %@ %@",
                          prefixes[i % prefixes.count],
                          drama.title,
                          suffixes[i % suffixes.count]];
        RRBannerModel *banner = [RRBannerModel modelWithDict:@{
            @"banner_id": drama.dramaId,
            @"title": title,
            @"image_url": drama.bannerUrl ?: drama.coverUrl ?: @"",
        }];
        [bannerModels addObject:banner];
    }
    self.banners = [bannerModels copy];
}

- (void)refreshData {
    self.currentPage = 1;
    self.hasMore = YES;
    [self.collectionView.mj_footer resetNoMoreData];
    [self fetchCategories];
    [self fetchDramas];
}

- (void)loadMore {
    if (!self.hasMore || self.isLoading) return;
    self.currentPage++;
    [self fetchDramas];
}

#pragma mark - Actions

- (void)searchTapped {
    NSLog(@"搜索被点击");
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // Section 0: 分类导航
    // Section 1: 剧集列表
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) return 1;  // 分类导航
    return self.dramaList.count;  // 剧集
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 分类导航
    if (indexPath.section == 0) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCategoryCellId forIndexPath:indexPath];
        for (UIView *sub in cell.contentView.subviews) [sub removeFromSuperview];
        
        RRCategoryBarView *categoryBar = [[RRCategoryBarView alloc] initWithFrame:cell.contentView.bounds];
        categoryBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        categoryBar.delegate = self;
        categoryBar.categories = [self.categories copy];
        categoryBar.selectedCategoryId = self.selectedCategoryId;
        [cell.contentView addSubview:categoryBar];
        return cell;
    }
    
    // 剧集列表（三列网格）
    RRDramaVerticalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVerticalCellId forIndexPath:indexPath];
    [cell configureWithModel:self.dramaList[indexPath.item]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    RRSkitsSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                        withReuseIdentifier:kHeaderId
                                                                               forIndexPath:indexPath];
    if (indexPath.section == 1) {
        header.title = @"🔥 全部短剧";
        header.moreTapped = nil;
    } else {
        header.title = @"";
    }
    
    return header;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat screenWidth = collectionView.bounds.size.width;
    CGFloat contentWidth = screenWidth - 32;
    
    if (indexPath.section == 0) return CGSizeMake(screenWidth, 90);
    
    // 三列网格
    CGFloat itemWidth = (contentWidth - 20) / 3.0;
    CGFloat itemHeight = itemWidth * 1.35 + 44;
    return CGSizeMake(itemWidth, itemHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section < 1) return CGSizeMake(collectionView.bounds.size.width, 8);
    return CGSizeMake(collectionView.bounds.size.width, 44);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 1) return;
    
    RRDramaModel *drama = self.dramaList[indexPath.item];
    NSLog(@"点击短剧: %@ (id=%@)", drama.title, drama.dramaId);
    
    RRDramaDetailViewController *detailVC = [[RRDramaDetailViewController alloc] init];
    detailVC.dramaId = drama.dramaId;
    detailVC.dramaTitle = drama.title;
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - RRBannerViewDelegate

- (void)bannerView:(id)bannerView didSelectAtIndex:(NSInteger)index {
    if (index < self.banners.count) {
        RRBannerModel *banner = self.banners[index];
        NSLog(@"点击Banner: %@", banner.title);
    }
}

#pragma mark - RRCategoryBarViewDelegate

- (void)categoryBarView:(id)barView didSelectCategory:(RRCategoryModel *)category {
    NSLog(@"选择分类: %@ (id=%@)", category.name, category.categoryId);
    
    self.selectedCategoryId = category.categoryId;
    self.currentPage = 1;
    self.hasMore = YES;
    [self.collectionView.mj_footer resetNoMoreData];
    
    // 更新分类栏的选中状态
    RRCategoryBarView *categoryBar = (RRCategoryBarView *)barView;
    categoryBar.selectedCategoryId = category.categoryId;
    
    // 清空旧的剧集列表
    [self.dramaList removeAllObjects];
    
    // 只刷新短剧列表（section 1）
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
    
    [self fetchDramas];
}

@end
