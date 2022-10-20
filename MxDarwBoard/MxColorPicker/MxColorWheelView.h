//
//  MxColorWheelView.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MxColorWheelViewDelegate;

@interface MxColorWheelView : UIControl

@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, weak) id <MxColorWheelViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIView *borderView;

@end

@protocol MxColorWheelViewDelegate <NSObject>
- (void)colorWheelViewDidSnapToCenter:(MxColorWheelView *)view;
@end

NS_ASSUME_NONNULL_END
