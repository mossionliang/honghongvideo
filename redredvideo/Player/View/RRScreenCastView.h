//
//  RRScreenCastView.h
//  redredvideo
//
//  投屏设备选择弹窗
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RRScreenCastViewDelegate <NSObject>
@optional
- (void)screenCastViewDidDismiss;
/// 投屏已连接，需要 push 到控制页面
- (void)screenCastViewDidConnect:(NSString *)deviceName videoURL:(NSString *)videoURL videoTitle:(nullable NSString *)title;
@end

@interface RRScreenCastView : UIView

@property (nonatomic, weak) id<RRScreenCastViewDelegate> delegate;

/// 显示投屏设备选择弹窗，videoURL 为要投屏的视频地址，title 为视频标题
- (void)showInView:(UIView *)view videoURL:(NSString *)videoURL videoTitle:(nullable NSString *)title;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
