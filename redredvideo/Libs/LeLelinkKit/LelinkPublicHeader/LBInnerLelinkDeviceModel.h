//
//  LBInnerLelinkDeviceModel.h
//  LBInnerLelinkDemo
//
//  Created by 刘明星 on 2018/4/16.
//  Copyright © 2018年 深圳乐播科技有限公司. All rights reserved.
//

#import "LBLelinkBase.h"
#import <Foundation/Foundation.h>

@class LBInnerLelinkServiceModel;

@interface LBInnerLelinkDeviceModel : NSObject

@property (nonatomic, assign,getter=isFromeQRCode) BOOL fromeQRCode;

//  tv设备ip地址
@property (nonatomic,copy)NSString *ipAddress;

//  tv设备服务名称
@property (nonatomic,copy)NSString *name;

/**
 mac地址
 */
@property (nonatomic, copy) NSString *devicemac;

//  tv是否支持无界面音乐播放(tv老版本音乐播放，会出现黑屏，新版本推音乐播放，无黑屏界面，只有声音)
@property (nonatomic,assign)BOOL isSupportMusicCast;

//  tv是否支持弹幕播放
@property (nonatomic,assign)BOOL isSupportBarrageCast;

//  是否是历史连接设备
@property (nonatomic,assign)BOOL isHistoryConnect;

//  (将废弃)连接状态 0:未连接 1:已连接推送URl播放 2:正在连接 3:已镜像 4:正在镜像ing 5:连接到自己手机
@property (nonatomic,assign)NSInteger conState;

/**
 是否被选中，  如果是已经连接的状态，则为选中，即 conState 不为0，5
 */
@property (nonatomic, assign) BOOL isSelectd;

/**
 接收端SDK版本
 */
@property (nonatomic, copy) NSString *receiverSdkVersion;
/**
 接收端SDK渠道
 */
@property (nonatomic, copy) NSString *receiverSdkChannel;
/**
 接收端包名
 */
@property (nonatomic, copy) NSString *packageName;
/**
 是否有新版本
 */
@property (nonatomic, assign) BOOL hasNewVersion;




@property (nonatomic,strong)LBInnerLelinkServiceModel *sdkModel;
@property (nonatomic,strong)LBInnerLelinkServiceModel *apkModel;

//#warning 以下属性是乐播App专用属性，打包时可以删除
//
//// 镜像状态 0 未镜像   1:已镜像
//@property (nonatomic,assign)NSInteger mirrorState;
// 是扫码获得互联网连接电视
@property (nonatomic,assign)BOOL isScanInternetTV;
// 电视唯一标示
@property (nonatomic,copy)NSString *cname;// uid
// 是否在同一网络
@property (nonatomic,assign)BOOL isSameNetwork;
// 电视wifi名字
@property (nonatomic,copy)NSString *tvSsid;

/**
 ver
 */
@property (nonatomic, copy) NSString *ver;


/**
 是否为 常用
 */
@property (nonatomic, assign) BOOL usual;

/**
 是否为 在线
 */
@property (nonatomic, assign) BOOL online;

/**
 备注名
 */
@property (nonatomic, copy) NSString *alias;

/**
 是否保存到过服务器  默认为NO
 */
@property (nonatomic, assign) BOOL isUploaded;

/**
 idcode
*/
@property (nonatomic, copy) NSString *idCode;

/// 是否支持水兔项目功能（即会议功能）
@property (nonatomic, assign) BOOL wr;
@property (nonatomic, assign) BOOL isCommerce;      /**< 是否商显TV端 */
/// 搜到的原始数据（投屏码、扫码解析得到长链的数据）
@property (nonatomic, strong) NSDictionary *_Nullable originalData;

/// 来源方式
@property (nonatomic, assign) LBLelinkServiceSourceStyle sourceStyle;


- (BOOL)isEqualToInnerLelinkDeviceModel:(LBInnerLelinkDeviceModel *)object;


@end
