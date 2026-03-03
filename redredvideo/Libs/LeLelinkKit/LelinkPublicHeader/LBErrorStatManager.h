//
//  LBErrorStatManager.h
//  LBReplayKit
//
//  Created by fuchen on 2020/3/9.
//  Copyright © 2020 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kErrorCode_200101001;

// 乐联V1镜像
extern NSString * const kErrorCode_200102001;
extern NSString * const kErrorCode_200102002;
extern NSString * const kErrorCode_200102003;
extern NSString * const kErrorCode_200102004;
extern NSString * const kErrorCode_200102005;
extern NSString * const kErrorCode_200102006;
extern NSString * const kErrorCode_200102007;

// 新乐联镜像,编号03
extern NSString * const kErrorCode_200103001;  // 主连接失败
extern NSString * const kErrorCode_200103002;  // 音频连接失败
extern NSString * const kErrorCode_200103003;  // 视频连接失败
extern NSString * const kErrorCode_200103004;  // 设备信息不对
extern NSString * const kErrorCode_200103005;  // 音频编码失败
extern NSString * const kErrorCode_200103006;  // 视频编码失败
extern NSString * const kErrorCode_200103007;  // 内存告警
extern NSString * const kErrorCode_200103008;  // 加密失败
extern NSString * const kErrorCode_200103009;  // 断开连接
// 乐联V1推送，编号04
extern NSString * const kErrorCode_200104001;  // 主连接失败
extern NSString * const kErrorCode_200104002;  // 播放连接失败
extern NSString * const kErrorCode_200104003;  // 发起播放失败
extern NSString * const kErrorCode_200104004;  // 暂停失败
extern NSString * const kErrorCode_200104005;  // 恢复播放失败
extern NSString * const kErrorCode_200104006;  // 音量操作失败
extern NSString * const kErrorCode_200104007;  // 播放进度操作失败
extern NSString * const kErrorCode_200104008;  // 停止播放失败
extern NSString * const kErrorCode_200104009;  // 数据异常

// 新乐联推送，编号05
extern NSString * const kErrorCode_200105001;  // 主连接失败
extern NSString * const kErrorCode_200105002;  // 播放连接失败
extern NSString * const kErrorCode_200105003;  // 发起播放失败
extern NSString * const kErrorCode_200105004;  // 暂停失败
extern NSString * const kErrorCode_200105005;  // 恢复播放失败
extern NSString * const kErrorCode_200105006;  // 音量操作失败
extern NSString * const kErrorCode_200105007;  // 播放进度操作失败
extern NSString * const kErrorCode_200105008;  // 停止播放失败
extern NSString * const kErrorCode_200105009;  // 独占模式切换失败
extern NSString * const kErrorCode_200105010;  // 播放失败参数出错
extern NSString * const kErrorCode_200105011;  // 播放失败tv不在线

// DLNA，编号06
extern NSString * const kErrorCode_200106001;  // 发现设备失败
extern NSString * const kErrorCode_200106002;  // 播放失败
extern NSString * const kErrorCode_200106003;  // 暂停失败
extern NSString * const kErrorCode_200106004;  // 恢复播放失败
extern NSString * const kErrorCode_200106005;  // 停止播放失败
extern NSString * const kErrorCode_200106006;  // 音量操作失败
extern NSString * const kErrorCode_200106007;  // 播放进度操作失败
extern NSString * const kErrorCode_200106008;  // 设置播放url失败
extern NSString * const kErrorCode_200106009;  // 参数出错

// SDK授权，编号07
extern NSString * const kErrorCode_200107001;  // SDK授权失败

// 游密，编号08
extern NSString * const kErrorCode_200108001;  // 获取房间号失败
extern NSString * const kErrorCode_200108002;  // 加入房间失败
extern NSString * const kErrorCode_200108003;  // 推流失败
extern NSString * const kErrorCode_200108004;  // 收端加入房间失败
extern NSString * const kErrorCode_200108005;  // 创建播放器失败
extern NSString * const kErrorCode_200108006;  // 初始化SDK失败
extern NSString * const kErrorCode_200108007;  //服务不支持互联网YouMe镜像
extern NSString * const kErrorCode_200108008;  // 发端云连接失败
extern NSString * const kErrorCode_200108009; // 收端退出镜像

// IM 编号10
extern NSString * const kErrorCode_200110001;  // 发现设备失败
extern NSString * const kErrorCode_200110002;  // 播放失败
extern NSString * const kErrorCode_200110003;  // 连接失败
extern NSString * const kErrorCode_200110004;  // 播放失败参数出错
extern NSString * const kErrorCode_200110005;  // 播放失败tv不在线
extern NSString * const kErrorCode_200110006;  // 认证失败
extern NSString * const kErrorCode_200110007;  // 解析出错
extern NSString * const kErrorCode_200110008;  // 发控出错
extern NSString * const kErrorCode_200110009;  // 不支持该模式
extern NSString * const kErrorCode_200110010;  // 数据异常

