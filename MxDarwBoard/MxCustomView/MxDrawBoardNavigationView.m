//
//  MxDrawBoardNavigationView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/23.
//

#import "MxDrawBoardNavigationView.h"
#import "MxColorSelectViewController.h"
#import "MxCustomPopoverBackgroundView.h"
#import "MxDrawModelViewController.h"
#import "DrawModelPopoverBackgroundView.h"
#import "MxPickerViewController.h"
@import MeshSDK;


@interface MxDrawBoardNavigationView ()<MxColorSelectViewControllerDelagate,MxDrawModelViewControllerDelegate,MxPickerViewControllerDelegate>
@property(nonatomic,strong) UIButton *photoBtn;
//选择颜色的按钮
@property(nonatomic,strong) UIButton *colorSelectBtn;

@property(nonatomic,strong) UIButton *modelBtn;

@end

@implementation MxDrawBoardNavigationView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 1);
        [self layoutSubview];
    }
    return self;
}

-(void)layoutSubview{
    //图标
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(16), FIT_TO_IPAD_VER_VALUE(28), FIT_TO_IPAD_VER_VALUE(28), FIT_TO_IPAD_VER_VALUE(28))];
    iconView.image = [UIImage imageNamed:@"logo_AWE"];
    [self addSubview:iconView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(56), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(120), FIT_TO_IPAD_VER_VALUE(24))];
    titleLabel.text = @"绘图软件";
    titleLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(17)];
    titleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:titleLabel];
    
    UIButton *modelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    modelBtn.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(130), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(260), FIT_TO_IPAD_VER_VALUE(24));
    [modelBtn setTitle:@"20x10" forState:UIControlStateNormal];
//    [modelBtn setTitle:@"18x18" forState:UIControlStateSelected];
    [modelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [modelBtn addTarget:self action:@selector(modelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:modelBtn];
    NSInteger modeType = 0;
    NSString * type = [[NSUserDefaults standardUserDefaults] valueForKey:DrawModelType];
    if (type) {
        modeType = [type intValue];
    }
    
    if (modeType == 1) {
        modelBtn.selected = YES;
    }
    self.modelBtn = modelBtn;
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    backBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(200), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(120), FIT_TO_IPAD_VER_VALUE(24));
//    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
//    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    backBtn.titleLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(17)];
//    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:backBtn];
    
    //选取模版
    self.photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.photoBtn.frame = CGRectMake(Screen_WIDTH - FIT_TO_IPAD_VER_VALUE(180), FIT_TO_IPAD_VER_VALUE(27), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(30));
    [self.photoBtn setImage:[UIImage imageNamed:@"icon_btn_canphoto"] forState:UIControlStateNormal];
    [self.photoBtn setImage:[UIImage imageNamed:@"icon_btn_photo"] forState:UIControlStateHighlighted];
    [self.photoBtn addTarget:self action:@selector(seletPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.photoBtn];
    self.photoBtn.hidden = YES;
    
    //分享
    
//    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    shareBtn.frame = CGRectMake(Screen_WIDTH - FIT_TO_IPAD_VER_VALUE(116), FIT_TO_IPAD_VER_VALUE(27), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(30));
////    shareBtn.backgroundColor = [UIColor redColor];
//    [shareBtn addTarget:self action:@selector(sharePhoto:) forControlEvents:UIControlEventTouchUpInside];
//    [shareBtn setImage:[UIImage imageNamed:@"icon_btn_share"] forState:UIControlStateNormal];
//    [self addSubview:shareBtn];
    
    
    //选择颜色的按钮
    self.colorSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.colorSelectBtn.frame = CGRectMake(Screen_WIDTH - FIT_TO_IPAD_VER_VALUE(46), FIT_TO_IPAD_VER_VALUE(27), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(30));
    [self.colorSelectBtn addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
    self.colorSelectBtn.backgroundColor = [UIColor redColor];
    self.colorSelectBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(15);
    [self addSubview:self.colorSelectBtn];
  
}

-(void)updateNavigatonMeshConnectStatus:(NSInteger)connectStatus{
    if (connectStatus == 1) {
        [self.modelBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [self.modelBtn setTitle:[NSString stringWithFormat:@"20x10  %@:%@",[MeshSDK sharedInstance].currentDeviceName,[MeshSDK sharedInstance].currenRssi] forState:UIControlStateNormal];
    }else{
        [self.modelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}


- (void)isShowPhotoBtn:(BOOL)isShow{
    self.photoBtn.hidden = !isShow;
}

#pragma mark - UIButtonClicked -

-(void)seletPhoto:(UIButton *)sender{
//    if ([self.delegate respondsToSelector:@selector(selectPhotoBtnClick)]) {
//        [self.delegate selectPhotoBtnClick];
//    }
    
    MxDrawModelViewController *modelVC = [[MxDrawModelViewController alloc]init];
    modelVC.popoverPresentationController.sourceView = self.colorSelectBtn;
    modelVC.popoverPresentationController.sourceRect = self.colorSelectBtn.bounds;
    modelVC.popoverPresentationController.popoverBackgroundViewClass = DrawModelPopoverBackgroundView.class;
    modelVC.delegate = self;
    [self.viewController presentViewController:modelVC animated:YES completion:nil];
}

-(void)sharePhoto:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(shareImage)]) {
        [self.delegate shareImage];
    }
}

-(void)selectColor:(UIButton *)sender{
//    MxColorSelectViewController *vc = [[MxColorSelectViewController alloc] initWithColorArray:self.colorArray];
//    vc.popoverPresentationController.sourceView = sender;
//    vc.popoverPresentationController.sourceRect = sender.bounds;
//    vc.popoverPresentationController.popoverBackgroundViewClass = MxCustomPopoverBackgroundView.class;
//    vc.delegate = self;
//    [self.viewController presentViewController:vc animated:YES completion:nil];
    
    MxPickerViewController *picker = [[MxPickerViewController alloc] initWithColor:sender.backgroundColor];
    picker.delegate = self;
    picker.popoverPresentationController.sourceView = sender;
    picker.popoverPresentationController.sourceRect = sender.bounds;
    picker.popoverPresentationController.popoverBackgroundViewClass = MxCustomPopoverBackgroundView.class;
    [self.viewController presentViewController:picker animated:YES completion:nil];
}



-(void)modelBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    NSInteger type = 0;
    if (sender.isSelected) {
        type = 1;
    }
    if ([self.delegate respondsToSelector:@selector(changeModelWithType:)]) {
        [self.delegate changeModelWithType:type];
    }
}
#pragma mark -MxColorSelectViewControllerDelegate -
-(void)didSelectColor:(UIColor *)color{
    self.colorSelectBtn.backgroundColor = color;
    if ([self.delegate respondsToSelector:@selector(colorSeletFinish:)]) {
        [self.delegate colorSeletFinish:color];
    }
}

#pragma mark -MxDrawModelViewControllerDelegate-
- (void)didSelectLocationArray:(NSArray *)locationArray{
    if ([self.delegate respondsToSelector:@selector(didSelectLocation:)]) {
        [self.delegate didSelectLocation:locationArray];
    }

}
#pragma mark -MxPickerViewControllerDelegate -

- (void)pickerControllerDidSelectColor:(MxPickerViewController *)controller {
    self.colorSelectBtn.backgroundColor = controller.selectedColor;
    if ([self.delegate respondsToSelector:@selector(colorSeletFinish:)]) {
        [self.delegate colorSeletFinish:controller.selectedColor];
    }
}

-(void)backBtnClick:(UIButton *)sender{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}
@end
