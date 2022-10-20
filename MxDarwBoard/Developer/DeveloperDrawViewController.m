//
//  DeveloperDrawViewController.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import "DeveloperDrawViewController.h"
#import "MXDrawView.h"
#import "MxDrawBoardSettingView.h"
#import "MxDrawBoardBaseView.h"
#import "DeveloperNavigaSetView.h"
#import "DevelopManager.h"
#import "DevelopDrawBaseView.h"
#import "DevelopDrawView.h"
#import "MxDrawModelViewController.h"
#import "DrawModelPopoverBackgroundView.h"
#import "UIImage+MxTool.h"


@interface DeveloperDrawViewController ()<MxDrawBoardSettingViewDelegate,MxDrawViewDelegate,DeveloperNavigaSetViewDelegate,MxDrawModelViewControllerDelegate>

@property (nonatomic,strong) MXDrawView *mxDrawView;

@property (nonatomic,strong) MxDrawBoardSettingView *settingView;

@property (nonatomic,strong) UIImage *modelImage;

@property (nonatomic,copy) NSMutableArray *locationArray;

@property (nonatomic,strong) UIView *maskView;


@end

@implementation DeveloperDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getDevelopAllPointList];
    MxDrawBoardBaseView * baseView = [[MxDrawBoardBaseView alloc] initWithFrame:self.view.bounds];
    self.view = baseView;
    baseView.isDebug = YES;
    self.mxDrawView = [[MXDrawView alloc] initWithFrame:CGRectMake(DrawBoardBaseViewX, FIT_TO_IPAD_VER_VALUE(75) - FIT_TO_IPAD_VER_VALUE(3), FIT_TO_IPAD_VER_VALUE(600) + FIT_TO_IPAD_VER_VALUE(6), FIT_TO_IPAD_VER_VALUE(600) + FIT_TO_IPAD_VER_VALUE(6))];
//    self.mxDrawView.isDebug = YES;
    [self.view addSubview:self.mxDrawView];
    self.mxDrawView.delegate = self;
    [self setDrawViewColor:[UIColor whiteColor]];
    [self initSettingView];
    [self getLocalProductList];
}


-(void)initSettingView{
    self.settingView = [[MxDrawBoardSettingView alloc] initWithFrame:CGRectMake(0, FIT_TO_IPAD_VER_VALUE(210), FIT_TO_IPAD_VER_VALUE(120), FIT_TO_IPAD_VER_VALUE(350))];
    self.settingView.delegate = self;
    [self.view addSubview:self.settingView];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.settingView.bounds byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(FIT_TO_IPAD_VER_VALUE(8),FIT_TO_IPAD_VER_VALUE(8))];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame= self.settingView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.settingView.layer.mask = maskLayer;
    
    DeveloperNavigaSetView *navigaSetView = [[DeveloperNavigaSetView alloc] initWithFrame:CGRectMake(0, 0, Screen_WIDTH, FIT_TO_IPAD_VER_VALUE(64))];
    navigaSetView.delegate = self;
    [self.view addSubview:navigaSetView];
    
}




-(NSMutableArray *)locationArray{
    if (!_locationArray) {
        _locationArray = [NSMutableArray array];
    }
    return _locationArray;
}
//清屏
-(void)clearDrawView:(UIButton *)sender{
    [self.mxDrawView clear];
}
//撤销操作
-(void)revokeDrawView:(UIButton *)sener{
    [self.mxDrawView undo];
}

//橡皮擦
-(void)deleteBtnDrawView:(UIButton *)sender{
    [self.mxDrawView earear];
}

//设置颜色
-(void)setDrawViewColor:(UIColor *)color{
    [self.mxDrawView setLineColor:color];
}

//设置宽度
-(void)setDrawViewWidth:(CGFloat )width{
    [self.mxDrawView setLineWidth:21];
}


-(void)showConfirmSaveView{
    if (!self.maskView) {
        self.maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.maskView.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 0.6);
        [self.view addSubview:self.maskView];
    }
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(180), Screen_HEIGHT/2 - FIT_TO_IPAD_VER_VALUE(240), FIT_TO_IPAD_VER_VALUE(360), FIT_TO_IPAD_VER_VALUE(30))];
    titleLabel.text = @"是否确认保存？";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(25)];
    [self.maskView addSubview:titleLabel];
