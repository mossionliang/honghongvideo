//
//  RRDramaEpisodeCell.h
//  redredvideo
//
//  剧集播放 Cell - 每个 cell 包含一个播放器
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RRDramaEpisodeCell;

@protocol RRDramaEpisodeCellDelegate <NSObject>
@optional
- (void)episodeCellDidLongPress:(RRDramaEpisodeCell *)cell;
- (void)episodeCell:(RRDramaEpisodeCell *)cell didFinishPlaying:(NSDictionary *)episode;
- (void)episodeCellDidTapEpisodePanel:(RRDramaEpisodeCell *)cell;
- (void)episodeCellDidTapNextEpisode:(RRDramaEpisodeCell *)cell;
@end

@interface RRDramaEpisodeCell : UICollectionViewCell

@property (nonatomic, weak) id<RRDramaEpisodeCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *episode;
@property (nonatomic, assign) BOOL hasPreloaded;
@property (nonatomic, assign) BOOL hasStarted;
@property (nonatomic, assign) float currentSpeed;

- (void)configureWithEpisode:(NSDictionary *)episode baseURL:(NSString *)baseURL;
- (void)configureBottomBarWithText:(NSString *)text showNextButton:(BOOL)showNext;
- (void)startPlaying;
- (void)stopPlaying;
- (void)pausePlaying;
- (void)resumePlaying;
- (void)preload;
- (void)setPlaybackSpeed:(float)speed;

@end

NS_ASSUME_NONNULL_END
