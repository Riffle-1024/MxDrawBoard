//
//  MxColorPicker.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/16.
//

#import "MxColorPicker.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MxColorWheelView.h"
#import "MxColorSlider.h"
#import "MxDrawBoardManager.h"

@interface MxColorPicker () <MxColorWheelViewDelegate>
@property (nonatomic, strong) AlphaSlider *alphaSlider;
@property (nonatomic, strong) MxColorSlider *brightnessSlider;
@property (nonatomic, strong) MxColorWheelView *colorWheel;
@property (nonatomic, strong) UIView *contentView;
//@property (nonatomic, strong) UIVisualEffectView *backgroundView;
@property (nonatomic, strong) UIView *backgroundView;

@property(nonatomic,strong) UILabel *titleLabel;

//@property (nonatomic, strong) UIView *selectedColorContainerView;
//@property (nonatomic, strong) UIView *selectedColorView;

@property(nonatomic,strong) UIColor *firstColor;

@property(nonatomic,strong) UIColor *secondColor;

@property (nonatomic,strong) UIView *firstSelectedColorView;

@property (nonatomic,strong) UIView *secondSelectedColorView;

@end

@implementation MxColorPicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
        _backgroundView = [[UIView alloc] init];
        [self addSubview:_backgroundView];
        _backgroundView.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 1);

        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_contentView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_contentView addSubview:_titleLabel];
        _titleLabel.text = @"颜色";
        _titleLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(24)];
        _titleLabel.textColor = UIColorWithAlphaFromRGB(0xFFFFFF, 0.7);
        
        
        _firstSelectedColorView = [[UIView alloc] initWithFrame:CGRectZero];
        [_contentView addSubview:_firstSelectedColorView];
        _firstSelectedColorView.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(4);
        _firstSelectedColorView.userInteractionEnabled = YES;
        [_firstSelectedColorView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(firstColorViewClicked:)]];
        
        
        _secondSelectedColorView = [[UIView alloc] initWithFrame:CGRectZero];
        [_contentView addSubview:_secondSelectedColorView];
        _secondSelectedColorView.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(4);
        _secondSelectedColorView.userInteractionEnabled = YES;
        [_secondSelectedColorView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(secondColorViewClicked:)]];
        self.secondColor = [MxDrawBoardManager getRecordColor];
        
        _brightnessSlider = [[MxColorSlider alloc] initWithFrame:CGRectZero];
//        [_contentView addSubview:_brightnessSlider];

        _alphaSlider = [[AlphaSlider alloc] initWithFrame:CGRectZero];
//        [_contentView addSubview:_alphaSlider];

        _colorWheel = [[MxColorWheelView alloc] initWithFrame:CGRectZero];
        _colorWheel.delegate = self;
        [_contentView addSubview:_colorWheel];

//        _selectedColorContainerView = [[UIView alloc] initWithFrame:CGRectZero];
//        _selectedColorContainerView.backgroundColor = [UIColor colorWithPatternImage:[AlphaSlider checkerboardImage]];
//        _selectedColorContainerView.layer.cornerRadius = 7.0f;
//        [_contentView addSubview:_selectedColorContainerView];
//
//        _selectedColorView = [[UIView alloc] initWithFrame:CGRectZero];
//        _selectedColorView.layer.cornerRadius = 7.0f;
//        _selectedColorView.backgroundColor = [UIColor redColor];
//        [_selectedColorContainerView addSubview:_selectedColorView];


        [_colorWheel addTarget:self action:@selector(onWheelColorChange:) forControlEvents:UIControlEventValueChanged];
        [_brightnessSlider addTarget:self action:@selector(onBrightnessChange:) forControlEvents:UIControlEventValueChanged];
        [_alphaSlider addTarget:self action:@selector(onAlphaChange:) forControlEvents:UIControlEventValueChanged];

#if 0
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = UIColor.redColor.CGColor;

        _contentView.layer.borderWidth = 0.5;
        _contentView.layer.borderColor = UIColor.blueColor.CGColor;
#endif
    }
    return self;
}

- (void)setSelectedColor:(UIColor *)selectedColor{
    _selectedColor = selectedColor;
    self.colorWheel.selectedColor = selectedColor;
    self.firstSelectedColorView.backgroundColor = selectedColor;
    
}

