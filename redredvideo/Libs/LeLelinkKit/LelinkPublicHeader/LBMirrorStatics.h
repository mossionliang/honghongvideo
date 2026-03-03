//
//  LBMirrorStatics.h
//  HPPlayTVAssistant
//
//  Created by lbkj on 2020/1/14.
//  Copyright © 2020 HPPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface LBMirrorStaticsModel : NSObject
@property(nonatomic, copy) NSString *serviceType; // st,mirror:2 keepalive:2
@property(nonatomic, copy) NSString *serviceNumber; // sn,keepalive:101
@property(nonatomic, copy) NSString *sessionId; // s 会话Id
@property(nonatomic, copy) NSString *csessionId; // 主sessionId
@property(nonatomic, copy) NSString *uriId; // uriid
@property(nonatomic, copy) NSString *uuid; // 用户登录编号 lbid(lebo_uuid)
@property(nonatomic, copy) NSString *roomId; // 房间号 lnb(live_number) mci(mirror_cloud_id)
@property(nonatomic, copy) NSString *protocol; // p 5:lelink_v2 7:游密云镜像协议,协议类型,枚举//1:lelink;2:airplay;3:dlna;4:跨网云推送;5:lelink_v2;6:Andlink;7:游密;8:MIRACAST;9:钉钉扩展插件;102:USB;;200:即构云镜像;
@property(nonatomic, copy) NSString *et;     // 错误码
+ (instancetype)mirrorStaticsWithDict:(NSDictionary *)dict;
- (NSDictionary *)dict;
@end

@interface LBKeepAliveStaticsModel : NSObject
@property(nonatomic, copy) NSString *csessionId; // 主sessionId
@property(nonatomic, copy) NSString *uriId; // uriid
@property(nonatomic, copy) NSString *serviceType; // st,2
@property(nonatomic, copy) NSString *serviceNumber; // sn, 101
@property(nonatomic, copy) NSString *sessionId; // s, 会话Id
@property(nonatomic, copy) NSString *nextheart;  // nc 心跳间隔（单位:秒)
@property(nonatomic, copy) NSString *fps; // fp 帧率
@property(nonatomic, copy) NSString *sresolution; // sr 视频分辨率
@property(nonatomic, copy) NSString *bps; // bps 每秒字节数，单位Byte，大B
@property(nonatomic, copy) NSString *uuid; // 用户登录编号
@property(nonatomic, copy) NSString *roomId; // 房间号
@property(nonatomic, copy) NSString *protocol; // p 5:lelink_v2 7:游密云镜像协议

+ (instancetype)keepAliveStaticsWithDict:(NSDictionary *)dict;
- (NSDictionary *)dict;
@end

@interface LBMirrorStatics : NSObject
+ (instancetype)shareInstance;

- (void)updateMirrorStaticsWithModel:(LBMirrorStaticsModel *)mirrorStaticsModel;
- (void)updateKeepAliveStaticsWithModel:(LBKeepAliveStaticsModel *)keepAliveStaticsModel;

- (LBMirrorStaticsModel *)mirrorStaticsModel;
- (LBKeepAliveStaticsModel *)keepAliveStaticsModel;

@end

NS_ASSUME_NONNULL_END
