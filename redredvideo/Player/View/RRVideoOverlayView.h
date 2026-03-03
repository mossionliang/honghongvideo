//
//  RRVideoOverlayView.h
//  redredvideo
//
//  视频播放器覆盖层（标题、互动按钮等）
//

#import <UIKit/UIKit.h>

@class RRVideoModel;

NS_ASSUME_NONNULL_BEGIN

@protocol RRVideoOverlayViewDelegate <NSObject>
@optional
- (void)overlayViewDidTapLike:(id)overlayView;
- (void)overlayViewDidTapComment:(id)overlayView;
- (void)overlayViewDidTapShare:(id)overlayView;
@end

@interface RRVideoOverlayView : UIView

@property (nonatomic, weak) id<RRVideoOverlayViewDelegate> delegate;

- (void)configureWithModel:(RRVideoModel *)model;

@end

NS_ASSUME_NONNULL_END
