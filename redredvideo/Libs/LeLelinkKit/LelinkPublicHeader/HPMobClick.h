//
//  HPMobClick.h
//  HPAnalytics_SDK_Demo
//
//  Created by Mossion on 16/11/12.
//  Copyright © 2016年 Mossion. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class LBADInfo;

// 需要生成keychain,不懂请访问http://blog.sina.com.cn/s/blog_5971cdd00102vqgy.html
@interface HPKeyChainStore : NSObject

@end

typedef enum {
    AType = 1, // airplay
    MType, //   mirror
    LelinkVideoType,//乐联推送的视频
    LelinkMusicType,//乐联推送的音乐
    LePlayPhotoType,//play推送的照片
}CastType;

@interface HPMobClick : NSObject


/**
 防止两次logIn
 */
@property (nonatomic, assign) BOOL isLogin;

/**
 单例
 
 @return 实例
 */
+ (_Nonnull instancetype)shareInstance;

/**
 是否使用统计
 
 @param statics 是否开启统计
 */
+ (void)setStatics:(BOOL)statics;

/**
 设置app_id,sdk渠道和sdk版本，并开启统计
 
 @param appID      app_id
 @param channel    sdk渠道
 @param sdkVersion sdk版本号
 */
+ (void)startWithAppkey:(NSString *_Nullable)appID sdkChannel:(NSString *_Nullable)channel sdkVersion:(NSString *_Nullable)sdkVersion;


/// 获取授权次数
+ (NSInteger)getAuthContinueFailedCount;

/// 授权失败，判断是否需要授权失败次数递增
+ (void)authFailedAddCountIfNeeded;

@end


/**
 数据上报新模块功能：
 1、授权 ——> 请求授权，返回所有接口地址，暴露接口供上层调用
 2、登录上报 ——>（设备信息上报，已经上报了就再上报设备信息） 模块内部完成，初始化以及进入前台上报登录
 3、心跳 ——> 模块内部完成，根据心跳时间，上报心跳
 4、业务埋点 ——> 暴露业务埋点接口，供上层调用
 5、推送埋点 ——> 除了镜像之外的所有投屏行为
 6、镜像埋点 ——> 镜像埋点，能获取到则埋点，获取不到则不埋点
 7、登出上报 ——> 模块内部完成，进入后台上报登出
 */
@interface HPMobClick (NewModule)

/// 更新APP的功能id
/// @param functionSessionId APP的功能ID
- (void)updataAppFunctionSessionId:(NSString *_Nullable)functionSessionId DEPRECATED_MSG_ATTRIBUTE("已废弃");

- (void)updateInstall_id:(NSString *_Nullable)install_id;
- (void)updateBoot_id:(NSString *_Nullable)boot_id;
- (void)updateConn_session_id:(NSString *_Nullable)conn_session_id;
- (void)updateCast_session_id:(NSString *_Nullable)cast_session_id;

///**
// 连接埋点
//
// @param sn service_number 1：lelink连接 2：微信扫码连接 3.APP扫码连接 4：公网投屏连接 5：扫码公网 6：扫码乐联
// @param lt 持续时间，连接所需时间
// @param sta 状态：1 - 成功；2 - 失败
// @param et 失败必填。错误类型代码
// */
//- (void)reportConnWithSn:(NSString *_Nullable)sn latsettime:(NSString *_Nullable)lt status:(NSString *_Nullable)sta errortype:(NSString *_Nullable)et;

