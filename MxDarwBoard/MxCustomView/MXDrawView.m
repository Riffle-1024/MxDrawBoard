//
//  MXDrawView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/17.
//

#import "MXDrawView.h"
#import "MxDrawBoardManager.h"
#import "UIColor+Turn.h"




#define DefaultProductColor [UIColor whiteColor]


@interface MXDrawView()

@property (nonatomic, strong) UIBezierPath *path ;

@property (nonatomic, copy) NSMutableArray *pathArray;

@property (nonatomic, copy) NSMutableArray <UIBezierPath *>*pointPathArray;;

@property (nonatomic, strong) UIColor *drawColor;//绘画的颜色

@property(nonatomic, assign) BOOL isEarear;

@property (nonatomic,copy) NSMutableArray <CAShapeLayer *>*layerArray;

@property (nonatomic,copy) NSMutableArray <MxPointModel *>*pointModelArray;

@property (nonatomic,copy) NSMutableArray <LocationModel *>*currentPointArray;//当前绘制的point数组

@property (nonatomic,copy) NSMutableArray <NSArray *>*historyPointArray;//point数组历史数据

@property (nonatomic,copy) NSArray *productLocationArray;

@property (nonatomic,assign) NSInteger modelType;//0:20x20;1:18x18

@end

@implementation MXDrawView

-(NSMutableArray *)pathArray{
  if (_pathArray == nil) {
    _pathArray = [NSMutableArray array];
  }
  return _pathArray;
  
}

-(NSMutableArray *)pointPathArray{
    if (!_pointPathArray) {
        _pointPathArray = [NSMutableArray array];
    }
    return _pointPathArray;
}

-(NSMutableArray *)layerArray{
    if (!_layerArray) {
        _layerArray = [NSMutableArray array];
    }
    return _layerArray;
}

-(NSMutableArray *)pointModelArray{
    if (!_pointModelArray) {
        _pointModelArray = [NSMutableArray array];
    }
    return _pointModelArray;
}

-(NSMutableArray *)currentPointArray{
    if (!_currentPointArray) {
        _currentPointArray = [NSMutableArray array];
    }
    return _currentPointArray;;
}

-(NSMutableArray *)historyPointArray{
    if (!_historyPointArray) {
        _historyPointArray = [NSMutableArray array];
    }
    return _historyPointArray;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.lineWidth = 1;
        self.drawColor = [UIColor redColor];
        self.backgroundColor = [UIColor clearColor];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:singleTap];
        [singleTap setNumberOfTouchesRequired:1];//触摸点个数
        [singleTap setNumberOfTapsRequired:1];//点击次数
        [self layoutSubview];
    }
    return self;
}

-(void)layoutSubview{
    //整个模版默认颜色绘制
    for (int i = 0; i < [MxDrawBoardManager shareInstance].pointList.count; i++) {
        CGPoint point = CGPointFromString([[MxDrawBoardManager shareInstance].pointList objectAtIndex:i]);
        UIColor *paintColor = DefaultBaseColor;
        if (self.modelType == 1) {
            if (i%20 == 0 || i%20 == 19 || i/20 == 0 || i/20 == 19 ) {
                paintColor = [UIColor blackColor];
            }
        }else if(self.modelType == 2){
            if (i >= 200 ) {
                paintColor = [UIColor blackColor];
            }
        }
        [self drawWithPoint:point Color:paintColor Location:i];
        MxPointModel *pointModel = [[MxPointModel alloc] init];
        pointModel.index = 0;
        pointModel.location = i;
        [pointModel.colorArray addObject:DefaultBaseColor];
        [self.pointModelArray addObject:pointModel];
    }
}
- (void)setIsDebug:(BOOL)isDebug{
    _isDebug = isDebug;
    if (isDebug) {
        [self clear];
    }
}

