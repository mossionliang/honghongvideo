//
//  LBAppGroupUserDefault.h
//  LBReplayKit
//
//  Created by lbkj on 2019/12/3.
//  Copyright © 2019 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - APP主程序：主动存值
/// 发送端app的token
static NSString * const kMirror_appToken_Key = @"kMirror_appToken_Key";
/// 收端uuid
static NSString * const kMirror_receiverUuid_Key = @"kMirror_receiverUuid_Key";
/// 收端登录状态（"收端登录状态:-1-未知,0-未登录,1-登录"）
static NSString * const kMirror_receiverIsLogin_Key = @"kMirror_receiverIsLogin_Key";

#pragma mark - 非APP主程序：主动存值
/// pushMirror接口成功时返回的字典类型数据key
static NSString * const kMirror_pushMirrorDict_Key = @"kMirror_pushMirrorDict_Key";

#pragma mark -
// 乐联镜像设备模型
@interface LBDeviceInUserDefaultModel : NSObject
@property (nonatomic, copy) NSString *lelinkServiceName;    // 服务名称
@property (nonatomic, copy) NSString *lelinkIPString;       // IP地址
@property (nonatomic, copy) NSString *lelinkPort;           // 端口号
@property (nonatomic, copy) NSString *version;              // 乐联协议版本
@property (nonatomic, copy) NSString *mirrorStatus;         // 0,选中断开镜像/1,选中镜像/2,已连接/3,已断开/4,已镜像/5,断开镜像
@property (nonatomic, copy) NSString *mirrorType;           // 0,局域网镜像，1,游密云镜像 默认局域网镜像
@property (nonatomic, copy) NSString *tvUID;                // 唯一标识
@property (nonatomic, copy) NSString *appID;
@property (nonatomic, copy) NSString *port;             // 端口
@property (nonatomic, copy) NSString *remotePort;       // 远端端口
@property (nonatomic, copy) NSString *roomId;           // 房间号
@property (nonatomic, copy) NSString *userId;           // 用户ID
@property (nonatomic, copy) NSString *uuid;             // uuid
@property (nonatomic, copy) NSString *sessionId;        // sessionId
@property (nonatomic, copy) NSString *mirrorReconnect;  // mirrorReconnect
@property (nonatomic, copy) NSString *mirrorPort;
@property (nonatomic, copy) NSString *et;               // 错误验证码


// 镜像质量埋点时间间隔，单位s
@property (nonatomic, copy) NSString *mirrorStatisticsInterval;   // 埋点时间间隔，单位s
@property (nonatomic, copy) NSString *mirrorYoumeAuth;  // 游密镜像无缝切换权限， 0 - 无权限，1 - 有权限
@property (nonatomic, copy) NSString *defaultChannel; // 1 - 默认乐联, 2 - 游密云镜像, 3 - rudp

@property (nonatomic, assign) BOOL openPictureAntiHarass; /**<图形防骚扰开关 */


+ (instancetype)deviceInfoWithDict:(NSDictionary *)dict;
- (NSDictionary *)deviceInfoDict;

@end

@interface LBAppGroupUserDefault : NSObject
@property (nonatomic, copy, readonly) NSString *lelinkIPString;
@property (nonatomic, assign, readonly) NSInteger lelinkPort;


+ (instancetype)shareInstance;

- (void)setAppGroupId:(NSString *)appGroupId;

#pragma mark - 通用存、取、删方法
- (void)saveValue:(id)value forKey:(NSString *)key;
- (id)getValueForKey:(NSString *)key;
- (void)removeKey:(NSString *)key;
#pragma mark -

- (void)setMaxMirrorDeviceAmount:(NSUInteger)amount;

- (void)addDevice: (LBDeviceInUserDefaultModel *)deviceInfo;

- (void)removeDevice: (LBDeviceInUserDefaultModel *)deviceInfo;

- (void)updateMirrorDeviceStatus: (LBDeviceInUserDefaultModel *)mirrorDeviceStatus;

- (LBDeviceInUserDefaultModel *)getMirrorDeviceStatus;

- (LBDeviceInUserDefaultModel *)getDefaultDeviceModel;

- (NSString *)getDefaultDeviceMirrorType;

- (void)cleanAllDevice;

- (NSArray <LBDeviceInUserDefaultModel *> *)getMirrorDeviceList;

- (void)updateVideoCount:(NSInteger)videoCount audioCount:(NSInteger)audioCount;

- (NSInteger)videoCount;

- (NSInteger)audioCount;

/// 保存镜像的风险信息
- (void)addMirrorRiskErrorInfo:(NSDictionary *)errorInfo;
/// 获取镜像的风险信息
- (NSDictionary *)getMirrorRiskErrorInfo;
/// 保存人脸识别信息
- (void)addMirrorRiskFaceRecognition:(NSDictionary *)errorInfo;
/// 获取人脸识别信息
- (NSDictionary *)getMirrorFaceRecognitionMessage;

/// 保存镜像接口（pushmirror）错误信息
- (void)addMirrorOccurredErrorWithErrorInfo:(NSDictionary *)errorInfo;
/// 获取收发双端只支持游密镜像能力的信息
- (NSDictionary *)getMirrorOccurredErrorErrorInfo;

- (void)addZegoMirrorPublisherStreamQuality:(NSDictionary *)quality;
- (NSDictionary *)getZegoMirrorPublisherStreamQuality;
- (void)removeZegoMirrorPublisherStreamQuality;


/// 乐联镜像推流信息: 目前只有帧率和码率
/// - Parameter quality: 流信息
- (void)addLelinkMirrorPublisherStreamQuality:(NSDictionary *)quality;
- (NSDictionary *)getLelinkMirrorPublisherStreamQuality;
- (void)removeLelinkMirrorPublisherStreamQuality;

@end

NS_ASSUME_NONNULL_END