///**
// 连接埋点
//
// @param st 业务类型（默认为3）
// @param sn service_number 1：lelink连接 2：微信扫码连接 3.APP扫码连接 4：公网投屏连接 5：扫码公网 6：扫码乐联
// @param lt 持续时间，连接所需时间
// @param sta 状态：1 - 成功；2 - 失败
// @param et 失败必填。错误类型代码
//*/
//- (void)reportConnWithSt:(NSString *_Nullable)st sn:(NSString *_Nullable)sn latsettime:(NSString *_Nullable)lt status:(NSString *_Nullable)sta errortype:(NSString *_Nullable)et;
//
///// 连接埋点
///// @param st 业务类型（默认是3）
///// @param sn service_number 1：lelink连接 2：微信扫码连接 3.APP扫码连接 4：公网投屏连接 5：扫码公网 6：扫码乐联
///// @param lt 持续时间，连接所需时间
///// @param sta 状态：1 - 成功；2 - 失败
///// @param et 失败必填。错误类型代码
///// @param cs 主连接的sessionid
//- (void)reportConnWithSt:(NSString *_Nullable)st sn:(NSString *_Nullable)sn latsettime:(NSString *_Nullable)lt status:(NSString *_Nullable)sta errortype:(NSString *_Nullable)et cs:(NSString *_Nullable)cs;

- (void)reportConnWithSt:(NSString *_Nullable)st sn:(NSString *_Nullable)sn latsettime:(NSString *_Nullable)lt status:(NSString *_Nullable)sta errortype:(NSString *_Nullable)et cs:(NSString *_Nullable)cs p:(NSString *_Nullable)p;

/// 连接埋点
/// @param st 业务类型（默认是3）
/// @param sn service_number 1：lelink连接 2：微信扫码连接 3.APP扫码连接 4：公网投屏连接 5：扫码公网 6：扫码乐联
/// @param lt 持续时间，连接所需时间
/// @param sta 状态：1 - 成功；2 - 失败
/// @param et 失败必填。错误类型代码
/// @param cs 连接的sessionid
/// @param p 协议 1：lelink  2：airplay 3：dlna 5: lelink_v2 102:USB 6:Andlink 7:游密云镜像协议 8:miracast
/// @param isReceiver 是否作为接收端上报，默认NO
/// @param ec 错误code
- (void)reportConnWithSt:(NSString *_Nullable)st sn:(NSString *_Nullable)sn latsettime:(NSString *_Nullable)lt status:(NSString *_Nullable)sta errortype:(NSString *_Nullable)et cs:(NSString *_Nullable)cs p:(NSString *_Nullable)p isReceiver:(BOOL)isReceiver ec:(NSInteger)ec;

/// 连接埋点
/// @param st 业务类型（默认是3）
/// @param sn service_number 1：lelink连接 2：微信扫码连接 3.APP扫码连接 4：公网投屏连接 5：扫码公网 6：扫码乐联
/// @param lt 持续时间，连接所需时间
/// @param sta 状态：1 - 成功；2 - 失败
/// @param et 失败必填。错误类型代码
/// @param cs 连接的sessionid
/// @param p 协议 1：lelink  2：airplay 3：dlna 5: lelink_v2 102:USB 6:Andlink 7:游密云镜像协议 8:miracast
/// @param isReceiver 是否作为接收端上报，默认NO
/// @param ec 错误code
/// @param parameter 其他参数
- (void)reportConnWithSt:(NSString *_Nullable)st
                      sn:(NSString *_Nullable)sn
              latsettime:(NSString *_Nullable)lt
                  status:(NSString *_Nullable)sta
               errortype:(NSString *_Nullable)et
                      cs:(NSString *_Nullable)cs
                       p:(NSString *_Nullable)p
              isReceiver:(BOOL)isReceiver
                      ec:(NSInteger)ec
          otherParameter:(NSDictionary *_Nullable)parameter;

/// 连接时接收端活跃设备列表上报
/// @param cs 主连接session
/// @param dll 活跃的可连接设备列表，每个设备用  英文逗号,分隔每个设备描述信息用  英文#区分.例:A1#A2#A3,B1#B2#B3,C1##C3设备描述信息共计有六个,按顺序如下: receiver_device_type  : 接收端设备类型   0:非乐播sdk接收端    1:乐播sdk接收端 receiver_local_ip:当接收端设备类型为0时,可为空，ip地址.本地ip地址 receiver_mac:当接收端设备类型为0时,可为空接收端mac地址 receiver_manufacturer:当接收端设备类型为0时,可为空dlna的manufacturer，receiver_manufacturer_name:当接收端设备类型为0时,可为空，接收端的dlna的服务类型名称.同push埋点的  receiver_u字段.receiver_uid:接收端的uid，当接收端设备类型为1时,可为空
- (void)reportConnLiveWithCs:(NSString *_Nullable)cs dll:(NSString *_Nullable)dll;

