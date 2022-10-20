//
//  MxSimpleSlider.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/16.
//

#import "MxColorSlider.h"

@interface MxSimpleSlider ()
@property (nonatomic, strong) UIView *thumbView;
@property (nonatomic, strong) UIView *thumbContainerView;
@property (nonatomic, assign) CGFloat touchOffset;
@property (nonatomic, assign) CGFloat value;
@end

const CGFloat SliderHeight = 0;

@implementation MxSimpleSlider
+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _thumbContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _thumbContainerView.userInteractionEnabled = NO;
        [self addSubview:_thumbContainerView];

        _thumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _thumbView.backgroundColor = [UIColor clearColor];
        _thumbView.userInteractionEnabled = NO;
        _thumbView.layer.borderWidth = 3;
        _thumbView.layer.borderColor = UIColor.whiteColor.CGColor;
        _thumbView.layer.cornerRadius = CGRectGetMidY(_thumbView.bounds);
        _thumbView.layer.shadowOffset = CGSizeMake(0, 0);
        _thumbView.layer.shadowRadius = 3.0;
        _thumbView.layer.shadowOpacity = 0.2;
        [_thumbContainerView addSubview:_thumbView];

        self.layer.cornerRadius = CGRectGetMidY(self.bounds);
    }
    return self;
}

- (void)setFrame:(CGRect)bounds {
    [super setFrame:CGRectMake(bounds.origin.x,
                               bounds.origin.y,
                               bounds.size.width,
                               SliderHeight)];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, SliderHeight);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, SliderHeight);
}

- (void)layoutSubviews {
    _thumbContainerView.frame = CGRectInset(self.bounds, CGRectGetMidY(self.bounds), 0);
    _thumbView.center = CGPointMake(CGRectGetWidth(_thumbContainerView.bounds) * _value, CGRectGetMidY(_thumbContainerView.bounds));

    CAGradientLayer *layer = (id)self.layer;
    layer.startPoint = CGPointMake(CGRectGetMinX(_thumbContainerView.frame) / CGRectGetWidth(self.bounds), 0.5);
    layer.endPoint = CGPointMake(CGRectGetMaxX(_thumbContainerView.frame) / CGRectGetWidth(self.bounds), 0.5);
}

- (void)setValue:(CGFloat)value {
    if (ABS(_value - value) <= CGFLOAT_MIN) {
        return;
    }
    _value = value;
    [self setNeedsLayout];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGFloat location = [touch locationInView:_thumbContainerView].x;
    _touchOffset = _thumbView.center.x - location;
    return CGRectContainsPoint(_thumbView.bounds, [touch locationInView:_thumbView]);
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGFloat location = [touch locationInView:_thumbContainerView].x + _touchOffset;
    self.value = MIN(MAX(0.0, location / CGRectGetWidth(_thumbContainerView.bounds)), 1.0);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self continueTrackingWithTouch:touch withEvent:event];
}

@end

@interface MxColorSlider ()
@property (nonatomic, assign) CGFloat hue;
@property (nonatomic, assign) CGFloat saturation;
@property (nonatomic, assign) CGFloat brightness;
@end

@implementation MxColorSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    CGFloat h = 0, s = 0, b = 0;
    [selectedColor getHue:&h saturation:&s brightness:&b alpha:NULL];

    if (ABS(_hue - h) <= CGFLOAT_MIN && ABS(_saturation - s) <= CGFLOAT_MIN && ABS(_brightness - b) <= CGFLOAT_MIN) {
        return;
    }

    _hue = h;
    _saturation = s;
    _brightness = b;
    [self updateTrack];
    [self setNeedsLayout];
}

- (UIColor *)selectedColor {
    return [UIColor colorWithHue:_hue saturation:_saturation brightness:self.value alpha:1.0];
}

- (void)updateTrack {
    self.value = _brightness;
    CAGradientLayer *layer = (id)self.layer;
    layer.colors = @[
        (id)[UIColor colorWithHue:_hue saturation:_saturation brightness:0 alpha:1].CGColor,
        (id)[UIColor colorWithHue:_hue saturation:_saturation brightness:1 alpha:1].CGColor,
    ];
}

@end

@implementation AlphaSlider

+ (UIImage *)checkerboardImage {
    static dispatch_once_t onceToken;
    static UIImage *image = nil;
    dispatch_once(&onceToken, ^{
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(FIT_TO_IPAD_VER_VALUE(24), FIT_TO_IPAD_VER_VALUE(24))];
        image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [[UIColor colorWithWhite:0.8 alpha:1.0] setFill];
            UIRectFill(CGRectMake(0, 0, FIT_TO_IPAD_VER_VALUE(12), FIT_TO_IPAD_VER_VALUE(12)));
            UIRectFill(CGRectMake(FIT_TO_IPAD_VER_VALUE(12), FIT_TO_IPAD_VER_VALUE(12), FIT_TO_IPAD_VER_VALUE(12), FIT_TO_IPAD_VER_VALUE(12)));
        }];
    });
    return image;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[AlphaSlider checkerboardImage]];
        self.alphaValue = 1.0;
    }
    return self;
}

- (CGFloat)alphaValue {
    return self.value;
}

- (void)setAlphaValue:(CGFloat)alphaValue {
    self.value = alphaValue;
}

- (void)updateTrack {
    CAGradientLayer *layer = (id)self.layer;
    layer.colors = @[
        (id)[UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:0].CGColor,
        (id)[UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:1].CGColor,
    ];
}

- (UIColor *)selectedColor {
    return [UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:self.alphaValue];
}

@end

