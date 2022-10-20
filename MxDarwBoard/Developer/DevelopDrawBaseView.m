//
//  DevelopDrawBaseView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import "DevelopDrawBaseView.h"


@implementation DevelopDrawBaseView

-(void)drawRect:(CGRect)rect{
    for (int i = 0; i < FIT_TO_IPAD_VER_VALUE(360)/FIT_TO_IPAD_VER_VALUE(7.5); i++) {//纵坐标
        CGFloat pointX = i*FIT_TO_IPAD_VER_VALUE(7.5);
//          DLog(@"poinX:%f",poinX);
        CGPoint startPoint = CGPointMake(pointX, 0);
        CGPoint endPoint = CGPointMake(pointX, FIT_TO_IPAD_VER_VALUE(360));
        UIColor * lineColor = UIColorFromRGB(0x2B2B2B);
        CGFloat lineWidth = 0.5;
        [self drawlineWithStartPoint:startPoint EndPoint:endPoint LineColor:lineColor LineWidth:lineWidth DottedLine:NO];
    }
    for (int i = 0; i < FIT_TO_IPAD_VER_VALUE(360)/FIT_TO_IPAD_VER_VALUE(7.5); i++) {//横坐标
        CGFloat pointY =  i*FIT_TO_IPAD_VER_VALUE(7.5);
        CGPoint startPoint = CGPointMake(0, pointY);
        CGPoint endPoint = CGPointMake(FIT_TO_IPAD_VER_VALUE(360), pointY);
        UIColor * lineColor = UIColorFromRGB(0x2B2B2B);
        CGFloat lineWidth = 0.5;
        [self drawlineWithStartPoint:startPoint EndPoint:endPoint LineColor:lineColor LineWidth:lineWidth DottedLine:NO];
    }
}


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGB(0x252525);
    }
    return self;
}





-(void)drawlineWithStartPoint:(CGPoint )startPoint EndPoint:(CGPoint )endPoint LineColor:(UIColor *)lineColor LineWidth:(CGFloat )lineWidth DottedLine:(BOOL)dottedLine
{
    //获得处理的上下文
      CGContextRef context = UIGraphicsGetCurrentContext();
      //设置线条样式
      CGContextSetLineCap(context, kCGLineCapSquare);
      //设置线条粗细宽度
      CGContextSetLineWidth(context, lineWidth);
      CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
      //设置颜色
//      CGContextSetRGBStrokeColor(context, 100, 100, 100, 1.0);
//    CGContextSetRGBFillColor(context, 100, 100, 100, 0.5);
      //开始一个起始路径
      CGContextBeginPath(context);
    if (dottedLine) {
        CGFloat lengths[] = {2,2};
            CGContextSetLineDash(context, 0, lengths,2);
    }
    
      //起始点设置为(100, 100)
      CGContextMoveToPoint(context, startPoint.x, startPoint.y);
      //设置下一个坐标点
      CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
      //连接上面定义的坐标点
      CGContextStrokePath(context);
}

@end
