//
//  MxCountDownLabel.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/7/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MxCountDownLabel : UILabel

//开始倒计时时间
@property (nonatomic, assign) int count;

- (instancetype)initWithFrame:(CGRect)frame;
//执行这个方法开始倒计时
- (void)startCount:(void(^)(void))comPlete;

@end

NS_ASSUME_NONNULL_END
