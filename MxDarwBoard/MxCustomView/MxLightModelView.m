//
//  MxLightModelView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/21.
//

#import "MxLightModelView.h"

@implementation MxLightModelView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
//        UITapGestureRecognizer *recongizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(modelViewPan:)];
//        [self addGestureRecognizer:recongizer];
    }
    return self;
}


-(void)modelViewPan:(UITapGestureRecognizer *)rep{
    CGPoint curP = [rep locationInView:self];
      DLog(@"has pan with view tag:%ld;UIview:%@",self.tag,self);
}

- (void)setBackColor:(UIColor *)backColor{
    self.backColor = backColor;
    self.backgroundColor = backColor;
}

- (UIColor *)backColor{
    return self.backColor;;
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
////      DLog(@"D_view---pointInside withEvent ---");
//    BOOL isInside = [super pointInside:point withEvent:event];
////      DLog(@"D_view---pointInside withEvent --- isInside:%d",isInside);
//    if (isInside) {
////      DLog(@"__func__:%s;UIView.tag%ld",__func__,self.tag);
//
//    }
//    return isInside;
//}
//
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
////      DLog(@"__func__:%s",__func__);
////      DLog(@"UIView:%@",self);
//    return [super hitTest:point withEvent:event];
//}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
////      DLog(@"__func__:%s",__func__);
//}
//
//-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
////      DLog(@"__func__:%s",__func__);
//    CGPoint point = [self getTouchSet:touches];
////    [super hitTest:point withEvent:event];
//    BOOL isInside = [self pointInside:point withEvent:event];
//    if (isInside) {
//      DLog(@"__func__:%s;UIView.tag%ld",__func__,self.tag);
//
//    }
//}
//
//- (CGPoint)getTouchSet:(NSSet *)touches{
//    
//    UITouch *touch = [touches anyObject];
//     return [touch locationInView:self];
//
//}
@end
