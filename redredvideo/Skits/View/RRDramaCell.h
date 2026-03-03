//
//  RRDramaCell.h
//  redredvideo
//
//  短剧卡片Cell
//

#import <UIKit/UIKit.h>

@class RRDramaModel;

NS_ASSUME_NONNULL_BEGIN

/// 竖版卡片（推荐列表用）
@interface RRDramaVerticalCell : UICollectionViewCell

- (void)configureWithModel:(RRDramaModel *)model;

@end

/// 横版卡片（水平滚动列表用）
@interface RRDramaHorizontalCell : UICollectionViewCell

- (void)configureWithModel:(RRDramaModel *)model;

@end

/// 排行榜卡片
@interface RRDramaRankCell : UITableViewCell

- (void)configureWithModel:(RRDramaModel *)model rank:(NSInteger)rank;

@end

NS_ASSUME_NONNULL_END
