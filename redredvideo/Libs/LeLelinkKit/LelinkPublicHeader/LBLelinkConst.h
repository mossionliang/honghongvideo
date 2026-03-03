//
//  LBLelinkConst.h
//  AppleSenderSDK
//
//  Created by 刘明星 on 2018/4/12.
//  Copyright © 2018年 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
//#include "lb_srp.h"

/** 标识发送端产品类别：3002代表发送端SDK产品，具体见wiki */
extern NSString * const LBAPP_ID;

/** 标识SDK的版本号 */
//extern NSString * const LBSDK_VERSION; 使用 [HPCastFoundationTool setSDKVersion:];

extern NSString * const LBAPP_ID_OVERSEAS;
extern NSString * const LBAPP_KEY_OVERSEAS;

/** im相关常量 */
extern NSString * const LBIM_HOST;//@"im.hpplay.cn"
extern NSInteger const LBIM_PORT;
extern NSInteger const LBIM_TIMEOUT;
extern NSInteger const LBIM_MAX_BUFFER;
extern NSInteger const LBIM_READ_TIME_OUT;
extern NSInteger const LBIM_WRITE_TIME_OUT;

/** 秘听相关常量 */
extern NSInteger const LBPASSTH_SECRETLISTEN_PORT;

extern BOOL LBLelinkKitIsAuthed;
extern BOOL LBLelinkKitIsRegisterAsInteractiveAdObserver;

extern NSString * const LBLastConnectedService;

extern NSString * const LBLocalNotificationSavedKey;
extern NSString * const LBLocalNotificationEnableKey;
extern NSString * const LBLocalNotificationAlertTitleKey;
extern NSString * const LBLocalNotificationAlertBotyKey;

extern NSString * const LBIMHostKey;


typedef enum { //播放状态
    HPIMSocketUnknownState = 0,      // 未知状态
    HPIMSocketPlayingState,          // 正常播放
    HPIMSocketPlaySuccessState,      // 播放成功
    HPIMSocketSuspendState,          // 暂停
    HPIMSocketStopedState,           // 结束播放
    HPIMSocketCompleteState,         // 完成播放
    HPIMSocketEpisodeCommpletedState,// 剧集单集完成播放
    HPIMSocketErrorState,            // 错误
}HPIMSocketPlayState;

typedef struct{//视频播放进度
    NSInteger IMSocketDuration;  //时长    （单位：秒）
    NSInteger IMSocketPeriod;  //播放时间 （单位：秒）
}HPIMSocketProgress;

typedef enum{//视频播放进度
    HPIMSocketHarassWait = 1,    // 等待
    HPIMSocketHarassAllow,       // 允许
    HPIMSocketHarassReject       // 拒绝
}HPIMSocketHarass;


typedef struct{//视频播放进度
    NSInteger duration;  //时长    （单位：秒）
    NSInteger position;  //播放时间 （单位：秒）
}HPProgress;

typedef enum { //播放状态
    HPUnknownState = 0, // 未知
    HPLoadingState,     // 加载视频
    HPSuspendState,     // 暂停
    HPPlayingState,     // 正常播放
    HPStopedState,      // 结束播放
    HPPlayFailureState, // 播放失败(错误链接...)
    HPErrorState,       // 错误
    HPVideohide,        // 收起手机上的播放器
}HPPlayState;

typedef struct{//媒体音量
    NSInteger maxVolume;        // 最大音量
    NSInteger currentVolume;    // 现在音量
}HPVolume;

extern NSString * const LBNotificationOfLelinkServiceOffline;
extern NSString * const LBNotificationOfDlnaServiceOffline;
extern NSString * const LBNotificationOfImServiceOffline;
extern NSString * const LBNotificationOnlineStatusChanged;
extern NSString * const LBNotificationOfLelinkServiceDidConnect;

extern NSString * const LBNotificationServiceInfoDidChanged;
extern NSString * const LBNotificationDidReceiveInteractiveADInfoFromeTV;
extern NSString * const LBNotificationSearchDeviceFromeServerDidCompleted;
extern NSString * const LBNotificationUserLogin; // 乐播APP专用的通知，在APP层，当用户登录后发送该通知
extern NSString * const LBNotificationBrowserStopSearch;


