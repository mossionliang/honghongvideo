//
//  RRScreenCastManager.h
//  redredvideo
//
//  投屏管理器（单例）：搜索设备、连接、推送视频
//

#import <Foundation/Foundation.h>
#import <LBLelinkKit/LBLelinkKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RRScreenCastManagerDelegate <NSObject>
@optional
/// 设备列表更新
- (void)screenCastDidUpdateServices:(NSArray<LBLelinkService *> *)services;
/// 连接成功
- (void)screenCastDidConnect:(LBLelinkService *)service;
/// 连接断开
- (void)screenCastDidDisconnect:(LBLelinkService *)service;
/// 连接失败
- (void)screenCastDidFailWithError:(NSError *)error;
/// 播放状态变化
- (void)screenCastPlayStatusChanged:(LBLelinkPlayStatus)status;
/// 播放进度更新
- (void)screenCastProgressUpdated:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;
@end

@interface RRScreenCastManager : NSObject

@property (nonatomic, weak) id<RRScreenCastManagerDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray<LBLelinkService *> *services;
@property (nonatomic, assign, readonly) BOOL isConnected;
@property (nonatomic, strong, readonly, nullable) LBLelinkService *connectedService;

+ (instancetype)shared;

/// 开始搜索设备
- (void)startSearch;
/// 停止搜索
- (void)stopSearch;
/// 连接设备
- (void)connectToService:(LBLelinkService *)service;
/// 断开连接
- (void)disconnect;
/// 推送视频URL播放
- (void)playVideoWithURL:(NSString *)urlString title:(nullable NSString *)title;
/// 暂停投屏播放
- (void)pause;
/// 继续播放
- (void)resume;
/// 停止播放
- (void)stop;
/// 跳转到指定位置（秒）
- (void)seekTo:(NSInteger)seconds;
/// 设置播放速度
- (void)setPlaySpeed:(CGFloat)speed;

@end

NS_ASSUME_NONNULL_END