//绘制某个位置灯的颜色
-(void)drawWithPoint:(CGPoint )point Color:(UIColor *)color Location:(int)location{
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.lineWidth = 1;
    //圆环的颜色
    layer.strokeColor = color.CGColor;
    //背景填充色
    layer.fillColor = color.CGColor;
    //设置半径为15
    CGFloat radius = 15;
    //按照顺时针方向
    BOOL clockWise = true;
    //初始化一个路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:radius startAngle:(0) endAngle:M_PI*2 clockwise:clockWise];
    [path closePath];
    layer.path = [path CGPath];
    [self.layer addSublayer:layer];
    [self.pointPathArray addObject:path];
    [self.layerArray addObject:layer];
    
    if (self.isDebug) {
        CATextLayer * titleLayer = [CATextLayer layer];
        titleLayer.frame = CGRectMake(point.x - FIT_TO_IPAD_VER_VALUE(15), point.y - FIT_TO_IPAD_VER_VALUE(6), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(12));
        titleLayer.fontSize = FIT_TO_IPAD_VER_VALUE(12);
        titleLayer.alignmentMode = kCAAlignmentCenter;
        titleLayer.foregroundColor = [UIColor blackColor].CGColor;
        titleLayer.string = [NSString stringWithFormat:@"%d",location + 1];
        titleLayer.contentsScale = 3;
        [self.layer addSublayer:titleLayer];
    }
}

//创建新的CAShapeLayer
-(CAShapeLayer *)getNewLayerWoithColor:(UIColor *)color CGPoint:(CGPoint )point{
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.lineWidth = 1;
    //圆环的颜色
    layer.strokeColor = color.CGColor;
    //背景填充色
    layer.fillColor = color.CGColor;
    //设置半径为15
    CGFloat radius = 15;
    //按照顺时针方向
    BOOL clockWise = true;
    //初始化一个路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:radius startAngle:(0) endAngle:M_PI*2 clockwise:clockWise];
    [path closePath];
    layer.path = [path CGPath];
    return layer;
}

//绘画模式
-(void)draw{
    self.isEarear = NO;
}
//清屏
- (void)clear{
    [self.layerArray removeAllObjects];
    [self.pointPathArray removeAllObjects];
    [self.historyPointArray removeAllObjects];
    [self.pointModelArray removeAllObjects];
    self.layer.sublayers = nil;
    [self layoutSubview];
    if (self.patinModel == PaintingModeAddColor) {
        [self loadProductWithLocationArray:self.productLocationArray];
    }
}
//撤销
//最后一次操作的点，全部恢复到之前的颜色(未完成)
-(void)undo{
    if (self.historyPointArray.count > 0) {
        NSArray <NSNumber *>*pointArray = [self.historyPointArray lastObject];
        for (NSNumber * location in pointArray) {
            int locationValue = [location intValue];
            MxPointModel *pointModel = [self.pointModelArray objectAtIndex:locationValue];
            pointModel.index -= 1;
            [pointModel.colorArray removeLastObject];
            if (pointModel.index < pointModel.colorArray.count) {
                UIColor *newColor = [pointModel.colorArray lastObject];
                [self updateLightViewWithLocation:locationValue Color:newColor];
//                [self.pointModelArray replaceObjectAtIndex:locationValue withObject:pointModel];
            }
            
        }
        [self.historyPointArray removeLastObject];
    }
    
  
}
//橡皮擦
-(void)earear{
    self.isEarear = YES;
}
//设置线的宽度
-(void)setLineWidth:(NSInteger )width{
  self.Width = width;
}   
//设置线的颜色
- (void)setLineColor:(UIColor *)color{
    self.drawColor = color;
}

-(void)loadProductWithLocationArray:(NSArray *)locationArray{
    self.productLocationArray = locationArray;
    for (int i = 0; i < locationArray.count; i++) {
        int location = [[locationArray objectAtIndex:i] intValue];
        CGPoint point = CGPointFromString([[MxDrawBoardManager shareInstance].pointList objectAtIndex:location]);
        UIColor *paintColor = DefaultProductColor;
        [self updateViewWithPoint:point Color:paintColor Complete:^(BOOL isUpdate, int location) {
                    
        }];
    }
}

