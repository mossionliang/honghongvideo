//
//  RRSeekBar.h
//  redredvideo
//
//  可拖动进度条（支持seek、缓冲显示、按下放大效果）
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RRSeekBarDelegate <NSObject>
@optional
/// 开始拖动
- (void)seekBarDidBeginDragging:(id)seekBar;
/// 拖动中（实时回调）
- (void)seekBar:(id)seekBar didSeekToProgress:(float)progress;
/// 结束拖动
- (void)seekBar:(id)seekBar didEndSeekAtProgress:(float)progress;
@end

@interface RRSeekBar : UIView

@property (nonatomic, weak) id<RRSeekBarDelegate> delegate;
/// 播放进度 0~1
@property (nonatomic, assign) float progress;
/// 缓冲进度 0~1
@property (nonatomic, assign) float bufferProgress;
/// 是否正在拖动
@property (nonatomic, assign, readonly) BOOL isDragging;

@end

NS_ASSUME_NONNULL_END
