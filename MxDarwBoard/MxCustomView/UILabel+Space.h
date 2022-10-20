//
//  UILabel+Space.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/7/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Space)

//1.设置：行间距
+ (void)changeLineSpaceForLabel:(UILabel *)label WithSpace:(float)space;

//2.设置：字间距
+ (void)changeWordSpaceForLabel:(UILabel *)label WithSpace:(float)space;

//3.设置：行间距 与 字间距
+ (void)changeSpaceForLabel:(UILabel *)label withLineSpace:(float)lineSpace WordSpace:(float)wordSpace;

@end

NS_ASSUME_NONNULL_END
