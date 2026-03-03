//
//  LBInnerLelinkConnection.h
//  LBInnerLelinkDemo
//
//  Created by 刘明星 on 2018/4/17.
//  Copyright © 2018年 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LBInnerLelinkDeviceModel;
@class LBPositiveSocket;
@class LBReverseSocket;
@class LBLelinkPlaySocket;
@class LBInnerLelinkConnection;

@protocol LBInnerLelinkConnectionDelegate <NSObject>
@optional

- (void)innerLelinkConnection:(LBInnerLelinkConnection *)connection onError:(NSError *)error;
- (void)innerLelinkConnection:(LBInnerLelinkConnection *)connection didConnectToDevice:(LBInnerLelinkDeviceModel *)device;
- (void)innerLelinkConnection:(LBInnerLelinkConnection *)connection disConnectToDevice:(LBInnerLelinkDeviceModel *)device;

@end

@interface LBInnerLelinkConnection : NSObject

@property (nonatomic, strong) LBInnerLelinkDeviceModel * deviceModel;
@property (nonatomic, weak) id<LBInnerLelinkConnectionDelegate> delegate;
@property (nonatomic, strong) LBPositiveSocket * positiveSocket;
@property (nonatomic, strong) LBReverseSocket * reverserSocket;
@property (nonatomic, strong) LBLelinkPlaySocket * lelinkPlaySocket;
@property (nonatomic, assign, readonly, getter=isConnected) BOOL connected;
@property (nonatomic, copy,readonly) NSString *sessionId;


- (instancetype)init;
- (instancetype)initWithDeviceModel:(LBInnerLelinkDeviceModel * _Nullable)deviceModel delegate:(id<LBInnerLelinkConnectionDelegate> _Nullable)delegate;

- (void)connect;
- (void)connectWithInnerLelinkDeviceModel:(LBInnerLelinkDeviceModel *)deviceModel;

- (void)disConnect;

@end

NS_ASSUME_NONNULL_END
