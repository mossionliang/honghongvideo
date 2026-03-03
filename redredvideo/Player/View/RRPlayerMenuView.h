//
//  RRPlayerMenuView.h
//  redredvideo
//
//  长按弹出菜单（列表式底部弹窗）
//  功能：倍速播放、保存到相册、投屏
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RRPlayerMenuViewDelegate <NSObject>
@optional
/// 选择了倍速
- (void)playerMenuDidSelectSpeed:(float)speed;
/// 保存到相册
- (void)playerMenuDidTapSaveToAlbum;
/// 投屏
- (void)playerMenuDidTapScreenCast;
/// 菜单关闭
- (void)playerMenuDidDismiss;
@end

@interface RRPlayerMenuView : UIView

@property (nonatomic, weak) id<RRPlayerMenuViewDelegate> delegate;
/// 当前选中的倍速
@property (nonatomic, assign) float currentSpeed;

/// 显示菜单
- (void)showInView:(UIView *)view;
/// 隐藏菜单
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
