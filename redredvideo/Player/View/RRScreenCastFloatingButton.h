//
//  RRScreenCastFloatingButton.h
//  redredvideo
//
//  投屏悬浮按钮：可拖动，自动吸附边缘
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRScreenCastFloatingButton : UIView

+ (instancetype)sharedButton;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
