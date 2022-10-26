//
//  MxCountDownLabel.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/7/7.
//

#import "MxCountDownLabel.h"


typedef void(^AnimationBlock)(void);

@interface MxCountDownLabel()

@property (nonatomic, strong) NSTimer *timer;

@property(nonatomic,copy) AnimationBlock resultBlock;

@end

@implementation MxCountDownLabel


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(200)];
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}
//开始倒计时
- (void)startCount:(void(^)(void))comPlete{
    self.resultBlock = comPlete;
    [self initTimer];
}

- (void)initTimer{
    //如果没有设置，则默认为3
    if (self.count == 0){
        self.count = 3;
    }self.text = [NSString stringWithFormat:@"%d",_count + 1];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
}

- (void)countDown{
    if (_count > 0){
        self.text = [NSString stringWithFormat:@"%d",_count];
//        CAKeyframeAnimation *anima2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
//        //字体变化大小
//        NSValue *value1 = [NSNumber numberWithFloat:FIT_TO_IPAD_VER_VALUE(16)];
//        NSValue *value2 = [NSNumber numberWithFloat:FIT_TO_IPAD_VER_VALUE(12)];
//        NSValue *value3 = [NSNumber numberWithFloat:FIT_TO_IPAD_VER_VALUE(8)];
//        NSValue *value4 = [NSNumber numberWithFloat:FIT_TO_IPAD_VER_VALUE(4)];
//        NSValue *value5 = [NSNumber numberWithFloat:FIT_TO_IPAD_VER_VALUE(2)];
//        anima2.values = @[value1,value2,value3,value4,value5];
//        anima2.duration = 0.5;
//        [self.layer addAnimation:anima2 forKey:@"scalsTime"];
        _count -= 1;
    }else {
        [_timer invalidate];
        [self removeFromSuperview];
        self.resultBlock();
    }
}

@end
