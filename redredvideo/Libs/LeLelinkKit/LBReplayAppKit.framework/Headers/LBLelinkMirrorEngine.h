//
//  LBLelinkMirrorEngine.h
//  LBReplayAppKit
//
//  Created by wangzhijun on 2021/3/16.
//  Copyright © 2021 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBLelinkMirrorBase.h"

@class LBLelinkConnection;
@class LBLelinkService;

NS_ASSUME_NONNULL_BEGIN

@protocol LBLelinkMirrorEngineDelegate <NSObject>


/// 添加设备成功
/// @param lelinkConnection 设备连接模型
/// @param mirrorStype 镜像方式
- (void)mirrorAddMirrorDeviceSucceedConnection:(LBLelinkConnection *)lelinkConnection mirrorStype:(LBLelinkMirrorStype)mirrorStype;


/// 添加设备失败
/// @param lelinkConnection 设备连接模型
/// @param error 错误对象
- (void)mirrorAddMirrorDeviceFailureConnection:(LBLelinkConnection *)lelinkConnection error:(NSError *)error;


/// 镜像错误
/// @param error 错误对象
/// @param mirrorStype 镜像方式
- (void)mirrorOnError:(NSError *)error mirrorStype:(LBLelinkMirrorStype)mirrorStype;

/// 扩展程序启动
/// @param mirrorStype 镜像方式
- (void)mirrorDidBroadcastExtensionStartedMirrorStype:(LBLelinkMirrorStype)mirrorStype;

/// 扩展程序关闭
/// @param mirrorStype 镜像方式
- (void)mirrorDidBroadcastExtensionStopedMirrorStype:(LBLelinkMirrorStype)mirrorStype;


/// 镜像成功
/// @param lelinkConnection 设备连接模型
/// @param mirrorStype 镜像方式
- (void)mirrorMirrorDeviceDidConnectConnection:(LBLelinkConnection *)lelinkConnection mirrorStype:(LBLelinkMirrorStype)mirrorStype;


/// 镜像结束
/// @param lelinkConnection 设备连接模型
/// @param mirrorStype 镜像方式
- (void)mirrorMirrorDeviceDisConnectConnection:(LBLelinkConnection *)lelinkConnection mirrorStype:(LBLelinkMirrorStype)mirrorStype;


/// 镜像状态回调
/// 调用isMirrored的状态回调
/// @param mirroring 镜像状态
/// @param mirrorStype 镜像方式
- (void)mirrorStateMirroring:(BOOL)mirroring mirrorStype:(LBLelinkMirrorStype)mirrorStype;

/// 镜像推流质量
/// @param quality 云镜像一质量；具体参数如下：
 /**
  audioCaptureFPS:音频采集帧率；
  audioKBPS :音频码率；
  audioSendBytes:已发送的音频字节数；
  audioSendFPS:音频发送帧率；
  isHardwareEncode:是否开启硬件编码；
  level:推流质量级别，0 ~ 5，0:非常好，1:好，2:一般，3:差，4:失败，5:未知；
  packetLostRate: 丢包率，单位为百分比，0.0 ~ 1.0；
  rtt:本端至服务端的延迟，单位为毫秒；
  streamID:流ID；totalSendBytes:已发送的总字节数，包括音频、视频和SEI等；
  videoCaptureFPS:视频采集帧率；
  videoCodecID = 0；
  videoEncodeFPS:视频编码帧率；
  videoKBPS:视频码率；
  videoSendBytes:已发送的视频字节数；
  videoSendFPS:视频发送帧率*/
/// @param rtcQualitys 云镜像二质量；具体参数如下：
/**
 rxQuality: 拉流质量；
 txQuality: 推流质量；
 userId: 用户ID;
 */
- (void)mirrorPublicStreamQuality:(NSDictionary *)quality andRTCQualitys:(NSArray<NSDictionary *> *)rtcQualitys;

/// 镜像质量数据回调
/// @param videoFPS 帧率
/// @param bitRate 码率
/// @param resolution 分辨率
- (void)mirrorQualityVideoFPS:(int)videoFPS videoBitRate:(int)bitRate resolution:(CGSize)resolution;

/// 云镜像RTC相关信息回调
- (void)mirrorPublicRTCQualitys:(NSDictionary *)rtcQuality;

/// 镜像视频数据
/// @param videoFrame 视频数据
- (void)mirrorReceiveVideoFrame:(id _Nullable)videoFrame;

/// 镜像音频数据
/// @param audioFrame 音频数据
- (void)mirrorReceiveAudioFrame:(id _Nullable)audioFrame;

/// 云镜像的提供者
/// @param providerSource 云镜像的提供者
- (void)mirrorCloudProviderSource:(LBCloudMirrorProviderType)providerSource;

@end

@interface LBLelinkMirrorEngine : NSObject


/// 镜像引擎代理
@property (nonatomic,weak)id<LBLelinkMirrorEngineDelegate> delegate;

/// 实例化镜像引擎
+ (instancetype)shareInstance;

/// 设置app组id
/// @param appGroupId app组id
- (void)setAppGroupId:(NSString *)appGroupId;

/// 设置镜像配置，码率单位为 kbps,如果传入的值小于或等于 0 作为此次不需要更新值，还是使用上次设置的值
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

/// 是否在镜像中,镜像状态在mirrorStateMirroring回调
- (void)isMirrored;

/// 添加一个乐联设备
/// 现仅支持添加一个，再次添加会覆盖旧的设备信息
/// @param lelinkConnection 服务连接
- (void)addMirrorDeviceWithConnection:(LBLelinkConnection *)lelinkConnection;

/// 添加一个乐联设备（备注：该接口功能暂时只对乐播APP有效，其他APP暂不支持多通道镜像）
/// 现仅支持添加一个，再次添加会覆盖旧的设备信息
/// @param lelinkConnection 服务连接
/// @param isMutiTunnels YES: 支持多通道    NO: 不支持多通道
- (void)addMirrorDeviceWithConnection:(LBLelinkConnection *)lelinkConnection mutiTunnels:(BOOL)isMutiTunnels;

/// 清除镜像设备信息
- (void)cleanMirrorDevice;

/// 强制停止扩展app
- (void)stopExtensionApp;

/// 暂停镜像
- (void)pauseMirror;

/// 继续镜像
- (void)resumeMirror;
/// 能否切换至临时独占模式,需收端功能支持并且在镜像后
- (BOOL)canSwitchTemporaryPrivateMode;
// 打开临时独占模式
// 调用这个方法之前，先调取canSwitchTemporaryPrivateMode是否支持临时独占模式
- (void)passthSwitchTemporaryPrivateMode:(BOOL)open;

/// 多通道切换
/// @param mirrorType 切换类型，不能为 LBLelinkMirrorStypeUnknown 
- (void)switchToMirrorType:(LBLelinkMirrorStype)mirrorType;

/// 获取最新云设备的状态
- (void)checkMirrorServiceStatus:(LBLelinkService *_Nullable)checkService callback:(void(^)(LBLelinkService *lelinkServic,BOOL offLine))callback;

/// 上报镜像错误（镜像审核使用）
- (void)mirrorWithAudit:(NSError *)error;


/// 设置扩展API
/// - Parameter dict: key为api方法，value为参数，参数有多个时，传参数数组
/// 现支持设置镜像后台限制的超时时间，超一定时间，会自动结束镜像，默认为300s，可修改，key为@“setBackgroundTimeoutInterval:”，value为@(300)
- (void)setExtensionAPI:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
