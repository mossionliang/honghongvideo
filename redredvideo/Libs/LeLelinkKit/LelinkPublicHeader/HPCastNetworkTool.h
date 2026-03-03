//
//  HPCastNetworkTool.h
//  HPBaseLib
//
//  Created by LTMAC on 2018/1/19.
//  Copyright © 2018年 HPPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HPCastNetworkTool : NSObject


/**
 授权认证接口

 @param appid 乐播开发者平台中注册的appID
 @param secretKey 乐播开发者平台中注册的密钥
 @param errPtr 错误信息，授权成功时为nil，授权失败时不为nil，可log出Error的信息以便调试
 @return 是否授权成功，YES：授权成功，NO：授权失败
 */
+ (BOOL)authWithAppid:( NSString * _Nonnull )appid secretKey:( NSString * _Nonnull )secretKey error:( NSError * _Nullable *)errPtr;

/// 判断是否已经授权成功
+ (BOOL)authIsSucceed;

/// 获取imserver连接的ip地址
/// @param callBlock callBlock
+ (void)getImServerCallBlock:(void(^)(BOOL succeed ,NSString *_Nullable ipserver,NSError * _Nullable error))callBlock;

/// 获取通用配置接口
/// @param callBlock callBlock
+ (void)getGeneralConfigCallBlock:(void(^)(BOOL succeed ,NSDictionary *_Nullable dictionary,NSError * _Nullable error))callBlock;

/**
 老的授权认证接口，仅限于乐播APP用，其他APP使用无效
 */
+ (void)loadSDKAuth;

#pragma mark - 清理SDK缓存数据
+ (void)cleanSDKCacheData;

#pragma mark - 域名

/// 设置域名环境：0：正式环境；1：测试环境test01；2：开发环境test02
+ (void)setDomainEnvironment: (NSInteger)env;

/// 获取当前的域名环境：0：正式环境；1：测试环境test01；2：开发环境test02
+ (NSInteger)getDomainEnvironment;

/// 传入一个生产域名，返回当前域名环境下的域名字符串
+ (NSString *)getCurrentEnvironmentDomainWith:(NSString *)domainString;

/**
 logreport接口地址
 
 @return logreport接口地址
 */
+ (NSString *_Nullable)logreport_interface;

/**
 switch接口地址: 广告开关接口，用于乐播投屏APP的启动广告开启和关闭的控制
 
 @return switch接口地址
 */
+ (NSString *_Nullable)switch_interface;

/**
 获取二维码短链解析接口地址

 @return 短链解析接口地址
 */
+ (NSString *_Nullable)shorturl_interface;

/**
 userapi接口地址

 @return userapi接口地址
 */
+ (NSString *_Nullable)userapi_interface;

/**
 report接口地址：数据上报地址接口，用户数据上报

 @return report接口地址
 */
+ (NSString *_Nullable)report_interface;

/**
 gslb接口地址

 @return gslb接口地址
 */
+ (NSString *_Nullable)gslb_interface;

/**
 push接口地址

 @return push接口地址
 */
+ (NSString *_Nullable)push_interface;

/**
 ad接口地址

 @return ad接口地址
 */
+ (NSString *_Nullable)ad_interface;

/**
 adengine接口地址

 @return adengine接口地址
 */
+ (NSString *_Nullable)adengine_interface;

/**
 获取设备管理接口地址
 
 @return 设备管理的接口地址
 */
+ (NSString *_Nullable)devicemgr_interface;

/**
 获取imdns服务接口域名
 
 @return imdns服务接口域名
 */
+ (NSString *_Nullable)imdns_interface;

/// 获取会员权益接口
+ (NSString *_Nullable)membershipAuth_interface;

/// 获取pin码接口
+ (NSString *_Nullable)pin_interface;

/// 获取tvapi接口
+ (NSString *_Nullable)tvapi_interface;

/// 获取conf接口
+ (NSString *_Nullable)conf_interface;

/// 会议室meeting接口
+ (NSString *_Nullable)meeting_interface;

/// saas 接口
+ (NSString *)saas_interface;

#pragma mark -

/// saas 公共header
+ (NSDictionary *_Nullable)requestHTTPHeaderField;

/// 获取im服务器ip地址
+ (NSString *_Nullable)imserver_ipAddress;
/**
 token 值

 @return token值
 */
+ (nullable NSString *)token_value;

/**
 获取APPID

 @return APPID
 */
