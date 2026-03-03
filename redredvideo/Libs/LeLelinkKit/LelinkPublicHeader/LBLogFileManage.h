//
//  LBLogFileManage.h
//  AppleSenderSDK
//
//  Created by wangzhijun on 2020/7/28.
//  Copyright © 2020 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBLelinkBase.h"
//#import "LBLelinkConnection.h"

/// 拓展程序云镜像的路径
#define kLBMirrorExtenderLogPath @"Library/Caches/Cloud"
/// 拓展程序会议云镜像的路径
#define kLBMeetingExtenderLogPath @"Library/Caches/Meeting"
NS_ASSUME_NONNULL_BEGIN

@interface LBLogFileManage : NSObject

+ (instancetype)shareLogFileManage;

//@property (nonatomic,weak)LBLelinkConnection *lelinkConnection;
@property (nonatomic, assign) BOOL isEnableLog;
@property (nonatomic, assign) BOOL isEnableCloudLog;
@property (nonatomic, strong) NSString *cloudPath;

// 输出日志
+ (void)logOutput:(NSString *)string level:(NSNumber *)levelNumber;
// 异常日志输出
+ (void)abnormalLogOutput:(NSString *)string level:(NSNumber *)levelNumber;

+ (void)logUploadWithEid:(NSString *_Nullable)eid problemType:(LBLogReportProblemType)problemType phoneNum:(NSString *_Nullable)phoneNum callBlock:(void(^)(BOOL succeed ,NSString *_Nullable euqid,NSError * _Nullable error))callBlock;

/// 上报会议信息
+ (void)logUploadWithEid:(NSString *_Nullable)eid problemType:(LBLogReportProblemType)problemType phoneNum:(NSString *_Nullable)phoneNum meetingInfo:(NSDictionary *_Nullable)meetingInfo callback:(void(^)(BOOL succeed ,NSString *_Nullable euqid,NSError * _Nullable error))callBlock;

+ (void)logUploadWithEid:(NSString *_Nullable)eid et:(NSString *_Nullable)et phoneNum:(NSString *_Nullable)phoneNum callBlock:(void(^)(BOOL succeed ,NSString *_Nullable euqid,NSError * _Nullable error))callBlock;

// 异常日志上报，仪表盘需求日志上报
+ (void)logUploadWithEid:(NSString *_Nullable)eid et:(NSString *_Nullable)et ls:(NSString *_Nullable)ls callBlock:(void(^)(BOOL succeed ,NSString *_Nullable euqid,NSError * _Nullable error))callBlock;
+ (BOOL)logUploadAuthorityWithEt:(NSString *_Nullable)et;

+ (void)logReportAskNeedNowReport;
+ (BOOL)allowUploadLogChannel;

+ (NSURL *)appGroupURLForComponent:(NSString *)pathComponent appGroupId:(NSString *)appGroupId;
+ (void)logFileCreatedAppExtToDoucumentFileWithAppGroupId:(NSString *)appGroupId appendingPathComponent:(NSString *)pendPath;
+ (void)logFileCopyAppExtToDeviceFileWithAppGroupId:(NSString *)appGroupId appendingPathComponent:(NSString *)pendPath;

+ (void)logFileExtensionWithLogString:(NSString *)logString fileLogPath:(NSString *)path groupId:(NSString *)groupId;

+ (void)logFileCopyMirrorExtToDeviceFileWithAppGroupId:(NSString *)appGroupId;

/// 完整的即构会议日志路径， 设置 cloudPath 之后，获取完整的文件路径
+ (NSString *)integralMeetingCloudLogsFilePath;

@end

NS_ASSUME_NONNULL_END