//typedef enum{//htv值,密钥协商算法
//    LBPairHtvNone = 0,//无加密
//    LBPairHtvEcdhe,//ecdhe方式加密
//    LBPairHtvSrp,//srp加密方式
//}LBPairHtv;

typedef enum//乐联新协议vv数值枚举
{
    LBLelinkNewProtocolVVNone = 0,//老板本,无加密
    LBLelinkNewProtocolVVNoEncrypt = 1,//新版本,不加密, 注意此版本仅在调试时出现
    LBLelinkNewProtocolVVEncrypt = 2,//新版本加密
}LBLelinkNewProtocolVV;

typedef NS_ENUM(NSInteger, LB_PAIR_HTV) //htv握手验证方式 0:默认无,1:ECDHE 2:SRP,待开发
{
    LB_PAIR_HTV_NONE = 0,
    LB_PAIR_HTV_ECDHE,
    LB_PAIR_HTV_SRP,
};

typedef NS_ENUM(NSInteger, LB_PAIR_ATV)
{
    LB_PAIR_ATV_NONE = 0,
    LB_PAIR_ATV_PASSWORD,
    LB_PAIR_ATV_PINCODE,
};

typedef NS_ENUM(NSInteger, LB_PAIR_ETV)
{
    LB_PAIR_ETV_NONE = 0,
    LB_PAIR_ETV_CHACHA,
    LB_PAIR_ETV_AES_GCM,
};

typedef enum // 对称加密类型
{
    LB_PAIR_TAG_HAF = 0, // 4-byte
    
    LB_PAIR_TAG_TYPE = 1, // 1-byte
    LB_PAIR_TAG_STAGE = 2, // 1-byte
    
    LB_PAIR_TAG_SHAKE_ECDH_M1_CLIENT = 3, // 64-byte
    LB_PAIR_TAG_SHAKE_ECDH_M1_SERVER = 3, // 64-byte
    
    LB_PAIR_TAG_SHAKE_ECDH_M2_CLIENT = 4, // 64-byte
    LB_PAIR_TAG_SHAKE_ECDH_M2_SERVER = 4, // 96-byte
    
    LB_PAIR_TAG_SHAKE_ECDH_M3_CLIENT = 5, // 64-byte
    LB_PAIR_TAG_SHAKE_ECDH_M3_SERVER = 5, // 32-byte
    
    LB_PAIR_TAG_AUTH_SRP_M1_CLIENT_METHOD = 3,   //method;
    LB_PAIR_TAG_AUTH_SRP_M1_CLIENT_USERNAME = 4, //username;
    
    LB_PAIR_TAG_AUTH_SRP_M2_CLIENT_PUBLIC_KEY = 5, //256-byte
    LB_PAIR_TAG_AUTH_SRP_M1_SERVER_PBULIC_KEY = 5, //256-byte;
    LB_PAIR_TAG_AUTH_SRP_M1_SERVER_PUBLIC_SALT = 6, //SRP_lb  handshake salt;
    
    LB_PAIR_TAG_AUTH_SRP_M2_CLIENT_PROOF = 8, //20-byte
    LB_PAIR_TAG_AUTH_SRP_M2_SERVER_PROOF = 8, //20-byte
    
    LB_PAIR_TAG_AUTH_SRP_M3_CLIENT_SIGN_BODY = 9, //64-byte
    LB_PAIR_TAG_AUTH_SRP_M3_CLIENT_SIGN_HEMAC = 10, //16-byte
    LB_PAIR_TAG_AUTH_SRP_M3_CLIENT_PUBLIC_SALT = 11, //32-byte
    LB_PAIR_TAG_AUTH_SRP_M3_SERVER_SIGN_BODY = 9, //64-byte
    LB_PAIR_TAG_AUTH_SRP_M3_SERVER_SIGN_HEMAC = 10, //16-byte
    LB_PAIR_TAG_AUTH_SRP_M3_SERVER_PUBLIC_SALT = 11, //32-byte
} LB_PAIR_TAG;