+ (NSString *_Nullable)getAppid;

/**
 获取密钥

 @return 密钥
 */
+ (NSString *_Nullable)getSecretKey;

/**
 获取租户tid

 @return 租户tid
 */
+ (NSInteger )getTid;

/**
 获取服务器返回的搜索设备上报频控时间，用于控制服务器压力

 @return 时间，单位分钟
 */
+ (NSInteger)getScanTime;

/**
 设置用户id

 @param uid 用户id
 */
+ (void)setUserId:(NSString *_Nullable)uid;

/**
 描述: 获取是否配置通用开关和是否设置收藏ID
 return  NO：不可收藏, YES：可收藏
 */
+ (BOOL)getFavoriteIdAndSwitch;

/**
 获取用户id --> uuid

 @return 用户id
 */
+ (NSString *_Nullable)getUserId;

+ (void)setNickName:(NSString *_Nullable)nickName;
/// 获取用户昵称
+ (NSString *_Nullable)getNickName;

+ (void)setUserToken:(NSString *_Nullable)userToken;
/// 获取用户登录token
+ (NSString *_Nullable)getUserToken;

+ (void)setUserUID:(NSString *_Nullable)uid;
/// 获取用户的UID --> uid
+ (NSString *_Nullable)getUserUID;

+ (void)setEhid:(NSString *_Nullable)ehid;
// 获取租户设置的设备id
+ (NSString *_Nullable)getEhid;

+ (void)setUserMembership:(NSString *_Nullable)membership;
// 获取用户是否会员 0:非会员 1:会员
+ (NSString *)getUserMembership;

/**
 设置第三方检测

 @param u Tv端的u
 @param prot 投屏协议，1为airplay，2为乐联，3为DLNA，4为公网投屏
 @param url 投屏的url，需encode
 @param s sessionid 详见投屏协议的 sessionid 定义
 @param uri 详见投屏协议的 uri 定义
 @param actions 检测行为
 @param delegate 代理
 @param selector 代理方法
 */
//+ (void)setMonitorActionWithU:(NSString *_Nullable)u
//                     protocol:(NSInteger)prot
//                    URLString:(NSString *_Nullable)url
//                    sessionID:(NSString *_Nullable)s
//                        urlID:(NSString *_Nullable)uri
//                     monitors:(NSArray <LBMonitorAction *> *)actions
//                     delegate:(id)delegate
//                     selector:(SEL)selector;

+ (void)setAuth402:(BOOL)auth402;
+ (BOOL)auth402;

/// 用户的会员权益
/// @param userid 用户的userid
/// @param usertoken 用户登录的token
+ (void)interestsAuthWithUserId:(NSString *_Nullable)userid token:(NSString *_Nullable)usertoken;

/// 用户的会员权益
/// @param userid 用户的userid
/// @param usertoken 用户登录的token
/// @param nickname 用户昵称
+ (void)interestsAuthWithUserId:(NSString *_Nullable)userid token:(NSString *_Nullable)usertoken nickname:(NSString *_Nullable)nickname;

/// 用户的会员权益
/// @param userid 用户的userid -->  uuid
/// @param usertoken 用户登录的token  --> token
/// @param nickname 用户的昵称  -->  nickname
/// @param uid 用户的uid  -->  uid
+ (void)interestsAuthWithUserId:(NSString *_Nullable)userid token:(NSString *_Nullable)usertoken nickname:(NSString *_Nullable)nickname uid:(NSString *_Nullable)uid;

/// 用户的会员权益请求
/// @param userid 用户的userid -->  uuid
/// @param usertoken 用户登录的token  --> token
/// @param nickname 用户的昵称  -->  nickname
/// @param uid 用户的uid  -->  uid
/// @param ehid 设备的ehid  -->  企业付费的设备id （企业授权必传）
+ (void)interestsAuthWithUserId:(NSString *_Nullable)userid token:(NSString *_Nullable)usertoken nickname:(NSString *_Nullable)nickname uid:(NSString *_Nullable)uid ehid:(NSString *_Nullable)ehid;

