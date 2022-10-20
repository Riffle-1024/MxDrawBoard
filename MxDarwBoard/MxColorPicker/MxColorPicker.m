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

@interface MxColorPicker () <MxColorWheelViewDelegate>
@property (nonatomic, strong) AlphaSlider *alphaSlider;
@property (nonatomic, strong) MxColorSlider *brightnessSlider;
@property (nonatomic, strong) MxColorWheelView *colorWheel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIVisualEffectView *backgroundView;

@property (nonatomic, strong) UIView *selectedColorContainerView;
@property (nonatomic, strong) UIView *selectedColorView;
@end

@implementation MxColorPicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
        [self addSubview:_backgroundView];

        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_contentView];

        _brightnessSlider = [[MxColorSlider alloc] initWithFrame:CGRectZero];
//        [_contentView addSubview:_brightnessSlider];

        _alphaSlider = [[AlphaSlider alloc] initWithFrame:CGRectZero];
//        [_contentView addSubview:_alphaSlider];

        _colorWheel = [[MxColorWheelView alloc] initWithFrame:CGRectZero];
        _colorWheel.delegate = self;
        [_contentView addSubview:_colorWheel];

        _selectedColorContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _selectedColorContainerView.backgroundColor = [UIColor colorWithPatternImage:[AlphaSlider checkerboardImage]];
        _selectedColorContainerView.layer.cornerRadius = 7.0f;
        [_contentView addSubview:_selectedColorContainerView];

        _selectedColorView = [[UIView alloc] initWithFrame:CGRectZero];
        _selectedColorView.layer.cornerRadius = 7.0f;
        _selectedColorView.backgroundColor = [UIColor redColor];
        [_selectedColorContainerView addSubview:_selectedColorView];


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
}

- (void)layoutSubviews {
    _backgroundView.frame = self.bounds;

    CGRect safeRect = UIEdgeInsetsInsetRect(self.bounds, self.layoutMargins);
    if (@available(iOS 11.0, *)) {
        safeRect = CGRectIntersection(UIEdgeInsetsInsetRect(self.bounds, self.safeAreaInsets), safeRect);
    }
//    safeRect = CGRectInset(safeRect, 10, 10);
    _contentView.frame = safeRect;

    const CGFloat itemSpacing = 35.0f;
    const CGFloat selectedColorSize = SliderHeight + itemSpacing;
    const CGFloat minSize = MIN(CGRectGetWidth(safeRect), CGRectGetHeight(safeRect));
    _selectedColorContainerView.frame = CGRectMake(minSize - selectedColorSize,
                                                   0,
                                                   selectedColorSize,
                                                   selectedColorSize);
    _selectedColorView.frame = _selectedColorContainerView.bounds;
    if (self.selectedColor) {
        _selectedColorView.backgroundColor = self.selectedColor;
    }

    const CGFloat wheelSize = minSize - selectedColorSize;
    _alphaSlider.frame = CGRectMake(0,
                                    CGRectGetMinY(_selectedColorContainerView.frame),
                                    wheelSize - itemSpacing,
                                    SliderHeight);

    _colorWheel.frame = CGRectMake(0,
                                   CGRectGetMaxY(_alphaSlider.frame) + itemSpacing,
                                   wheelSize + 5,
                                   wheelSize + 5);

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
    _selectedColor = [_alphaSlider selectedColor];
    _selectedColorView.backgroundColor = _selectedColor;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)colorWheelViewDidSnapToCenter:(MxColorWheelView *)view {
    AudioServicesPlaySystemSound(1519);
}


@end
