//
//  MxDrawBoardViewController.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/15.
//

#import "MxDrawBoardViewController.h"
#import "MxDrawBoardBaseView.h"
#import "MxPickerViewController.h"
#import "MxDrawBoardManager.h"
#import "MXDrawView.h"
#import "MxDrawBoardSettingView.h"
#import "MxDrawBoardNavigationView.h"
#import "MxDrawBoardBottomSetView.h"
#import "MxLockButton.h"
#import "LocationModel.h"
#import "MxMeshManager.h"
#import "AppInfo.h"
#import "DevelopManager.h"
#import "ViewController.h"
#import "UIImage+MxTool.h"
#import "DevelopShowImageViewController.h"
#import "MxUploadImageManager.h"
#import "MxShowImageView.h"
#import "MxCountDownLabel.h"
#import "UIColor+Turn.h"
#import "MxMessageManager.h"
#import "MxDrawBoardNewBottomSetView.h"
#import "MxRadarView.h"
#import "MxTimer.h"


@interface MxDrawBoardViewController ()<MxPickerViewControllerDelegate,MxDrawViewDelegate,MxDrawBoardSettingViewDelegate,MxDrawBoardNavigationViewDelegate,MxDrawBoardBottomSetViewDelegate,MesManagerConnectDelegate,MxDrawBoardNewBottomSetViewDelegate>

@property (nonatomic, strong) MXDrawView *mxDrawView;

@property (nonatomic,strong) MxDrawBoardSettingView *settingView;

@property (nonatomic,strong) MxDrawBoardNavigationView *navigaSetView;

@property (nonatomic,strong) MxDrawBoardBottomSetView *bottomSetView;

@property (nonatomic,strong) MxDrawBoardNewBottomSetView *boardBottomSetView;

@property (nonatomic,strong) MxLockButton *lockBtn;

@property (nonatomic,assign) BOOL isShowSetView;

@property (nonatomic,copy) NSArray *deviceList;

@property (nonatomic,copy)NSMutableDictionary *drawPointDic;

@property (nonatomic,copy)NSMutableDictionary *drawLocationDic;

@property (nonatomic,strong) MxShowImageView *showImageView;

@property (nonatomic,strong)  UIButton *drawAllLightBtn;

@property(nonatomic,assign) BOOL isSingle;//单灯控制

@property(nonatomic,assign) BOOL isGroup;//单灯控制

@property(nonatomic,assign) BOOL isDrawAll;//单灯全亮


@property(nonatomic,strong) UIView *maskView;

@property(nonatomic,strong) UIColor *currentColor;

@property (nonatomic, strong) MxRadarView * scanRadarView;

@property (nonatomic,strong) MxTimer *timer;

@property (nonatomic,assign) NSInteger currentIndex;

@end

@implementation MxDrawBoardViewController


-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_WIDTH, Screen_HEIGHT)];
        _maskView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_maskView];
    }
    return _maskView;
}


-(NSMutableDictionary *)drawPointDic{
    if (!_drawPointDic) {
        _drawPointDic = [NSMutableDictionary dictionary];
    }
    return _drawPointDic;
}

-(NSMutableDictionary *)drawLocationDic{
    if (!_drawLocationDic) {
        _drawLocationDic = [NSMutableDictionary dictionary];
    }
    return _drawLocationDic;
}