- (void)layoutSubviews {
    _backgroundView.frame = self.bounds;
    self.firstColor = _selectedColor;
    CGRect safeRect = UIEdgeInsetsInsetRect(self.bounds, self.layoutMargins);
    if (@available(iOS 11.0, *)) {
        safeRect = CGRectIntersection(UIEdgeInsetsInsetRect(self.bounds, self.safeAreaInsets), safeRect);
    }
//    safeRect = CGRectInset(safeRect, 10, 10);
//    _contentView.frame = safeRect;
    _contentView.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(10), FIT_TO_IPAD_VER_VALUE(10), FIT_TO_IPAD_VER_VALUE(182), FIT_TO_IPAD_VER_VALUE(230));

    const CGFloat itemSpacing = 35.0f;
    const CGFloat selectedColorSize = SliderHeight + itemSpacing;
    const CGFloat minSize = MIN(CGRectGetWidth(safeRect), CGRectGetHeight(safeRect));
//    _selectedColorContainerView.frame = CGRectMake(minSize - selectedColorSize,
//                                                   0,
//                                                   selectedColorSize,
//                                                   selectedColorSize);
//    _selectedColorView.frame = _selectedColorContainerView.bounds;
//    if (self.selectedColor) {
//        _selectedColorView.backgroundColor = self.selectedColor;
//    }
    
  

    const CGFloat wheelSize = minSize - selectedColorSize;
//    _alphaSlider.frame = CGRectMake(0,
//                                    CGRectGetMinY(_selectedColorContainerView.frame),
//                                    wheelSize - itemSpacing,
//                                    SliderHeight);
    
    _titleLabel.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(14), FIT_TO_IPAD_VER_VALUE(12), FIT_TO_IPAD_VER_VALUE(60), FIT_TO_IPAD_VER_VALUE(25));

//    _colorWheel.frame = CGRectMake(0,
//                                   CGRectGetMaxY(_alphaSlider.frame) + itemSpacing,
//                                   wheelSize + 5,
//                                   wheelSize + 5);
    _colorWheel.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(6),
                                   FIT_TO_IPAD_VER_VALUE(54),
                                   FIT_TO_IPAD_VER_VALUE(170),
                                   FIT_TO_IPAD_VER_VALUE(170));
    _firstSelectedColorView.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(158), FIT_TO_IPAD_VER_VALUE(9), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(20));
    _secondSelectedColorView.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(124), FIT_TO_IPAD_VER_VALUE(9), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(20));
    if (self.selectedColor) {
        self.firstSelectedColorView.backgroundColor = self.selectedColor;
    }
    if (self.secondColor) {
        self.secondSelectedColorView.backgroundColor = self.secondColor;
    }

    _brightnessSlider.transform = CGAffineTransformIdentity;
    _brightnessSlider.frame = _alphaSlider.frame;
    _brightnessSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _brightnessSlider.center = CGPointMake(minSize - CGRectGetMidY(_alphaSlider.bounds),
                                           CGRectGetMaxY(_colorWheel.frame) - CGRectGetMidX(_brightnessSlider.bounds));
}

- (void)onWheelColorChange:(MxColorWheelView *)colorWheel {
    _brightnessSlider.selectedColor = colorWheel.selectedColor;
    _alphaSlider.selectedColor = colorWheel.selectedColor;
    [self updateSelectedColor];
}

- (void)onBrightnessChange:(MxColorSlider *)slider {
    _colorWheel.selectedColor = slider.selectedColor;
    _alphaSlider.selectedColor = slider.selectedColor;
    [self updateSelectedColor];
}

- (void)onAlphaChange:(AlphaSlider *)slider {
    [self updateSelectedColor];
}

- (void)updateSelectedColor {
    self.selectedColor = [_alphaSlider selectedColor];
    self.secondColor = self.firstColor;
//    self.firstColor = _selectedColor;
//    _selectedColorView.backgroundColor = _selectedColor;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)colorWheelViewDidSnapToCenter:(MxColorWheelView *)view {
    AudioServicesPlaySystemSound(1519);
}


//-(void)setFirstColor:(UIColor *)firstColor{
//    _firstColor = firstColor;
//    _firstSelectedColorView.backgroundColor = firstColor;
//}

-(void)setSecondColor:(UIColor *)secondColor{
    if (secondColor) {
        _secondColor = secondColor;
        _secondSelectedColorView.backgroundColor = secondColor;
        [MxDrawBoardManager saveRecordColor:secondColor];
    }

}



-(void)firstColorViewClicked:(UITapGestureRecognizer *)sender{
    if (self.firstColor) {
        self.selectedColor = self.firstColor;
        _colorWheel.selectedColor = self.firstColor;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
}

-(void)secondColorViewClicked:(UITapGestureRecognizer *)sender{
    if (self.secondColor) {
        UIColor *tempColor = self.secondColor;
        self.secondColor = self.selectedColor;
        self.selectedColor = tempColor;
        self.firstColor = tempColor;
        _colorWheel.selectedColor = self.firstColor;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
}
@end
