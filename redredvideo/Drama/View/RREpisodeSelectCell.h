//
//  RREpisodeSelectCell.h
//  redredvideo
//
//  选集Cell
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RREpisodeSelectCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UIImageView *playingIcon;

- (void)configureWithNumber:(NSInteger)number isPlaying:(BOOL)isPlaying isFree:(BOOL)isFree;

@end

NS_ASSUME_NONNULL_END