-(MxShowImageView *)showImageView{
    if (!_showImageView) {
        _showImageView = [[MxShowImageView alloc] initWithFrame:CGRectMake((Screen_WIDTH - FIT_TO_IPAD_VER_VALUE(700))/2, (Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(700))/2, FIT_TO_IPAD_VER_VALUE(700), FIT_TO_IPAD_VER_VALUE(700))];
        [self.view addSubview:_showImageView];
        _showImageView.hidden = YES;
    }
    return _showImageView;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    self.isShowSetView = YES;
    self.currentColor = [UIColor redColor];
    MxDrawBoardBaseView * baseView = [[MxDrawBoardBaseView alloc] initWithFrame:self.view.bounds];
    self.view = baseView;
//    self.customColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.customColorBtn setTitle:@"自定义颜色" forState:UIControlStateNormal];
//    self.customColorBtn.frame = CGRectMake(Screen_WIDTH - FIT_TO_IPAD_VER_VALUE(180), FIT_TO_IPAD_VER_VALUE(600), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(30));
//    self.customColorBtn.titleLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(20)];
//    [self.customColorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.customColorBtn setBackgroundColor:[UIColor redColor]];
//    [self.customColorBtn addTarget:self action:@selector(customColorSelect:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.customColorBtn];

    
    if (DrawBoardType == 1) {
        self.mxDrawView = [[MXDrawView alloc] initWithFrame:CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(300) - FIT_TO_IPAD_VER_VALUE(3), FIT_TO_IPAD_VER_VALUE(225) - FIT_TO_IPAD_VER_VALUE(3), FIT_TO_IPAD_VER_VALUE(600) + FIT_TO_IPAD_VER_VALUE(6), FIT_TO_IPAD_VER_VALUE(300) + FIT_TO_IPAD_VER_VALUE(6))];
    }else{
        self.mxDrawView = [[MXDrawView alloc] initWithFrame:CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(300) - FIT_TO_IPAD_VER_VALUE(3), FIT_TO_IPAD_VER_VALUE(75) - FIT_TO_IPAD_VER_VALUE(3), FIT_TO_IPAD_VER_VALUE(600) + FIT_TO_IPAD_VER_VALUE(6), FIT_TO_IPAD_VER_VALUE(600) + FIT_TO_IPAD_VER_VALUE(6))];
    }
    
    
//    NSInteger modeType = 0;
//    NSString * type = [[NSUserDefaults standardUserDefaults] valueForKey:DrawModelType];
//    if (type) {
//        modeType = [type intValue];
//    }
//    [self.mxDrawView setModelType:modeType];
    [self.mxDrawView setModelType:0];
    [self.view addSubview:self.mxDrawView];
    [self.mxDrawView setLineColor:self.currentColor];
    
    self.mxDrawView.delegate = self;
    [self initSettingView];
//    [self initBottomBtnViews];
    [self initLockBtn];
    [self initDevelopBtn];
    [MxMeshManager initMeshManager];
    MxMeshManager.shareInstance.delegate = self;
//    [MBProgressHUD showMessage:@"正在连接设备" ToView:self.view];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [[AppInfo sharedInstance].deviceList removeAllObjects];
//    if ([AppInfo sharedInstance].deviceList.count == 0) {
//        NSArray *devicesList = [MxMeshManager fetchAllNodeUUID];
//        for (NSString *uuid in devicesList) {
//            NSDictionary *nodeInfo = [MxMeshManager getNodeInfoWithUuid:uuid];
//            NSMutableDictionary *newNode = [NSMutableDictionary dictionaryWithDictionary:nodeInfo];
//            [newNode setObject:[NSNumber numberWithBool:[MxMeshManager checkDeviceIsOnlineWithUuid:uuid]] forKey:@"isOnline"];
//            [newNode setObject:uuid forKey:@"nodeUUID"];
//            [newNode setObject:[[MxMeshManager getDeviceMacAddressWithUuid:uuid] stringByReplacingOccurrencesOfString:@":" withString:@""] forKey:@"nodeMac"];
//            [[AppInfo sharedInstance].deviceList addObject:newNode];
//        }
//        
//    }
//    self.deviceList = [AppInfo sharedInstance].deviceList;
//    [MxMeshManager connect];
    NSDictionary * allLightInfo = [MxDrawBoardManager getAllBindLightInfo];
    DLog(@"allLightInfo:%@",allLightInfo);
    
//    for (int i = 1; i <= 400; i++) {
//        NSString * key = [NSString stringWithFormat:@"%d",i];
//        NSDictionary * info = [allLightInfo objectForKey:key];
//        if (!info) {
//            DLog(@"%@灯不存在",key);
//        }
//    }
    
//    NSDictionary *dic = [MxDrawBoardManager get]
}

