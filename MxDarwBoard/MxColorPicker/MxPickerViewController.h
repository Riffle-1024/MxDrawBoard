//
//  MxPickerViewController.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol MxPickerViewControllerDelegate;
@interface MxPickerViewController : UIViewController

@property (nonatomic, strong, readonly) UIColor *selectedColor;
@property (nonatomic, weak) id <MxPickerViewControllerDelegate> delegate;
- (instancetype)initWithColor:(UIColor *)color;

@end

@protocol MxPickerViewControllerDelegate <NSObject>

- (void)pickerControllerDidSelectColor:(MxPickerViewController *)controller;

@end
NS_ASSUME_NONNULL_END