-(void)drawPointWtithLocation:(NSInteger )location Color:(UIColor *)color Complete:(void(^)(BOOL isUpdate,int location))comPlete{
    CGPoint point = CGPointFromString([[MxDrawBoardManager shareInstance].pointList objectAtIndex:location]);
    [self updateViewWithPoint:point Color:color Complete:comPlete];
}


////更新灯的颜色
//-(void)updateViewWithLocation:(NSInteger)location Color:(UIColor *)color{
//    CGPoint point = CGPointFromString([[MxDrawBoardManager shareInstance].pointList objectAtIndex:location]);
//    [self drawWithPoint:point Color:self.drawColor Location:location];
//}

//手势滑动
- (void)pan:(UIPanGestureRecognizer *)pan{
  
  CGPoint curP = [pan locationInView:self];
      DLog(@"curp:%@",NSStringFromCGPoint(curP));
    [self updateViewWithPoint:curP Color:self.drawColor Complete:^(BOOL isUpdate, int location) {
        if (isUpdate) {
        }
    }];
//    if(pan.state == UIGestureRecognizerStateEnded){
//        [self.historyPointArray addObject:[self.currentPointArray copy]];
//        if ([self.delegate respondsToSelector:@selector(changeLocationArray:OpeaType:)]) {
//            DrawOpeaType opeatype = AddPoint;
//            if (self.isEarear) {
//                opeatype = DeletPoint;
//            }
//            [self.delegate changeLocationArray:self.currentPointArray OpeaType:opeatype];
//        }
//        [self.currentPointArray removeAllObjects];
//    }

  
}

-(void)singleTap:(UITapGestureRecognizer *)singleTap{
    CGPoint curP = [singleTap locationInView:self];
      DLog(@"curp:%@",NSStringFromCGPoint(curP));
    [self updateViewWithPoint:curP Color:self.drawColor Complete:^(BOOL isUpdate, int location) {
//        if (isUpdate) {
//            [self.historyPointArray addObject:[self.currentPointArray copy]];
//            if ([self.delegate respondsToSelector:@selector(changeLocationArray:OpeaType:)]) {
//                DrawOpeaType opeatype = AddPoint;
//                if (self.isEarear) {
//                    opeatype = DeletPoint;
//                }
//                [self.delegate changeLocationArray:self.currentPointArray OpeaType:opeatype];
//            }
//            [self.currentPointArray removeAllObjects];
//        }
    }];
    

}

//UIView被点击
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    CGPoint point = [self getTouchSet:touches];
//    int location =  [self updateViewWithPoint:point];
//}


//更新灯的颜色，如果灯的颜色和上次一样，就不再做处理
-(void)updateViewWithPoint:(CGPoint)point Color:(UIColor *)color Complete:(void(^)(BOOL isUpdate,int location))comPlete{
    int location = [self getLocationWihtPoint:point];
    BOOL isUpdate = NO;
    if (location != 1000) {
        UIColor *newColor;
        if (self.isEarear) {
            newColor = DefaultBaseColor;
            if (self.patinModel == PaintingModeAddColor) {
                if ([self isContainProtuctLocation:location]) {
                    newColor = DefaultProductColor;
                }
            }
        }else{
            newColor = color;
        }
        if (self.modelType == 1) {
            if (location%20 == 0 || location%20 == 19 || location/20 == 0 || location/20 == 19 ) {
                NSLog(@"超出18x18范围，不需要绘制");
                return;
            }
        }else if(self.modelType == 2){
            if (location >= 200 ) {
                NSLog(@"超出18x18范围，不需要绘制");
                return;
            }
        }
        BOOL isNeedUpdateView = [self isNeedUpdateViewWithLoaction:location NewColor:newColor];
        if (isNeedUpdateView) {
              DLog(@"need draw new color point is:%@,location is:%d",NSStringFromCGPoint(point),location);
            [self updateLightViewWithLocation:location Color:newColor];
            isUpdate = YES;
        }else{
              DLog(@"the same color and no draw point is:%@,location is:%d",NSStringFromCGPoint(point),location);
        }
    }
    comPlete(isUpdate,location);
}

