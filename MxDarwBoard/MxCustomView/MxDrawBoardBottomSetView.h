//
//  MxDrawBoardBottomSetView.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/24.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,DrawType){
//    DrawTypeRealtime = 0,//实时绘画
    DrawTypeCreat = 0,//创作绘画
    DrawTypeProduct = 1  //添色模式
};

@protocol MxDrawBoardBottomSetViewDelegate <NSObject>

-(void)drawTypeSeleted:(DrawType)drawType;

@end


NS_ASSUME_NONNULL_BEGIN

@interface MxDrawBoardBottomSetView : UIView

@property(nonatomic,weak) id<MxDrawBoardBottomSetViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
