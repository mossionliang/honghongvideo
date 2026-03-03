//
//  LBSystemPermissions.h
//  AppleSenderSDK
//
//  Created by wangzhijun on 2020/11/18.
//  Copyright © 2020 深圳乐播科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class LBSystemPermissions;
NS_ASSUME_NONNULL_BEGIN

@protocol LBSystemPermissionsDelegate <NSObject>

- (void)localNetworkPermissionsPolicyDeniedDelegate:(LBSystemPermissions *)systemPermissions;

@end

@interface LBSystemPermissions : NSObject

@property (nonatomic,weak)id<LBSystemPermissionsDelegate> delegate;

///麦克风权限状态查询
+ (AVAuthorizationStatus)microphonePermissionsStatus API_AVAILABLE(macos(10.14),ios(3.0));


/// 请求麦克风授权
/// @param callback 授权结果回调
+ (void)requestMicrophonePermissions:(void(^)(BOOL canRecord))callback API_AVAILABLE(macos(10.14),ios(3.0));


/// 显示权限设置警告窗口
/// @param title 授权标题
//+ (void)showPermissionsSetAlertViewWithTitle:(NSString *)title API_UNAVAILABLE(macos);

/// 本地网络权限查询，无权限在代理返回,有权限不回调
- (void)localNetworkPermissionsQuery;

@end

NS_ASSUME_NONNULL_END
