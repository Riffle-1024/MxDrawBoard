//
//  DeveloperNavigaSetView.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DeveloperNavigaSetViewDelegate <NSObject>

-(void)btnClickedWithBtnTitle:(NSString *)btnTitle Sender:(UIButton *)sender;

@end

@interface DeveloperNavigaSetView : UIView

@property(nonatomic,weak) id<DeveloperNavigaSetViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
