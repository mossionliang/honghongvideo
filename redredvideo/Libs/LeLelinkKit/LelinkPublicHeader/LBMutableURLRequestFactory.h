//
//  LBMutableURLRequestFactory.h
//  AppleSenderSDK
//
//  Created by liumingxing on 2019/1/9.
//  Copyright © 2019 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LBMutableURLRequestFactory : NSMutableURLRequest

+ (instancetype)requestWithURL:(nonnull NSURL *)url timeOut:(NSTimeInterval)intervel method:(NSString *)method bodyData:(NSData *)bodyData;

@end

NS_ASSUME_NONNULL_END
