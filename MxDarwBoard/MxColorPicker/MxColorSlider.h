//
//  MxSimpleSlider.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat SliderHeight;

NS_CLASS_AVAILABLE_IOS(10.0)
@interface MxSimpleSlider : UIControl
@property (nonatomic, assign, readonly) CGFloat value; // [0, 1]
@end

NS_CLASS_AVAILABLE_IOS(10.0)
@interface MxColorSlider : MxSimpleSlider
@property (nonatomic, strong) UIColor *selectedColor;
@end

NS_CLASS_AVAILABLE_IOS(10.0)
@interface AlphaSlider : MxColorSlider
+ (UIImage *)checkerboardImage;
@property (nonatomic, assign) CGFloat alphaValue;
@end

NS_ASSUME_NONNULL_END
