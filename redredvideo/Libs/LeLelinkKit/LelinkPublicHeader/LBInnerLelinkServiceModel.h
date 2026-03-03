//
//  LBInnerLelinkServiceModel.h
//  LBInnerLelinkDemo
//
//  Created by 刘明星 on 2018/4/16.
//  Copyright © 2018年 深圳乐播科技有限公司. All rights reserved.
//

#import "LBBaseModel.h"

@interface LBInnerLelinkServiceModel : LBBaseModel

/**
 *  service
 */
@property (nonatomic,strong)NSNetService *service;

@property (nonatomic,copy)NSString *name;

/**
 *  ip地址
 */
@property (nonatomic,copy)NSString *ipAddress;

/**
 *  端口(发布端口)
 */
@property (nonatomic,assign)NSInteger port;

/**
 *  remote端口(远程安装端口)
 */
@property (nonatomic,assign)NSInteger remotePort;

/**
 *  leboPlayPort(airplay端口)
 */
@property (nonatomic,assign)NSInteger leboPlayPort;

/**
 *  lelinkport端口(乐联协议端口)
 */
@property (nonatomic,assign)NSInteger lelinkport;

/// 通道探测端口，如果没有此端口，则接收端不支持通道探测
@property(nonatomic, assign) NSInteger netprobeport;

/**
 *  raop端口(属于airplay端口内的一种)
 */
@property (nonatomic,assign)NSInteger raopPort;


/**
 *  mirror
 */
@property (nonatomic,assign)NSInteger mirror;

/**
 *  版本号
 */
@property (nonatomic,copy)NSString *version;

/**
 *  功能 1 -->应用安装     2 --> 应用卸载         4 --> 应用打开    8 -->点播推送   16 -->直播推送
 64-->表示弹幕   128-->表示音乐连接推送
 */
@property (nonatomic,copy)NSString *feature;


/**
 * 接收端渠道支持引流的字段
 * 举例如下：
 （B渠道打开 ： drainage：1）
 00000000 000000000 00000000 00000001
 （只打开西瓜渠道 drainage：2）
 000000000 00000000 00000000 00000010
 （B站和西瓜渠道都打开引流 ：drainage：3）
 00000000 00000000 00000000 00000011
 （假设有32个渠道每个渠道都打开 ：drainage：65535）
 11111111 11111111 11111111 11111111
 */
@property (nonatomic,copy)NSString *drainage;

/**
 *  通道channel
 */
@property (nonatomic,copy)NSString *channel;

/**
 *  设备mac唯一标示
 */
@property (nonatomic,copy)NSString *devicemac;

/**
 包名
 */
@property (nonatomic, copy) NSString *packagename;

/**
 *  属性类型 （1代表是:SDK  2:APK）
 */
@property (nonatomic,assign)NSInteger attributeType;

/// 是扫码获得Service
@property (nonatomic,assign)BOOL isScanGetService;
/**
 airplay服务信息
 */
@property (nonatomic,strong)NSDictionary *leboPlayTxt;
/**
 Raop服务信息
 */
@property (nonatomic,strong)NSDictionary *leboRaopTxt;
/**
 hostName
 */
@property (nonatomic,copy)NSString *hostName;
/**
 是否与该服务同一网段
 */
@property (nonatomic,assign)BOOL isSameNetwork;

/**
 接收端的唯一标识符 u
 */
@property (nonatomic, copy) NSString *u;

/**
 */
@property (nonatomic, copy) NSString *ver;

/**
 乐联协议版本区分标志 0:默认值(不使用),1:新乐联V1(测试协议,会话无加密) 2:新乐联V2(正式版本，会话经过加密)
 */
@property (nonatomic, copy) NSString *vv;

/**
 乐联验证类型版本 0:普通模式 1:password模式 2:pair-pin模式 3:公网投屏模式(预留)
 */
@property (nonatomic, copy) NSString *atv;

/**
 乐联加密类型版本 0:默认,无加密 1:chacha20+poly305,2:AES-GCM
 */
@property (nonatomic, copy) NSString *etv;

/**
 乐联握手类型版本 0:默认 1:ECDHE,2:SRP
 */
@property (nonatomic, copy) NSString *htv;

/**
 乐联设备型号
 */
@property (nonatomic, copy) NSString *hmd;

/**
 乐联AppID
 */
@property (nonatomic, copy) NSString *appID;

/**
 乐联协议版本号
 */
@property (nonatomic, copy) NSString *hstv;

/** 接收端的宽 */
@property (nonatomic, copy) NSString *width;
/** 接收端的高 */
@property (nonatomic, copy) NSString *height;

/** 多通道切换标示， 为 3 支持多通道切换 */
@property (nonatomic, copy) NSString *tunnels;

/// 是否支持水兔功能（即会议功能）
@property (nonatomic, assign) BOOL wr;

/// 是否是商显TV端
@property (nonatomic, assign) BOOL isCommerce;

/// 搜到的原始数据（投屏码、扫码解析得到长链的数据）
@property (nonatomic, strong) NSDictionary *_Nullable originalData;


- (BOOL)isEqualToInnerLelinkServiceModel:(LBInnerLelinkServiceModel *)object;


@end
