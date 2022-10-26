//
//  MxDrawBoardNewBottomSetView.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/10/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MxDrawBoardNewBottomSetViewDelegate <NSObject>

-(void)newBottomViewSeleted:(NSInteger)index IsSelected:(BOOL)isSelected;

-(void)selectAllLight;

@end

@interface MxDrawBoardNewBottomSetView : UIView


@property(nonatomic,weak) id<MxDrawBoardNewBottomSetViewDelegate>delegate;



-(void)resetAllBtn;

@end

NS_ASSUME_NONNULL_END