/// 用户的会员权益请求
/// @param userid 用户的userid -->  uuid
/// @param usertoken 用户登录的token  --> token
/// @param nickname 用户的昵称  -->  nickname
/// @param uid 用户的uid  -->  uid
/// @param ehid 设备的ehid  -->  企业付费的设备id （企业授权必传）
/// @param otherParam 其他通用参数
+ (void)interestsAuthWithUserId:(NSString *_Nullable)userid token:(NSString *_Nullable)usertoken nickname:(NSString *_Nullable)nickname uid:(NSString *_Nullable)uid ehid:(NSString *_Nullable)ehid otherParam:(NSDictionary *)otherParam;

+ (void)senderTempAuthWithRuid:(NSString *_Nullable)ruid rappid:(NSString *_Nullable)rappid block:(void(^)(BOOL succeed ,NSArray *_Nullable response,NSError * _Nullable error))callBlock;

/// license授权请求
/// @param callBlock 授权结果
+ (void)licenseAuthRequestBlock:(void(^)(BOOL succeed ,NSDictionary *_Nullable response, NSError * _Nullable error))callBlock;

/// 获取license授权是否通过
/// @param error 错误
+ (BOOL)licenseAuthError:(NSError **)error;
/// 获得权益列表
+ (NSArray *)membershipInterestsError:(NSError * _Nullable *)error;

/// 环境标记，设置测试环境还是开发环境,0,测试服环境，1，开发服环境，默认测试服环境
+ (void)setEnvironment:(NSInteger)environment;

/// 获取环境标记 0,测试服环境，1，开发服环境
+ (NSInteger)environment;

/// 获取多协议设备时dlna是否隐藏开关
+ (BOOL)getMultiProtocolDeviceDLNAHideSwitch;
// 获取上传日志时间间隔是否超过24小时
+ (BOOL)abnormalUploadCountWithEt:(NSString *_Nullable)et;
// 获取配置接口是否有上传权限 notuploadlog_channel字段
+ (NSString *_Nullable)getAbnormalNotUploadLogChannel;
// 保存已经上传日志的错误码
+ (void)setAbnormalUploadCountWithEt:(NSString *_Nullable)et lastDate:(NSDate *)date;
// 日志上传
+ (void)logUploadWithEid:(NSString *_Nullable)eid et:(NSString *_Nullable)et phoneNum:(NSString *_Nullable)phoneNum filePath:(NSString *_Nullable)filePath callBlock:(void(^)(BOOL succeed ,NSString *_Nullable euqid,NSError * _Nullable error))callBlock;
+ (void)logUploadWithEid:(NSString *_Nullable)eid et:(NSString *_Nullable)et phoneNum:(NSString *_Nullable)phoneNum filePath:(NSString *_Nullable)filePath ls:(NSString *_Nullable)ls callBlock:(void(^)(BOOL succeed ,NSString *_Nullable euqid,NSError * _Nullable error))callBlock;

+ (void)logUploadWithEid:(NSString *_Nullable)eid et:(NSString *_Nullable)et phoneNum:(NSString *_Nullable)phoneNum filePath:(NSString *_Nullable)filePath ls:(NSString *_Nullable)ls extraInfo:(NSDictionary *_Nullable)extraInfo callBlock:(void(^)(BOOL succeed ,NSString *_Nullable euqid,NSError * _Nullable error))callBlock;

// 异常日志上报查询
+ (void)logReportAskCallback:(void(^)(BOOL succeed ,NSString *_Nullable eid,NSError * _Nullable error))callBlock;


/// 投屏码生成
/// @param name name
/// @param localIp 本地ip
/// @param localPort 本地Port
/// @param callBlock 回调（succeed:请求是否成功，response:请求结果，error:错误）
+ (void)castCodeGenerateWithName:(NSString *_Nullable)name localIp:(NSString *_Nullable)localIp localPort:(NSString *_Nullable)localPort callBlock:(void(^)(BOOL succeed ,NSDictionary *_Nullable response,NSError * _Nullable error))callBlock;


/// 投屏码解析
/// @param code 投屏码
/// @param callBlock  回调（succeed:请求是否成功，response:请求结果，error:错误）
+ (void)castCodeParsingWithCode:(NSString *_Nullable)code callBlock:(void(^)(BOOL succeed ,NSDictionary *_Nullable response,NSError * _Nullable error))callBlock;

/// id码解析
/// @param idCodeArray 投屏码数组
/// @param callBlock  回调（succeed:请求是否成功，response:请求结果，error:错误）
+ (void)idCodeParsingWithIdCodeArray:(NSArray *)idCodeArray callBlock:(void(^)(BOOL succeed ,NSDictionary *_Nullable response,NSError * _Nullable error))callBlock;

