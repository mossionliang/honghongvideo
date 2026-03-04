//
//  AppDelegate.m
//  redredvideo
//
//  Created by Liang on 2026/3/2.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <KTVHTTPCache/KTVHTTPCache.h>
#import <LBLelinkKit/LBLelinkKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define kAppid @"15"
#define kLBSerectKey @"34af861a598abe0a3e47a04ccf5f24e3"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 设置音频会话：播放模式，忽略静音开关
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:nil];
    [session setActive:YES error:nil];
    
    // 初始化 KTVHTTPCache 视频缓存代理
    NSError *error = nil;
    [KTVHTTPCache proxyStart:&error];
    if (error) {
        NSLog(@"[KTVHTTPCache] 启动失败: %@", error);
    } else {
        NSLog(@"[KTVHTTPCache] 代理已启动");
    }
    // 设置缓存上限 500MB
    [KTVHTTPCache cacheSetMaxCacheLength:500 * 1024 * 1024];
    // 开启日志（调试用）
    [KTVHTTPCache logSetConsoleLogEnable:NO];
    
    // 初始化乐播投屏SDK
    [self registerLBLelinkSDK];
    
    return YES;
}

/// 注册投屏SDK
- (void)registerLBLelinkSDK {
    
   
    NSLog(@"对leboSDK 开始授权");
    __block BOOL isLoadAuth = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        [LBLelinkKit enableLog:YES];
        isLoadAuth = [LBLelinkKit authWithAppid:kAppid secretKey:kLBSerectKey error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [LBLelinkKit connectIM];
            if (isLoadAuth) {
                NSLog(@"[LBLelinkKit] 授权成功");
            } else {
                NSLog(@"[LBLelinkKit] 授权失败: %@", error);
            }
        });
        
    });
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

// 控制屏幕旋转：只支持竖屏
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}


@end
