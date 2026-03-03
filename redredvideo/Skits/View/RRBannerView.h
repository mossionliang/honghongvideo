//
//  RRBannerView.h
//  redredvideo
//
//  首页Banner轮播组件
//

#import <UIKit/UIKit.h>

@class RRBannerModel;

NS_ASSUME_NONNULL_BEGIN

@protocol RRBannerViewDelegate <NSObject>
@optional
- (void)bannerView:(id)bannerView didSelectAtIndex:(NSInteger)index;
@end

@interface RRBannerView : UIView

@property (nonatomic, weak) id<RRBannerViewDelegate> delegate;
@property (nonatomic, copy) NSArray<RRBannerModel *> *banners;

/// 开始自动滚动（默认3秒间隔）
- (void)startAutoScroll;
/// 停止自动滚动
- (void)stopAutoScroll;

@end

NS_ASSUME_NONNULL_END
