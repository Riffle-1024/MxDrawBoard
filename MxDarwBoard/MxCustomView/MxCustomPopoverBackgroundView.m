//
//  MxCustomPopoverBackgroundView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import "MxCustomPopoverBackgroundView.h"

#define HArrowHeight 20
#define HArrowBase 30
#define HArrowInsets 0

@interface MxCustomPopoverBackgroundView()
//用于绘制箭头，如果不绘制，将没有箭头
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation MxCustomPopoverBackgroundView


//以下两个属性需要被覆盖
@synthesize arrowDirection = _arrowDirection;//箭头位置
@synthesize arrowOffset = _arrowOffset;//箭头偏移

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
          DLog(@"%@",NSStringFromCGRect(frame));
       // self.backgroundColor = [UIColor lightGrayColor];
        //创建箭头
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.arrowImageView = arrowImageView;
        [self addSubview:self.arrowImageView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

//    //更改箭头位置
//    CGSize arrowSize = CGSizeMake([[self class] arrowBase], [[self class] arrowHeight]);
//    self.arrowImageView.image = [self drawArrowImage:arrowSize];
//
//    CGFloat x;
//    CGFloat y;
//    
//    CGFloat selfWidth = self.bounds.size.width;
//    CGFloat selfHeight = self.bounds.size.height;
//    CGFloat arrowWidth = arrowSize.width;
//    CGFloat arrowHeigt = arrowSize.height;
//    
//    switch (_arrowDirection) {
//        case UIPopoverArrowDirectionUp:
//            x = (selfWidth - arrowWidth)/2.0 + _arrowOffset;
//            y = 0;
//            break;
//        case UIPopoverArrowDirectionLeft:
//            x = 0;
//            y = (selfHeight - arrowHeigt)/2.0 + _arrowOffset;
//            break;
//        case UIPopoverArrowDirectionDown:
//            x = (selfWidth - arrowWidth)/2.0+ _arrowOffset;
//            y = selfHeight - arrowHeigt;
//            break;
//        case UIPopoverArrowDirectionRight:
//            x = selfWidth - arrowWidth;
//            y = (selfHeight - arrowHeigt)/2.0+ _arrowOffset;
//            break;
//            
//        default://UIPopoverArrowDirectionAny忽略
//            x = 0;
//            y =0;
//            break;
//    }
//    
//    self.arrowImageView.frame = CGRectMake(x, y, arrowSize.width, arrowSize.height);
}

//绘制箭头图片
- (UIImage *)drawArrowImage:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] setFill];
    CGContextFillRect(ctx, CGRectMake(0.0f, 0.0f, size.width, size.height));
    
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
    
    //根据箭头位置确认箭头的3个绘制点
    //箭头的UIPopoverArrowDirectionAny类型会被判断成上左下右中的其中一种
    switch (_arrowDirection) {
        case UIPopoverArrowDirectionUp:
            
            point1 = CGPointMake(size.width/2.0, 0);
            point2 = CGPointMake(size.width, size.height);
            point3 = CGPointMake(0, size.height);
            
            break;
        case UIPopoverArrowDirectionLeft:
            
            point1 = CGPointMake(0, size.height/2.0);
            point2 = CGPointMake(size.width, size.height);
            point3 = CGPointMake(size.width, 0);
            
            break;
        case UIPopoverArrowDirectionDown:
            
            point1 = CGPointMake(0, 0);
            point2 = CGPointMake(size.width/2.0, size.height);
            point3 = CGPointMake(size.width, 0);
            
            break;
        case UIPopoverArrowDirectionRight:
            point1 = CGPointMake(0, 0);
            point2 = CGPointMake(size.width, size.height/2.0);
            point3 = CGPointMake(0, size.height);
            
            break;
            
        default:
            break;
    }
    
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    CGPathMoveToPoint(arrowPath, NULL, point1.x, point1.y);
    CGPathAddLineToPoint(arrowPath, NULL, point2.x, point2.y);
    CGPathAddLineToPoint(arrowPath, NULL, point3.x, point3.y);
    CGPathCloseSubpath(arrowPath);

    CGContextAddPath(ctx, arrowPath);
    CGPathRelease(arrowPath);
    UIColor *fillColor = [UIColor whiteColor];
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//箭头底部宽度
+ (CGFloat)arrowBase {
    return HArrowBase;
}

//内容视图的偏移
+ (UIEdgeInsets)contentViewInsets {
    return  UIEdgeInsetsMake(HArrowInsets, HArrowInsets, HArrowInsets,HArrowInsets);
}

//箭头高度
+ (CGFloat)arrowHeight {
    return HArrowHeight;
}

//是否使用默认的内置阴影和圆角
+(BOOL)wantsDefaultContentAppearance {
    return YES;
}

@end