//更新灯的颜色
-(void)updateLightViewWithLocation:(int)location Color:(UIColor *)newColor{
    CGPoint newPoint = CGPointFromString([[MxDrawBoardManager shareInstance].pointList objectAtIndex:location]);
    CAShapeLayer *layer = [self.layerArray objectAtIndex:location];
    CAShapeLayer *newLayer = [self getNewLayerWoithColor:newColor CGPoint:newPoint];
    [self.layer replaceSublayer:layer with:newLayer];
    [self.layerArray replaceObjectAtIndex:location withObject:newLayer];

    [self updatePointModelWithLocation:location Color:newColor];
    if ([self isSameColorWithFirstColor:DefaultProductColor SecondColor:newColor]) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(changeLocation:LocationModel:DrawOpeaType:)]) {
        DrawOpeaType opeatype = AddPoint;
        if (self.isEarear) {
            opeatype = DeletPoint;
        }
        [self.delegate changeLocation:location LocationModel:[[LocationModel alloc] initWithLocation:location Color:newColor IsOpen:!self.isEarear] DrawOpeaType:opeatype];
    }
}

//新旧颜色一致，不需要更新UI
-(BOOL)isNeedUpdateViewWithLoaction:(int)location NewColor:(UIColor *)newColor{
    MxPointModel *pointModel = [self.pointModelArray objectAtIndex:location];
    UIColor *color = [pointModel.colorArray lastObject];
    return ![self isSameColorWithFirstColor:color SecondColor:newColor];
}


-(BOOL)isContainProtuctLocation:(int)location{
    
    for (int i = 0; i < self.productLocationArray.count; i++) {
        int productLocation = [[self.productLocationArray objectAtIndex:i] intValue];
        if (location == productLocation) {
            return YES;
        }
    }
    return NO;

}

//灯的颜色更新，记录灯的变化记录
-(void)updatePointModelWithLocation:(int)location Color:(UIColor *)color{
    MxPointModel *pointModel = [self.pointModelArray objectAtIndex:location];
    pointModel.index += 1;
    [pointModel.colorArray addObject:color];
    LocationModel *locationModel = [[LocationModel alloc] init];
    locationModel.location = location;
    locationModel.hexColor = [UIColor hexStringFromColor:color];
    locationModel.isOpen = !self.isEarear;
    locationModel.hsvColor = [UIColor hsvStringFromColor:color];
    [self.currentPointArray addObject:locationModel];
//    [self.pointModelArray replaceObjectAtIndex:location withObject:pointModel];
}

//获取触摸点point
//- (CGPoint)getTouchSet:(NSSet *)touches{
//    UITouch *touch = [touches anyObject];
//     return [touch locationInView:self];
//}

//通过point获取灯的位置号码（0-399）
-(int)getLocationWihtPoint:(CGPoint)point{
    for (int i = 0; i < self.pointPathArray.count; i++) {
        UIBezierPath *path = [self.pointPathArray objectAtIndex:i];
        if ([path containsPoint:point]) {
            return i;
        }
    }
    return 1000;
}

//对比是否是相同的UIcolor
-(BOOL)isSameColorWithFirstColor:(UIColor *)firstColor SecondColor:(UIColor *)secondColor{
    NSString *firstColorString = [UIColor hexStringFromColor:firstColor];
    NSString *secondColorString = [UIColor hexStringFromColor:secondColor];
//      DLog(@"firstColorString:%@;secondColorString:%@",firstColorString,secondColorString);
    return [firstColorString isEqualToString:secondColorString];
}


-(void)setAllPointWihtColor:(UIColor *)color{
    self.drawColor = color;
    for (int i = 0; i < [MxDrawBoardManager shareInstance].pointList.count; i++) {
        int location = i;
        CGPoint point = CGPointFromString([[MxDrawBoardManager shareInstance].pointList objectAtIndex:location]);
        [self updateViewWithPoint:point Color:self.drawColor Complete:^(BOOL isUpdate, int location) {
                    
        }];
    }
}

-(void)setModelType:(NSInteger )modeType{
    _modelType = modeType;
    [self clear];
}

@end
