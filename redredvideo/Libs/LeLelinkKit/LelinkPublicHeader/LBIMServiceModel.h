//
//  LBIMServiceModel.h
//  AppleSenderSDK
//
//  Created by 刘明星 on 2018/4/12.
//  Copyright © 2018年 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBLelinkBase.h"

@interface LBIMServiceModel : NSObject

/** 接收端的u 对应LBLelinkService中的tvUID*/
@property (nonatomic, copy) NSString *uid;
/** 服务名称，即搜索到的接收端的名称 */
@property (nonatomic, copy) NSString *lelinkServiceName;
/**（非必要的）别名，开发者可开放出来供用户修改设备名称的别名，方便用户自己识别和区分自己的设备 */
@property (nonatomic, copy) NSString *alias;
/**（非必要的）是否为常用，开发者可开放出来供用户设置设备为常用设备 */
@property (nonatomic, assign) BOOL isFrequentlyUsed;
/** (非必要的)曾经连接过的设备 */
@property (nonatomic, assign) BOOL isOnceConnected;
/** (非必要的)上次连接过的设备 */
@property (nonatomic, assign) BOOL isLastTimeConnected;
/** 是否从二维码获得的设备 */
@property (nonatomic, assign, getter=isFromQRCode) BOOL fromQRCode;
/** 发送端登陆的账号，接收端拿他与自己的登陆账号判断，是否同一用户，同一用户就不弹防骚扰提示 */
@property (nonatomic, copy) NSString *vuuid;

/** 平台类型0:未知  1:Android  2:IOS  3:PC */
@property (nonatomic, copy) NSString *pt; // 转为int使用
/** 本地wifi的BSSID */
@property (nonatomic, copy) NSString *bssid;
/** 本地服务IP */
@property (nonatomic, copy) NSString *localIp;
/** 本地服务端口 */
@property (nonatomic, copy) NSString *localPort;

/** TV端支持的传输协议，1：腾讯云 2：直接转发 3：声网 4：游密，多个，号分开，例如1，2 */
@property (nonatomic, copy) NSString *pol;

/** 接收端的u */
@property (nonatomic, copy) NSString *receiveU;

/** 接收端的appid*/
@property (nonatomic, copy) NSString *rappId;

/// 来源方式
@property (nonatomic, assign) LBLelinkServiceSourceStyle sourceStyle;

/// 连接body，包含接收端信息
@property (nonatomic, strong)NSDictionary *connectBodyDic;
/** 多通道切换标示， 为 3 支持多通道切换 */
@property (nonatomic, copy) NSString *tunnels;

/// 是否支持水兔项目功能（即会议功能）
@property (nonatomic, assign) BOOL wr;

@property (nonatomic, assign) BOOL isCommerce;      /**< 是否商显TV端 */

/// 搜到的原始数据（投屏码、扫码解析得到长链的数据）
@property (nonatomic, strong) NSDictionary *_Nullable originalData;


/**
 重写父类的比较方法
 
 @param object 比较的对象
 @return 是否等同，YES：等同，NO：不等同
 */
- (BOOL)isEqual:(id)object;

/**
 提供本类对象的等同性判断方法
 
 @param object 比较的对象
 @return 是否等同，YES：等同，NO：不等同
 */
- (BOOL)isEqualToLBIMServiceModel:(LBIMServiceModel *)object;

@end
