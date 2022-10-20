//
//  MxColorSelectViewController.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/24.
//

#import <UIKit/UIKit.h>


@protocol MxColorSelectViewControllerDelagate <NSObject>

-(void)didSelectColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MxColorSelectViewController : UIViewController

@property(nonatomic,strong)UIColor *selectedColor;

@property(nonatomic,weak)id<MxColorSelectViewControllerDelagate>delegate;

-(instancetype)initWithColorArray:(NSArray *)colorArray;

@end

NS_ASSUME_NONNULL_END
