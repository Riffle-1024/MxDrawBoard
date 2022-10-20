//
//  UIImage+MxTool.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/3/9.
//

#import "UIImage+MxTool.h"


#define imageScale 3

@implementation UIImage (MxTool)


+(UIImage *)creatShareImage:(UIImage *)image{
    UIImage * baseImage = [UIImage imageNamed:@"share_image_base"];
    
    UIImage *backImage = [UIImage createImageColor:[UIColor blackColor] size:CGSizeMake(290 * imageScale, 290 * imageScale)];

    UIImage * image2 = image;

    CGSize size = CGSizeMake(baseImage.size.width * imageScale, baseImage.size.height * imageScale);

    UIGraphicsBeginImageContext(size);

    [baseImage drawInRect:CGRectMake(0, 0, size.width , size.height)];
    
//    [backImage drawInRect:CGRectMake(43 * imageScale, 241 * imageScale, 290 * imageScale, 290 * imageScale)];

//    [image2 drawInRect:CGRectMake(38 * imageScale, 236 * imageScale, 300 * imageScale, 300 * imageScale)];
    [image2 drawInRect:CGRectMake(145, 756,880, 880)];
    UIImage *resultingImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

+(UIImage *)screenShotView:(UIView *)view{
       UIImage *imageRet = [[UIImage alloc]init];
    

    UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0);
       [view.layer renderInContext:UIGraphicsGetCurrentContext()];
       imageRet = UIGraphicsGetImageFromCurrentImageContext();
       UIGraphicsEndImageContext();
    NSInteger modeType = 0;
    NSString * type = [[NSUserDefaults standardUserDefaults] valueForKey:DrawModelType];
    if (type) {
        modeType = [type intValue];
    }
    if (modeType == 1) {
        return [UIImage imageWithImage:imageRet ModelType:modeType];
    }else{
        return imageRet;
    }
      
}


+ (UIImage *)imageWithImage:(UIImage*)image ModelType:(NSInteger )type{
    CGSize newSize = CGSizeMake(FIT_TO_IPAD_VER_VALUE(1079), FIT_TO_IPAD_VER_VALUE(1079));
    CGRect rect = CGRectMake(FIT_TO_IPAD_VER_VALUE(66),FIT_TO_IPAD_VER_VALUE(66),newSize.width,newSize.height);
//    UIGraphicsBeginImageContext(newSize);
//    [image drawInRect:CGRectMake(FIT_TO_IPAD_VER_VALUE(33),FIT_TO_IPAD_VER_VALUE(33),newSize.width,newSize.height)];
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
        CGImageRef imageRef = image.CGImage;
        CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, rect);
        UIImage *cropImage = [UIImage imageWithCGImage:imagePartRef];
        CGImageRelease(imagePartRef);
    return cropImage;
}

+(UIImage*)getImageByCuttingImage:(UIImage  *)image ToRect:(CGRect)rect {

    //  大图  bigImage
    //  定义  myImageRect  ，截图的区域
    CGRect    toImageRect = rect;
    UIImage  *bigImage= image;

    CGImageRef  imageRef = bigImage.CGImage;
    CGImageRef  subImageRef =  CGImageCreateWithImageInRect(imageRef, toImageRect);

    CGSize size;
    size.  width  = rect.size.width;
    size.  height  = rect.size.height;

    UIGraphicsBeginImageContext(size);
    CGContextRef  context =  UIGraphicsGetCurrentContext ();
    CGContextDrawImage(context, toImageRect, subImageRef);
    UIImage  *smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();

    return  smallImage;
}
+(UIImage *)takeScreenshotView:(UIView *)view Frame:(CGRect)frame{

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, view.frame.size.height), YES, 0);
    //设置截屏大小
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    CGRect rect = frame;//这里可以设置想要截图的区域
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];

//    //以下为图片保存代码
//    UIImageWriteToSavedPhotosAlbum(sendImage, nil, nil, nil);//保存图片到照片库
//    NSData *imageViewData = UIImagePNGRepresentation(sendImage);
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSDate *datenow = [NSDate date];
//    NSString *pictureName= [NSString stringWithFormat:@"%ld_screenShow.png",(long)[datenow timeIntervalSince1970]];
//    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:pictureName];
//    [imageViewData writeToFile:savedImagePath atomically:YES];//保存照片到沙盒目录
//    CGImageRelease(imageRefRect);
//
//    //从手机本地加载图片
//    UIImage *bgImage2 = [[UIImage alloc]initWithContentsOfFile:savedImagePath];
    return sendImage;
}

+(UIImage *)createImageColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
/*  ============================================================  */
#pragma mark - 生成二维码的方法
+ (UIImage *)QRCodeMethod:(NSString *)qrCodeString {

    UIImage *qrcodeImg = [UIImage createNonInterpolatedUIImageFormCIImage:[self createQRForString:qrCodeString] withSize:250.0f];
    // ** 将生成的
    return qrcodeImg;
}

/*  ============================================================  */
#pragma mark - InterpolatedUIImage
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - QRCodeGenerator
+ (CIImage *)createQRForString:(NSString *)qrString {
    
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];

    return qrFilter.outputImage;
}

#pragma mark - imageToTransparent
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

+(NSData *)imageData:(UIImage *)myimage{
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    if (data.length>500*1024) {//大于100k
        if (data.length > 10240*1024) {//大于10M
            data = UIImageJPEGRepresentation(myimage, 0.1);
        }else if (data.length>5*1024*1024){//s大于5M
            data = UIImageJPEGRepresentation(myimage, 0.2);
        }
        else if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.3);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(myimage, 0.8);
        }
    }
    return data;
}
@end
