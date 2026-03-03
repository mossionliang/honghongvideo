//
//  LBLelinkMirrorError.h
//  LBReplayAppKit
//
//  Created by wangzhijun on 2021/3/22.
//  Copyright © 2021 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const __nonnull LBLelinkMirrorErrorDomain;
extern NSString * const __nonnull LBLelinkMirrorExtensionErrorDomain;


/* 镜像相关错误代码*/
typedef NS_ENUM(NSInteger, LBLelinkMirrorErrorCode) {
    LBLelinkMirrorErrorServerUnsupportedLANLelink = -3000,            // 服务不支持局域网乐联镜像
    LBLelinkMirrorErrorServerUnsupportedInternetYouMe = -3001,        // 服务不支持互联网YouMe镜像
    LBLelinkMirrorErrorLelinkConnectionNotConnected = -3010,          // 连接未建立
    LBLelinkMirrorErrorNoCloudMirrorRights = -3020,                   // 无云镜像权益
    LBLelinkMirrorErrorConnectionProtocolNotSupportMirror = -3030,    // 连接的协议不支持镜像
    LBLelinkMirrorErrorNotMirroringTemporaryPrivateSetFailure = -3031,// 不在镜像中设置临时独占失败
    LBLelinkMirrorErrorConnectionAtRisk = -3032, /**< 风险等级较高 */
    LBLelinkMirrorErrorFaceRecognition = -3033, /**< 镜像需人脸识别认证 */
    LBLelinkMirrorErrorMirrorProtocolBeBanned = -3034, /**< 匹配到的镜像协议被封禁 */
    LBLelinkMirrorErrorCloudMirrorRefused = -3035,     ///云镜像被拒绝
    LBLelinkMirrorErrorMirrorStartAppExternalLimitStop = -3040,           // 镜像启动时在APP外部被限制停止
    LBLelinkMirrorErrorMirroringAppExternalLimit = -3041,                 // 镜像过程中在APP外部被限制暂停
    LBLelinkMirrorErrorMirroringAppExternalLimitTimeoutStop = -3042,      // 镜像过程中在APP外部被限制超时停止
};

/* 镜像扩展程序相关错误代码*/
typedef NS_ENUM(NSInteger, LBLelinkMirrorExtensionErrorCode) {
    LBLelinkMirrorExtensionErrorUnknown = -4000,
    LBLelinkMirrorExtensionErrorServerUnsupportedInternetYouMe = -4001,        // 收端服务不支持互联网YouMe镜像
    LBLelinkMirrorExtensionErrorNotMirrorDeviceInfo = -4002,                   // 没有镜像设备信息
    LBLelinkMirrorExtensionErrorNotRoomId = -4003,                             // 没有房间号
    LBLelinkMirrorExtensionErrorNotToken = -4004,                              // 没有token   
    LBLelinkMirrorExtensionErrorNetworkRequestFailed = -4005,                  // 网络请求失败
    LBLelinkMirrorExtensionErrorNetworkRequestParamWrong = -4006,              // 网络请求参数错误
    LBLelinkMirrorExtensionErrorAuthFailed = -4007, //授权失败                   // 授权失败
    LBLelinkMirrorExtensionErrorReceiverNotOnline = -4008,                     // 接收端不在线
    LBLelinkMirrorExtensionErrorServerError = -4009,                           // 服务错误
    LBLelinkMirrorExtensionErrorTokenOverdue = -4010,                          // token 过期
    LBLelinkMirrorExtensionErrorRequestParamMissing = -4011,                   // 请求参数缺失
    LBLelinkMirrorExtensionErrorJsonParsingExceptions = -4012,                 // Json解析异常
    LBLelinkMirrorExtensionErrorResponseParamWrong = -4013,                    // 响应参数错误
    LBLelinkMirrorExtensionErrorReceiverExitsMirror = -4014,                   // 收端退出镜像
    LBLelinkMirrorExtensionErrorReceiverNotJoinedRoom = -4020,                 // 收端未加入房间
    LBLelinkMirrorExtensionErrorSenderJoinedRoomFailedTimeout = -4030,         // 发端加入房间失败超时
    LBLelinkMirrorExtensionErrorSenderReconnectCloudFailed = -4031,            // 发端云连接失败
    LBLelinkMirrorExtensionErrorSenderReconnectReceiverNotInRoom = -4032,      // 发端重连接成功收端不在房间
    LBLelinkMirrorExtensionErrorSenderUnsupportedInternetProtocol = -4040,     // 发端不支持的公网镜像协议
    LBLelinkMirrorExtensionErrorRiskWarning = -4050, /**< 镜像的风险警告 */
    LBLelinkMirrorExtensionErrorFaceRecognition = -4051, /**< 需要人脸识别 */
    LBLelinkMirrorExtensionErrorMirrorProtocolBeBanned = -4052, /**< 匹配到的镜像协议被封禁 */
    LBLelinkMirrorExtensionErrorInCommonMode = -4053,           /**< 接收端在公共模式，不允许镜像 */
    LBLelinkMirrorExtensionErrorMirrorContentViolation = -4054, /**镜像内容检测违规**/
};
/* RTC相关错误代码*/
typedef NS_ENUM(NSInteger, LBLelinkMirrorNERTCErrorCode) {
    LBLelinkMirrorNERTCErrorPermissionDenied = -5000, /// 权限不足
    LBLelinkMirrorNERTCErrorTimeOut = -5001, /// 请求超时
    LBLelinkMirrorNERTCErrorParam = -5002, /// 服务器请求参数错误
    LBLelinkMirrorNERTCErrorAppKey = -5003, /// 非法的APP KEY
    LBLelinkMirrorNERTCErrorMoreThanTwoUser = -5004, /// 只支持两个用户, 有第三个人试图使用相同的房间名分配房间
    LBLelinkMirrorNERTCErrorServerFail = -5005,  /// 分配房间服务器出错
    LBLelinkMirrorNERTCErrorRequestJoinChannelFail = -5006, /// 加入房间操作失败
    LBLelinkMirrorNERTCErrorInvalidUserID = -5007,  /// 非法的用户 ID
    LBLelinkMirrorNERTCErrorMediaNotStarted = -5008, /// 用户多媒体数据未连接
    LBLelinkMirrorNERTCErrorSourceNotFound = -5009, /// source 未找到
    LBLelinkMirrorNERTCErrorEncryptNotSuitable= -5010, /// 设置的媒体流加密密钥与房间中其他成员不一致，加入房间失败
    LBLelinkMirrorNERTCErrorConnectionNotFound = -5011, /// 连接未找到
    LBLelinkMirrorNERTCErrorChannelBeClosed = -5012, /// 房间已被关闭
    LBLelinkMirrorNERTCErrorChannelLeaveByDuplicateUidLogin = -5013, /// 房间被关闭因为有重复 uid 登录
    LBLelinkMirrorNERTCErrorOther = -5014, /// 其他错误
};

NS_ASSUME_NONNULL_END
