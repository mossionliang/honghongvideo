//
//  SceneDelegate.m
//  redredvideo
//

#import "SceneDelegate.h"
#import "RRTabBarController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    
    // 设置根控制器为TabBarController
    RRTabBarController *tabBarController = [[RRTabBarController alloc] init];
    self.window.rootViewController = tabBarController;
    
    // 全局深色风格
    self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    
    [self.window makeKeyAndVisible];
}

- (void)sceneDidDisconnect:(UIScene *)scene {}
- (void)sceneDidBecomeActive:(UIScene *)scene {}
- (void)sceneWillResignActive:(UIScene *)scene {}
- (void)sceneWillEnterForeground:(UIScene *)scene {}
- (void)sceneDidEnterBackground:(UIScene *)scene {}

@end