/**
 5、推送 埋点 ——> 除了镜像之外的所有投屏行为
 
 @param s sessionID
 @param uri url id
 @param p 协议：1 - 乐联协议；2 - AirPlay协议； 3 - DLNA协议； 4 - 公网推送
 @param sta 状态：1 - 成功；2 - 失败
 @param sn 业务埋点序号：1 - 开始；2 - 推送
 */
- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn;

/**
 推送 埋点 ——> 除了镜像之外的所有投屏行为

 @param s sessionID
 @param uri url id
 @param p 协议：1 - 乐联协议；2 - AirPlay协议； 3 - DLNA协议； 4 - 公网推送
 @param sta 状态：1 - 成功；2 - 失败
 @param sn 业务埋点序号：1 - 开始；2 - 推送
 @param mt mimetype sn=1、3必填，媒体类型，枚举：101、音频；102、视频；103、图片；104、幻灯片
 */
- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt;

/**
 推送 埋点 ——> 除了镜像之外的所有投屏行为
 
 @param s sessionID
 @param uri url id
 @param p 协议：1 - 乐联协议；2 - AirPlay协议； 3 - DLNA协议； 4 - 公网推送
 @param sta 状态：1 - 成功；2 - 失败
 @param sn 业务埋点序号：1 - 开始；2 - 推送
 @param mt mimetype sn=1、3必填，媒体类型，枚举：101、音频；102、视频；103、图片；104、幻灯片
 @param reu sn=1时,必填；如果是dlna协议,则填写接收端的dlna的服务类型名称，如果是乐联包括新乐联协议,则填写接收端的u
 @param rem sn=1时且是dlna协议时,必填，填写dlna的manufacturer信息
 */
- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem;

/// 推送 埋点 ——> 除了镜像之外的所有投屏行为
/// @param s sessionID
/// @param uri url id
/// @param p 协议：1 - 乐联协议；2 - AirPlay协议； 3 - DLNA协议； 4 - 公网推送
/// @param sta 状态：1 - 成功；2 - 失败
/// @param sn 业务埋点序号：1 - 开始；2 - 推送
/// @param mt mimetype sn=1、3必填，媒体类型，枚举：101、音频；102、视频；103、图片；104、幻灯片
/// @param reu reu sn=1时,必填；如果是dlna协议,则填写接收端的dlna的服务类型名称，如果是乐联包括新乐联协议,则填写接收端的u
/// @param rem sn=1时且是dlna协议时,必填，填写dlna的manufacturer信息
/// @param cs 主连接的sessionid
- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs;


- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs mdd:(NSString *_Nullable)mdd mdn:(NSString *_Nullable)mdn;

- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs mdd:(NSString *_Nullable)mdd mdn:(NSString *_Nullable)mdn url:(NSString *_Nullable)url;

- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs mdd:(NSString *_Nullable)mdd mdn:(NSString *_Nullable)mdn url:(NSString *_Nullable)url ez:(NSString *_Nullable)ez iez:(NSString *_Nullable)iez;

- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs mdd:(NSString *_Nullable)mdd mdn:(NSString *_Nullable)mdn url:(NSString *_Nullable)url ez:(NSString *_Nullable)ez iez:(NSString *_Nullable)iez ec:(NSInteger)ec et:(NSString *_Nullable)et;

- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs mdd:(NSString *_Nullable)mdd mdn:(NSString *_Nullable)mdn url:(NSString *_Nullable)url ez:(NSString *_Nullable)ez iez:(NSString *_Nullable)iez ispl:(BOOL)ispl plj:(NSString *_Nullable)plj plid:(NSString *_Nullable)plid pli:(NSString *_Nullable)pli ec:(NSInteger)ec et:(NSString *_Nullable)et;

- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs mdd:(NSString *_Nullable)mdd mdn:(NSString *_Nullable)mdn isReceiver:(BOOL)isReceiver;

- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs mdd:(NSString *_Nullable)mdd mdn:(NSString *_Nullable)mdn isReceiver:(BOOL)isReceiver st:(NSString *_Nullable)st;

- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs mdd:(NSString *_Nullable)mdd mdn:(NSString *_Nullable)mdn isReceiver:(BOOL)isReceiver st:(NSString *_Nullable)st url:(NSString *_Nullable)url;

- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs mdd:(NSString *_Nullable)mdd mdn:(NSString *_Nullable)mdn isReceiver:(BOOL)isReceiver st:(NSString *_Nullable)st url:(NSString *_Nullable)url ispl:(BOOL)ispl plj:(NSString *_Nullable)plj plid:(NSString *_Nullable)plid pli:(NSString *_Nullable)pli;

/// 推送 埋点 ——> 除了镜像之外的所有投屏行为
/// @param s sessionID
/// @param uri url id
/// @param p 协议：1 - 乐联协议；2 - AirPlay协议； 3 - DLNA协议； 4 - 公网推送
/// @param sta 状态：1 - 成功；2 - 失败
/// @param sn 业务埋点序号：1 - 开始；2 - 推送 ; 110 -推送播放结束
/// @param mt mimetype sn=1、3必填，媒体类型，枚举：101、音频；102、视频；103、图片；104、幻灯片
/// @param reu reu sn=1时,必填；如果是dlna协议,则填写接收端的dlna的服务类型名称，如果是乐联包括新乐联协议,则填写接收端的u
/// @param rem sn=1时且是dlna协议时,必填，填写dlna的manufacturer信息
/// @param cs 主连接的sessionid
/// @param mdd dlna设备modelDescription字段
/// @param mdn dlna设备modelName字段
/// @param isReceiver 是否作为接收端上报，默认NO
/// @param ec error type  错误类型
/// @param et error domain 错误信息
- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs mdd:(NSString *_Nullable)mdd mdn:(NSString *_Nullable)mdn isReceiver:(BOOL)isReceiver st:(NSString *_Nullable)st url:(NSString *_Nullable)url ispl:(BOOL)ispl plj:(NSString *_Nullable)plj plid:(NSString *_Nullable)plid pli:(NSString *_Nullable)pli ez:(NSString *_Nullable)ez iez:(NSString *_Nullable)iez ec:(NSInteger)ec et:(NSString *_Nullable)et;


- (void)reportPushWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri protocol:(NSString *_Nullable)p status:(NSString *_Nullable)sta sn:(NSString *_Nullable)sn mt:(NSString *_Nullable)mt reu:(NSString *_Nullable)reu rem:(NSString *_Nullable)rem cs:(NSString *_Nullable)cs mdd:(NSString *_Nullable)mdd mdn:(NSString *_Nullable)mdn isReceiver:(BOOL)isReceiver st:(NSString *_Nullable)st url:(NSString *_Nullable)url ispl:(BOOL)ispl plj:(NSString *_Nullable)plj plid:(NSString *_Nullable)plid pli:(NSString *_Nullable)pli ez:(NSString *_Nullable)ez iez:(NSString *_Nullable)iez ec:(NSInteger)ec et:(NSString *_Nullable)et otherParameter:(NSDictionary *_Nullable)otherParameter;
/**
 镜像埋点 ——> 镜像埋点，能获取到则埋点，获取不到则不埋点，iOS 11之前可以开启一键镜像则使用此接口，否则不使用
 
 @param s sessionID, 填乐联连接的session id
 @param sta 状态，成功或着失败
 */
