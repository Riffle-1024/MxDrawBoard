//
//  ViewController.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/15.
//

#import "ViewController.h"
#import "MxDrawBoardViewController.h"

#import "MxUploadImageManager.h"
#import "DeveloperDrawViewController.h"
#import "MxDeviceListViewController.h"
#import "MxNoGroupDeviceListViewController.h"
#import "MxDebugDrawBoardViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];

    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_HOR_VALUE(80), Screen_HEIGHT/2 - FIT_TO_IPAD_VER_VALUE(120), FIT_TO_IPAD_HOR_VALUE(160), FIT_TO_IPAD_VER_VALUE(60));
//    [btn setTitle:@"进入画板" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btn setBackgroundColor:[UIColor redColor]];
//    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    
    UIButton * developBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    developBtn.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_HOR_VALUE(80), Screen_HEIGHT/2 -  FIT_TO_IPAD_VER_VALUE(180), FIT_TO_IPAD_HOR_VALUE(160), FIT_TO_IPAD_VER_VALUE(60));
    [developBtn setTitle:@"进入开发者" forState:UIControlStateNormal];
    [developBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [developBtn setBackgroundColor:[UIColor redColor]];
    [developBtn addTarget:self action:@selector(developBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:developBtn];
    
    UIButton * addDeviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addDeviceBtn.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_HOR_VALUE(80), Screen_HEIGHT/2 -  FIT_TO_IPAD_VER_VALUE(90), FIT_TO_IPAD_HOR_VALUE(160), FIT_TO_IPAD_VER_VALUE(60));
    [addDeviceBtn setTitle:@"蓝牙设备列表" forState:UIControlStateNormal];
    [addDeviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addDeviceBtn setBackgroundColor:[UIColor redColor]];
    [addDeviceBtn addTarget:self action:@selector(deviceList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addDeviceBtn];
    
    UIButton * noGroupDeviceListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    noGroupDeviceListBtn.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_HOR_VALUE(80), Screen_HEIGHT/2, FIT_TO_IPAD_HOR_VALUE(160), FIT_TO_IPAD_VER_VALUE(60));
    [noGroupDeviceListBtn setTitle:@"未加入群组设备列表" forState:UIControlStateNormal];
    [noGroupDeviceListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [noGroupDeviceListBtn setBackgroundColor:[UIColor redColor]];
    [noGroupDeviceListBtn addTarget:self action:@selector(noGroupDeviceListBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:noGroupDeviceListBtn];
    
    
    UIButton * debugBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    debugBtn.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_HOR_VALUE(80) , Screen_HEIGHT/2 +  FIT_TO_IPAD_VER_VALUE(90), FIT_TO_IPAD_HOR_VALUE(160), FIT_TO_IPAD_VER_VALUE(60));
    [debugBtn setTitle:@"调试灯模式" forState:UIControlStateNormal];
    [debugBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [debugBtn setBackgroundColor:[UIColor redColor]];
    [debugBtn addTarget:self action:@selector(debugBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:debugBtn];
    
    
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(Screen_WIDTH/2 - FIT_TO_IPAD_HOR_VALUE(80), Screen_HEIGHT/2 +  FIT_TO_IPAD_VER_VALUE(180), FIT_TO_IPAD_HOR_VALUE(160), FIT_TO_IPAD_VER_VALUE(60));
    [backBtn setTitle:@"退出" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setBackgroundColor:[UIColor redColor]];
    [backBtn addTarget:self action:@selector(backBtnCick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
   
    NSArray <UIColor *>*colorArray = @[[UIColor redColor],[UIColor orangeColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor yellowColor],[UIColor blueColor],[UIColor greenColor],[UIColor brownColor],[UIColor magentaColor],[UIColor lightGrayColor]];
    
    for (UIColor *color in colorArray) {
        NSString *hexColor = [self hexStringFromColor:color];
          DLog(@"HexColor:%@",hexColor);
    }
//    UIColor *redColor = [UIColor redColor];
//    NSString *hexColor = [self hexStringFromColor:redColor];
//      DLog(@"HexColor:%@",hexColor);
    
    
    UIImage *image = [UIImage imageNamed:@"image_edit_finish"];;
    NSData *imageData = [self imageData:image];
//    [MxUploadImageManager uploadImageWithUrl:@"https://awe-electricity-game-dev.mxchip.com.cn/api/awe/image" ImageData:imageData Completion:^(NSError * _Nonnull error, BOOL isSuccess) {
//        if (isSuccess) {
//              DLog(@"图片上传成功");
//        }else{
//              DLog(@"图片上传失败：%@",error);
//        }
//    }];
//    NSDictionary *para = @{@"awe_image":@"2022022410071208"};
//    [MxUploadImageManager POST:@"https://awe-electricity-game-dev.mxchip.com.cn/api/awe/image" parameters:para FileData:imageData fileName:@"imagName00001" success:^(NSDictionary * _Nullable dic) {
//          DLog(@"图片上传成功:%@",dic);
//    } failure:^(NSError * _Nullable error) {
//          DLog(@"图片上传失败：%@",error);
//    }];
}


-(NSData *)imageData:(UIImage *)myimage{
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    if (data.length>100*1024) {//大于100k
        if (data.length > 10240*1024) {//大于10M
            data = UIImageJPEGRepresentation(myimage, 0.02);
        }else if (data.length>5*1024*1024){//s大于5M
            data = UIImageJPEGRepresentation(myimage, 0.04);
        }
        else if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.1);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(myimage, 0.4);
        }else if (data.length>200*1024) {//0.25M-0.5M
            data=UIImageJPEGRepresentation(myimage, 0.8);
        }
    }
    return data;
}
#pragma mark - UIButtonClicked -

-(void)btnClicked:(UIButton *)sender{
    MxDrawBoardViewController * drawBoardVC = [[MxDrawBoardViewController alloc] init];
    drawBoardVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:drawBoardVC animated:YES completion:nil];
}


-(void)developBtnClicked:(UIButton *)sender{
    DeveloperDrawViewController * developVC = [[DeveloperDrawViewController alloc] init];
    developVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:developVC animated:YES completion:nil];
}


-(void)deviceList:(UIButton *)sender{
    MxDeviceListViewController *addDeviceVC = [[MxDeviceListViewController alloc] init];
    UINavigationController *nav  = [[UINavigationController alloc] initWithRootViewController:addDeviceVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)noGroupDeviceListBtnClick:(UIButton *)sender{
    MxNoGroupDeviceListViewController * vc = [[MxNoGroupDeviceListViewController alloc]init];
    UINavigationController *nav  = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)backBtnCick{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)debugBtn:(UIButton *)sender{
    MxDebugDrawBoardViewController *vc = [[MxDebugDrawBoardViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}


//UIColor转Hex
- (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

@end
