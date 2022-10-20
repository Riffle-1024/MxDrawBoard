//
//  PlanViewController.m
//  MeshSDKDemo
//
//  Created by 华峰 on 2021/5/7.
//

#import "PlanViewController.h"
#import "AppInfo.h"
#import "MxPickerViewController.h"
#import "MxMeshManager.h"
#import "UIColor+Turn.h"
#import "MxDrawBoardManager.h"
#import "AppInfo.h"
#import "MxTimer.h"


@interface PlanViewController ()<UITextFieldDelegate,MxPickerViewControllerDelegate> {
    UITextField *elementTF;
    UITextField *inputTF;
    UILabel *outputLB;
    UILabel *subscribeMsgLB;
}


@property (nonatomic, strong) UIButton *customColorBtn;

@property (nonatomic, strong) UIColor *selectColor;

@property (nonatomic,strong) MxTimer *timer;

@end

@implementation PlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 80)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    
    UIButton *joinGroupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    joinGroupBtn.frame = CGRectMake(20, 20, 100, 40);
    [joinGroupBtn setBackgroundColor:[UIColor blueColor]];
    [joinGroupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [joinGroupBtn setTitle:@"加入群组" forState:UIControlStateNormal];
    [joinGroupBtn addTarget:self action:@selector(joinGroupBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:joinGroupBtn];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    btn.frame = CGRectMake((self.view.frame.size.width-320)/2.0, 20, 100, 40);
    [btn setTitle:@"开" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(openLight) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeInfoDark];
    btn2.frame = CGRectMake(CGRectGetMaxX(btn.frame)+10, 20, 100, 40);
    [btn2 setTitle:@"关" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(closeLight) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btn2];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeContactAdd];
    btn3.frame = CGRectMake(CGRectGetMaxX(btn2.frame)+10, 20, 100, 40);
    [btn3 setTitle:@"添加网络" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(addNetWorkKey) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btn3];
    
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    openBtn.frame = CGRectMake(CGRectGetMaxX(btn3.frame)+10, 20, 100, 40);
    [openBtn setTitle:@"open" forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(openBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:openBtn];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    closeBtn.frame = CGRectMake(CGRectGetMaxX(openBtn.frame)+10, 20, 100, 40);
    [closeBtn setTitle:@"close" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:closeBtn];
    
    [self.view addSubview:headerView];
    if (self.deviceInfo[@"name"]) {
        self.title = self.deviceInfo[@"name"];
    }
    
    elementTF = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(headerView.frame)+20, 40, 40)];
    elementTF.borderStyle = UITextBorderStyleRoundedRect;
    elementTF.delegate = self;
    elementTF.text = @"0";
    [self.view addSubview:elementTF];
    
    inputTF = [[UITextField alloc] initWithFrame:CGRectMake(70, CGRectGetMaxY(headerView.frame)+20, self.view.frame.size.width-40, 40)];
    inputTF.borderStyle = UITextBorderStyleRoundedRect;
    inputTF.delegate = self;
    [self.view addSubview:inputTF];
    

    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(20, CGRectGetMaxY(inputTF.frame)+10, self.view.frame.size.width-40, 40);
    [sendBtn setBackgroundColor:[UIColor blueColor]];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendMeshMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    
    UIButton *ProScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    ProScreenBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(200), FIT_TO_IPAD_VER_VALUE(700), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(30));
    [ProScreenBtn setBackgroundColor:[UIColor blueColor]];
    [ProScreenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [ProScreenBtn setTitle:@"一键投屏" forState:UIControlStateNormal];
    [ProScreenBtn addTarget:self action:@selector(ProScreenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ProScreenBtn];
    
    UIButton *CleanScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CleanScreenBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(400), FIT_TO_IPAD_VER_VALUE(700), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(30));
    [CleanScreenBtn setBackgroundColor:[UIColor blueColor]];
    [CleanScreenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [CleanScreenBtn setTitle:@"一键清屏" forState:UIControlStateNormal];
    [CleanScreenBtn addTarget:self action:@selector(CleanScreenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:CleanScreenBtn];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(600), FIT_TO_IPAD_VER_VALUE(700), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(30));
    [deleteBtn setBackgroundColor:[UIColor blueColor]];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteBtn setTitle:@"删除设备" forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
    
    
//    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    testBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(600), FIT_TO_IPAD_VER_VALUE(700), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(30));
//    [testBtn setBackgroundColor:[UIColor blueColor]];
//    [testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [testBtn setTitle:@"调试" forState:UIControlStateNormal];
//    [testBtn addTarget:self action:@selector(testBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:testBtn];
    
    outputLB = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(inputTF.frame)+60, self.view.frame.size.width-40, 40)];
    [outputLB setBackgroundColor:[UIColor clearColor]];
    [outputLB setTextColor:[UIColor redColor]];
    [outputLB setFont:[UIFont systemFontOfSize:16]];
    outputLB.text = nil;
    [self.view addSubview:outputLB];
    
    subscribeMsgLB = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(outputLB.frame)+40, self.view.frame.size.width-40, 40)];
    [subscribeMsgLB setBackgroundColor:[UIColor clearColor]];
    [subscribeMsgLB setTextColor:[UIColor redColor]];
    [subscribeMsgLB setFont:[UIFont systemFontOfSize:16]];
    subscribeMsgLB.text = nil;
    [self.view addSubview:subscribeMsgLB];
    
    [MxMeshManager subscribeMeshDownMessageWithCallback:^(NSDictionary<NSString *,id> * _Nonnull dict) {
        NSString *uuid = [self.deviceInfo objectForKey:@"nodeUUID"];
        if ([dict objectForKey:uuid]) {
            NSDictionary *msgDict = [dict objectForKey:uuid];
            NSString *msg = [msgDict objectForKey:@"message"];
            NSInteger elementIndex = [msgDict[@"elementIndex"] intValue];
            self->subscribeMsgLB.text = [NSString stringWithFormat:@"设备上报消息：%@, element下标:%ld",msg,elementIndex];
        }
    }];
    
    
    self.customColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.customColorBtn setTitle:@"自定义颜色" forState:UIControlStateNormal];
    self.customColorBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(20), FIT_TO_IPAD_VER_VALUE(700), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(30));
    self.customColorBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.customColorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.customColorBtn setBackgroundColor:[UIColor redColor]];
    [self.customColorBtn addTarget:self action:@selector(customColorSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.customColorBtn];
    

}