+ (void)tvStatusParsingWithTvUid:(NSString *_Nullable)tvUid tvAppid:(NSString *_Nullable)tvappid callBlock:(void(^)(BOOL succeed ,NSDictionary *_Nullable response,NSError * _Nullable error))callBlock;

+ (void)tvStatusParsingWithTvDsn:(NSString *_Nullable)tvDsn tvAppid:(NSString *_Nullable)tvappid callBlock:(void(^)(BOOL succeed ,NSDictionary *_Nullable response,NSError * _Nullable error))callBlock;

+ (void)getMdnsTXTInfoWithIpAddress:(NSString *_Nullable)ipAddress remotePort:(NSInteger)port block:(void(^)(BOOL requestSucceed,NSDictionary *_Nullable response))callBlock;
+ (void)getMdnsTXTInfoWithIpAddress:(NSString *_Nullable)ipAddress remotePort:(NSInteger)port timeout:(NSTimeInterval)interval block:(void(^)(BOOL requestSucceed,NSDictionary *_Nullable response))callBlock;

/// 搜索无设备监测
+ (void)searchNoDeviceMonitoringCallBlock:(void(^)(BOOL succeed ,NSArray *_Nullable response,NSError * _Nullable error))callBlock;
/// 获取搜索设备上报开关
+ (BOOL)getSearchDeviceDataReportSwitch;

/// 获取搜索设备上报时间间隔
+ (NSInteger)getSearchDeviceDataReportSeconds;

/// 获取tvapk的推荐名称提示
+ (NSString *)getTVApkDevNamePrompt;
/// sdk广告资源位
+ (void)getCastAdInfoWithCompleter:(void(^)(BOOL succeed ,NSArray *_Nullable response,NSError * _Nullable error))completer;


/// 获取广告配置
/// @param completer 回调
+ (void)getDAConfigWithCompleter:(void(^)(BOOL succeed ,NSDictionary *_Nullable response,NSError * _Nullable error))completer;


/// 获取广告资源
/// @param url 推送的url
/// @param timeout 请求超时时间
/// @param sessionid sessid
/// @param rappid 接收端id
/// @param ruid 接收端uid
/// @param rhid 接收端hid
/// @param udn dlna的udn
/// @param uri 乐联协议的uri
/// @param completer 回调
+ (void)getDAResourcesWithURL:(NSString *_Nullable)url timeout:(NSTimeInterval)timeout sessionid:(NSString *_Nullable)sessionid rappid:(NSString *_Nullable)rappid ruid:(NSString *_Nullable)ruid rhid:(NSString *_Nullable)rhid udn:(NSString *_Nullable)udn uri:(NSString *_Nullable)uri completer:(void(^)(BOOL succeed ,NSDictionary *_Nullable adData,NSInteger adrnum,NSInteger adtout,NSError * _Nullable error))completer;

/**
 查询用户连接关系数据
 
 @param phone 脱敏手机号
 */
+ (void)userInfoQueryLinkeWithPhone:(NSString *_Nullable)phone completer:(void(^)(BOOL succeed ,NSArray *_Nullable response,NSError * _Nullable error))completer;

/// 对设备进行风险检测
/// @param suid 接收端uid
/// @param said 接收端appid
/// @param completer 回调
+ (void)carryOnRiskDetectionWithSuid:(NSString *_Nullable)suid said:(NSString *_Nullable)said completer:(void(^_Nullable)(NSDictionary *_Nullable resDict, NSError *_Nullable error))completer;

#pragma mark - - -  设备收藏

/**
 描述: 设置收藏关系ID
   需要收藏所需的唯一ID
 @param devsID 收藏唯一标识ID
 */
+ (void)setFavoriteDevsID:(NSString *)devsID;

/**
 描述: 创建收藏设备关系接口
   需收藏的设备同步到乐播云保存
   
 @param appId 收端APPID
 @param uid   收端UID
 @param completer 返回结果
 */
+ (void)setFavoriteDevsWithAppId:(NSString *)appId devsUid:(NSString *)uid completer:(void(^)(BOOL succeed ,NSError * _Nullable error))completer;

/**
 描述: 删除收藏设备关系接口
 
 @param deives 收端APPID和收端UID
 @param completer 返回结果
 */
+ (void)deleteFavoriteDevices:(NSArray *)deives completer:(void(^)(BOOL succeed ,NSError * _Nullable error))completer;

