//
//  LEBLog.h
//  LEBGWTP
//
//  Created by 刘明星 on 2018/4/6.
//  Copyright © 2018年 刘明星. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 log 等级类型

 - LEBLogLevelTypeUndefine: 未定义
 - LEBLogLevelTypeDebug: 调试
 - LEBLogLevelTypeInfo: 提示
 - LEBLogLevelTypeWarnning: 警告
 - LEBLogLevelTypeError: 错误
 - LEBLogLevelTypeFatal: 致命
 */
typedef NS_ENUM(NSUInteger, LEBLogLevelType) {
    LEBLogLevelTypeUndefine = 0,
    LEBLogLevelTypeDebug,
    LEBLogLevelTypeInfo,
    LEBLogLevelTypeWarnning,
    LEBLogLevelTypeError,
    LEBLogLevelTypeAbnormal,
    LEBLogLevelTypeFatal,
};

#define LEBLOG(lv,s,...)       [LEBLog logLevel:lv file:__FILE__ lineNumber:__LINE__ functionName:__FUNCTION__ format:(s),##__VA_ARGS__]
#define LEBCATEGORYLOG(cat, lv, s, ...)       [LEBLog logLevel:lv category:cat file:__FILE__ lineNumber:__LINE__ functionName:__FUNCTION__ format:(s),##__VA_ARGS__]

/**
 调用以下几个宏，来进行打印输出
 */
#define LEBDEBUGLOG(s,...)     LEBLOG(LEBLogLevelTypeDebug,s,##__VA_ARGS__)

// 旧的INFO日志：为了统一降级为LEBLogLevelTypeDebug处理
#define LEBINFOLOG(s,...)      LEBLOG(LEBLogLevelTypeDebug,s,##__VA_ARGS__)
// 新的INFO日志：级别为LEBLogLevelTypeInfo
#define LEB_New_INFOLOG(s,...)  LEBLOG(LEBLogLevelTypeInfo,s,##__VA_ARGS__)
// 重连日志
#define LEB_RetryConnect_LOG(s, ...) LEBCATEGORYLOG(@"RetryConnect", LEBLogLevelTypeDebug,s,##__VA_ARGS__)
#define LEB_RetryConnect_Online_LOG(s, ...) LEBCATEGORYLOG(@"RetryConnect", LEBLogLevelTypeInfo,s,##__VA_ARGS__)

#define LEBWARNLOG(s,...)      LEBLOG(LEBLogLevelTypeWarnning,s,##__VA_ARGS__)
#define LEBERRLOG(s,...)       LEBLOG(LEBLogLevelTypeError,s,##__VA_ARGS__)
#define LEBFATALLOG(s,...)     LEBLOG(LEBLogLevelTypeFatal,s,##__VA_ARGS__)

// 异常日志打印
#define LEBABLOG(s,...)        LEBLOG(LEBLogLevelTypeAbnormal,s,##__VA_ARGS__)

#define LEBFRAMELOG(rect)      LEBDEBUGLOG(@"frame = %@",NSStringFromCGRect(rect));
#define LEBSIZELOG(size)       LEBDEBUGLOG(@"size = %@",NSStringFromCGSize(size));
#define LEBPOINTLOG(point)     LEBDEBUGLOG(@"point = %@",NSStringFromCGPoint(point));
#define LEBVECTORLOG(vec)      LEBDEBUGLOG(@"vector = %@",NSStringFromCGVector(vec));


@interface LEBLog : NSObject

/**
 log开关

 @param enable enable 为YES则打开log，为NO则关闭log，默认为YES。
 */
+ (void)enableLEBLog:(BOOL)enable;

/**
 将log日志转向写入到沙盒中，不在控制台中打印，辅助测试抓取log，需要在控制台打印时不要使用此方法
 */
+ (void)redirectLEBLogToDocumentFolder;


/**
 获取log日志文件路径

 @return log日志文件路径
 */
+ (NSString *)getRedirectTodayLogFilePath;


/**
 打印输出到接口

 @param target target
 @param selOutput selOutput
 */
+ (void)redirectLEBLogToTarget:(id)target output:(SEL)selOutput;

/**
 异常日志输出接口

 @param abnormalTarget target
 @param abnormalSelOutput selOutput
 */
+ (void)redirectLEBAbnormalLogToTarget:(id)abnormalTarget output:(SEL)abnormalSelOutput;

/**
 log方法

 @param level log等级
 @param sourceFile 文件名
 @param lineNum 行号
 @param funcName 方法名
 @param format 格式信息
 */
+ (void)logLevel:(LEBLogLevelType)level
            file:(const char *)sourceFile
      lineNumber:(int)lineNum
    functionName:(const char *)funcName
          format:(NSString *)format,...;

/**
 log方法

 @param level log等级
 @param category 自定义模块分类
 @param sourceFile 文件名
 @param lineNum 行号
 @param funcName 方法名
 @param format 格式信息
 */
+ (void)logLevel:(LEBLogLevelType)level
        category:(NSString *)category
            file:(const char *)sourceFile
      lineNumber:(int)lineNum
    functionName:(const char *)funcName
          format:(NSString *)format,...;

@end