-(void)deleteBtnClick{
    NSString *uuid = [self.deviceInfo objectForKey:@"nodeUUID"];
     
    BOOL isSuccess = [MxMeshManager deleteNodeWithUuid:uuid];
    if (isSuccess) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        self->outputLB.text = @"删除设备失败";
    }
}

-(void)joinGroupBtnClick{
    //220971D6-9E65-0078-C3D3-637804020000
    //220971D6-9E65-0078-C3D3-637804020000
        NSString *uuid = [self.deviceInfo objectForKey:@"nodeUUID"];
    DLog(@"self.deviceInfo :uuid:%@",uuid);
        [MxMeshManager groupAddDeviceWithUuid:uuid elementIndex:0 service:0 address:@"C100" isMaster:YES callback:^(BOOL isSuccess) {
            if (isSuccess) {
                DLog(@"添加群组成功");
                self->outputLB.text = @"添加群组成功";
            }else{
                DLog(@"添加群组失败");
                self->outputLB.text = @"添加群组失败";
            }
        }];
}

-(void)openBtnClick{
    NSString *uuid = [self.deviceInfo objectForKey:@"nodeUUID"];
    NSString *cmdStr = @"000101";
    NSString *msg = [cmdStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];
    [MxMeshManager sendMeshMessageWithOpCode:@"11" uuid:uuid elementIndex:0 Tid:@"" message:msg retryCount:1 timeout:1 isHoldCallback:NO networkKey:nil callback:^(NSDictionary<NSString *,id> * _Nonnull resultObject) {
        NSString *message = resultObject[@"message"];
        self->outputLB.text = message;
    }];
}

