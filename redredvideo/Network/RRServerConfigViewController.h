//
//  RRServerConfigViewController.h
//  redredvideo
//
//  服务器IP配置页面
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRServerConfigViewController : UIViewController

/// 配置完成回调
@property (nonatomic, copy) void(^onConfigured)(void);

@end

NS_ASSUME_NONNULL_END
