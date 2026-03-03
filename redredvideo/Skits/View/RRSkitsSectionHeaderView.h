//
//  RRSkitsSectionHeaderView.h
//  redredvideo
//
//  短剧板块标题视图
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRSkitsSectionHeaderView : UICollectionReusableView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) void (^moreTapped)(void);

@end

NS_ASSUME_NONNULL_END
