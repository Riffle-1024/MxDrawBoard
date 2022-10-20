//
//  MxLockButton.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/26.
//

#import "MxLockButton.h"

#define time_out 5

@interface MxLockButton()

@property(nonatomic,strong) dispatch_source_t timer;

@property(nonatomic,assign) BOOL isResuming;//正在计时


@end

@implementation MxLockButton

+(instancetype)buttonWithType:(UIButtonType)buttonType{
    MxLockButton * btn = [super buttonWithType:buttonType];
    return btn;
}

- (void)setHidden:(BOOL)hidden{

    if (hidden) {
        [self startTimer];
    }else{
        [super setHidden:hidden];
            [self startTimer];
    }
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        [self startTimer];
    }
}

-(void)startTimer{
    self.timeout = time_out;
    if (self.timer) {
        if (!self.isResuming) {
            dispatch_resume(self.timer);
            self.isResuming = YES;
        }
    }else{
        [self creatTimer];
    }
    
}



-(void)creatTimer{
    self.timeout = time_out;
    //获取全局队列
    dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //，并将定时器的任务交给全局队列执行(并行，不会造成主线程阻塞)
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global);
    //    self.recordStatus = 1;
    // 设置触发的间隔时间
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    WEAK_SELF;
    dispatch_source_set_event_handler(self.timer, ^{
        
        //1. 每调用一次 数值-1，为5s
        weakSelf.timeout --;
        DLog(@"监控消息超时——————————————————>%d",weakSelf.timeout);
        //2.对timeout进行判断时间是停止倒计时，
        if (weakSelf.timeout <= 0) {
            dispatch_suspend(self.timer);
            weakSelf.isResuming = NO;
//            self.hidden = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [super setHidden:YES];
            });
            weakSelf.timeout = time_out;
            
        }
    });
    dispatch_resume(self.timer);
    self.isResuming = YES;
}
@end
