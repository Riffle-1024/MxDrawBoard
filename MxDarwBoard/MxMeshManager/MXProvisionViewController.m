//
//  MXProvisionViewController.m
//  MeshSDKDemo
//
//  Created by 华峰 on 2021/6/7.
//

#import "MXProvisionViewController.h"
#import "MXBluetoothProvisionModel.h"
#import "AppInfo.h"
#import "MxMeshManager.h"
#import "MxDrawBoardManager.h"
@import MeshSDK;

#define LightCurrnetLocation @"LightCurrnetLocation"

@interface MXProvisionViewController ()<UITableViewDelegate,UITableViewDataSource,MeshManagerProvisionDelegate,MeshManagerOOBProvisioningDelegate,MeshSDKProvisionDelegate,MeshSDKOOBProvisioningDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *statusGuideArray;
@property (nonatomic, assign) int currenLocation;

@end

@implementation MXProvisionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *currentLocation = [[NSUserDefaults standardUserDefaults] valueForKey:LightCurrnetLocation];
    if (!currentLocation) {
        self.currenLocation = 1;
    }else{
        self.currenLocation = [currentLocation intValue];
    }
    [self createUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    
//    [MxMeshManager startUnprovisionedDeviceProvisionWithMac:self.macStr networkKey:[AppInfo sharedInstance].netWorkKey provisioningDelegate:self oobDelegate:nil];
    [MeshSDK.sharedInstance startUnprovisionedDeviceProvisionWithMac:self.macStr networkKey:[AppInfo sharedInstance].netWorkKey provisioningDelegate:self oobDelegate:nil];
    
    
}

- (void)createGroupData {
    self.statusGuideArray = [NSMutableArray array];
    
    MXBluetoothProvisionModel *model1 = [[MXBluetoothProvisionModel alloc] init];
    model1.remindTitle = @"与设备建立蓝牙连接";
    model1.status = MXBluetoothProvisionModelStatusProcessing;
    [self.statusGuideArray addObject:model1];
    
    MXBluetoothProvisionModel *model2 = [[MXBluetoothProvisionModel alloc] init];
    model2.remindTitle = @"发现并启动蓝牙服务";
    model2.status = MXBluetoothProvisionModelStatusIdling;
    [self.statusGuideArray addObject:model2];
    
    MXBluetoothProvisionModel *model3 = [[MXBluetoothProvisionModel alloc] init];
    model3.remindTitle = @"设备连接MESH网络";
    model3.status = MXBluetoothProvisionModelStatusIdling;
    [self.statusGuideArray addObject:model3];
    
    MXBluetoothProvisionModel *model4 = [[MXBluetoothProvisionModel alloc] init];
    model4.remindTitle = @"设置设备的网络参数";
    model4.status = MXBluetoothProvisionModelStatusIdling;
    [self.statusGuideArray addObject:model4];
    
//    MXBluetoothProvisionModel *model5 = [[MXBluetoothProvisionModel alloc] init];
//    model5.remindTitle = @"获取设备的身份信息";
//    model5.status = MXBluetoothProvisionModelStatusIdling;
//    [self.statusGuideArray addObject:model5];
    
    [self.tableView reloadData];
}

- (void)beginBluetoothConnection {
    
}

- (void)InitialiseBluettothService {
    
    MXBluetoothProvisionModel *model1 = [self.statusGuideArray objectAtIndex:0];
    model1.status = MXBluetoothProvisionModelStatusSuccess;
    MXBluetoothProvisionModel *model2 = [self.statusGuideArray objectAtIndex:1];
    model2.status = MXBluetoothProvisionModelStatusProcessing;
    [self.statusGuideArray replaceObjectAtIndex:0 withObject:model1];
    [self.statusGuideArray replaceObjectAtIndex:1 withObject:model2];
    [self.tableView reloadData];
}

- (void)BeginConnectingToMesh {
    MXBluetoothProvisionModel *model1 = [self.statusGuideArray objectAtIndex:1];
    model1.status = MXBluetoothProvisionModelStatusSuccess;
    MXBluetoothProvisionModel *model2 = [self.statusGuideArray objectAtIndex:2];
    model2.status = MXBluetoothProvisionModelStatusProcessing;
    [self.statusGuideArray replaceObjectAtIndex:1 withObject:model1];
    [self.statusGuideArray replaceObjectAtIndex:2 withObject:model2];
    [self.tableView reloadData];
}

- (void)BeginCongifureMeshParams {
    MXBluetoothProvisionModel *model1 = [self.statusGuideArray objectAtIndex:2];
    model1.status = MXBluetoothProvisionModelStatusSuccess;
    MXBluetoothProvisionModel *model2 = [self.statusGuideArray objectAtIndex:3];
    model2.status = MXBluetoothProvisionModelStatusProcessing;
    [self.statusGuideArray replaceObjectAtIndex:2 withObject:model1];
    [self.statusGuideArray replaceObjectAtIndex:3 withObject:model2];
    NSLog(@"此时应该进入步骤4");
    [self.tableView reloadData];
}

- (void)FetchDeviceIdentity {
    
    MXBluetoothProvisionModel *model1 = [self.statusGuideArray objectAtIndex:3];
    model1.status = MXBluetoothProvisionModelStatusSuccess;
    MXBluetoothProvisionModel *model2 = [self.statusGuideArray objectAtIndex:4];
    model2.status = MXBluetoothProvisionModelStatusProcessing;
    [self.statusGuideArray replaceObjectAtIndex:3 withObject:model1];
    [self.statusGuideArray replaceObjectAtIndex:4 withObject:model2];
    [self.tableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[MeshSDK sharedInstance] mxMeshProvisionFinish];
    [MxMeshManager disconnect];
}