- (void)reportMirrorWithSessionID:(NSString *_Nullable)s status:(NSString *_Nullable)sta;

- (void)reportMirrorWithSessionID:(NSString *_Nullable)s status:(NSString *_Nullable)sta
                               st:(NSString *_Nullable)st
                               sn:(NSString *_Nullable)sn
                               cs:(NSString *_Nullable)cs
                            uriid:(NSString *_Nullable)uriid
                      otherParams:(NSDictionary *_Nullable)otherParams;

/// 镜像埋点
/// @param s sessionID, 填乐联连接的session id
/// @param sta 状态，成功或着失败
/// @param st 业务类型
/// @param sn 业务埋点序号
/// @param cs 主连接sessionId
/// @param uriid uri
/// @param otherParams 额外补充参数
/// @param isReceiver 是否作为接收端上报，默认NO
- (void)reportMirrorWithSessionID:(NSString *_Nullable)s status:(NSString *_Nullable)sta st:(NSString *_Nullable)st sn:(NSString *_Nullable)sn cs:(NSString *_Nullable)cs uriid:(NSString *_Nullable)uriid otherParams:(NSDictionary *_Nullable)otherParams  isReceiver:(BOOL)isReceiver;

- (void)reportKeepAliveWithSessionID:(NSString *_Nullable)s
                                  sn:(NSString *_Nullable)sn
                                 fps:(NSString *_Nullable)fps
                                  sr:(NSString *_Nullable)sr
                                  bi:(NSString *_Nullable)bi
                                 bps:(NSString *_Nullable)bps
                                  mt:(NSString *_Nullable)mt
                                  cs:(NSString *_Nullable)cs
                               uriid:(NSString *_Nullable)uriid;

/// 公网镜像流量埋点
/// @param s sessionID, 填乐联连接的session id
/// @param sn 业务埋点序号
/// @param fps 帧率
/// @param sr 视频分辨率 1920*720 1920*1024
/// @param bi 心跳批次技术，从0开始，每次增加1
/// @param bps 每秒字节数，Byte，大B
/// @param mt 心跳的媒体类型，101：音频；102：视频；102：图片；104：幻灯片
/// @param cs 主连接sessionId
/// @param uriid uri
/// @param isReceiver 是否作为接收端上报，默认NO
/// @param batchArray 质量json数据
/// @param otherParam 与 sn 平级的参数
- (void)reportKeepAliveWithSessionID:(NSString *_Nullable)s
                                  sn:(NSString *_Nullable)sn
                                 fps:(NSString *_Nullable)fps
                                  sr:(NSString *_Nullable)sr
                                  bi:(NSString *_Nullable)bi
                                 bps:(NSString *_Nullable)bps
                                  mt:(NSString *_Nullable)mt
                                  cs:(NSString *_Nullable)cs
                               uriid:(NSString *_Nullable)uriid
                          isReceiver:(BOOL)isReceiver
                          batchArray:(NSArray *_Nullable)batchArray
                          otherParam:(NSDictionary *_Nullable)otherParam;
/**
 业务埋点接口 :业务埋点 ——> 暴露业务埋点接口，供上层调用
 
 @param st 业务类型（必填）
 @param sn 业务编号（必填）
 @param pos 附加字典（选填）
 */
- (void)reportBusinessWithSt:(NSString *_Nullable)st andSn:(NSString *_Nullable)sn andPos:(NSString *_Nullable)pos;
- (void)reportBusinessWithSt:(NSString *_Nullable)st sn:(NSString *_Nullable)sn pos:(NSString *_Nullable)pos sessionID:(NSString *_Nullable)s status:(NSString *_Nullable)sta errorType:(NSString *_Nullable)et errorCode:(NSString *_Nullable)ec isReceiver:(BOOL)isReceiver;

