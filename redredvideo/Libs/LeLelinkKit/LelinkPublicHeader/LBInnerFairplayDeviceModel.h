//
//  LBInnerFairplayDeviceModel.h
//  Pods
//
//  Created by wangzhijun on 2024/5/7.
//

#import <Foundation/Foundation.h>
#import "LBLelinkBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LBInnerFairplayServiceModel : NSObject

@property (nonatomic, copy) NSString *receiverServiceId;
@property (nonatomic, copy)NSString *ipAddress;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, assign)NSInteger port;
@property (nonatomic, strong)NSDictionary<NSString *, NSData *> *originTXTDic;
// 0:代表fairplay，1:raop
@property (nonatomic, assign)NSInteger type;
@property (nonatomic, strong)NSNetService *service;
/// 当前是否是 AirPlay1
@property (nonatomic, assign, getter=isFairPlayOne) BOOL fairPlayOne;


@end


@interface LBInnerFairplayDeviceModel : NSObject

@property (nonatomic, copy, readonly) NSString *receiverId;
@property (nonatomic, copy, readonly)NSString *ipAddress;
@property (nonatomic, copy, readonly)NSString *name;
/// 端口
@property (nonatomic, assign, readonly) NSInteger port;
/// 来源方式
@property (nonatomic, assign) LBLelinkServiceSourceStyle sourceStyle;
@property (nonatomic, strong, readonly)LBInnerFairplayServiceModel *fairplayServiceModel;
@property (nonatomic, strong, readonly)LBInnerFairplayServiceModel *raopServiceModel;
// type = 0:代表fairplay，1:raop
- (void)setServiceModel:(LBInnerFairplayServiceModel *)serviceModel type:(NSInteger)type;

@end

NS_ASSUME_NONNULL_END