- (void)createUI{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    [self createGroupData];
}

- (void)bluetoothProvistionFail {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupErrorDataSource];
        [MxMeshManager deleteNodeWithUuid:self.macStr];
        [MxMeshManager disconnect];
    });
}

- (void)setupErrorDataSource {
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.statusGuideArray];
    for (MXBluetoothProvisionModel *model in array) {
        if (model.status == MXBluetoothProvisionModelStatusProcessing) {
            model.status = MXBluetoothProvisionModelStatusFailed;
        }
    }
    self.statusGuideArray = array;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.statusGuideArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     return 30.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MXBluetoothProvisionCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MXBluetoothProvisionCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.statusGuideArray.count > indexPath.row) {
        MXBluetoothProvisionModel *model = [self.statusGuideArray objectAtIndex:indexPath.row];
        cell.textLabel.text = model.remindTitle;
        if (model.status == 0) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else if (model.status == 1) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (model.status == 2) {
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

#pragma mark-----------------provision delegate-------------------



- (void)inputUnicastAddressWithElementNum:(NSInteger)elementNum handler:(void (^)(NSInteger))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入地址" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action_conform = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alert.textFields[0];
        self.currenLocation = textField.text.intValue;
        handler(textField.text.intValue + 255);
    }];
    [alert addAction:action_conform];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入配网的address";
        int locationAdress = self.currenLocation;
        textField.text = [NSString stringWithFormat:@"%d",locationAdress];
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

//- (void)inputPublicKeyWithHandler:(void (^)(NSString * _Nonnull))handler {
//    handler(@"");
//}


- (void)meshProvisionFinishWithError:(NSError *)error {
    if (error) {
        [self setupErrorDataSource];
    } else {
        NSDictionary *lightInfo = @{
            @"uuid":self.deviceUUID,
            @"mac":self.macStr,
            @"name":self.nameStr,
            @"productId":self.productIdStr,
            @"rssi":self.rssiStr
        };
        DLog(@"lightInfo:%@",lightInfo);
        [MxDrawBoardManager saveLightInfoWithInfo:lightInfo Location:self.currenLocation];
        
        
//        [[MxDrawBoardManager shareInstance].needAddGroup setValue:@"YES" forKey:self.macStr];
        
        [MxDrawBoardManager needAddGroupWithValue:[NSString stringWithFormat:@"%@——%d",self.nameStr,self.currenLocation] Key:self.macStr];
        
        [MxMeshManager groupAddDeviceWithUuid:self.deviceUUID elementIndex:0 service:0 address:@"C100" isMaster:YES callback:^(BOOL isSuccess) {
            if (isSuccess) {
                DLog(@"添加群组成功");
            }else{
                DLog(@"添加群组失败");
            }
        }];
        self.currenLocation += 1;
        [[NSUserDefaults standardUserDefaults] setObject:@(self.currenLocation) forKey:LightCurrnetLocation];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}




- (void)meshProvisionProcessWithStep:(NSInteger)step {
    switch (step) {
        case 0:
            [self beginBluetoothConnection];
            break;
        case 1:
            [self InitialiseBluettothService];
            break;
        case 2:
            [self BeginConnectingToMesh];
            break;
        case 3:
            [self BeginCongifureMeshParams];
            break;
        default:
            break;
    }
}

#pragma mark--------------------云端双重认证，需要实现下面两个方法---------------

- (void)inputExchangeInformationWithConfirmationKey:(NSString *)confirmationKey handler:(void (^)(NSString * _Nullable, NSString * _Nullable, NSString * _Nullable))handler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入信息" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action_cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *action_conform = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alert.textFields[0];
        
        NSString *inputMsg = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
        NSArray *infoArr = [inputMsg componentsSeparatedByString:@","];
        if (infoArr.count > 1) {
            NSString *random = infoArr[0];
            NSString *authValue = infoArr[1];
            handler(random,nil,authValue);
        }
        
        
    }];
    
    [alert addAction:action_cancel];
    [alert addAction:action_conform];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入random和authValue信息，并以逗号分开";
        textField.text = @"d89ffe3d82eb0577eae79f21c3407726,842aaff6670515d46709bdb0f577c0cf";
    }];

    [self presentViewController:alert animated:YES completion:nil];
}
//拿到deviceConfirmation、deviceRandom和provisionerRandom上传到云端校验，hander返回校验结果
- (void)checkStaticOOBDeviceInfoWithProvisionerRandom:(NSString *)provisionerRandom deviceConfirmation:(NSString *)deviceConfirmation deviceRandom:(NSString *)deviceRandom handler:(void (^)(BOOL))handler {
    
    handler(YES);
}

#pragma mark-----------------------------------
- (NSData *)dataWithHexString:(NSString *)hex
{
    char buf[3];
    buf[2] = '\0';
    NSAssert(0 == [hex length] % 2, @"Hex strings should have an even number of digits (%@)", hex);
    unsigned char *bytes = malloc([hex length]/2);
    unsigned char *bp = bytes;
    for (CFIndex i = 0; i < [hex length]; i += 2) {
        buf[0] = [hex characterAtIndex:i];
        buf[1] = [hex characterAtIndex:i+1];
        char *b2 = NULL;
        *bp++ = strtol(buf, &b2, 16);
        NSAssert(b2 == buf + 2, @"String should be all hex digits: %@ (bad digit around %ld)", hex, (long)i);
    }
    
    return [NSData dataWithBytesNoCopy:bytes length:[hex length]/2 freeWhenDone:YES];
}


@end
