//
//  MxDrawBoardBottomSetView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/24.
//

#import "MxDrawBoardBottomSetView.h"
#import "UIImage+MxTool.h"

@interface MxDrawBoardBottomSetView()

@property(nonatomic,strong) UIButton *middBtn;

@end

@implementation MxDrawBoardBottomSetView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 1);
        self.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(22.5);
        [self layoutSubview];
    }
    return self;
}

-(void)layoutSubview{
    for (int i = 0; i< 2 ;i++) {
        UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        setBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(15) + i * FIT_TO_IPAD_VER_VALUE(110), FIT_TO_IPAD_VER_VALUE(11), FIT_TO_IPAD_VER_VALUE(110), FIT_TO_IPAD_VER_VALUE(37));
        [setBtn setTitle:[[self btnTitlesArray] objectAtIndex:i] forState:UIControlStateNormal];
        [setBtn setTitleColor:UIColorFromRGB(0x0076FF) forState:UIControlStateSelected];
        [setBtn setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [setBtn setBackgroundImage:[UIImage createImageColor:UIColorWithAlphaFromRGB(0x767676, 0.5) size:CGSizeMake(FIT_TO_IPAD_VER_VALUE(110), FIT_TO_IPAD_VER_VALUE(37))] forState:UIControlStateSelected];
        [setBtn setBackgroundImage:[UIImage createImageColor:UIColorWithAlphaFromRGB(0x000000, 1) size:CGSizeMake(FIT_TO_IPAD_VER_VALUE(110), FIT_TO_IPAD_VER_VALUE(37))] forState:UIControlStateNormal];
        [self addSubview:setBtn];
        setBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(18.5);
        setBtn.layer.masksToBounds = YES;
        [setBtn addTarget:self action:@selector(setBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        setBtn.tag = 100 + i;
        if (i == 0) {
            setBtn.selected = YES;
            self.middBtn = setBtn;
        }
    }
    
}

-(NSArray *)btnTitlesArray{
    return @[@"创作",@"涂色"];
}


#pragma mark -UIButtonClicked -

-(void)setBtnClick:(UIButton *)sender{
    if (self.middBtn.tag == sender.tag) {
        return;
    }
    self.middBtn.selected = !self.middBtn.selected;
    sender.selected = !sender.selected;
    self.middBtn = sender;
    
    if ([self.delegate respondsToSelector:@selector(drawTypeSeleted:)]) {
        [self.delegate drawTypeSeleted:sender.tag - 100];
    }
}



@end
