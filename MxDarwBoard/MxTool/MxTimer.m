//
//  MxTimer.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/7/19.
//

#import "MxTimer.h"

/*
 注意：
 1.重复调用dispatch_resume会引起崩溃
 2.暂停之后再去取消会引起崩溃
 3.直接取消会崩溃
 */

@interface MxTimer ()

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic,assign) BOOL isSending;

@end

@implementation MxTimer

- (instancetype)initWithTimeInterval:(float)interval andWaitTime:(float)waitTime eventHandler:(nonnull void (^)(void))handler{
    self = [super init];
    if (self) {
        [self createTimerWithTimerInterval:interval andWaitTime:waitTime handler:handler];
    }
    return self;
}
/// 创建定时器
- (void)createTimerWithTimerInterval:(float)interval andWaitTime:(float)waitTime handler:(void(^)(void))handler{
    
    __block float waittingTime = waitTime;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        if (waitTime <= 0) {    // 时间无限
            handler();
        }else{  // 时间有限
            if (waittingTime <= 0) {
                dispatch_source_cancel(timer);
                return ;
            }
            handler();
            waittingTime --;
        }
        
    });
    _timer = timer;
    self.isSending = YES;
    dispatch_resume(timer);
    
}

/// 暂停
-(void)pauseTimer{
    
    if(_timer && self.isSending){
        self.isSending = NO;
        dispatch_suspend(_timer);
    }
}
/// 启动
-(void)resumeTimer{
    if(_timer && !self.isSending){
        self.isSending = YES;
        dispatch_resume(_timer);
    }
}
/// 取消
-(void)stopTimer{
    if(_timer){
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}
- (void)dealloc{
    NSLog(@"Timer销毁了...");
    [self stopTimer];
}

@end