-(void)initSettingView{
    self.settingView = [[MxDrawBoardSettingView alloc] initWithFrame:CGRectMake(0, FIT_TO_IPAD_VER_VALUE(220), FIT_TO_IPAD_VER_VALUE(60), FIT_TO_IPAD_VER_VALUE(264))];
    self.settingView.delegate = self;
    [self.view addSubview:self.settingView];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.settingView.bounds byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(FIT_TO_IPAD_VER_VALUE(18),FIT_TO_IPAD_VER_VALUE(18))];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.settingView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.settingView.layer.mask = maskLayer;
    
    self.navigaSetView = [[MxDrawBoardNavigationView alloc] initWithFrame:CGRectMake(0, 0, Screen_WIDTH, FIT_TO_IPAD_VER_VALUE(64))];
    self.navigaSetView.delegate = self;
    self.navigaSetView.viewController = self;
    [self.view addSubview:self.navigaSetView];
    
//    self.bottomSetView = [[MxDrawBoardBottomSetView alloc] initWithFrame:CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(80), Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(250), FIT_TO_IPAD_VER_VALUE(60))];
//    self.bottomSetView.delegate = self;
//    [self.view addSubview:self.bottomSetView];
//
//
//    UIButton *projectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [projectionBtn setBackgroundColor:[UIColor blackColor]];
//    [projectionBtn setTitle:@"投屏" forState:UIControlStateNormal];
//    projectionBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(9);
//    projectionBtn.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(170), Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(60));
//    [projectionBtn addTarget:self action:@selector(projectionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:projectionBtn];
        self.boardBottomSetView = [[MxDrawBoardNewBottomSetView alloc] initWithFrame:CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(300), Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(600), FIT_TO_IPAD_VER_VALUE(60))];
        self.boardBottomSetView.delegate = self;
        [self.view addSubview:self.boardBottomSetView];
    
    
    
    
    
}