/**
 描述: 清除/设置 别名接口
 
 @param appId 收端APPID
 @param uid   收端UID
 @param name  别名，当name为空时，则清除别名
 @param completer 返回结果
 */
+ (void)setFavoriteDevsAliasWithAppId:(NSString *)appId devsUid:(NSString *)uid aliasName:(NSString *)name completer:(void(^)(BOOL succeed ,NSError * _Nullable error))completer;

/**
 描述: 查询用户收藏设备接口
 
 @param online 在线状态,0:不在线, 1:在线, 传空:全部
 @param completer 返回结果
 */
+ (void)getFavoriteDevsOnline:(NSString *)online completer:(void(^)(BOOL succeed ,NSArray *_Nullable response ,NSError * _Nullable error))completer;


/**
 描述: 查询用户设备信息接口
 
 @param devs 收端APPID和收端uids
 @param completer 返回结果
 */
+ (void)queryDevices:(NSArray *)devs completer:(void(^)(BOOL succeed ,NSArray *_Nullable response ,NSError * _Nullable error))completer;

#pragma mark - - - 保存历史投屏设备

/**
 描述: 开启保存历史设备开关
    1.打开开关，投屏成功后自动保存设备记录到云端
    2.历史投屏设备按上次投屏时间，最多保存最新的10个设备（去重）
 
 @param enable YES：打开，NO：关闭; 默认 NO
 */
+ (void)enableHistorySwitch:(BOOL)enable;

/**
 描述: 创建历史投屏设备接口
   打开默认开关后和设置标识ID，投屏成功自动保存设备记录
 
 @param appId 收端APPID
 @param uid   收端UID
 @param completer 返回结果
 */
+ (void)setHistoryDevsWithAppId:(NSString *)appId devsUid:(NSString *)uid completer:(void(^)(BOOL succeed ,NSError * _Nullable error))completer;

/**
 描述: 删除历史投屏设备接口
 
 @param devs 收端APPID和收端UID
 @param type  删除类型  1：全部删除，2：部分删除
 @param completer 返回结果
 */
+ (void)deleteHistoryDevices:(NSArray *)devs delType:(NSString *)type completer:(void(^)(BOOL succeed ,NSError * _Nullable error))completer;

/**
 描述: 查询历史投屏设备接口
 
 @param online 在线状态,0:不在线, 1:在线, 传空:全部
 @param completer 返回结果
 */
+ (void)getHistoryDevsWithOnline:(NSString *)online completer:(void(^)(BOOL succeed ,NSArray *_Nullable response ,NSError * _Nullable error))completer;

#pragma mark - - - 连接设备关系
/**
 上报用户信息
 
 @param tvUid 收端uid
 @param appid 收端appid
 @param completer 回调
 */
+ (void)userInfoLinkeUploadWithTvId:(NSString *)tvUid appid:(NSString *)appid completer:(void(^)(BOOL succeed ,NSError * _Nullable error))completer;

/// 上报设备信息
/// @param tvUid 收端uid
/// @param appid 收端appid
/// @param other 附加参数
/// @param completer 回调
+ (void)userInfoLinkeUploadWithTvId:(NSString *)tvUid appid:(NSString *)appid otherParam:(NSDictionary *_Nullable)other completer:(void (^)(BOOL, NSError * _Nullable))completer;

/**
 查询用户连接关系数据
 
 @param phone 脱敏手机号
 @param online 设备在线状态
 */
+ (void)userInfoQueryLinkeWithPhone:(NSString *)phone online:(NSString *)online completer:(void(^)(BOOL succeed ,NSArray *_Nullable response,NSError * _Nullable error))completer;

/**
 描述: 清除/设置 别名接口
 
 @param appId 收端APPID
 @param uid   收端UID
 @param name  别名，当name为空时，则清除别名
 @param completer 返回结果
 */
+ (void)setConnectionDevsAliasWithAppId:(NSString *)appId devsUid:(NSString *)uid aliasName:(NSString *)name completer:(void(^)(BOOL succeed ,NSError * _Nullable error))completer;

/**
 描述: 删除连接设备关系接口
 
 @param deives 收端APPID和收端UID
 @param completer 返回结果
 */
+ (void)deleteConnectionDevices:(NSArray *)deives completer:(void(^)(BOOL succeed ,NSError * _Nullable error))completer;

@end

NS_ASSUME_NONNULL_END
