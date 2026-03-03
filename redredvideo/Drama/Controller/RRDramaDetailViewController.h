//
//  RRDramaDetailViewController.h
//  redredvideo
//
//  剧集详情页 - 展示剧集信息 + 分集列表 + 播放
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRDramaDetailViewController : UIViewController

/// 剧集ID（从API获取详情）
@property (nonatomic, copy) NSString *dramaId;
/// 剧集标题（导航栏用，可选）
@property (nonatomic, copy) NSString *dramaTitle;

@end

NS_ASSUME_NONNULL_END