-(void)initBottomBtnViews{
    UIButton *singleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [singleBtn setBackgroundColor:[UIColor blackColor]];
    [singleBtn setTitle:@"单灯调试模式" forState:UIControlStateNormal];
    singleBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(9);
    singleBtn.frame = CGRectMake(Screen_WIDTH/2 + FIT_TO_IPAD_VER_VALUE(350) , Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(130), FIT_TO_IPAD_VER_VALUE(60));
    [singleBtn addTarget:self action:@selector(singleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:singleBtn];
    
    
    self.drawAllLightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.drawAllLightBtn setBackgroundColor:[UIColor blackColor]];
    [self.drawAllLightBtn setTitle:@"绘制所有灯" forState:UIControlStateNormal];
    self.drawAllLightBtn.layer.cornerRadius = FIT_TO_IPAD_VER_VALUE(9);
    self.drawAllLightBtn.frame = CGRectMake(Screen_WIDTH/2 + FIT_TO_IPAD_VER_VALUE(180) , Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(100), FIT_TO_IPAD_VER_VALUE(60));
    [self.drawAllLightBtn addTarget:self action:@selector(drawAllLightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.drawAllLightBtn];
    self.drawAllLightBtn.hidden = YES;

    
}

-(void)initLockBtn{
    self.lockBtn = [MxLockButton buttonWithType:UIButtonTypeCustom];
    self.lockBtn.frame = CGRectMake(Screen_WIDTH - FIT_TO_IPAD_VER_VALUE(64), Screen_HEIGHT/2 - FIT_TO_IPAD_VER_VALUE(22), FIT_TO_IPAD_VER_VALUE(44), FIT_TO_IPAD_VER_VALUE(44));
    [self.lockBtn setImage:[UIImage imageNamed:@"icon_lock"] forState:UIControlStateSelected];
    [self.lockBtn setImage:[UIImage imageNamed:@"icon_unlock"] forState:UIControlStateNormal];
    [self.lockBtn addTarget:self action:@selector(lockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.lockBtn];
    self.lockBtn.hidden = NO;
//    
}

-(void)lockBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
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

-(void)projectionBtnClick:(UIButton *)sender{
    if (![self.drawLocationDic allKeys].count){
        return;
    }
    if (sender.isSelected) {
        return;
    }else{
        sender.selected = YES;
    }
    
//        DLog(@"[self.drawLocationDic allKeys]:%@",[self.drawLocationDic allKeys]);
      NSArray * allKeys = [self.drawLocationDic allKeys];
//      for (NSString * key in allKeys) {
//          LocationModel *pointModel = [self.drawPointDic objectForKey:key];
//          LocationModel *locationModel = [self.drawLocationDic objectForKey:key];
//            DLog(@"location:%d,hexColoer:%@,isOpen:%d",locationModel.location,locationModel.hexColor,locationModel.isOpen);
//      }
//        DLog(@"start touping");
        MxCountDownLabel *countLabel = [[MxCountDownLabel alloc] initWithFrame:CGRectMake(0, 0, Screen_WIDTH, Screen_HEIGHT)];
        countLabel.center = self.view.center;
        countLabel.font = [UIFont boldSystemFontOfSize:FIT_TO_IPAD_VER_VALUE(100)];
    NSInteger messageCount = [MxMessageManager getWaitSendMessageCount];
//    DLog(@"message count:%ld,meimiao xiaoxi shu：%ld",messageCount,messageCount);
    if (TimeInterval * messageCount > 3) {
//        float result = messageCount/(MseeageAccount);
        int time = ceil(TimeInterval * messageCount);
        countLabel.count = time;
//        DLog(@"daojishishijian:%d",time);
    }else{
        countLabel.count = 3; //不设置的话，默认是3
    }
        
        [self.view addSubview:countLabel];
    self.maskView.hidden = NO;
        [countLabel startCount:^{
//            DLog(@"daojishijieshu，kaishitouping~~~~~");
            sender.selected = NO;
            [MxMessageManager showScreen];
            self.maskView.hidden = YES;
        }];
    
   
}


-(void)screenProjection{
    if (![self.drawLocationDic allKeys].count){
        [MxMessageManager showScreen];
        [self.boardBottomSetView resetAllBtn];
        return;
    }
    [self.drawLocationDic removeAllObjects];
    MxCountDownLabel *countLabel = [[MxCountDownLabel alloc] initWithFrame:CGRectMake(0, 0, Screen_WIDTH, Screen_HEIGHT)];
    NSInteger messageCount = [MxMessageManager getWaitSendMessageCount];
    if (TimeInterval * messageCount > 3) {
        int time = ceil(TimeInterval * messageCount);
        countLabel.count = time;
    }else if(TimeInterval * messageCount > 1){
        countLabel.count = 3; //不设置的话，默认是3
    }else if(messageCount != 0){
        sleep(1);
        [MxMessageManager showScreen];
        [self.boardBottomSetView resetAllBtn];
        return;
    }else{
        [MxMessageManager showScreen];
        [self.boardBottomSetView resetAllBtn];
        return;
    }
    _scanRadarView = [MxRadarView scanRadarViewWithRadius:FIT_TO_IPAD_VER_VALUE(170) angle:400 radarLineNum:5 hollowRadius:0];
        [_scanRadarView showTargetView:self.view];
    countLabel.center = _scanRadarView.center;
    [self.view addSubview:countLabel];
    self.maskView.hidden = NO;
    [countLabel startCount:^{
        self->_maskView.hidden = YES;
//        [MxMessageManager showScreen];
        [self->_scanRadarView stopAnimation];
        [self->_scanRadarView dismiss];
        [self->_boardBottomSetView resetAllBtn];
        [MxMessageManager showScreen];
    }];
    [_scanRadarView startAnimatian];
    
    
}

-(void)resetLocationModel{
    NSArray * allKeys = [self.drawLocationDic allKeys];
    for (NSString * key in allKeys) {
        LocationModel *locationModel = [self.drawLocationDic objectForKey:key];
        locationModel.isOpen = NO;
        locationModel.hexColor = [UIColor hexStringFromColor:DefaultBaseColor];
    }
}






-(void)drawAllLightBtnClick:(UIButton *)sender{
    if (!self.isSingle) {//群组投屏
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mxDrawView setAllPointWihtColor:self.currentColor];
            [MxMessageManager  sendGroupMessage:[UIColor hsvStringFromColor:self.currentColor]];
            self.isGroup = NO;
        });
        return;
    }