/**
业务埋点接口, 用于投屏行为时调用的接口

@param st 业务类型（必填）
@param sn 业务编号（必填）
@param pos 附加字典（选填）
@param s 投屏相关业务产生行为时，sessionid（选填）
@param sta 状态 1：成功 0：失败
@param et 失败必填。错误类型代码
@param ec 播放器的错误码或程序的错误码
@param isReceiver 是否接收端
@param lbid 乐播会员域uuid
@param duration 页面停留时间,单位（毫秒）
@param ed 扩展数据,多个数据项拼接,每个数据项用英文逗号分隔.
*/
- (void)reportBusinessWithSt:(NSString *_Nullable)st sn:(NSString *_Nullable)sn pos:(NSString *_Nullable)pos sessionID:(NSString *_Nullable)s status:(NSString *_Nullable)sta errorType:(NSString *_Nullable)et errorCode:(NSString *_Nullable)ec isReceiver:(BOOL)isReceiver lbid:(NSString *_Nullable)lbid duration:(NSString *_Nullable)duration ed:(NSString *_Nullable)ed;

/**
 连接数据上报：发送端，发现可连接设备时（乐联协议），上报收发双端关键信息，通用的mDNS发现，协议中有 u 参数的，把连接信息上报上来即可

 @param ulist 接收端u 的list  有则必填 多个u用逗号隔开
 @param mlist 接收端mac 去冒号,多个mac用逗号隔开，有u的话mac可选
 */
- (void)reportRelationWithUlist:(NSString *_Nullable)ulist andMlist:(NSString *_Nullable)mlist;


/**
 连接数据上报：发送端，发现可连接设备时（乐联协议），上报收发双端关键信息，通用的mDNS发现，协议中有 u 参数的，把连接信息上报上来即可

 @param ulist 接收端u 的list  有则必填 多个u用逗号隔开
 @param mlist 接收端mac 去冒号,多个mac用逗号隔开，有u的话mac可选
 @param tch touch类型  0:发送端定时上报,(默认)   1:发送端主动上报,发送端在启动时或者在投屏时
 @param ltp local_timestamp发送端本地时间,touch为1时必填,在进行搜索设备上报之前生成.ltp的时间应该小于dlst里的时间; touch为0时不填
 @param dlst dlna_list
         搜索到的dlna设备列表,数据生成规则:
         dlna_manufacturer|dlna服务名称|dlna_mac|发现时的本地local_timestamp
         然后每个数据用英文逗号分隔,
         数据在生成时替换掉空格,替换掉英文逗号,替换掉管道符
         比如搜索到三个dlna设备,每搜索到一个记录下搜索到的时间,每个设备用逗号分隔
         如果在同一个设备上搜索到了u和dlna,则只报u,不用报dlna信息.
 */
- (void)reportRelationWithUlist:(NSString *_Nullable)ulist andMlist:(NSString *_Nullable)mlist tch:(NSString *_Nullable)tch ltp:(double)ltp dlst:(NSString *_Nullable)dlst;

- (void)reportRelationWithRb:(NSString *_Nullable)rb dlst:(NSString *_Nullable)dlst ltp:(double)ltp lte:(double)lte rpl:(NSString *_Nullable)rpl lrst:(NSString *_Nullable)lrst et:(NSString *_Nullable)et ec:(NSInteger)ec sdid:(NSString *_Nullable)sdid;

- (void)reportRelationWithRb:(NSString *_Nullable)rb dlst:(NSString *_Nullable)dlst ltp:(double)ltp lte:(double)lte rpl:(NSString *_Nullable)rpl lrst:(NSString *_Nullable)lrst et:(NSString *_Nullable)et ec:(NSInteger)ec;

- (void)reportRelationWithRb:(NSString *_Nullable)rb dlst:(NSString *_Nullable)dlst ltp:(double)ltp lte:(double)lte rpl:(NSString *_Nullable)rpl lrst:(NSString *_Nullable)lrst et:(NSString *_Nullable)et ec:(NSInteger)ec sdid:(NSString *_Nullable)sdid otherParam:(NSDictionary *_Nullable)parms;

