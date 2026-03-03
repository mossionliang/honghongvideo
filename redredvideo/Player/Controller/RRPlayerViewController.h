//
//  RRPlayerViewController.h
//  redredvideo
//
//  沉浸式视频播放控制器（增强版）
//  支持：预加载、分页加载、网络监控、内存管理
//

#import <UIKit/UIKit.h>

@class RRVideoModel;

NS_ASSUME_NONNULL_BEGIN

@interface RRPlayerViewController : UIViewController

/// 初始视频列表
@property (nonatomic, copy) NSArray<RRVideoModel *> *videos;
/// 从第几个开始播放
@property (nonatomic, assign) NSInteger startIndex;

@end

NS_ASSUME_NONNULL_END