//    _scanRadarView = [MxRadarView scanRadarViewWithRadius:FIT_TO_IPAD_VER_VALUE(170) angle:400 radarLineNum:5 hollowRadius:0];
//        [_scanRadarView showTargetView:self.view];
//    [_scanRadarView showTargetView:self.view];
//    MxCountDownLabel *countLabel = [[MxCountDownLabel alloc] initWithFrame:CGRectMake(0, 0, Screen_WIDTH, Screen_HEIGHT)];
//    countLabel.center = self.view.center;
//    countLabel.font = [UIFont boldSystemFontOfSize:FIT_TO_IPAD_VER_VALUE(100)];
//    NSInteger messageCount = [MxDrawBoardManager shareInstance].pointList.count;
//    if (TimeInterval * messageCount > 3) {
//        int time = ceil(TimeInterval * messageCount);
//        countLabel.count = time;
//    }else{
//        countLabel.count = 3; //不设置的话，默认是3
//    }
//    [self.view addSubview:countLabel];
//    self.maskView.hidden = NO;
//    [countLabel startCount:^{
////        [MxMessageManager showScreen];
//        self->_maskView.hidden = YES;
//        [self->_scanRadarView stopAnimation];
//        [self->_scanRadarView dismiss];
//    }];
//    [_scanRadarView startAnimatian];
    self.currentIndex = 0;
    NSString * timeOutString = [[NSUserDefaults standardUserDefaults] valueForKey:@"set_time"];
    if (!timeOutString) {
        timeOutString = @"150";
        [[NSUserDefaults standardUserDefaults] setValue:timeOutString forKey:@"set_time"];
    }
    float time = [timeOutString integerValue]/1000.00;

    if (!self.timer) {
        self.timer = [[MxTimer alloc] initWithTimeInterval:time andWaitTime:0 eventHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mxDrawView drawPointWtithLocation:self.currentIndex Color:self.currentColor Complete:^(BOOL isUpdate, int location) {

                }];
                self.currentIndex++;
                if (self.currentIndex >= [MxDrawBoardManager shareInstance].pointList.count) {
                    [self.timer pauseTimer];
                }
            });

        }];
    }else{
        DLog(@"jixu  sendMessage");
        [self.timer resumeTimer];
    }
    
//    [MxMessageManager sendDrawAllLightMessagezWithColro:self.currentColor Complete:^(LocationModel * _Nonnull locationModel) {
//        [self.mxDrawView drawPointWtithLocation:locationModel.location Color:self.currentColor Complete:^(BOOL isUpdate, int location) {
//
//        }];
//    }];
    
//    [MxMessageManager inOrderDrawAllLightWithColro:self.currentColor Complete:^(NSInteger location, BOOL isNext) {
//                [self.mxDrawView drawPointWtithLocation:location Color:self.currentColor Complete:^(BOOL isUpdate, int location) {
//
//                }];
//        self->_isDrawAll = isNext;
//    }];
    
    
}
#pragma mark - MxPickerViewControllerDelegate -
- (void)pickerControllerDidSelectColor:(MxPickerViewController *)controller {
    [self setDrawViewColor:controller.selectedColor];
}


