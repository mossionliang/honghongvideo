//
//  LBURLSSLSession.h
//  AppleSenderSDK
//
//  Created by wangzhijun on 2022/11/23.
//  Copyright © 2022 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 需要SSL双向认证的请求，NSURLSession替换为LBURLSSLSession类即可
@interface LBURLSSLSession : NSURLSession

+ (void)updateP12Passwd:(NSString *)passwd;
+ (void)updateP12Path:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
