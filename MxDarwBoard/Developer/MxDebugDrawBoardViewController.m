//
//  MxDebugDrawBoardViewController.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/7/22.
//

#import "MxDebugDrawBoardViewController.h"
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
#import "MxDrawBoardNavigationView.h"
#import "MxCountDownLabel.h"
#import "MxMessageManager.h"
#import "UIColor+Turn.h"
#import "MxPickerViewController.h"

@interface MxDebugDrawBoardViewController ()<MxPickerViewControllerDelegate,MxDrawViewDelegate,MxDrawBoardSettingViewDelegate,MxDrawBoardNavigationViewDelegate>

@property (nonatomic, strong) MXDrawView *mxDrawView;

@property (nonatomic,strong) MxDrawBoardSettingView *settingView;

@property (nonatomic,strong) MxDrawBoardNavigationView *navigaSetView;

@property (nonatomic,copy) NSArray *deviceList;

@property (nonatomic,copy)NSMutableDictionary *drawPointDic;

@property (nonatomic,copy)NSMutableDictionary *drawLocationDic;

@property(nonatomic,strong) UIColor *currentColor;

@property(nonatomic,assign) BOOL isDebug;

@property(nonatomic,assign) BOOL isGroup;


@end

@implementation MxDebugDrawBoardViewController

-(NSMutableDictionary *)drawLocationDic{
    if (!_drawLocationDic) {
        _drawLocationDic = [NSMutableDictionary dictionary];
    }
    return _drawLocationDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentColor = [UIColor redColor];
    MxDrawBoardBaseView * baseView = [[MxDrawBoardBaseView alloc] initWithFrame:self.view.bounds];
    self.view = baseView;
    baseView.isDebug = YES;
    self.mxDrawView = [[MXDrawView alloc] initWithFrame:CGRectMake(DrawBoardBaseViewX, FIT_TO_IPAD_VER_VALUE(75) - FIT_TO_IPAD_VER_VALUE(3), FIT_TO_IPAD_VER_VALUE(600) + FIT_TO_IPAD_VER_VALUE(6), FIT_TO_IPAD_VER_VALUE(600) + FIT_TO_IPAD_VER_VALUE(6))];
//    self.mxDrawView.isDebug = YES;
    [self.view addSubview:self.mxDrawView];
    self.mxDrawView.delegate = self;
    [self setDrawViewColor:[UIColor whiteColor]];
    [self initSettingView];
    [self setDrawViewColor:self.currentColor];
}

