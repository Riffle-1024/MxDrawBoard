//
//  UIImage+MxTool.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/3/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MxTool)

+(UIImage *)screenShotView:(UIView *)view;

+ (UIImage *)QRCodeMethod:(NSString *)qrCodeString;

+(UIImage *)creatShareImage:(UIImage *)image;

+(UIImage *)createImageColor:(UIColor *)color size:(CGSize)size;

+(NSData *)imageData:(UIImage *)myimage;

+(UIImage *)takeScreenshotView:(UIView *)view Frame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