#pragma mark - MxDrawViewDelegate -
//改location的灯颜色发生改变，操作为新增或删除
-(void)changeLocation:(int)location LocationModel:(LocationModel *)locationModel DrawOpeaType:(DrawOpeaType)drawOpeaType{
    if (self.isSingle) {
        [MxMessageManager sendDebugMessageWithLocalModel:locationModel];
//        [MxMessageManager newAddLocationModel:locationModel];
    }else if(!self.isGroup && !self.isDrawAll){
    NSString *key = [NSString stringWithFormat:@"%d",location];
      DLog(@"loction:%@,hexColor:%@,hsvColor:%@",key,locationModel.hexColor,locationModel.hsvColor);
//    [self.drawPointDic setValue:locationModel forKey:key];
//    if (drawOpeaType == AddPoint) {
        [self.drawLocationDic setValue:locationModel forKey:key];
//        [MxMessageManager sendMessageWithLocalModel:locationModel];
        [MxMessageManager addLocationModel:locationModel];
//        [MxMessageManager newAddLocationModel:locationModel];
        
//    }else{
//        [self.drawLocationDic removeObjectForKey:key];
//        [MxMessageManager cleanLightWithLocalModel:locationModel];
//    }
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

-(void)changeModelWithType:(NSInteger)modelType{
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",modelType] forKey:DrawModelType];
    [self.mxDrawView setModelType:modelType];
}

-(void)shareImage{
    UIImage *productImage = [UIImage screenShotView:self.mxDrawView];
    UIImage *showImage = [UIImage creatShareImage:productImage];
    NSData *imageData = [UIImage imageData:showImage];

        NSDictionary *para = @{@"awe_image":[self getCurrentHourAndMinuteTime]};
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showMessage:@"正在生成作品" ToView:self.view];
    });
        [MxUploadImageManager POST:@"https://awe-electricity-game-dev.mxchip.com.cn/api/awe/image" parameters:para FileData:imageData fileName:[self getCurrentHourAndMinuteTime] success:^(NSDictionary * _Nullable dic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view];
            });
            NSInteger code = [[dic objectForKey:@"code"] intValue];
            if (code == 0) {
                DLog(@"图片上传成功:%@",dic);
                NSDictionary *data = [dic objectForKey:@"data"];
                NSString *url = [data objectForKey:@"image_url"];
                UIImage *codeImage = [UIImage QRCodeMethod:url];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.showImageView.hidden = NO;
                    [self.showImageView updateShowImage:showImage AndQrCodeImage:codeImage];
                    
//                    DevelopShowImageViewController * vc = [[DevelopShowImageViewController alloc] init];
//                    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:vc];
//                    vc.showImage = showImage;
//                    [self presentViewController:navc animated:YES completion:nil];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showAutoMessage:[NSString stringWithFormat:@"作品生成失败：%@，code:%ld",[dic objectForKey:@"message"],code]];
                });
                DLog(@"图片上传错误：%@,code:%ld",[dic objectForKey:@"message"],code);
            }
        } failure:^(NSError * _Nullable error) {
              DLog(@"图片上传失败：%@",error);
                }];
}


-(void)showImage:(UIImage *)image AndQRCode:(UIImage *)qrCode{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake((Screen_WIDTH - (Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(40)))/2, FIT_TO_IPAD_VER_VALUE(20), Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(40), Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(40))];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(14), FIT_TO_IPAD_VER_VALUE(14), FIT_TO_IPAD_VER_VALUE(323), FIT_TO_IPAD_VER_VALUE(700))];
    [backView addSubview:imageView];
    imageView.image = image;
    
    UIImageView *QRCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(391), FIT_TO_IPAD_VER_VALUE(202.5), FIT_TO_IPAD_VER_VALUE(323), FIT_TO_IPAD_VER_VALUE(323))];
    QRCodeImageView.image = qrCode;
    [backView addSubview:QRCodeImageView];
    
}

//获取当前时间
-(NSString * )getCurrentHourAndMinuteTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置想要的格式，hh与HH的区别:分别表示12小时制,24小时制
    //    [formatter setDateFormat:@"HH:mm:ss.SSS"];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSDate *dateNow = [NSDate date];
    //把NSDate按formatter格式转成NSString
    NSString *currentTime = [formatter stringFromDate:dateNow];
    return currentTime;
    
}
#pragma mark -MxDrawBoardBottomSetViewDelegate-

//切换绘画模式
-(void)drawTypeSeleted:(DrawType)drawType{
    
    if (drawType == DrawTypeProduct) {
        self.mxDrawView.patinModel = PaintingModeAddColor;
        [self.navigaSetView isShowPhotoBtn:YES];
    }/*else if(drawType == DrawTypeRealtime){
        self.mxDrawView.patinModel = PaintingModeThen;
        [self.navigaSetView isShowPhotoBtn:NO];
    }*/else{
        self.mxDrawView.patinModel = PaintingModeCreat;
        [self.navigaSetView isShowPhotoBtn:NO];
    }
    [self.mxDrawView clear];
}


#pragma mark - MxDrawBoardNewBottomSetViewDelegate -


