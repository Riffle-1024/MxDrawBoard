//
//  DarwModelViewCell.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import "DarwModelViewCell.h"
#import "ProductModelView.h"


@interface DarwModelViewCell()

@property(nonatomic,strong) UILabel *titleLabel;

//@property(nonatomic,strong) ProductModelView *modelView;

@property(nonatomic,strong) UIView *backView;


@property(nonatomic,strong) UIImageView *modelView;

@end

@implementation DarwModelViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 0.2);

        [self layoutSubview];
    }
    return self;
}


-(void)refleshView{
    [self.titleLabel removeFromSuperview];
    [self.modelView removeFromSuperview];
    self.titleLabel = nil;
    self.modelView  = nil;
    [self layoutSubview];
}

-(void)layoutSubview{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(10), FIT_TO_IPAD_VER_VALUE(5), FIT_TO_IPAD_VER_VALUE(100), FIT_TO_IPAD_VER_VALUE(12))];
    self.titleLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(12)];
    self.titleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:self.titleLabel];
    

    self.backView = [[UIView alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(6), FIT_TO_IPAD_VER_VALUE(1), FIT_TO_IPAD_VER_VALUE(188), FIT_TO_IPAD_VER_VALUE(188))];
    [self addSubview:self.backView];
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(170), 0, FIT_TO_IPAD_VER_VALUE(25), FIT_TO_IPAD_VER_VALUE(25));
    self.deleteBtn.hidden = YES;
    [self.deleteBtn setImage:[UIImage imageNamed:@"icon_deleteBtn"] forState:UIControlStateNormal];
    [self addSubview:self.deleteBtn];
    
//    self.modelView = [[ProductModelView alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(25), FIT_TO_IPAD_VER_VALUE(20), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(150))];
//    [self addSubview:self.modelView];
    self.modelView = [[UIImageView alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(25), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(150))];
    [self addSubview:self.modelView];
}

//-(void)updateViewWithLocationArray:(NSArray *)locationArray{
//    [self.modelView updateViewWithLocationArray:locationArray];
//}

-(void)updateViewWithLocationData:(NSDictionary *)locationData{
    NSString *imageKey = [locationData valueForKey:@"imageKey"];
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:imageKey];
    UIImage* image = [UIImage imageWithData:imageData];
    self.modelView.image = image;
}

-(void)isSelected:(BOOL)isSelect{
    if (isSelect) {
        self.backView.layer.borderWidth = FIT_TO_IPAD_VER_VALUE(2);
        self.backView.layer.borderColor = UIColorFromRGB(0x0076FF).CGColor;
        self.backView.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(4);
    }else{
        self.backView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)setTitleString:(NSString *)titleString{
    _titleString = titleString;
    self.titleLabel.text = titleString;
}


@end
