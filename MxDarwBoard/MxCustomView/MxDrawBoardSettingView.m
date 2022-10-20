//
//  MxDrawBoardSettingView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/23.
//

#import "MxDrawBoardSettingView.h"

@interface MxDrawBoardSettingView()

@property(nonatomic,strong) UIButton *middBtn;


@end

@implementation MxDrawBoardSettingView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 1);
        [self layoutSubview];
    }
    return self;
}


-(NSArray *)btnTitlesArray{
    return @[@"橡皮擦",@"绘画",@"清屏"];
}

-(NSArray *)btnImageSelect{
    return @[@"icon_btn_earear",@"icon_btn_draw",@"icon_btn_clear"];
}
-(NSArray *)btnImageUnSelect{
    return @[@"icon_btn_canearear",@"icon_btn_candraw",@"icon_btn_canclear"];
}

-(NSArray *)btnImageCannotSelect{
    return @[@"icon_btn_cannotearear",@"icon_btn_connotdraw",@"icon_btn_cannotclear"];
}

-(void)layoutSubview{
    for (int i = 0; i < [self btnImageSelect].count; i++) {
        UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        setBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(5), FIT_TO_IPAD_VER_VALUE(41) + i * FIT_TO_IPAD_VER_VALUE(75), FIT_TO_IPAD_VER_VALUE(44), FIT_TO_IPAD_VER_VALUE(60));
        [setBtn setImage:[UIImage imageNamed:[[self btnImageSelect] objectAtIndex:i]] forState:UIControlStateSelected];
        [setBtn setImage:[UIImage imageNamed:[[self btnImageUnSelect] objectAtIndex:i]] forState:UIControlStateNormal];
        [setBtn setImage:[UIImage imageNamed:[[self btnImageSelect] objectAtIndex:i]] forState:UIControlStateHighlighted];
        [setBtn addTarget:self action:@selector(setBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        setBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(22);
        setBtn.tag = 100 + i;
        [self addSubview:setBtn];
        if (i == 1) {
            self.middBtn = setBtn;
            setBtn.selected = YES;
            [setBtn setBackgroundColor:UIColorWithAlphaFromRGB(0x767676, 0.5)];
        }
    }
}


-(void)setBtnClick:(UIButton *)sender{

    if (sender.tag != 102) {
        [self.middBtn setBackgroundColor:[UIColor clearColor]];
        self.middBtn.selected = !self.middBtn.selected;
        sender.selected = !sender.selected;
        self.middBtn = sender;
        [sender setBackgroundColor:UIColorWithAlphaFromRGB(0x767676, 0.5)];
    }
    if ([self.delegate respondsToSelector:@selector(btnClickWithActionType:)]) {
        [self.delegate btnClickWithActionType:sender.tag - 100];
    }
}
@end
