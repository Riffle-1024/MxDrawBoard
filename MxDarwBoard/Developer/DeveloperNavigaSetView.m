//
//  DeveloperNavigaSetView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import "DeveloperNavigaSetView.h"


@implementation DeveloperNavigaSetView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 1);
        [self layoutSubview];
    }
    return self;
}
-(void)layoutSubview{
    NSInteger count = [self btnTitlesArray].count;
    for (int i = 0; i < count; i++) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(Screen_WIDTH - ((count - i) * FIT_TO_IPAD_VER_VALUE(100) - FIT_TO_IPAD_VER_VALUE(20)), FIT_TO_IPAD_VER_VALUE(27), FIT_TO_IPAD_VER_VALUE(50), FIT_TO_IPAD_VER_VALUE(30));
        btn.titleLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(24)];
        [btn setTitle:[[self btnTitlesArray] objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:btn];
        btn.tag = 100 + i;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
  
}

-(NSArray *)btnTitlesArray{
    return @[@"退出",@"新增",@"保存",@"编辑"];
}
#pragma mark - UIButtonClicked -

-(void)btnClicked:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(btnClickedWithBtnTitle:Sender:)]) {
        sender.selected = !sender.selected;
        [self.delegate btnClickedWithBtnTitle:sender.titleLabel.text Sender:sender];
    }
}

@end
