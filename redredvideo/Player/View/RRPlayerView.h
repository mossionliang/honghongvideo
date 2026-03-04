//
//  RRPlayerView.h
//  redredvideo
//
//  视频播放器视图（增强版）
//  支持：预加载、网络状态监控、缓冲进度、播放进度回调
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RRPlayerState) {
    RRPlayerStateIdle,          // 空闲
    RRPlayerStateLoading,       // 加载中
    RRPlayerStateBuffering,     // 缓冲中
    RRPlayerStatePlaying,       // 播放中
    RRPlayerStatePaused,        // 暂停
    RRPlayerStateError,         // 错误
    RRPlayerStateFinished,      // 播放完成
};

@protocol RRPlayerViewDelegate <NSObject>
@optional
- (void)playerViewDidTap:(id)playerView;
- (void)playerViewDidLongPress:(id)playerView;
- (void)playerViewDidFinishPlaying:(id)playerView;
- (void)playerView:(id)playerView stateChanged:(RRPlayerState)state;
- (void)playerView:(id)playerView playProgress:(float)progress currentTime:(NSTimeInterval)current totalTime:(NSTimeInterval)total;
- (void)playerView:(id)playerView bufferProgress:(float)progress;
- (void)playerView:(id)playerView isLoading:(BOOL)loading; // 新增：通知加载状态
@end

@interface RRPlayerView : UIView

@property (nonatomic, weak) id<RRPlayerViewDelegate> delegate;
@property (nonatomic, assign, readonly) RRPlayerState state;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) NSTimeInterval totalTime;

/// 加载视频
- (void)loadVideoWithURL:(NSURL *)url;
/// 预加载视频（只加载不播放）
- (void)preloadVideoWithURL:(NSURL *)url;
/// 播放
- (void)play;
/// 暂停
- (void)pause;
/// 停止并释放
- (void)stop;
/// 静音
- (void)setMuted:(BOOL)muted;
/// 跳转
- (void)seekToTime:(CMTime)time;
/// 设置播放速率
- (void)setRate:(float)rate;
/// 重试
- (void)retry;

/// 预缓存URL（不创建播放器，只让KTVHTTPCache提前下载）
+ (void)precacheURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