//    DevelopDrawBaseView *confirmView = [[DevelopDrawBaseView alloc] initWithFrame:CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(180), Screen_HEIGHT/2 - FIT_TO_IPAD_VER_VALUE(180), FIT_TO_IPAD_VER_VALUE(360), FIT_TO_IPAD_VER_VALUE(360))];
//    [self.maskView addSubview:confirmView];
//    DevelopDrawView *drawView = [[DevelopDrawView alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(300), FIT_TO_IPAD_VER_VALUE(300))];
//    [drawView updateViewWithLocationArray:self.locationArray];
//    [confirmView addSubview:drawView];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(180), Screen_HEIGHT/2 - FIT_TO_IPAD_VER_VALUE(180), FIT_TO_IPAD_VER_VALUE(360), FIT_TO_IPAD_VER_VALUE(360))];
    backView.backgroundColor = UIColorFromRGB(0x252525);
    [self.maskView addSubview:backView];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(300), FIT_TO_IPAD_VER_VALUE(300))];
    self.modelImage = [UIImage screenShotView:self.mxDrawView];
    imageView.image = self.modelImage;
    [backView addSubview:imageView];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(150), Screen_HEIGHT/2 +  FIT_TO_IPAD_VER_VALUE(200), FIT_TO_IPAD_VER_VALUE(100), FIT_TO_IPAD_VER_VALUE(30));
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.maskView addSubview:cancleBtn];
    [cancleBtn addTarget:self action:@selector(cancelSave:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(Screen_WIDTH/2 + FIT_TO_IPAD_VER_VALUE(30), Screen_HEIGHT/2 +  FIT_TO_IPAD_VER_VALUE(200), FIT_TO_IPAD_VER_VALUE(100), FIT_TO_IPAD_VER_VALUE(30));
    [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.maskView addSubview:confirmBtn];
    [confirmBtn addTarget:self action:@selector(confirmSave:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)cancelSave:(UIButton *)sender{
    [self.maskView removeFromSuperview];
    self.maskView = nil;
}

-(void)confirmSave:(UIButton *)sender{
    [DevelopManager saveLocationArrayWithNewArray:self.locationArray Image:self.modelImage];
    [self.maskView removeFromSuperview];
    self.maskView = nil;
    [self.locationArray removeAllObjects];
    [self.mxDrawView clear];
}

#pragma mark -MxDrawBoardSettingViewDelegate-
- (void)btnClickWithActionType:(ActionType)actionType{
    if (actionType == ActionTypeEarea) {//橡皮擦
        [self.mxDrawView earear];
    }else if (actionType == ActionTypeDraw){//绘画
        [self.mxDrawView draw];
    }else if (actionType == ActionTypeClear){//清屏
        [self.mxDrawView clear];
        [self.locationArray removeAllObjects];
    }else if (actionType == ActionTypeFinish){//完成
        
    }
}

#pragma mark -MxDrawViewDelegate -

-(void)changeLocation:(int)location LocationModel:(LocationModel *)locationModel{
    if (locationModel.isOpen) {
        [self addPointWithLocation:location];
    }else{
        [self deletePointWithLocation:location];
    }
}

-(void)changeLocation:(int)location Color:(UIColor *)color OpeaType:(DrawOpeaType)opeaType{

}

#pragma mark - DeveloperNavigaSetViewDelegate -

-(void)btnClickedWithBtnTitle:(NSString *)btnTitle Sender:(nonnull UIButton *)sender{
      DLog(@"btnClickedWithBtnTitle:%@",btnTitle);
    if ([btnTitle isEqualToString:@"编辑"]) {
        MxDrawModelViewController *modelVC = [[MxDrawModelViewController alloc]init];
        modelVC.popoverPresentationController.sourceView = sender;
        modelVC.popoverPresentationController.sourceRect = sender.bounds;
        modelVC.popoverPresentationController.popoverBackgroundViewClass = DrawModelPopoverBackgroundView.class;
        modelVC.isDebug = YES;
        modelVC.delegate = self;
        [self presentViewController:modelVC animated:YES completion:nil];
    }else if ([btnTitle isEqualToString:@"删除"]){
        
    }else if ([btnTitle isEqualToString:@"保存"]){
        if (self.locationArray.count) {
            [self showConfirmSaveView];
        }
    }else if([btnTitle isEqualToString:@"新增"]){
        
    }else if ([btnTitle isEqualToString:@"退出"]){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - MxDrawModelViewControllerDelegate -

-(void)didSelectLocationArray:(NSArray *)locationArray{
    [self.mxDrawView clear];
    [self.locationArray removeAllObjects];
    [self.locationArray addObjectsFromArray:locationArray];
    [self.mxDrawView loadProductWithLocationArray:locationArray];

}

-(void)addPointWithLocation:(int)location{
    [self.locationArray addObject:@(location)];
}

-(void)deletePointWithLocation:(int)location{
    for (int i = 0; i < self.locationArray.count; i++) {
        int pointLocation = [[self.locationArray objectAtIndex:i] intValue];
        if (location == pointLocation) {
            [self.locationArray removeObjectAtIndex:i];
            return;
        }
    }
}

-(void)getLocalProductList{
    NSArray *array = [DevelopManager getLocalProductArray];
      DLog(@"get local product is success :%@",array);
}

-(void)getDevelopAllPointList{
    for (int i = 0; i < 400; i++) {
        NSInteger pointX = FIT_TO_IPAD_VER_VALUE(7.5) + i % 20 *FIT_TO_IPAD_VER_VALUE(15);
        NSInteger pointY = FIT_TO_IPAD_VER_VALUE(7.5) + i/20 * FIT_TO_IPAD_VER_VALUE(15);
        CGPoint point = CGPointMake(pointX, pointY);
        [[DevelopManager shareInstance].pointList addObject:NSStringFromCGPoint(point)];
    }
}


@end
