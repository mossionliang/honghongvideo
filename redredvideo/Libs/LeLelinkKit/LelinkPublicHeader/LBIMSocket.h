//
//  LBIMSocket.h
//  LBIMServiceDemo
//
//  Created by 刘明星 on 2018/4/13.
//  Copyright © 2018年 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBLelinkConst.h"
#import "LBLelinkBase.h"

@class LBIMSocket;

/**
 连接代理
 */
@protocol LBIMSocketConnectionDelegate <NSObject>
/**
建立连接
*/
- (void)imSocketDidConnect;

/// IM 开始连接
- (void)imSocketDidStartRetryConnect;

/// IM 重连成功
- (void)imSocketDidRetryConnectSuccessfully;

/**
断开连接
*/
- (void)imSocketDidDisconnect;


/**
认证成功
*/
- (void)imSocketAuthSuccessful;

/**
im 超负载
*/
- (void)imSocketServerSuperLoad;


/**
im 连接超时
*/
- (void)imSocketServerConnectionTimeout;

/// 防骚扰 -- 等待
/// - Parameters:
///   - timeout: 超时时长（默认15s）
///   - type: 防骚扰方式 1: 遥控器确认方式； 2: 图形码验证方式
///   - pictures: 图片数组。当 type 为 2 时，才下发数据。
- (void)imSocketHarassWait:(NSInteger)timeout harassType:(LBLelinkHarassType)type pictures:(NSArray *_Nullable)pictures;

/**
 防骚扰 -- 允许
 */
- (void)imSocketHarassAllow;

/**
 更新接收端信息
 */
- (void)imSocketUpdateConnectBodyDic:(NSDictionary *_Nullable)connectBodyDic;

/**
 防骚扰 -- 拒绝
 */
- (void)imSocketHarassReject;

/**
 防骚扰 -- 拒绝，由于超时
 */
- (void)imSocketHarassRejectDueToTimeOut;

/**
 防骚扰 -- 拒绝，由于用户不允许
 */
- (void)imSocketHarassRejectDueToUserAction;

/**
 防骚扰 -- 拒绝，由于发端设备处于黑名单中
 */
- (void)imSocketHarassRejectDueToBlacklist;

/// 防骚扰 -- 拒绝，由于收端图片异常
- (void)imSocketHarassRejectDueToPicturesAbnormal;

/// 防骚扰 -- 拒绝，由于图片验证失败
- (void)imSocketHarassRejectDueToVerificationFailed;

/**
 是否支持在线图片和在线音频

 @param supportPhoto YES支持，NO不支持
 @param supportAudio YES支持，NO不支持
 */
- (void)imSocketIsSupportedPhoto:(BOOL)supportPhoto andAudio:(BOOL)supportAudio;


/**
权益同步

@param socket socket
@param rightsDict 权益字典
*/
- (void)imSocket:(LBIMSocket *_Nullable)socket passthRightsSynchronousDict:(NSDictionary *_Nullable)rightsDict;

- (void)imSocket:(LBIMSocket *_Nullable)socket passthManifestVerBody:(NSDictionary *_Nullable)body;

- (void)imSocket:(LBIMSocket *_Nullable)socket serverPassAppDataWithAction:(NSString *_Nullable)action body:(id _Nullable)body;

- (void)imSocket:(LBIMSocket *_Nullable)socket passthMirrorActionType:(LBPassthMirrorActionType)mirrorActionType;

- (void)imSocket:(LBIMSocket *_Nullable)socket passthEventReverseControlBodyDic:(NSDictionary *_Nullable)bodyDic;

- (void)imSocket:(LBIMSocket *_Nullable)socket passthRemoteControlEventDic:(NSDictionary *_Nullable)bodyDic;

- (void)imSocket:(LBIMSocket *_Nullable)socket passthMicroAppMessage:(NSDictionary *_Nullable)_NullablebodyDic;

- (void)imSocket:(LBIMSocket *_Nullable)socket passthMicroAppClose:(NSDictionary *_Nullable)bodyDic;

/// 普通消息通知
- (void)imSocket:(LBIMSocket *_Nullable)socket serverPassthNormalDataWithAction:(NSString *_Nullable)action body:(id _Nullable)body;
- (void)imSocket:(LBIMSocket *_Nullable)socket passthCloudAppCookieBodyDic:(NSDictionary *_Nullable)bodyDic;
- (void)imSocket:(LBIMSocket *_Nullable)socket mirrorStatus:(NSInteger)imPlayStatus reason:(NSInteger)reason;

/// 发送带指令的消息后，IM消息回调
- (void)imSocket:(LBIMSocket *_Nullable)socket operation:(NSInteger)operation bodyDic:(NSDictionary *_Nullable)bodyDic;

@end


/**
 播放控制代理
 */
@protocol LBIMSocketControlDelegate <NSObject>

- (void)imSocketPlayStatus:(HPIMSocketPlayState)imPlayStatus reason:(LBLelinkPlayStatusReason)reason;
- (void)imSocketProgress:(HPIMSocketProgress)imProgress;
- (void)imSocketCurrentMediaId:(NSString *)mediaId;
- (void)imSocketCurrentMediaInfo:(NSDictionary *_Nullable)mediaInfo;

@end

