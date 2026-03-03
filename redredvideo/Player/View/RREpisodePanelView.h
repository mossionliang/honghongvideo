//
//  RREpisodePanelView.h
//  redredvideo
//
//  选集面板：从底部弹出的选集选择面板
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RREpisodePanelViewDelegate <NSObject>
- (void)episodePanelDidSelectEpisodeAtIndex:(NSInteger)index;
@end

@interface RREpisodePanelView : UIView

@property (nonatomic, weak) id<RREpisodePanelViewDelegate> delegate;

- (instancetype)initWithEpisodes:(NSArray<NSDictionary *> *)episodes 
                    currentIndex:(NSInteger)currentIndex
                      dramaTitle:(NSString *)dramaTitle
                       coverURL:(NSString *)coverURL;

- (void)showInView:(UIView *)view;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
