//
//  UIColor+Turn.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/3/8.
//

#import "UIColor+Turn.h"

@implementation UIColor (Turn)







//UIColor转Hex
+ (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

+ (NSString *)hsvStringFromColor:(UIColor *)color{
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    BOOL success = [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    if (success) {
        NSInteger hueColor =hue * 360;
        NSString * hue16 = [UIColor getHexByDecimal:hueColor];
        if (hue16.length == 2) {
            hue16 = [NSString stringWithFormat:@"00%@",hue16];
        }
        NSString * firstStr = [hue16 substringWithRange:NSMakeRange(0, 2)];
        NSString * secondStr = [hue16 substringWithRange:NSMakeRange(2, 2)];
        NSString * satStr = [UIColor getHexByDecimal:saturation * 100];

          DLog(@"success: hue: %0.2f, saturation: %0.2f, brightness: %0.2f, alpha: %0.2f", hue, saturation, brightness, alpha);
        return [NSString stringWithFormat:@"%@%@%@64",secondStr,firstStr,satStr];
                   
    }else{
        return [NSString stringWithFormat:@"00006464"];//红色
    }
}



+ (NSString *)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    if (hex.length %2 != 0) {
        hex = [NSString stringWithFormat:@"0%@",hex];
    }
    return hex;
}
@end