-(void)closeBtnClick{
    NSString *uuid = [self.deviceInfo objectForKey:@"nodeUUID"];
    NSString *cmdStr = @"000100";
    NSString *msg = [cmdStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];
    [MxMeshManager sendMeshMessageWithOpCode:@"11" uuid:uuid elementIndex:0 Tid:@"" message:msg retryCount:1 timeout:1 isHoldCallback:NO networkKey:nil callback:^(NSDictionary<NSString *,id> * _Nonnull resultObject) {
        NSString *message = resultObject[@"message"];
        self->outputLB.text = message;
    }];
}

-(void)testBtnClick{
     __block int i = 0;
     self.timer = [[MxTimer alloc] initWithTimeInterval:0.1f andWaitTime:100 eventHandler:^{
        NSString * cmd = [NSString stringWithFormat:@"2301%@%@%@%@",[self getHex],[self getHex],[self getHex],[self getHex]];
        NSString *msg = [cmd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];
        DLog(@"==cmd==%@",cmd);
//        outputLB.text = nil;
//        NSString *uuid = [self.deviceInfo objectForKey:@"nodeUUID"];
         DLog(@"==i==%d",i);
        NSString *uuid = [MxDrawBoardManager getDeviceUUIDWithLocation:i%4 + 1];
        DLog(@"==uuid==%@",uuid);
        [MxMeshManager sendMeshMessageWithOpCode:@"11" uuid:uuid elementIndex:0 Tid:nil message:msg retryCount:1 timeout:1 isHoldCallback:NO networkKey:nil callback:^(NSDictionary * _Nullable result) {
            NSString *message = result[@"message"];
            DLog(@"==result==%@",result);
            self->outputLB.text = message;
        }];
        i+=1;
    }];
}

-(NSString *)getHex{
    int x = arc4random() % 101;
    return [self getHexByDecimal:x];
}

