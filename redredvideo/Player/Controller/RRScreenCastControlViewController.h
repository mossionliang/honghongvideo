//
//  RRScreenCastControlViewController.h
//  redredvideo
//
//  投屏控制页面：显示已连接设备，提供倍速、清晰度、结束投屏等控制
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRScreenCastControlViewController : UIViewController

/// 初始化，传入设备名、视频URL和标题
- (instancetype)initWithDeviceName:(NSString *)deviceName videoURL:(NSString *)videoURL videoTitle:(nullable NSString *)title;

/// 初始化，传入设备名、剧集列表、当前集数索引
- (instancetype)initWithDeviceName:(NSString *)deviceName episodes:(NSArray<NSDictionary *> *)episodes currentIndex:(NSInteger)currentIndex dramaTitle:(nullable NSString *)dramaTitle;

@end

NS_ASSUME_NONNULL_END