/// 上报 browser
/// @param sn  service_number
/// @param evi 事件 ID，开始搜索和结束搜索事件 ID 用同一个
/// @param source_ip 发端 ip
/// @param sink_ips 匹配到的收端 ip
- (void)reportBrowserWithSn:(NSString *_Nonnull)sn evi:(NSString *_Nonnull)evi source_ip:(NSString *_Nullable)source_ip sink_ips:(NSString *_Nullable)sink_ips;

/// 上报 browser
/// @param sn  service_number
/// @param evi 事件 ID，开始搜索和结束搜索事件 ID 用同一个
/// @param source_ip 发端 ip
/// @param otherParameter 其他的参数
- (void)reportBrowserWithSn:(NSString *_Nonnull)sn evi:(NSString *_Nonnull)evi source_ip:(NSString *_Nullable)source_ip otherParameter:(NSDictionary *_Nullable)otherParameter;

/// 订单生成数据埋点 -- (业务类型 st 默认为100，后续需要则再扩展)
/// @param sn 业务埋点序号
/// @param ot 订单类型 sn=200 必填 sn=300  必填   枚举值1:普通订单 2:续费订单
/// @param prid 产品ID sn=200 必填 sn=300  必填
/// @param oid 产品ID sn=200 必填 sn=300  必填
/// @param prc 产品ID sn=200 必填 sn=300  必填
/// @param sta 1:成功  0:失败
/// @param et 失败必填。错误类型代码
- (void)reportOrderWithSn:(NSString *_Nullable)sn ot:(NSString *_Nullable)ot prid:(NSString *_Nullable)prid oid:(NSString *_Nullable)oid prc:(NSString *_Nullable)prc sta:(NSString *_Nullable)sta et:(NSString *_Nullable)et;

/// 订单支付上报 -- (业务类型 st 默认为100，后续需要则再扩展)
/// @param sn 业务埋点
/// @param pid 产品id
/// @param prc 产品编号
/// @param oid 订单id
/// @param taid 乐播的交易流水号（写订单id）
/// @param tpte 第三方支付类型(内购)
/// @param tpid 第三方支付系统支付流水号（写订单id）
/// @param rc 支付结果 1:成功 2:失败 0:未知  sn=200  必填
/// @param sta 1：成功 0：失败
/// @param et 错误类型代码   失败必填
- (void)reportOrderP_ayWithSn:(NSString *_Nullable)sn prid:(NSString *_Nullable)pid prc:(NSString *_Nullable)prc oid:(NSString *_Nullable)oid taid:(NSString *_Nullable)taid tpte:(NSString *_Nullable)tpte tpid:(NSString *_Nullable)tpid rc:(NSString *_Nullable)rc sta:(NSString *_Nullable)sta et:(NSString *_Nullable)et;

/*
 会员账号注册与登陆
 @param st st=100 注册   st=200 登陆
 @param sn 注册: sn=100  注册页面展现上报 sn=200 注册按钮点击上报 sn=300 注册结果上报
           登陆: sn=400 登陆入口页面展现上报 sn=500  登陆按钮点击上报 sn=600  登陆结果上报
 @param ste 0:未知 1.pc端扫码 2.tv端扫码 3.pc端原生 4.手机App原生 5.手机端H5交互
 @param sta 1:成功 0:失败
 @param et 错误类型代码  失败必填。
 @param lbid
 */
- (void)reportSguWithSt:(NSString *_Nullable)st sn:(NSString *_Nullable)sn ste:(NSString *_Nullable)ste sta:(NSString *_Nullable)sta et:(NSString *_Nullable)et lbid:(NSString *_Nullable)lbid;

- (void)initAuthSessionID;
//- (void)addNotifications;
- (void)reportLogin;
- (void)reportLogout;

