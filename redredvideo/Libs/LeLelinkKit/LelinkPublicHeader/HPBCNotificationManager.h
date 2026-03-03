//
//  HPBCNotificationManager.h
//  HPPlayTVAssistant
//
//  Created by wubaolai on 2019/10/30.
//  Copyright © 2019 HPPlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CFNotificationCenter.h>

NS_ASSUME_NONNULL_BEGIN

@class HPBCNotificationManager;
@class LBLelinkService;

@protocol HPBCNotificationManagerDelegate<NSObject>
- (void)broadCastDidStarted:(HPBCNotificationManager *)bcNotificationManager;
- (void)broadCastDidStoped:(HPBCNotificationManager *)bcNotificationManager;
- (void)broadCastBufferDidGotVideo:(HPBCNotificationManager *)bcNotificationManager;
- (void)broadCastBufferDidGotAudio:(HPBCNotificationManager *)bcNotificationManager;

- (void)broadCastDeviceDidConnect:(HPBCNotificationManager *)bcNotificationManager lelinkService:(LBLelinkService *)lelinkService;
- (void)broadCastDeviceDisConnect:(HPBCNotificationManager *)bcNotificationManager lelinkService:(LBLelinkService *)lelinkService;
- (void)broadCastDidMirroring:(HPBCNotificationManager *)bcNotificationManager;

/// 镜像方式发生变化
/// @param stype 1：乐联镜像、2：游密镜像
- (void)broadcastMirroringStypeDidChanged:(NSInteger)stype;

/// 镜像的风险警告
/// @param riskInfo 警告信息
- (void)broadCastDidRiskWarning:(HPBCNotificationManager *)bcNotificationManager riskInfo:(NSDictionary *)riskInfo;

@end

@interface HPBCNotificationManager : NSObject

@property (nonatomic, weak) id<HPBCNotificationManagerDelegate> delegate;
+ (instancetype)defaultManager;

- (void)postStartPushNotification; // 启动镜像
- (void)postStopPushNotification; // 强制停止镜像
- (void)postFindDeviceNotification; // 通知发现设备
- (void)postAppStartedNotification; // APP已启动
- (void)postAppMirrorDeviceChangedNotification; // 镜像设备变化
- (void)postAppDetectMirrorStatusNotification; // 检查镜像状态查询
- (void)postPauseMirrorNotification; // 暂停镜像
- (void)postResumeMirrorNotification; // 继续镜像
- (void)postTurnToLelinkMirrorNotification; // 切换乐联镜像
- (void)postTurnToYoumeMirrorNotification; // 切换游密镜像

// 添加所有监听
- (void)addObserverOfNotificationCTROnHostApp;
// 移除所有监听
- (void)removeNotificationCTROnHostApp;
// 云镜像结束评分后上报
- (void)reportMirrorEndWithScore:(NSDictionary *)param;
@end

NS_ASSUME_NONNULL_END
