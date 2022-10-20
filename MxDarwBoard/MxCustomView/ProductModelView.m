//
//  ProductModelView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import "ProductModelView.h"
#import "DevelopManager.h"

#define DefaultBaseColor UIColorWithAlphaFromRGB(0x767676, 1)


@implementation ProductModelView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self layoutSubview];
    }
    return self;
}

-(void)layoutSubview{
    //整个模版默认颜色绘制
    for (int i = 0; i < [DevelopManager shareInstance].modelPointList.count; i++) {
        CGPoint point = CGPointFromString([[DevelopManager shareInstance].modelPointList objectAtIndex:i]);
        UIColor *paintColor = DefaultBaseColor;
        [self drawWithPoint:point Color:paintColor];
    }
}

-(void)updateViewWithLocationArray:(NSArray *)locationArray{
    for (int i = 0; i < locationArray.count; i++) {
        int location = [[locationArray objectAtIndex:i] intValue];
        CGPoint point = CGPointFromString([[DevelopManager shareInstance].modelPointList objectAtIndex:location]);
        [self drawWithPoint:point Color:[UIColor whiteColor]];
    }
}

//绘制某个位置灯的颜色
-(void)drawWithPoint:(CGPoint )point Color:(UIColor *)color{
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.lineWidth = 1;
    //圆环的颜色
    layer.strokeColor = color.CGColor;
    //背景填充色
    layer.fillColor = color.CGColor;
    //设置半径为15
    CGFloat radius = 3.75;
    //按照顺时针方向
    BOOL clockWise = true;
    //初始化一个路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:radius startAngle:(0) endAngle:M_PI*2 clockwise:clockWise];
    [path closePath];
    layer.path = [path CGPath];
    [self.layer addSublayer:layer];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return [super hitTest:point withEvent:event];;
}

@end
