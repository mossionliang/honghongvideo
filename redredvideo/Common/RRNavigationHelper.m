//
//  RRNavigationHelper.m
//  redredvideo
//
//  导航辅助工具：获取当前可用的 navigationController
//

#import "RRNavigationHelper.h"

@implementation RRNavigationHelper

+ (UINavigationController *)currentNavigationController {
    UIViewController *currentVC = [self currentViewController];
    
    // 如果当前 VC 有 navigationController，直接返回
    if (currentVC.navigationController) {
        return currentVC.navigationController;
    }
    
    // 如果当前 VC 本身就是 navigationController
    if ([currentVC isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)currentVC;
    }
    
    // 如果是 tabBarController，获取选中的 VC 的 navigationController
    if ([currentVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBar = (UITabBarController *)currentVC;
        UIViewController *selectedVC = tabBar.selectedViewController;
        if ([selectedVC isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)selectedVC;
        }
        return selectedVC.navigationController;
    }
    
    return nil;
}

+ (UIViewController *)currentViewController {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findCurrentViewControllerFrom:rootVC];
}

+ (UIViewController *)findCurrentViewControllerFrom:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [self findCurrentViewControllerFrom:nav.visibleViewController];
    }
    
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        return [self findCurrentViewControllerFrom:tab.selectedViewController];
    }
    
    if (vc.presentedViewController) {
        return [self findCurrentViewControllerFrom:vc.presentedViewController];
    }
    
    return vc;
}

@end
