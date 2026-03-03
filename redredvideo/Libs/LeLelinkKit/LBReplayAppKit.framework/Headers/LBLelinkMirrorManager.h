//
//  LBLelinkMirrorManager.h
//  LBReplayAppKit
//
//  Created by lbkj on 2019/12/11.
//  Copyright © 2019 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class LBLelinkService;
@class LBLelinkMirrorManager;
@protocol LBLelinkMirrorManagerDelegate <NSObject>
@optional

- (void)mirrorOnError:(NSError *)error;
- (void)mirrorDidStarted;
- (void)mirrorDidStoped;
- (void)mirrorDidAddService:(LBLelinkService *)service;
- (void)mirrorDidRemoveService:(LBLelinkService *)service;
- (void)mirrorDidMirroring:(BOOL)mirroring; // 正在镜像
/// 镜像方式发生变化
/// @param stype 1：乐联镜像、2：游密镜像
- (void)mirrorStypeDidChanged:(NSInteger)stype;
/// 乐联镜像的帧率码率信息
- (void)mirrorLelinkPublicStreamInfo:(NSDictionary *)streamInfo;
@end

@interface LBLelinkMirrorManager : NSObject
@property(nonatomic, weak) id<LBLelinkMirrorManagerDelegate> delegate;

+ (instancetype)defaultManager;

/**
 设置groupid
 */
- (void)setAppGroupId:(NSString *)appGroupId;

/// 设置镜像配置
/// @param fps 帧率
/// @param bitrate 码率
/// @param maxBitrate 最大码率
/// @param minBitrate 最小码率
/// @param frameWidth 分辨率的宽度
/// @param frameHeight 分辨率的高度
- (void)configVideoFps:(NSUInteger)fps
               bitrate:(NSInteger)bitrate
            maxBitrate:(NSInteger)maxBitrate
            minBitrate:(NSInteger)minBitrate
            frameWidth:(NSInteger)frameWidth
           frameHeight:(NSInteger)frameHeight;

/**
 开始镜像
 */
- (void)startMirror;

/**
 停止镜像
 */
- (void)stopMirror;

/**
暂停镜像，对外暂不支持
*/
- (void)pauseMirror;

/**
继续镜像，对外暂不支持
*/
- (void)resumeMirror;

/**
 是否在镜像中
 */
- (void)isMirrored;


/// 是否支持镜像
/// @param service 设备服务
- (BOOL)canAddMirrorService:(LBLelinkService *)service;

/**
 添加一个乐联设备镜像
 */
- (NSError *_Nullable)addMirrorService:(LBLelinkService *)service;

/**
 去掉一个乐联设备镜像
 */
- (void)removeMirrorService:(LBLelinkService *)service;

- (void)cleanMirrorDevice;

/**
强制停止扩展app
*/
- (void)stopExtensionApp;

- (void)setExtensionAPI:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
