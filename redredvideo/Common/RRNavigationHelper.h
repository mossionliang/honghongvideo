//
//  RRNavigationHelper.h
//  redredvideo
//
//  导航辅助工具：获取当前可用的 navigationController
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRNavigationHelper : NSObject

/// 获取当前可用的 navigationController
+ (nullable UINavigationController *)currentNavigationController;

/// 获取当前最顶层的 viewController
+ (nullable UIViewController *)currentViewController;

@end

NS_ASSUME_NONNULL_END
