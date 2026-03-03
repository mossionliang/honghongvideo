//
//  LBIMConnection.h
//  AppleSenderSDK
//
//  Created by 刘明星 on 2018/4/12.
//  Copyright © 2018年 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBLelinkBase.h"
#import "LBLelinkConst.h"

@class LBIMConnection;
@class LBIMServiceModel;
@class LBIMSocket;

NS_ASSUME_NONNULL_BEGIN

@protocol LBIMConnectionDelegate <NSObject>

@optional
- (void)imConnection:(LBIMConnection *)imConnection onError:(NSError *)error;
- (void)imConnection:(LBIMConnection *)imConnection didConnectToService:(LBIMServiceModel *)serviceModel;
- (void)imConnection:(LBIMConnection *)imConnection disConnectToService:(LBIMServiceModel *)serviceModel;

/// IM 重连回调
/// - Parameters:
///   - imConnection: imConnection
///   - serviceModel: 服务模型
///   - reconnectCount: 重连次数
- (void)imConnection:(LBIMConnection *)imConnection reconnectToService:(LBIMServiceModel *)serviceModel reconnectCount:(NSInteger)reconnectCount;
- (void)imConnection:(LBIMConnection *)imConnection harassTime:(NSInteger)timeout harassType:(LBLelinkHarassType)type pictures:(NSArray *_Nullable)pictures;
- (void)imConnection:(LBIMConnection *)imConnection passthRightsSynchronousDict:(NSDictionary *_Nullable)rightsDict error:(NSError *_Nullable)error;
/// 连接后，得到接收端信息
- (void)imConnection:(LBIMConnection *)connection passthManifestVerBody:(NSDictionary *)body;
- (void)imConnection:(LBIMConnection *)connection serverPassAppDataWithAction:(NSString *)action body:(id)body;
- (void)imConnection:(LBIMConnection *)connection passthMirrorActionType:(LBPassthMirrorActionType)mirrorActionType;
- (void)imConnection:(LBIMConnection *)connection passthEventReverseControlBodyDic:(NSDictionary *)bodyDic;
- (void)imConnection:(LBIMConnection *)connection passthRemoteControlEventDic:(NSDictionary *)bodyDic;
- (void)imConnection:(LBIMConnection *)connection passthMicroAppMessage:(NSDictionary *)bodyDic;
- (void)imConnection:(LBIMConnection *)connection passthNormalMessage:(NSDictionary *)bodyDic;
- (void)imConnection:(LBIMConnection *)connection passthMicroAppClose:(NSDictionary *)bodyDic;
- (void)imConnection:(LBIMConnection *)connection passthWaterRabbitData:(id)dataObj handlerType:(LBLelinkPassthHandlerType)handlerType;
- (void)imConnection:(LBIMConnection *)connection passthQueryMirrorAndPushReplySet:(NSDictionary *)bodyDic;
- (void)imConnection:(LBIMConnection *)connection passthCollectServiceReplyMessage:(NSDictionary *)bodyDic;
- (void)imConnection:(LBIMConnection *)connection passthRiskSecureMassege:(NSDictionary *)bodyDic;
- (void)imConnection:(LBIMConnection *)connection passthCloudFunctionReplyMessage:(NSDictionary *)bodyDic;
- (void)imConnection:(LBIMConnection *)connection passthUploadLogFileBodyDic:(NSDictionary *)bodyDic;
- (void)imConnection:(LBIMConnection *)connection passthPublicManifestType:(LBPassthManifestType)manifestType bodyDic:(NSDictionary *)bodyDic headDic:(NSDictionary *)headDic;
- (void)imConnection:(LBIMConnection *)connection passthCloudAppCookieBodyDic:(NSDictionary *)bodyDict;
/**
 自定义的业务错误代理回调
 比如：查询当前设备是否在会议中时，403（TV离线）错误时的回调

 @param connection 当前连接
 @param error 错误信息
 */
- (void)imConnection:(LBIMConnection *)connection onBusinessError:(NSError *)error;
- (void)imConnection:(LBIMConnection *)connection mirrorStatus:(NSInteger)playStatus reason:(NSInteger)reason;
/// 发送带指令的消息后，IM消息回调
- (void)imConnection:(LBIMConnection *)connection operation:(NSInteger)operation bodyDic:(NSDictionary *_Nullable)bodyDic;

@end

@protocol LBIMConnectionReverseControlDelegate <NSObject>

- (void)imConnection:(LBIMConnection *)connection updateTouchArray:(NSArray<LBLelinkTouch *> *)touches;

@end


/**
 透传代理
 */
@protocol LBIMTransDelegate <NSObject>

@optional
- (void)imConnection:(LBIMConnection *)connection passthHarassinfo:(LBLelinkHarassInfo)harassinfo;
- (void)imConnection:(LBIMConnection *)connection passthReponseError:(NSError *)error;
- (void)imConnection:(LBIMConnection *)connection passthReceivedDataError:(NSError *)error;
- (void)imConnection:(LBIMConnection *)connection passthInternalData:(id)dataObj handlerType:(LBLelinkPassthHandlerType)handlerType;
- (void)imConnection:(LBIMConnection *)connection passthExternalData:(id)dataObj handlerType:(LBLelinkPassthHandlerType)handlerType;
- (void)imConnection:(LBIMConnection *)connection passthPlaySpeed:(NSString *)rate;
- (void)imConnection:(LBIMConnection *)connection passthPlaySpeedResponseError:(NSError *)error;

