//
//  MxDrawBoardSettingView.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/23.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ActionType) {
    ActionTypeEarea = 0,//橡皮擦
    ActionTypeDraw = 1,//绘画
    ActionTypeClear = 2,//清屏
    ActionTypeFinish = 3//完成
};

NS_ASSUME_NONNULL_BEGIN

@protocol MxDrawBoardSettingViewDelegate <NSObject>

-(void)btnClickWithActionType:(ActionType )actionType;

@end

@interface MxDrawBoardSettingView : UIView

@property(nonatomic,weak) id<MxDrawBoardSettingViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
