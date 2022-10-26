//
//  MxPickerViewController.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/16.
//

#import "MxPickerViewController.h"
#import "MxColorPicker.h"

@interface MxPickerViewController () <UIPopoverPresentationControllerDelegate>

@end

@implementation MxPickerViewController

- (instancetype)initWithColor:(UIColor *)color {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.delegate = self;
        _selectedColor = color;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.view.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 0.3);
    MxColorPicker *picker = [[MxColorPicker alloc] initWithFrame:self.view.bounds];
    picker.selectedColor = _selectedColor;
    picker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [picker addTarget:self action:@selector(onColorChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:picker];
    
    self.preferredContentSize = CGSizeMake(FIT_TO_IPAD_VER_VALUE(202), FIT_TO_IPAD_VER_VALUE(250));
}

- (void)onColorChange:(MxColorPicker *)picker {
    _selectedColor = picker.selectedColor;
    [_delegate pickerControllerDidSelectColor:self];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