-(void)initSettingView{
    self.settingView = [[MxDrawBoardSettingView alloc] initWithFrame:CGRectMake(0, FIT_TO_IPAD_VER_VALUE(220), FIT_TO_IPAD_VER_VALUE(60), FIT_TO_IPAD_VER_VALUE(305))];
    self.settingView.delegate = self;
    [self.view addSubview:self.settingView];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.settingView.bounds byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(FIT_TO_IPAD_VER_VALUE(8),FIT_TO_IPAD_VER_VALUE(8))];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.settingView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.settingView.layer.mask = maskLayer;
    
    self.navigaSetView = [[MxDrawBoardNavigationView alloc] initWithFrame:CGRectMake(0, 0, Screen_WIDTH, FIT_TO_IPAD_VER_VALUE(64))];
    self.navigaSetView.delegate = self;
    self.navigaSetView.viewController = self;
    [self.view addSubview:self.navigaSetView];
    
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [exitBtn setBackgroundColor:[UIColor blackColor]];
    [exitBtn setTitle:@"退出" forState:UIControlStateNormal];
    exitBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(9);
    exitBtn.frame = CGRectMake(Screen_WIDTH/2 + FIT_TO_IPAD_VER_VALUE(200) , Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(60));
    [exitBtn addTarget:self action:@selector(exitBtnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitBtn];
    
    
    UIButton *debugBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [debugBtn setBackgroundColor:[UIColor blackColor]];
    [debugBtn setTitle:@"单灯调试模式" forState:UIControlStateNormal];
    debugBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(9);
    debugBtn.frame = CGRectMake(Screen_WIDTH/2 + FIT_TO_IPAD_VER_VALUE(350) , Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(60));
    [debugBtn addTarget:self action:@selector(debugBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:debugBtn];
    
    
    UIButton *drawAllLightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [drawAllLightBtn setBackgroundColor:[UIColor blackColor]];
    [drawAllLightBtn setTitle:@"绘制所有灯" forState:UIControlStateNormal];
    drawAllLightBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(9);
    drawAllLightBtn.frame = CGRectMake(Screen_WIDTH/2 , Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(60));
    [drawAllLightBtn addTarget:self action:@selector(drawAllLightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:drawAllLightBtn];
    
    
    UIButton *projectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [projectionBtn setBackgroundColor:[UIColor blackColor]];
    [projectionBtn setTitle:@"投屏" forState:UIControlStateNormal];
    projectionBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(9);
    projectionBtn.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(170), Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(60));
    [projectionBtn addTarget:self action:@selector(projectionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:projectionBtn];
    
    UIButton *groupProjectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [groupProjectionBtn setBackgroundColor:[UIColor blackColor]];
    [groupProjectionBtn setTitle:@"群组投屏" forState:UIControlStateNormal];
    groupProjectionBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(9);
    groupProjectionBtn.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(400), Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(60));
    [groupProjectionBtn addTarget:self action:@selector(groupProjectionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:groupProjectionBtn];
    
}





#pragma mark - UIButtonClick -
-(void)customColorSelect:(UIButton *)sender{

}

-(void)startDrawView:(UIButton *)sender{
    [self.mxDrawView draw];
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
    [self.mxDrawView setLineWidth:FIT_TO_IPAD_VER_VALUE(11)];
}




-(void)lineWidthChange:(UISlider *)slider{
      DLog(@"slider.value:%f",slider.value);
    [self setDrawViewWidth:slider.value * 21];
}

-(void)debugBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.isDebug = sender.isSelected;
    if (sender.isSelected) {
        sender.backgroundColor = [UIColor redColor];
    }else{
        [sender setBackgroundColor:[UIColor blackColor]];
    }
}


-(void)groupProjectionBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.isGroup = sender.isSelected;
    if (sender.isSelected) {
        sender.backgroundColor = [UIColor redColor];
    }else{
        [sender setBackgroundColor:[UIColor blackColor]];
    }
    
    
    
}

-(void)exitBtnBtnClick:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)drawAllLightBtnClick:(UIButton *)sender{

    [self.mxDrawView setAllPointWihtColor:self.currentColor];
    if (self.isGroup) {
        [MxMessageManager sendGroupMessage:[UIColor hsvStringFromColor:self.currentColor]];
    }
//    for (int i = 0; i < 400; i++) {
//        LocationModel *model = [[LocationModel alloc] initWithLocation:i Color:self.currentColor IsOpen:YES];
//        NSString *key = [NSString stringWithFormat:@"%d",i];
//        [self.drawLocationDic setValue:model forKey:key];
//        [MxMessageManager addLocationModel:model];
//    }
}

-(void)projectionBtnClick:(UIButton *)sender{
    if (![self.drawLocationDic allKeys].count){
        return;
    }
    if (sender.isSelected) {
        return;
    }else{
        sender.selected = YES;
    }
    
        DLog(@"[self.drawLocationDic allKeys]:%@",[self.drawLocationDic allKeys]);
      NSArray * allKeys = [self.drawLocationDic allKeys];
      for (NSString * key in allKeys) {
//          LocationModel *pointModel = [self.drawPointDic objectForKey:key];
          LocationModel *locationModel = [self.drawLocationDic objectForKey:key];
            DLog(@"location:%d,hexColoer:%@,isOpen:%d",locationModel.location,locationModel.hexColor,locationModel.isOpen);
      }
        DLog(@"kaishitouping");
        MxCountDownLabel *countLabel = [[MxCountDownLabel alloc] initWithFrame:CGRectMake(0, 0, Screen_WIDTH, Screen_HEIGHT)];
        countLabel.center = self.view.center;
        countLabel.font = [UIFont boldSystemFontOfSize:FIT_TO_IPAD_VER_VALUE(100)];
        countLabel.textColor = [UIColor blueColor];
    NSInteger messageCount = [MxMessageManager getWaitSendMessageCount];
    DLog(@"degndaifasongxiaoxi:%ld,每秒消息数：%ld",messageCount,messageCount);
    if (TimeInterval * messageCount > 3) {
//        float result = messageCount/(MseeageAccount);
        int time = ceil(TimeInterval * messageCount);
        countLabel.count = time;
        DLog(@"daojishishijian:%d",time);
    }else{
        countLabel.count = 3; //不设置的话，默认是3
    }

        
        [self.view addSubview:countLabel];
        
        [countLabel startCount:^{
            DLog(@"daojishijieshu，kaishitouping~~~~~");
            sender.selected = NO;
            [MxMessageManager showScreen];
        }];
    
   
}

