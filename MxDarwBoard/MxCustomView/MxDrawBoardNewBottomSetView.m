//
//  MxDrawBoardNewBottomSetView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/10/25.
//

#import "MxDrawBoardNewBottomSetView.h"
#import "UIImage+MxTool.h"

@interface MxDrawBoardNewBottomSetView()

@property(nonatomic,strong)UIButton *firstBtn;

@property(nonatomic,strong)UIButton *secondBtn;

@property(nonatomic,strong)UIButton *thirdBtn;

@property(nonatomic,strong)UIButton *allLightBtn;

@end

@implementation MxDrawBoardNewBottomSetView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        [self layoutSubview];
    }
    return self;
}

-(void)layoutSubview{
    for (int i = 0; i< 3 ;i++) {
        UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        setBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(140) + i * FIT_TO_IPAD_VER_VALUE(110), 0, FIT_TO_IPAD_VER_VALUE(100), FIT_TO_IPAD_VER_VALUE(60));
        [setBtn setTitle:[[self btnTitlesArray] objectAtIndex:i] forState:UIControlStateNormal];
        if (i == 0) {
            [self.allLightBtn setTitleColor:UIColorFromRGB(0x0076FF) forState:UIControlStateHighlighted];
        }else{
            [setBtn setTitleColor:UIColorFromRGB(0x0076FF) forState:UIControlStateSelected];
        }
        [setBtn setTitleColor:UIColorFromRGB(0xBBBBBB) forState:UIControlStateNormal];
        setBtn.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 0.25);
        setBtn.titleLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(16)];
        [self addSubview:setBtn];
        setBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(18);
        setBtn.layer.masksToBounds = YES;
        [setBtn addTarget:self action:@selector(setBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        setBtn.tag = 100 + i;
        if (i == 0) {
            self.firstBtn = setBtn;
        }else if (i == 1){
            self.secondBtn = setBtn;
        }else{
            self.thirdBtn = setBtn;
        }
    }
    self.allLightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.allLightBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(470) , FIT_TO_IPAD_VER_VALUE(8), FIT_TO_IPAD_VER_VALUE(52), FIT_TO_IPAD_VER_VALUE(44));
    [self.allLightBtn setTitle:@"全亮" forState:UIControlStateNormal];
    [self.allLightBtn setTitleColor:UIColorFromRGB(0x0076FF) forState:UIControlStateSelected];
    [self.allLightBtn setTitleColor:UIColorFromRGB(0xBBBBBB) forState:UIControlStateNormal];
    self.allLightBtn.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 0.25);
    self.allLightBtn.titleLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(14)];
    [self addSubview:self.allLightBtn];
    self.allLightBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(18);
    self.allLightBtn.layer.masksToBounds = YES;
    [self.allLightBtn addTarget:self action:@selector(selectAllLight:) forControlEvents:UIControlEventTouchUpInside];
    self.allLightBtn.hidden = YES;
}
-(NSArray *)btnTitlesArray{
    return @[@"群组投屏",@"一键投屏",@"实时绘画"];
}

#pragma mark -UIButtonClicked -

-(void)setBtnClick:(UIButton *)sender{
    if (sender == self.secondBtn && sender.isSelected) {
        return;
    }
    sender.selected = !sender.isSelected;
    
    if ([self.delegate respondsToSelector:@selector(newBottomViewSeleted:IsSelected:)]) {
        [self.delegate newBottomViewSeleted:sender.tag - 100 IsSelected:sender.isSelected];
    }
    if (sender == self.thirdBtn) {
        if (sender.isSelected) {
            self.firstBtn.selected = NO;
            self.allLightBtn.hidden = NO;
            [self setOtherBtnEnable:NO];
        }else{
            self.allLightBtn.hidden = YES;
            [self setOtherBtnEnable:YES];
        }
    }
    
//    if (sender.isSelected) {
//        if (sender == self.firstBtn) {
//            self.thirdBtn.selected = NO;
//            [self setSecondBtnEnable:NO];
//            self.allLightBtn.hidden = YES;
//        }else if (sender == self.secondBtn){
//
//        }else{
//            self.firstBtn.selected = NO;
//            [self setSecondBtnEnable:NO];
//            self.allLightBtn.hidden = NO;
//        }
//    }else{
//        if (sender == self.firstBtn) {
//            self.thirdBtn.selected = NO;
//            [self setSecondBtnEnable:YES];
//            self.allLightBtn.hidden = YES;
//            [self setSecondBtnEnable:YES];
//        }else if (sender == self.secondBtn){
//
//        }else{
//            self.firstBtn.selected = NO;
//        }
//    }
}

-(void)setOtherBtnEnable:(BOOL)enable{
    self.secondBtn.enabled = enable;
    self.firstBtn.enabled = enable;
    if (enable) {
        [self.firstBtn setTitleColor:UIColorFromRGB(0xBBBBBB) forState:UIControlStateNormal];
        [self.secondBtn setTitleColor:UIColorFromRGB(0xBBBBBB) forState:UIControlStateNormal];
    }else{
        [self.firstBtn setTitleColor:UIColorFromRGB(0x484848) forState:UIControlStateNormal];
        [self.secondBtn setTitleColor:UIColorFromRGB(0x484848) forState:UIControlStateNormal];
    }
}

-(void)selectAllLight:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(selectAllLight)]) {
        [self.delegate selectAllLight];
    }
}




-(void)resetAllBtn{
    self.firstBtn.selected = NO;
    self.secondBtn.selected = NO;
    self.thirdBtn.selected = NO;
}
@end
