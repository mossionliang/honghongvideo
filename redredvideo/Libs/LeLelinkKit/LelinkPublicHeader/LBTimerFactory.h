//
//  LBTimerFactory.h
//  AppleSenderSDK
//
//  Created by liumingxing on 2019/1/9.
//  Copyright © 2019 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LBExecuteTimerBlock) (NSTimer *timer);

@interface LBTimerFactory : NSTimer

+ (NSTimer *)lb_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval executeBlock:(LBExecuteTimerBlock)block repeats:(BOOL)repeats;

@end

NS_ASSUME_NONNULL_END
