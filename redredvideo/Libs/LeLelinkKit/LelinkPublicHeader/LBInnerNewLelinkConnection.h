//
//  LBInnerNewLelinkConnection.h
//  AppleSenderSDK
//
//  Created by 王志军 on 10/24/18.
//  Copyright © 2018 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBLelinkBase.h"

NS_ASSUME_NONNULL_BEGIN

@class LBInnerLelinkDeviceModel;
@class LBInnerNewLelinkConnection;
@class LBLelinkConnectSocket;
@class LBLelinkPassthConnection;
@class LBLelinkPlayerConnection;

@protocol LBInnerNewLelinkConnectionDelegate <NSObject>
@optional

- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection onError:(NSError *)error;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection didConnectToDevice:(LBInnerLelinkDeviceModel *)device;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection disConnectToDevice:(LBInnerLelinkDeviceModel *)device;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection decoderList:(NSArray *)decoderArray;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection passthBody:(NSDictionary *)body;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection rightsSynchronous:(NSDictionary *_Nullable)rightsDict error:(NSError *_Nullable)error;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection mirrorActionType:(LBPassthMirrorActionType)mirrorActionType;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection eventReverseControlBodyDic:(NSDictionary *)bodyDic;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection remoteControlEventDic:(NSDictionary *)bodyDic;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection microAppMessage:(NSDictionary *)bodyDic;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection microAppClose:(NSDictionary *)bodyDic;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection waterRabbitDic:(NSDictionary *)bodyDic;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection queryMirrorAndPushReplySet:(NSDictionary *)mediaObject;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection collectServiceReplyMessage:(NSDictionary *)messge;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection cloudFunctionReplyMessage:(NSDictionary *)messge;
- (void)innerNewLelinkConnection:(LBInnerNewLelinkConnection *)connection publicManifestType:(NSInteger)manifestType bodyDic:bodyDic headDic:headDic;
@end

@interface LBInnerNewLelinkConnection : NSObject

@property (nonatomic, strong) LBInnerLelinkDeviceModel * deviceModel;
@property (nonatomic, weak) id<LBInnerNewLelinkConnectionDelegate> delegate;
@property (nonatomic, strong) LBLelinkConnectSocket *lelinkConnectSocket;
@property (nonatomic, strong) LBLelinkPassthConnection *passthConnection;
@property (nonatomic, weak) LBLelinkPlayerConnection *playerConnection;
@property (nonatomic, assign, readonly, getter=isConnected) BOOL connected;
@property (nonatomic, copy,readonly) NSString *sessionId;
@property (nonatomic, copy) NSString *tid;
@property (nonatomic, assign) BOOL openMirrorSwitchSpace;

- (instancetype)init;
- (instancetype)initWithDeviceModel:(LBInnerLelinkDeviceModel * _Nullable)deviceModel delegate:(id<LBInnerNewLelinkConnectionDelegate> _Nullable)delegate;

- (void)connect;
- (void)connectWithInnerLelinkDeviceModel:(LBInnerLelinkDeviceModel *)deviceModel;

- (void)disConnect;

- (void)sendCloudMirroRoomId:(NSString *)roomId type:(NSString *)type;
- (BOOL)canPassthRightsQuery;
- (void)passthRightsQuery;
- (BOOL)canPassthJournalFile;
- (void)passthJournalFileWithEid:(NSString *)eid euqid:(NSString *)euqid et:(NSString *)et;
- (BOOL)canPassthPerformedMirrorAction;
- (void)passthPerformedMirrorActionType:(LBPassthMirrorActionType)mirrorActionType;
- (BOOL)canPassthEventReverseControl;
- (void)passthEventReverseControl;
- (BOOL)canPassthRemoteControlEvent;
- (void)passthListenRemoteControlSwitch:(BOOL)swch;

- (BOOL)canPassthPluginInfo;
- (void)passthPlugAppId:(NSString* )appId type:(NSInteger)type pluginUrl:(NSString *)pluginUrl pluginproof:(NSString*)pluginproof loginInfo:(NSString* )loginInfo ;

- (BOOL)canPassthPluginMessage;
- (void)passthMicroAppMessageWithAppId:(NSString* )appId type:(NSInteger)type content:(NSString *)content;

- (BOOL)canPassthPluginClose;
- (void)passthMicroAppCloseWithType:(NSInteger)type;

- (BOOL)canPushVideoList;
- (BOOL)canSwitchAudioTrack;
- (BOOL)canSwitchTemporaryPrivateMode;
- (BOOL)canWaterRabbit;
- (BOOL)canCastSpace;
- (void)passthSwitchTemporaryPrivateMode:(BOOL)open;
- (void)passthWaterRabbitUseDataDic:(NSDictionary *)dataDic;

- (BOOL)canPassthContorMessage;
- (void)passthSendContorMessageWithContorType:(NSInteger)type contorCommands:(NSArray *)commands;
- (BOOL)canPassthMirrorAndPushSet;
- (void)passthQueryMirrorAndPushPortSet;
- (BOOL)canPassthFavorityLelinkServcie;
- (void)passthFavorityLelinkServcieWithName:(NSString *_Nullable)name;
- (BOOL)canPassthReceiverPlayerErrorInfo;

@end

NS_ASSUME_NONNULL_END
