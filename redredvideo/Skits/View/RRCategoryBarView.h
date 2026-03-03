//
//  RRCategoryBarView.h
//  redredvideo
//
//  首页分类导航栏
//

#import <UIKit/UIKit.h>

@class RRCategoryModel;

NS_ASSUME_NONNULL_BEGIN

@protocol RRCategoryBarViewDelegate <NSObject>
@optional
- (void)categoryBarView:(id)barView didSelectCategory:(RRCategoryModel *)category;
@end

@interface RRCategoryBarView : UIView

@property (nonatomic, weak) id<RRCategoryBarViewDelegate> delegate;
@property (nonatomic, copy) NSArray<RRCategoryModel *> *categories;

@end

NS_ASSUME_NONNULL_END