@end


@interface LBIMConnection : NSObject

@property (nonatomic, strong) LBIMServiceModel *_Nullable serviceModel;
@property (nonatomic, weak) id<LBIMConnectionDelegate> delegate;
@property (nonatomic, weak) id<LBIMTransDelegate> transDelegate;
@property (nonatomic, weak) id<LBIMConnectionReverseControlDelegate> reverseControlDelegate;
@property (nonatomic, assign, readonly, getter=isConnected) BOOL connected;
@property (nonatomic, strong) LBIMSocket *imSocket;
//@property (nonatomic, copy) NSString *sid;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *tid; // 乐播云租户ID
@property (nonatomic, copy) NSString *_Nullable sm;
@property (nonatomic, assign)BOOL enableMultiTunnels;
// 自动重连IM
@property (nonatomic, assign)BOOL autoReconnect;

@property (nonatomic, assign, getter=isSupportPhoto, readonly) BOOL supportPhoto;
@property (nonatomic, assign, getter=isSupportAudio, readonly) BOOL supportAudio;
@property (nonatomic, assign) BOOL openPicAntiHarass; /**< 图形验证防骚扰开关 */
@property (nonatomic, assign) BOOL openMirrorSwitchSpace;

- (instancetype)init;
- (instancetype)initWithIMService:(LBIMServiceModel * _Nullable)serviceModel delegate:(id<LBIMConnectionDelegate> _Nullable)delegate;

- (void)connectToIMServiceModel;

- (void)disConnect;



- (void)thirdPartPassthIMDataWithBodyDict:(NSDictionary *)bodydict handlerType:(LBLelinkPassthHandlerType)handlerType targetAppid:(NSString *_Nullable)targetAppid;

- (void)leboPassthIMDataWithDatadict:(NSDictionary *)dataDict handlerType:(LBLelinkPassthHandlerType)handlerType targetAppId:(NSString *_Nullable)targetAppId;
/// 水兔合并所需的透传协议
- (void)waterRabbitPassthIMDataWithDataDict:(NSDictionary *)dataDict handlerType:(LBLelinkPassthHandlerType)handlerType targetAppId:(NSString *_Nullable)targetAppId;

- (void)impassthErrorInfoWithErrorCode:(NSInteger)errorcode error:(NSString *)error handlerType:(LBLelinkPassthHandlerType)handlerType targetAppid:(NSString *_Nonnull)targetAppId;

- (BOOL)canPassthJournalFile;
- (void)impassthJournalFileWithEid:(NSString *)eid euqid:(NSString *)euqid et:(NSString *)et targetAppid:(NSString *_Nullable)targetAppId;

- (void)passthGetPlaySpeed;
- (void)passthSetPlaySpeedWithRate:(double)rate;

- (BOOL)canPassthRightsQuery;
- (void)passthRightsQuery;
- (BOOL)canPassthPerformedMirrorAction;
- (void)passthPerformedMirrorActionType:(LBPassthMirrorActionType)mirrorActionType;
- (BOOL)canPassthEventReverseControl;
- (void)passthEventReverseControl;
- (BOOL)canPassthRemoteControlEvent;
- (void)passthListenRemoteControlSwitch:(BOOL)swch;
- (void)passthCacheVideoList:(NSArray *)urlArray startIndex:(NSInteger)index;
- (BOOL)canPushVideoList;
- (BOOL)canWaterRabbit;
- (BOOL)canCastSpace;

- (BOOL)canPassthPluginInfo;
- (void)passthPlugAppId:(NSString* )appId type:(NSInteger)type pluginUrl:(NSString *)pluginUrl pluginproof:(NSString*)pluginproof loginInfo:(NSString* )loginInfo ;

- (BOOL)canPassthPluginMessage;
- (void)passthMicroAppMessageWithAppId:(NSString* )appId type:(NSInteger)type content:(NSString *)content;

- (BOOL)canPassthPluginClose ;
- (void)passthMicroAppCloseWithType:(NSInteger)type;
- (BOOL)canSwitchAudioTrack;
- (BOOL)canSwitchTemporaryPrivateMode;
- (void)switchTemporaryPrivateMode:(BOOL)open;

- (BOOL)canPassthContorMessage;
- (void)passthSendContorMessageWithContorType:(NSInteger)type contorCommands:(NSArray *)commands;
- (BOOL)canPassthMirrorAndPushSet;
- (void)passthQueryMirrorAndPushPortSet;
- (BOOL)canPassthFavorityLelinkServcie;
- (void)passthFavoriteActionWithName:(NSString *_Nullable)name;
/// 通知接收端验证防骚扰图片
/// - Parameters:
///   - picId: 图片ID
- (void)pushPictureComfirmWithPicId:(NSString *_Nullable)picId;
/// 通知接收端取消防骚扰验证
- (void)cancelHarassVerification;
- (void)passthCloudAppUid:(NSString *)uid rtcUid:(NSString *)rtcUid domain:(NSString *)domain cookieBodyDic:(NSString * _Nullable)cookieBodyDic;
- (BOOL)canPassthReceiverPlayerErrorInfo;
#pragma mark - 通过 IM TCP 通道，进行消息发送

- (void)imSendMessageWithOperation:(NSInteger)operation andBody:(id)bodyData;

#pragma mark -

@end

NS_ASSUME_NONNULL_END
