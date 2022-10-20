//
//  MxAddDeviceContoller.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/28.
//

#import "MxAddDeviceContoller.h"
#import "MxMeshManager.h"
#import "MXProvisionViewController.h"

@interface MxAddDeviceContoller ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *list;

@end

@implementation MxAddDeviceContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"重新扫描" style:UIBarButtonItemStylePlain target:self action:@selector(scanMeshDevices)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scanMeshDevices];
}


// 3.发现mesh设备
- (void)scanMeshDevices {
      DLog(@"scanMeshDevices");
    [MxMeshManager scanDeviceWithMac:nil timeout:0 callback:^(NSArray<NSDictionary<NSString *,id> *> * _Nonnull devices) {
          DLog(@"发现设备 %@",devices);
        self.list = devices;
        [self.tableView reloadData];
    }];
    

}



#pragma mark - UITableViewDelegate UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];;
    }
    if (self.list.count > indexPath.row) {
        NSDictionary *info = [self.list objectAtIndex:indexPath.row];
        cell.textLabel.text = [info objectForKey:@"name"];
        cell.detailTextLabel.text = [info objectForKey:@"mac"];
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.list.count > indexPath.row) {
        NSDictionary *info = [self.list objectAtIndex:indexPath.row];
        [self.view setUserInteractionEnabled:NO];
        [MxMeshManager disconnect];
        MXProvisionViewController *vc = [[MXProvisionViewController alloc] init];
//        vc.device = info[@"device"];
        /**
         {
             device = "<MXMeshProvision.UnprovisionedDevice: 0x2836f0330>";
             mac = "04:78:63:D3:C3:49";
             name = " mxLight C349";
             peripheral = "<CBPeripheral: 0x28099e760, identifier = D8D59661-FC40-81F4-6D41-5A9AC89FD8F3, name =  mxLight C349, state = disconnected>";
             productId = 6659818;
             rssi = "-64";
             uuid = "220971EA-9E65-0049-C3D3-637804020000";
         }
         */
        vc.peripheral = info[@"peripheral"];
        vc.deviceUUID = info[@"uuid"];
        vc.productIdStr = info[@"productId"];
        vc.rssiStr = info[@"rssi"];
        vc.nameStr = info[@"name"];
        vc.macStr = [info[@"mac"] stringByReplacingOccurrencesOfString:@":" withString:@""];
        vc.device = info[@"device"];
        [self.navigationController pushViewController:vc animated:YES];
//        [[MeshSDK sharedInstance] startUnprovisionedDeviceProvisionWithDevice:info[@"device"] peripheral:info[@"peripheral"] networkKey:[AppInfo sharedInstance].netWorkKey callback:^(BOOL isSuccess) {
//            [self.view setUserInteractionEnabled:YES];
//            if (isSuccess) {
//                [[AppInfo sharedInstance].deviceList addObject:info];
//                [self.navigationController popViewControllerAnimated:YES];
//            } else {
//                [self scanMeshDevices];
//            }
//        }];
    }
}
@end