-(void)ProScreenBtnClick{
    NSString *cmdStr = @"250101";
    NSString *msg = [cmdStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];
    int elementIndex = [[elementTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue];
    
    NSString *netWorkKey = [AppInfo sharedInstance].netWorkKey;
    
    [MxMeshManager sendGroupMessageWithAddress:@"C100" opCode:@"12" uuid:nil elementIndex:elementIndex message:msg networkKey:netWorkKey repeatNum:1];
    
    
//    NSString *cmdStr = @"250101";
//    NSString *msg = [cmdStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];;
//    [MxMeshManager sendMeshMessageWithOpCode:@"11" uuid:[MxMessageManager shareInstance].uuid elementIndex:0 Tid:nil message:msg retryCount:1 timeout:1 isHoldCallback:NO networkKey:nil callback:^(NSDictionary<NSString *,id> * _Nonnull resultObject) {
//
//    }];

}


-(void)CleanScreenBtnClick{
    NSString *cmdStr = @"250100";
    NSString *msg = [cmdStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];
    int elementIndex = [[elementTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue];
    
    NSString *netWorkKey = [AppInfo sharedInstance].netWorkKey;
    
    [MxMeshManager sendGroupMessageWithAddress:@"C100" opCode:@"12" uuid:nil elementIndex:elementIndex message:msg networkKey:netWorkKey repeatNum:1];
}
- (void)openLight {
    NSDictionary *propertyDict = @{@"LightSwitch":@1};
    NSString *uuid = [self.deviceInfo objectForKey:@"nodeUUID"];
//
//    NSString *msg = @"100F0800010101000000FFFFFFFFFFFF0A000E01";
//    [MxMeshManager sendMeshMessageWithOpCode:@"11" uuid:uuid elementIndex:0 Tid:nil message:msg retryCount:1 timeout:1 isHoldCallback:NO networkKey:nil callback:^(NSDictionary * _Nullable result) {
//        NSString *message = result[@"message"];
//          DLog(@"设备回消息：%@",message);
//    }];
//    return;
    
    [MxMeshManager setDevicePropertiesWithOpcode:@"11" uuid:uuid retryNum:1 properties:propertyDict callback:^(NSDictionary<NSString *,id> * _Nonnull result) {
              DLog(@"设备回消息：%@",result);
        self->outputLB.text = [NSString stringWithFormat:@"设备回消息：%@",result];
    }];
}

- (void)closeLight {
    NSDictionary *propertyDict = @{@"LightSwitch":@0};
    NSString *uuid = [self.deviceInfo objectForKey:@"nodeUUID"];
    [MxMeshManager setDevicePropertiesWithOpcode:@"11" uuid:uuid retryNum:1 properties:propertyDict callback:^(NSDictionary<NSString *,id> * _Nonnull result) {
              DLog(@"设备回消息：%@",result);
        self->outputLB.text = [NSString stringWithFormat:@"设备回消息：%@",result];
    }];
}

- (void)addNetWorkKey {
    NSString *uuid = [self.deviceInfo objectForKey:@"nodeUUID"];
    [MxMeshManager addNetworkKeyToNodeWithUuid:uuid networkKey:AppInfo.sharedInstance.networkKey2 appKey:nil callback:^(BOOL isSuccess) {
          DLog(@"添加networkkey %d", isSuccess);
    }];
    
//    [MxMeshManager deleteNetworkKeyToNodeWithUuid:uuid networkKey:AppInfo.sharedInstance.networkKey2 appKey:nil callback:^(BOOL isSuccess) {
//          DLog(@"删除networkkey %d", isSuccess);
//    }];
    
}

- (void)sendMeshMessage {
    [elementTF nextResponder];
    [inputTF nextResponder];
    NSString *msg = [inputTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];
    
    int elementIndex = [[elementTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue];
    
    outputLB.text = nil;
    NSString *uuid = [self.deviceInfo objectForKey:@"nodeUUID"];
//    NSString *uuid = [MxDrawBoardManager getDeviceUUIDWithLocation:4];
    [MxMeshManager sendMeshMessageWithOpCode:@"11" uuid:uuid elementIndex:elementIndex Tid:nil message:msg retryCount:1 timeout:1 isHoldCallback:NO networkKey:nil callback:^(NSDictionary * _Nullable result) {
        NSString *message = result[@"message"];
        self->outputLB.text = message;
    }];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField nextResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}


-(void)customColorSelect:(UIButton *)sender{
    MxPickerViewController *picker = [[MxPickerViewController alloc] initWithColor:self.customColorBtn.backgroundColor];
    picker.delegate = self;
    picker.popoverPresentationController.sourceView = self.customColorBtn;
    picker.popoverPresentationController.sourceRect = self.customColorBtn.bounds;
    [self presentViewController:picker animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)pickerControllerDidSelectColor:(MxPickerViewController *)controller {
    self.customColorBtn.backgroundColor = controller.selectedColor;
    self.selectColor = controller.selectedColor;
    [self getSaturationAndBrightness];
}


-(void)getSaturationAndBrightness{
//    NSInteger saturation = round(100 * self.selectColor.saturation);
//    NSInteger brightness = round(100 * self.selectColor.brightness);
//    NSInteger hue = round(360 * self.selectColor.hue);
//      DLog(@"****************hue:%ld",hue);
//    NSString * sat = [self getHexByDecimal:saturation];
//    NSString * bri = [self getHexByDecimal:brightness];
//    NSString * hue16 = [self getHexByDecimal:hue];
//
//    if (hue16.length == 2) {
//        hue16 = [NSString stringWithFormat:@"00%@",hue16];
//    }
//    NSString * firstStr = [hue16 substringWithRange:NSMakeRange(0, 2)];
//    NSString * sendStr = [hue16 substringWithRange:NSMakeRange(2, 2)];
//      DLog(@"****************hue16:%@",hue16);
//      DLog(@"****************zhaun:%@%@",sendStr,firstStr);
    NSString * cmd = [NSString stringWithFormat:@"2401%@",[UIColor hsvStringFromColor:self.selectColor]];
    inputTF.text = cmd;
    UITextView *textView = [[UITextView alloc] init];
    UITextField *textField = [[UITextField alloc] init];
    

}
- (NSString *)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    if (hex.length %2 != 0) {
        hex = [NSString stringWithFormat:@"0%@",hex];
    }
    return hex;
}


@end