// 会议 编号11
extern NSString * const kErrorCode_200111001;  // 会议上报日志
extern NSString * const kErrorCode_200111002;  // 连接事件-接收端防骚扰验证
extern NSString * const kErrorCode_200111003;  // 连接事件-发送端发起连接前
extern NSString * const kErrorCode_200111004;  // 连接事件-发送端发起连接后
extern NSString * const kErrorCode_200111005;  // 开始投屏-询问接收端是否在房间中
extern NSString * const kErrorCode_200111006;  // 查询会议状态超时
extern NSString * const kErrorCode_200111007;  // 开始投屏-通知接收端创建房间动作结束
extern NSString * const kErrorCode_200111008;  // 加入投屏-请求乐播云加入房间动作开始
extern NSString * const kErrorCode_200111009;  // 加入投屏-请求即构加入房间动作结束
extern NSString * const kErrorCode_200111010;  // 加入投屏-威尔云请求云桌面动作
extern NSString * const kErrorCode_200111011;  // 请求上传文件动作结束
extern NSString * const kErrorCode_200111012;  // 请求乐播云生成文件在线地址动作结束
extern NSString * const kErrorCode_200111013;  // 通知云应用加载文档动作开始
extern NSString * const kErrorCode_200111014;  // 通知云应用加载网址资源动作开始
extern NSString * const kErrorCode_200111015;  // 结束投屏事件
extern NSString * const kErrorCode_200111016;  // 投屏定时上报事件
extern NSString * const kErrorCode_200111017;  // 初始化失败
extern NSString * const kErrorCode_200111018;  // 登录失败
extern NSString * const kErrorCode_200111019;  // 获取主持人权限失败
extern NSString * const kErrorCode_200111020;  // 取消主持人权限失败

@interface LBErrorStatManager : NSObject
+ (instancetype)defaultManager;

- (void)reportErrorWithErrorCode:(NSString *)errorCode error:(NSError *)error;
- (void)reportAuthError:(NSError *)error;

#pragma mark - 镜像乐联V1错误码
- (void)reportLelinkV1MirrorConnectError:(NSError *)error;
- (void)reportLelinkV1MirrorAudioConnectError:(NSError *)error;
- (void)reportLelinkV1MirrorVideoConnectError:(NSError *)error;
- (void)reportLelinkV1MirrorDeviceError:(NSError *)error;
- (void)reportLelinkV1MirrorAudioEncodeError:(NSError *)error;
- (void)reportLelinkV1MirrorVideoEncodeError:(NSError *)error;

#pragma mark - 镜像乐联V5错误码
- (void)reportLelinkV5MirrorConnectError:(NSError *)error;
- (void)reportLelinkV5MirrorAudioConnectError:(NSError *)error;
- (void)reportLelinkV5MirrorVideoConnectError:(NSError *)error;
- (void)reportLelinkV5MirrorDeviceError:(NSError *)error;
- (void)reportLelinkV5MirrorAudioEncodeError:(NSError *)error;
- (void)reportLelinkV5MirrorVideoEncodeError:(NSError *)error;
- (void)reportLelinkV5MirrorEncryptError:(NSError *)error;

#pragma mark - 推送V1错误码
- (void)reportLelinkV1PushConnectError:(NSError *)error;
- (void)reportLelinkV1PushPlayConnectError:(NSError *)error;
- (void)reportLelinkV1PushStartPlayError:(NSError *)error;
- (void)reportLelinkV1PushPausePlayError:(NSError *)error;
- (void)reportLelinkV1PushResumePlayError:(NSError *)error;
- (void)reportLelinkV1PushVolumeError:(NSError *)error;
- (void)reportLelinkV1PushPlayProgressError:(NSError *)error;
- (void)reportLelinkV1PushStopPlayError:(NSError *)error;

#pragma mark - 推送V5错误码
- (void)reportLelinkV5PushConnectError:(NSError *)error;
- (void)reportLelinkV5PushPlayConnectError:(NSError *)error;
- (void)reportLelinkV5PushStartPlayError:(NSError *)error;
- (void)reportLelinkV5PushPausePlayError:(NSError *)error;
- (void)reportLelinkV5PushResumePlayError:(NSError *)error;
- (void)reportLelinkV5PushVolumeError:(NSError *)error;
- (void)reportLelinkV5PushPlayProgressError:(NSError *)error;
- (void)reportLelinkV5PushStopPlayError:(NSError *)error;

#pragma mark - DLNA推送错误码
- (void)reportDLNAPushSearchError:(NSError *)error;
- (void)reportDLNAPushPlayError:(NSError *)error;
- (void)reportDLNAPushPauseError:(NSError *)error;
- (void)reportDLNAPushResumePlayError:(NSError *)error;
- (void)reportDLNAPushStopPlayError:(NSError *)error;
- (void)reportDLNAPushVolumeError:(NSError *)error;
- (void)reportDLNAPushPlayProgressError:(NSError *)error;
- (void)reportDLNAPushSetUrlError:(NSError *)error;

#pragma mark - 游密镜像
- (void)reportYoumeMirrorGetRoomIdError:(NSError *)error;
- (void)reportYoumeMirrorJoinRoomError:(NSError *)error;
- (void)reportYoumeMirrorPushVideoError:(NSError *)error;
- (void)reportYoumeMirrorRevJoinRoomError:(NSError *)error;
- (void)reportYoumeMirrorCreatePlayerError:(NSError *)error;
- (void)reportYoumeMirrorInitError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