enum LB_PAIR_SHAKE_STAGE // 握手加密阶段
{
    LB_PAIR_SHAKE_STAGE_INIT = 0,
    
    LB_PAIR_SHAKE_STAGE_M1_REQ,
    LB_PAIR_SHAKE_STAGE_M1_RSP,
    LB_PAIR_SHAKE_STAGE_M2_REQ,
    LB_PAIR_SHAKE_STAGE_M2_RSP,
    LB_PAIR_SHAKE_STAGE_M3_REQ,
    LB_PAIR_SHAKE_STAGE_M3_RSP,
    
    LB_PAIR_SHAKE_STAGE_M1,
    LB_PAIR_SHAKE_STAGE_M2,
    LB_PAIR_SHAKE_STAGE_M3,
    LB_PAIR_SHAKE_STAGE_FINISHED,
    LB_PAIR_SHAKE_STAGE_ERROR,
    LB_PAIR_SHAKE_STAGE_BADLENGTH,
};

typedef enum
{
    LB_PAIR_AUTH_STAGE_INIT = 0,
    
    LB_PAIR_AUTH_STAGE_M1_REQ,
    LB_PAIR_AUTH_STAGE_M1_RSP,
    LB_PAIR_AUTH_STAGE_M2_REQ,
    LB_PAIR_AUTH_STAGE_M2_RSP,
    LB_PAIR_AUTH_STAGE_M3_REQ,
    LB_PAIR_AUTH_STAGE_M3_RSP,
    
    LB_PAIR_AUTH_STAGE_M1,
    LB_PAIR_AUTH_STAGE_M2,
    LB_PAIR_AUTH_STAGE_M3,
    LB_PAIR_AUTH_STAGE_FINISHED,
    LB_PAIR_AUTH_STAGE_ERROR,
    LB_PAIR_AUTH_STAGE_BADLENGTH,
}LB_PAIR_AUTH_STAGE;

//typedef  struct
//{
//    SRP_lb         *srp_user_theirs;
//    cstr_lb       *srp_secret_theirs;
//    cstr_lb        *srp_proof_theirs;
//    cstr_lb        *srp_public_theirs;
//    cstr_lb        *srp_salt_theirs;
//    cstr_lb        *srp_auth_tag_theirs;
//    cstr_lb        *srp_epk_theirs;
//    SRP_METHOD_lb *srp_method_theirs;
//    uint8_t     public_salt_theirs[32];
//
//    SRP_lb         *srp_user_ours;
//    cstr_lb        *srp_secret_ours;
//    cstr_lb        *srp_proof_ours;
//    cstr_lb        *srp_public_ours;
//    cstr_lb        *srp_salt_ours;
//    cstr_lb        *srp_auth_tag_ours;
//    cstr_lb        *srp_epk_ours;
//    SRP_METHOD_lb *srp_method_ours;
//    uint8_t     public_salt_ours[32];
//
//    int8_t      srp_username[64];//用户  device name
//    int8_t      srp_password[64];//pin
//    uint8_t     srp_salt[16];
//    LB_PAIR_ATV atv;
//}LBAuthSession;

//typedef struct //对称加密会话,保存三步握手流程的参数
//{
//    uint8_t ed_private[64];
//    uint8_t ed_ours[32];
//    uint8_t ed_theirs[32];
//    uint8_t ed_ours_salt[32];
//    uint8_t ed_theirs_salt[32];
//    uint8_t ecdh_ours[32];    //ours ecdh_public_key;
//    uint8_t ecdh_theirs[32];  //theirs ecdh_public_key;
//    uint8_t ecdh_private[32]; //ecdh_private_key;
//    uint8_t ecdh_secret[32];  //compute a shared ecdh_secret_key;
//    //    pair_status   status;
//}LBPairSession;