-(void)resetLocationModel{
    NSArray * allKeys = [self.drawLocationDic allKeys];
    for (NSString * key in allKeys) {
        LocationModel *locationModel = [self.drawLocationDic objectForKey:key];
        locationModel.isOpen = NO;
        locationModel.hexColor = [UIColor hexStringFromColor:DefaultBaseColor];
    }
}
#pragma mark - MxPickerViewControllerDelegate -
- (void)pickerControllerDidSelectColor:(MxPickerViewController *)controller {
    [self setDrawViewColor:controller.selectedColor];
    self.currentColor = controller.selectedColor;
}


#pragma mark - MxDrawViewDelegate -
//改location的灯颜色发生改变，操作为新增或删除
-(void)changeLocation:(int)location LocationModel:(LocationModel *)locationModel DrawOpeaType:(DrawOpeaType)drawOpeaType{
    if (self.isGroup) {
        return;
    }
    
    if (self.isDebug) {
        [MxMessageManager sendDebugMessageWithLocalModel:locationModel];
    }else{
        NSString *key = [NSString stringWithFormat:@"%d",location];
          DLog(@"loction:%@,hexColor:%@,hsvColor:%@",key,locationModel.hexColor,locationModel.hsvColor);
        
    //    [self.drawPointDic setValue:locationModel forKey:key];
        if (drawOpeaType == AddPoint) {
            [self.drawLocationDic setValue:locationModel forKey:key];
    //        [MxMessageManager sendMessageWithLocalModel:locationModel];
            [MxMessageManager addLocationModel:locationModel];
        }else{
            [self.drawLocationDic removeObjectForKey:key];
            [MxMessageManager cleanLightWithLocalModel:locationModel];
        }
        
    }
    
  
}

-(void)changeLocationArray:(NSArray<LocationModel *> *)locationArray OpeaType:(DrawOpeaType)opeaType{
    DLog(@"locationArray:");
    for (LocationModel * locationModel  in locationArray) {
          DLog(@"hexColor:%@,location:%d,hsvColor:%@\n",locationModel.hexColor,locationModel.location,locationModel.hsvColor);
        int location = locationModel.location;
        NSString *key = [NSString stringWithFormat:@"%d",location];
        [self.drawLocationDic setValue:locationModel forKey:key];
    }
}
#pragma mark -MxDrawBoardSettingViewDelegate-
- (void)btnClickWithActionType:(ActionType)actionType{
    if (actionType == ActionTypeEarea) {//橡皮擦
        [self.mxDrawView earear];
    }else if (actionType == ActionTypeDraw){//绘画
        [self.mxDrawView draw];
    }else if (actionType == ActionTypeClear){//清屏
        [MxMessageManager cleanScreen];
        [self resetLocationModel];
        [self.mxDrawView clear];
    }else if (actionType == ActionTypeFinish){//完成
        
          DLog(@"\n[self.drawPointDic allKeys]:%@\n[self.drawLocationDic allKeys]:%@",[self.drawPointDic allKeys],[self.drawLocationDic allKeys]);
        NSArray * allKeys = [self.drawPointDic allKeys];
        for (NSString * key in allKeys) {
            LocationModel *pointModel = [self.drawPointDic objectForKey:key];
            LocationModel *locationModel = [self.drawLocationDic objectForKey:key];
              DLog(@"key:%@\n%d,%@,%d\n%d,%@,%d",key,pointModel.location,pointModel.hexColor,pointModel.isOpen,locationModel.location,locationModel.hexColor,locationModel.isOpen);
        }
    }
}


#pragma mark -MxDrawBoardNavigationViewDelegate-

- (void)colorSeletFinish:(UIColor *)color{
    self.currentColor = color;
    [self.mxDrawView setLineColor:color];
}

-(void)selectPhotoBtnClick{
    
}

-(void)didSelectLocation:(NSArray *)locationArray{
    [self.mxDrawView loadProductWithLocationArray:locationArray];
    [self.mxDrawView clear];

}











//获取触摸点point
- (CGPoint)getTouchSet:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
     return [touch locationInView:self.view];
}
















@end
