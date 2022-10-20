//
//  UIColor+Turn.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/3/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Turn)

+ (NSString *)hexStringFromColor:(UIColor *)color;

+ (NSString *)hsvStringFromColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
