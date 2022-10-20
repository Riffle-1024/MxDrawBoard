//
//  MxTimer.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MxTimer : NSObject

/// 创建定时器
/// @param interval 定时器的时间间隔
/// @param waitTime 定时器持续时间  当小于等于0时定时器会一直持续下去
/// @param handler 每隔一段时间回调的方法
- (instancetype)initWithTimeInterval:(float)interval andWaitTime:(float)waitTime eventHandler:(void(^)(void))handler;
/// 暂停
-(void)pauseTimer;
/// 启动
-(void)resumeTimer;
/// 取消
-(void)stopTimer;

@end

NS_ASSUME_NONNULL_END
