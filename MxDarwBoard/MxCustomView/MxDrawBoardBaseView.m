//
//  MxDrawBoardBaseView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/15.
//

#import "MxDrawBoardBaseView.h"
#import "MxDrawBoardManager.h"

@implementation MxDrawBoardBaseView

-(void)drawRect:(CGRect)rect{
    for (int i = 0; i < Screen_WIDTH/FIT_TO_IPAD_VER_VALUE(15); i++) {//纵坐标
        CGFloat pointX = i*FIT_TO_IPAD_VER_VALUE(15);
//          DLog(@"poinX:%f",poinX);
        CGPoint startPoint = CGPointMake(pointX, 0);
        CGPoint endPoint = CGPointMake(pointX, Screen_HEIGHT);
        UIColor * lineColor = UIColorFromRGB(0x2B2B2B);
        CGFloat lineWidth = 0.5;
        [self drawlineWithStartPoint:startPoint EndPoint:endPoint LineColor:lineColor LineWidth:lineWidth DottedLine:NO];
    }
    for (int i = 0; i < Screen_HEIGHT/FIT_TO_IPAD_VER_VALUE(15); i++) {//横坐标
        CGFloat pointY =  i*FIT_TO_IPAD_VER_VALUE(15);
        CGPoint startPoint = CGPointMake(0, pointY);
        CGPoint endPoint = CGPointMake(Screen_WIDTH, pointY);
        UIColor * lineColor = UIColorFromRGB(0x2B2B2B);
        CGFloat lineWidth = 0.5;
        [self drawlineWithStartPoint:startPoint EndPoint:endPoint LineColor:lineColor LineWidth:lineWidth DottedLine:NO];
    }
}

- (void)setIsDebug:(BOOL)isDebug{
    if (isDebug) {
        for (int i = 0; i < 20; i++) {
            UILabel *xLbael = [[UILabel alloc] initWithFrame:CGRectMake(DrawBoardBaseViewX + i * FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(63), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(12))];
            xLbael.text = [NSString stringWithFormat:@"%d",i + 1];
            xLbael.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(12)];
            xLbael.textColor = [UIColor redColor];
            xLbael.textAlignment = NSTextAlignmentCenter;
            [self addSubview:xLbael];
        }
        for (int i = 0; i < 20; i++) {
            UILabel *yLbael = [[UILabel alloc] initWithFrame:CGRectMake(DrawBoardBaseViewX - FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(84) + i * FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(12))];
            yLbael.text = [NSString stringWithFormat:@"%d",i + 1];
            yLbael.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(12)];
            yLbael.textColor = [UIColor redColor];
            yLbael.textAlignment = NSTextAlignmentCenter;
            [self addSubview:yLbael];
            
            
            
            UILabel *countYlabel = [[UILabel alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(820), FIT_TO_IPAD_VER_VALUE(84) + i * FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(40), FIT_TO_IPAD_VER_VALUE(12))];
            countYlabel.text = [NSString stringWithFormat:@"%d",(i + 1) * 20];
            countYlabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(12)];
            countYlabel.textColor = [UIColor redColor];
            countYlabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:countYlabel];
        }
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