typedef enum { //透传消息类型
    LBPassthManifestTypeError = -1,               // 异常信息
    LBPassthManifestTypePlayerInfo = 1,           // 播放数据
    LBPassthManifestTypeMediaAsset = 2,           // 媒资信息
    LBPassthManifestTypeHarass = 3,               // 防骚扰
    LBPassthManifestTypeConnect = 4,              // 连接
    LBPassthManifestTypeBarrageSetting = 5,       // 弹幕设置
    LBPassthManifestTypeBarrageAttribute = 6,     // 单条弹幕属性
    LBPassthManifestTypeUserInfo = 7,             // 用户信息
    LBPassthManifestTypeOfficeRemoteDeviceInfo = 8,// 办公版远端设备信息
    LBPassthManifestTypeOfficeRemoteDeviceCastState = 9,// 远端设备设备投屏状态同步
    LBPassthManifestTypeOfficeRemoteDeviceList = 10,// 获取远端设备列表
    LBPassthManifestTypeEventReverseControl = 11,//接收端反向控制发送端
    LBPassthManifestTypeMultiSpeedPlayControl = 12,    // 倍速播放
    LBPassthManifestTypeDecodability = 14,    // 解码能力
    LBPassthManifestTypeMultiSpeedPlay = 15, // 获取当前播放速率
    LBPassthManifestTypeMultiSpeedPlayResponse = 16,// 返回播放速率
    LBPassthManifestTypeInternalUse = 100,        // 乐播透传专用
    LBPassthManifestTypeExternalUse = 10000,      // 第三方透传通道
    LBPassthManifestTypeSecretListening = 17,     // 秘听功能
    LBPassthManifestTypeCloudMirror = 20,     // 云镜像
    LBPassthManifestTypeJournalFile = 21,     // 日志文件
    LBPassthManifestTypeRightsQuery = 22,     // 权益查询
    LBPassthManifestTypeRightsSynchronize = 23,  // 权益同步
    LBPassthManifestTypeMirrorAction = 26,  // 镜像操作 暂停/播放
    LBPassthManifestTypeListenRemoteControl = 28,   // 监听遥控器
    LBPassthManifestTypeRemoteControlEvent = 29,   // 遥控器事件同步
    LBPassthManifestTypeCacheVideoList = 30,   // 缓存视频列表
    LBPassthManifestTypePluginInfo = 33, // 微应用插件信息
    LBPassthManifestTypePluginMessage = 34, //微应用透传信息
    LBPassthManifestTypePluginClose = 35, // 关闭微应用
    LBPassthManifestTypeSetTemPrivateMode = 36, // 设置临时独占模式
    LBPassthManifestTypeMultiSpeedPlaySync = 37, // 播放速率同步
    LBPassthManifestTypeWaterRabbitUse = 48,     // 水兔透传专用
    LBPassthManifestTypeSendContorMessage = 49, // 发送端发送控制消息
    LBPassthManifestTypeQueryMirrorAndPushPortSet = 50, // 查询接收端镜像/推送设置接口
    LBPassthManifestTypeQueryMirrorAndPushReplySet = 51, // 查询接收端镜像/推送设置回复
    LBPassthManifestTypeCollectedAction = 52, /**< 收藏设备确认 */
    LBPassthManifestTypeCollectedActionResponse = 53, /**< 回复收藏确认结果 */
    LBPassthManifestTypeCloudFunctionResponse = 54, /**< 回复so库是否下载完成支持云镜像/云桌面 */
    LBPassthManifestTypeReceiverPlayerErrorInfo = 57, /**< 接收端播放错误信息 */
}LBPassthManifestType;

/**
 透传办公消息类型
 */
typedef NS_ENUM(NSInteger, LBPassthOfficeMsgType) {
    LBPassthOfficeMsgTypeNewIncrease = 1,   //新增
    LBPassthOfficeMsgTypeSupplement = 2,    //追加
    LBPassthOfficeMsgTypeNewRemove = 3,     //移除
};


/** 乐联透传数据解析版本 **/
#define kLBLinkPassthDataVer 1

@interface LBLelinkConst : NSObject

@end