-(void)newBottomViewSeleted:(NSInteger)index IsSelected:(BOOL)isSelected{
    if (index == 0) {
        self.isGroup = YES;
        [self drawAllLightBtnClick:nil];
    }else if (index == 1){//开始投屏
        [self screenProjection];
    }else{
        self.isSingle = isSelected;
        if (isSelected) {
            [MxMessageManager setDrawType:1];
        }else{
            [MxMessageManager setDrawType:0];
            self.isDrawAll = NO;
        }
        
    }
}

-(void)selectAllLight{
    self.isDrawAll = YES;
    [self drawAllLightBtnClick:nil];
    
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [self getTouchSet:touches];
    BOOL isRespond = [self isNeedReponseWithPoint:point];
    if (!isRespond) {
        return;
    }
    if (self.lockBtn.isSelected) {
        self.lockBtn.hidden = NO;
        return;
    }
    if (self.isShowSetView) {
        [self hidDrawBoardSetView];
    }else{
        [self showDrawBoardSetView];
    }
    self.isShowSetView = !self.isShowSetView;
}



-(BOOL)isNeedReponseWithPoint:(CGPoint )point{
    CGRect drawViewRect = self.mxDrawView.frame;
    if (CGRectContainsPoint(drawViewRect, point)) {
        return NO;
    }
    CGRect setViewRect = self.settingView.frame;
    CGRect navigaViewRect = self.navigaSetView.frame;
    CGRect bottomViewRect = self.bottomSetView.frame;
    if ((CGRectContainsPoint(setViewRect, point) || CGRectContainsPoint(navigaViewRect, point) || CGRectContainsPoint(bottomViewRect, point)) && self.isShowSetView) {
        return NO;
    }
    return YES;
}

//获取触摸点point
- (CGPoint)getTouchSet:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
     return [touch locationInView:self.view];
}



-(void)hidDrawBoardSetView{
    [UIView animateWithDuration:0.5 animations:^{
        self.navigaSetView.frame = CGRectMake(0, -FIT_TO_IPAD_VER_VALUE(64), Screen_WIDTH, FIT_TO_IPAD_VER_VALUE(64));
        self.settingView.frame = CGRectMake(-FIT_TO_IPAD_VER_VALUE(210), FIT_TO_IPAD_VER_VALUE(210), FIT_TO_IPAD_VER_VALUE(120), FIT_TO_IPAD_VER_VALUE(305));
        self.bottomSetView.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(80), Screen_HEIGHT, FIT_TO_IPAD_VER_VALUE(240), FIT_TO_IPAD_VER_VALUE(60));
        self.lockBtn.hidden = NO;
    }];
}

-(void)showDrawBoardSetView{
    [UIView animateWithDuration:0.5 animations:^{
        self.navigaSetView.frame = CGRectMake(0, 0, Screen_WIDTH, FIT_TO_IPAD_VER_VALUE(64));
        self.settingView.frame = CGRectMake(0, FIT_TO_IPAD_VER_VALUE(210), FIT_TO_IPAD_VER_VALUE(120), FIT_TO_IPAD_VER_VALUE(305));
        self.bottomSetView.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_VER_VALUE(80), Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(70), FIT_TO_IPAD_VER_VALUE(250), FIT_TO_IPAD_VER_VALUE(60));
        self.lockBtn.hidden = NO;
    }];
}







-(void)initDevelopBtn{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(80), FIT_TO_IPAD_VER_VALUE(200), FIT_TO_IPAD_VER_VALUE(80));
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)btnClick:(UIButton *)sender{
  BOOL isShow =  [[DevelopManager shareInstance] isShowDevelop];
    if (isShow) {
        ViewController * vc = [[ViewController alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - MesManagerConnectDelegate -

-(void)subscribeMeshConnectStatus:(NSInteger)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigaSetView updateNavigatonMeshConnectStatus:status];
       
    });
    
    if (status == 1) {//连接成功
        [MxMessageManager setMeshNetWorkIsConnect:YES];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showAutoMessage:@"mesh已连接"];
//        });
 
//    }else{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showAutoMessage:@"mesh连接失败"];
//        });
    }
}

-(void)hasBindDeviceCount:(NSInteger)count{
//    if (count == 0) {//还没有绑定设备
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showAutoMessage:@"未绑定设备"];
//        });
   
//    }
}

@end
