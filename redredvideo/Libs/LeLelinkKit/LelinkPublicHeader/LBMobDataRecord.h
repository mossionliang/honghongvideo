//
//  LBMobDataRecord.h
//  LBLelinkKit
//
//  Created by wangzhijun on 2021/1/12.
//  Copyright © 2021 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBLelinkBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LBMobDataRecord : NSObject

+ (instancetype)shareInstance;

- (BOOL)addRelationWithName:(NSString *)name uid:(NSString *)uid sourceStyle:(LBLelinkServiceSourceStyle)sourceStyle searchTime:(double)searchTime state:(NSString *)state queryTime:(double)queryTime;
- (void)addRelationDlanListWithDeviceInfo:(NSString *)deviceInfo;
- (void)addServiceSourceStyle:(LBLelinkServiceSourceStyle)sourceStyle;

// 画面质量打点
- (void)addCastQualityWithQuality:(NSDictionary *)quality;
// 搜索sessionId埋点
- (void)addMeetingBrowserSessionId:(NSString *)sessionId;
// 投屏开始sessionId埋点
- (void)addMeetingCastJoinSessionId:(NSString *)sessionId;
// 投屏开始sessionId埋点
- (void)addMeetingCastFileSessionId:(NSString *)sessionId;
// 网络通道切换打点
- (void)addCastNetChannelWithTransInfo:(NSDictionary *)nettransInfo;

/// sn = request_lebocloud_upload_file_before
/// 页面来源ID
- (void)addUploadfileBenforePageViewSourceId:(NSString *_Nullable)pageId;
- (NSString *_Nullable)getUploadfileBenforePageViewSourceId;

/** 该方法由业务层处理 */
//- (NSString *)getSameIpDeviceInfoList:(NSArray *)lelinkServices;

- (NSString *)getRelationBodyJsonString;
- (NSString *)getRelationDlanListString;
- (NSString *)getRelationServiceSourceListString;

- (NSInteger)castQualityCount;
- (NSInteger)castNetChannelCount;

- (NSString *)getMeetingBrowserSessionId;
- (NSString *)getMeetingCastJoinSessionId;
- (NSString *)getMeetingCastFileSessionId;

// 镜像画面质量埋点
- (NSString *)getCastQualityString;

// 镜像网络切换埋点
- (NSString *)getCastNetChannelString;


- (void)clearRelationArray;
- (void)clearRelationDlanList;
- (void)clearAllRecord;

- (void)cleanCastQualityArray;
- (void)cleanCastNetChannelArray;


@end

NS_ASSUME_NONNULL_END