@interface HPIMMirrorSocketModel : NSObject      // 镜像信息
@property (nonatomic, copy)  NSString *pol;     // 支持的能力pol, 4,游密
@property (nonatomic, copy)  NSString *suid;    // 发送端的uid
@property (nonatomic, copy)  NSString *server;  // 传输的服务器入口地址
@property (nonatomic, copy)  NSString *timeout; // 超时时间
@property (nonatomic, copy)  NSString *sappid;  // 发送端appid
@property (nonatomic, copy)  NSString *roomid;  // 房间号
@property (nonatomic, copy)  NSString *sdkv;  // 发送端SDK版本
@property (nonatomic, copy)  NSString *sdid;  // 发送端唯一ID
@property (nonatomic, copy)  NSString *sm;     // 支持的能力sm
@property (nonatomic, copy)  NSString *vuuid;  // 登录的账号uuid
@property (nonatomic, copy)  NSString *sname;  // 发送端名称
@property (nonatomic, copy)  NSString *sid;  // 会话id
@property (nonatomic, copy)  NSString *csid;  // 主连接会话id
@property (nonatomic, copy)  NSString *uriid;  // 生成的uriid
@end

/**
 镜像代理
 */
@protocol LBIMMirrorControlDelegate <NSObject>

- (void)imsocket:(LBIMSocket *)socket connectWithMirrorModel:(HPIMMirrorSocketModel *)mirrorModel;  // 连接
- (void)imsocket:(LBIMSocket *)socket mirrorWithMirrorModel:(HPIMMirrorSocketModel *)mirrorModel;  // 镜像

@end

/**
 透传代理
 */
@protocol LBIMSocketPassthDelegate <NSObject>

@optional

- (void)imsocket:(LBIMSocket *)socket passthHarassinfo:(LBLelinkHarassInfo)harassinfo;
- (void)imsocket:(LBIMSocket *)socket passthReponseError:(NSError *)error;
- (void)imsocket:(LBIMSocket *)socket passthReceivedDataError:(NSError *)error;
- (void)imsocketPassthDidConnect:(LBIMSocket *)socket;
- (void)imsocket:(LBIMSocket *)socket passthInternalData:(id)dataObj handlerType:(LBLelinkPassthHandlerType)handlerType;
- (void)imsocket:(LBIMSocket *)socket passthExternalData:(id)dataObj handlerType:(LBLelinkPassthHandlerType)handlerType;
- (void)imsocket:(LBIMSocket *)socket passthWaterRabbitUseData:(id)dataObj handlerType:(LBLelinkPassthHandlerType)handlerType;
- (void)imsocket:(LBIMSocket *)socket passthManifestVerBody:(NSDictionary *)body;
- (void)imsocket:(LBIMSocket *)socket passthUploadLogFileBody:(NSDictionary *)body;
- (void)imsocket:(LBIMSocket *)socket passthUpdateTouchArray:(NSArray<LBLelinkTouch *> *)touches;
- (void)imsocket:(LBIMSocket *)socket passthPlaySpeed:(NSString *)rate;
- (void)imsocket:(LBIMSocket *)socket passthPlaySpeedResponseError:(NSError *)error;
- (void)imsocket:(LBIMSocket *)socket queryMirrorAndPushReplySet:(NSDictionary *)bodyDic;
- (void)imsocket:(LBIMSocket *)socket collectServiceReplyMessage:(NSDictionary *)bodyDic;
- (void)imsocket:(LBIMSocket *)socket cloudFunctionReplyMessage:(NSDictionary *)bodyDic;
/// 风险安全消息
- (void)imsocket:(LBIMSocket *)socket riskSecureMessage:(NSDictionary *)body;
- (void)imsocket:(LBIMSocket *)socket passthPublicManifestType:(LBPassthManifestType)manifestType bodyDic:(NSDictionary *)bodyDic headDic:(NSDictionary *)headDic;

@end

@interface LBIMSocketKeyDelegate : NSObject

@property (nonatomic,copy)NSString *sid;
@property (nonatomic,copy)NSString *ruid;
@property (nonatomic,copy)NSString *urlid;
@property (nonatomic,weak)id<LBIMSocketConnectionDelegate,LBIMSocketControlDelegate,LBIMSocketPassthDelegate> delegate;

@end

@interface LBIMSocket : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, strong) NSMutableArray<LBIMSocketKeyDelegate *> *connectionDelegateArray;
@property (nonatomic, strong) NSMutableArray<LBIMSocketKeyDelegate *> *controlDelegateArray;
@property (nonatomic, strong) NSMutableArray<LBIMSocketKeyDelegate *> *passthDelegateArray;

@property (nonatomic,weak) id<LBIMMirrorControlDelegate> mirrorControlDelegate;
@property (nonatomic, assign) HPIMSocketHarass imsocketHarassStatus;
@property (nonatomic, assign, getter=isConnected, readonly) BOOL connected;
/// IM 是否在重连中
@property (nonatomic, assign, readonly, getter=isRetryIMConnecting) BOOL retryIMConnecting;


- (void)connectIMSocket;
- (void)disConnectIMSocket;
- (void)sendMessage:(id)message;
/// 发送带指令的消息
- (void)sendMessageWithOperation:(NSInteger)operation andBody:(id)bodyData;
- (NSString *)localIp;
- (uint16_t)localPort;
- (void)cleanInvalidDelegate:(NSMutableArray<LBIMSocketKeyDelegate *> *)delegateArray;
@end