/*
 投屏网络传输埋点
 
 @param cs 主连接session id
 @param suc 64位发送端uid
 @param uri_id 镜像url_id
 */
- (void)reportConnLiveWithCs:(NSString *_Nullable)cs suc:(NSString *_Nullable)suc uriId:(NSString *_Nullable)uriId;

/// 错误埋点
///
/// @param errorCode 错误码，实际错误
- (void)reportErrorWithErrorCode:(NSString *_Nullable)errorCode error:(NSError *_Nullable)error;

/// 错误埋点
///
/// @param errorCode 错误码，实际错误
/// @param isReceiver 是否作为接收端上报，默认NO
- (void)reportErrorWithErrorCode:(NSString *_Nullable)errorCode error:(NSError *_Nullable)error isReceiver:(BOOL)isReceiver;
@end

@interface HPMobClick (LBADReport)

/**
 用于后台统计发送端支持互动广告的库存量
 上报时机:
 发送端进行推送的时候进行上报.

 @param s sessionID和推送事件的sessionid一致.和事件绑定
 @param uri urlID和推送事件的uri_id一致,和事件绑定
 */
- (void)adReportOnPlayMediaWithSessionID:(NSString *_Nullable)s urlID:(NSString *_Nullable)uri;

/**
 请求广告上报

 @param adInfo 广告信息
 */
- (void)adReportOnRequestSuccessWithADInfo:(id _Nullable)adInfo;

/**
 开始show广告上报

 @param adInfo 广告信息
 */
- (void)adReportOnStartShowWithADInfo:(id _Nullable)adInfo;

/**
 结束show广告上报

 @param adInfo 广告信息
 @param duration 展示时长，单位秒
 @param state 状态：YES->展示成功，NO->展示失败
 */
- (void)adReportOnEndShowWithADInfo:(id _Nullable)adInfo duration:(NSInteger)duration state:(BOOL)state;


/// 广告库存上报
/// @param adInfo 广告模型
/// @param uri 投屏协议的uri
/// @param ruid 收端uid
/// @param rappid 收端appid
/// @param state 广告获取成功值
/// @param lp 投屏协议1：lelink  2：airplay 3：dlna 5: lelink_v2 102:USB 6:Andlink 7:游密云镜像协议 8:miracast
/// @param udn dlna设备中的udn的uuid
/// @param et 失败错误类型
/// @param ec 失败错误码
- (void)adReportInventoryWithADInfo:(id _Nullable)adInfo urlID:(NSString *_Nullable)uri ruid:(NSString *_Nullable)ruid rappid:(NSString *_Nullable)rappid state:(NSString *_Nullable)state lp:(NSString *_Nullable)lp udn:(NSString *_Nullable)udn et:(NSString *_Nullable)et ec:(NSString *_Nullable)ec;

/// <#Description#>
/// @param adInfo <#adInfo description#>
/// @param uri <#uri description#>
/// @param ruid <#ruid description#>
/// @param rappid <#rappid description#>
/// @param state <#state description#>
/// @param lp <#lp description#>
/// @param udn <#udn description#>
/// @param et <#et description#>
/// @param ec <#ec description#>
- (void)adReportPlayOnStartWithADInfo:(id _Nullable)adInfo urlID:(NSString *_Nullable)uri ruid:(NSString *_Nullable)ruid rappid:(NSString *_Nullable)rappid state:(NSString *_Nullable)state lp:(NSString *_Nullable)lp udn:(NSString *_Nullable)udn et:(NSString *_Nullable)et ec:(NSString *_Nullable)ec;

- (void)adReportPlayOnEndWithADInfo:(id _Nullable)adInfo urlID:(NSString *_Nullable)uri ruid:(NSString *_Nullable)ruid rappid:(NSString *_Nullable)rappid state:(NSString *_Nullable)state lp:(NSString *_Nullable)lp udn:(NSString *_Nullable)udn et:(NSString *_Nullable)et ec:(NSString *_Nullable)ec;

@end



