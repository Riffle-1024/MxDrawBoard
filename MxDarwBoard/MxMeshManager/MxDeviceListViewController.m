//
//  MxDeviceListViewController.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/28.
//

#import "MxDeviceListViewController.h"
#import "MxMeshManager.h"
#import "AppInfo.h"
#import "MxAddDeviceContoller.h"
#import "PlanViewController.h"
#import "MxDrawBoardManager.h"
@interface MxDeviceListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *list;

@end

@implementation MxDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    BOOL isNetworkKeyExisted = [MxMeshManager isNetworkKeyExistsWithNetworkKey:[AppInfo sharedInstance].netWorkKey];
//    if (!isNetworkKeyExisted) {
//        //创建家庭的mesh网络key，一个家庭一个ApplicationKey
//        [MxMeshManager createNetworkKeyWithKey:[AppInfo sharedInstance].netWorkKey];
//    }
//    [MxMeshManager setCurrentNetworkKeyWithKey:[AppInfo sharedInstance].netWorkKey];
//
//    [MxMeshManager exportMeshNetworkWithCallback:^(NSString * _Nonnull jsonStr) {
//        DLog(@"mesh json = %@",jsonStr);
//        [MxMeshManager importMeshNetworkWithJsonString:jsonStr WithCallback:^(BOOL isSuccess) {
//            if (isSuccess) {
//                DLog(@"数据导入成功");
//            }else{
//                DLog(@"数据导入失败");
//            }
//        }];
//
//    }];
//
    
//    [MxMeshManager ]
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(exitViewController:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"添加设备" style:UIBarButtonItemStylePlain target:self action:@selector(addDevices:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    self.title = @"已绑定设备列表";
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
//    [MxMeshManager subscribeMeshConnectStatusWithCallback:^(NSInteger status) {
//          DLog(@"mesh 连接状态 %ld", status);
//        if (status == 1) {
//            //发送同步消息
//            [MxMeshManager sendSyncMessageWithNetworkKey:[AppInfo sharedInstance].netWorkKey];
//            [self addGroup];
//        }
//    }];
    [MxMeshManager subscribeDeviceStatusWithCallback:^(NSDictionary * _Nonnull result) {
        //NSArray *array = [result objectForKey:@"uuid"];
        NSArray *macArray = [result objectForKey:@"mac"];
        for (int i=0; i<self.list.count; i++) {
            NSMutableDictionary *info = [self.list objectAtIndex:i];
            [info setObject:@1 forKey:@"isOnline"];
//            for (NSString *uuid in array) {
//                if ([uuid isEqualToString:[info objectForKey:@"nodeUUID"]]) {
//                    [info setObject:@0 forKey:@"isOnline"];
//                    break;
//                }
//            }
            
            for (NSString *uuid in macArray) {
                if ([uuid isEqualToString:[info objectForKey:@"nodeMac"]]) {
                    [info setObject:@0 forKey:@"isOnline"];
                    break;
                }
            }
        }
        [self.tableView reloadData];
    }];
    //添加seq需要更新的监听
//    [MxMeshManager subscribeMeshSequencesUpdateWithCallback:^() {
//        UInt32 seq = [MxMeshManager getMeshNetworkSequence];
//          DLog(@"需要更新seq到云端 seq = %u",seq);
//    }];
//    [MxMeshManager exportMeshNetworkWithCallback:^(NSString * _Nonnull resultString) {
//        DLog(@"exportMeshNetworkWithCallback:%@",resultString);
//    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MxMeshManager stopScan];
    [[AppInfo sharedInstance].deviceList removeAllObjects];
    [self.list removeAllObjects];
    if ([AppInfo sharedInstance].deviceList.count == 0) {
        NSArray *devicesList = [MxMeshManager fetchAllNodeUUID];
        for (NSString *uuid in devicesList) {
            NSDictionary *nodeInfo = [MxMeshManager getNodeInfoWithUuid:uuid];
            NSMutableDictionary *newNode = [NSMutableDictionary dictionaryWithDictionary:nodeInfo];
            [newNode setObject:[NSNumber numberWithBool:[MxMeshManager checkDeviceIsOnlineWithUuid:uuid]] forKey:@"isOnline"];
            [newNode setObject:uuid forKey:@"nodeUUID"];
            NSString * macStr = [[MxMeshManager getDeviceMacAddressWithUuid:uuid] stringByReplacingOccurrencesOfString:@":" withString:@""];
            [newNode setObject:macStr forKey:@"nodeMac"];
            [[AppInfo sharedInstance].deviceList addObject:newNode];
        }
        
    }
    [self.list addObjectsFromArray:[self getAortdata:[AppInfo sharedInstance].deviceList]];
    [self.tableView reloadData];
    [MxMeshManager connect];
}

-(void)addGroup{
    NSDictionary * needAddGroupData = [MxDrawBoardManager getNeedAddGroupData];
    if ([needAddGroupData  allKeys].count) {
        for (NSDictionary *deviceInfo in self.list) {
            NSString * macStr = [deviceInfo objectForKey:@"nodeMac"];
            if ([needAddGroupData objectForKey:macStr]) {
                [self addGroupWithMacStr:macStr];
            }
        }
    }

}

-(void)addGroupWithMacStr:(NSString *)macStr{
    [MxMeshManager groupAddDeviceWithUuid:macStr elementIndex:0 service:0 address:@"C100" isMaster:NO callback:^(BOOL isSuccess) {
        if (isSuccess) {
            DLog(@"加入群组成功：%@",macStr);
            [MxDrawBoardManager deleteNeedAddGroupDaraWithKey:macStr];
        }else{
            DLog(@"加入群组失败");
        }
    }];
}

-(NSMutableArray *)list{
    if (!_list) {
        _list = [NSMutableArray array];
    }
    return _list;
}




//数据排序
-(NSArray *)getAortdata:(NSArray *)dataArray{
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    for (NSDictionary * deviceInfo in dataArray) {
        NSString *unicastAddress = deviceInfo[@"unicastAddress"];
        NSString * decimalStr = [NSString stringWithFormat:@"%lu",strtoul([unicastAddress UTF8String],0,16)];
        [dataDic setObject:deviceInfo forKey:decimalStr];
    }
    NSArray * keys = [dataDic allKeys];
    NSArray *resultKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2]; //升序
    }];
    NSMutableArray *newArray = [NSMutableArray array];
    for (NSString *key in resultKeys) {
        NSDictionary * deviceInfo = [dataDic objectForKey:key];
        [newArray addObject:deviceInfo];
    }
    return newArray;
}

-(void)addDevices:(UIButton *)sender{
    MxAddDeviceContoller *addVC = [[MxAddDeviceContoller alloc] init];
    [self.navigationController pushViewController:addVC animated:YES];
}

-(void)exitViewController:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.list.count > indexPath.row) {
        NSDictionary *info = [self.list objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@——%@",[info objectForKey:@"name"],[self getLocationWithDeviceInfo:info]];
        if ([[info objectForKey:@"isOnline"] boolValue]) {
            cell.backgroundColor = [UIColor whiteColor];
        } else {
            cell.backgroundColor = [UIColor lightGrayColor];
        }
        //cell.detailTextLabel.text = [info objectForKey:@"mac"];
    }
    
    return cell;
}


-(NSString *)getLocationWithDeviceInfo:(NSDictionary *)deviceInfo{
    NSString *unicastAddress = deviceInfo[@"unicastAddress"];
    NSString * decimalStr = [NSString stringWithFormat:@"%lu",strtoul([unicastAddress UTF8String],0,16)];
    return [NSString stringWithFormat:@"%d",[decimalStr intValue] - 255];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.list.count > indexPath.row) {
        NSDictionary *info = [self.list objectAtIndex:indexPath.row];
//        if (![[info objectForKey:@"isOnline"] boolValue]) {
//            return;
//        }
        PlanViewController *vc = [[PlanViewController alloc] init];
        vc.deviceInfo = info;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
