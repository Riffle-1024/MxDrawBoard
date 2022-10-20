//
//  MxNoGroupDeviceListViewController.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/7/21.
//

#import "MxNoGroupDeviceListViewController.h"
#import "MxDrawBoardManager.h"
#import "AppInfo.h"
#import "PlanViewController.h"
#import "MxDrawBoardManager.h"
#import "MxMeshManager.h"

@interface MxNoGroupDeviceListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) NSDictionary *needAddGroupData;
@property (nonatomic, strong) NSMutableArray *tagArray;


@end

@implementation MxNoGroupDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(exitViewController:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
//    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"添加设备" style:UIBarButtonItemStylePlain target:self action:@selector(addDevices:)];
//    self.navigationItem.rightBarButtonItem = rightBtn;
    self.title = @"未加入群组设备列表";
    self.needAddGroupData = [MxDrawBoardManager getNeedAddGroupData];
    self.list = [self.needAddGroupData allKeys];
    self.tagArray = [[NSMutableArray alloc] init];
    for (NSString *key in self.list) {
        [self.tagArray addObject:key];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
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
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.list.count > indexPath.row) {
        NSString *key = [self.list objectAtIndex:indexPath.row];
        NSString *name = [self.needAddGroupData objectForKey:key];
        cell.textLabel.text = name;
        //cell.detailTextLabel.text = [info objectForKey:@"mac"];
    }
    NSString *tagString = [self.tagArray objectAtIndex:indexPath.row];
    if ([tagString isEqualToString:@"1"]) {
        
        cell.detailTextLabel.text = @"已加入群组";
    }else{
        cell.detailTextLabel.text = @"未加入群组，点击加入";
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
        NSString *macStr = [self.list objectAtIndex:indexPath.row];
        NSString *tagString = [self.tagArray objectAtIndex:indexPath.row];
        if (![tagString isEqualToString:@"1"]) {
            [self addGroupWithMacStr:macStr Index:indexPath.row];
        }
        
        
        
////        if (![[info objectForKey:@"isOnline"] boolValue]) {
////            return;
////        }
//        for (NSDictionary *info in [AppInfo sharedInstance].deviceList) {
//
//            if ([[info objectForKey:@"nodeMac"] isEqualToString:macStr]) {
//                PlanViewController *vc = [[PlanViewController alloc] init];
//                vc.deviceInfo = info;
//                [self.navigationController pushViewController:vc animated:YES];
//                break;
//            }
//        }
    }
}


-(void)addGroupWithMacStr:(NSString *)macStr Index:(NSInteger )index{
    [MxMeshManager groupAddDeviceWithUuid:macStr elementIndex:0 service:0 address:@"C100" isMaster:YES callback:^(BOOL isSuccess) {
        if (isSuccess) {
            DLog(@"加入群组成功：%@",macStr);
            [MxDrawBoardManager deleteNeedAddGroupDaraWithKey:macStr];
            [self.tagArray replaceObjectAtIndex:index withObject:@"1"];
            [self.tableView reloadData];
        }else{
            DLog(@"加入群组失败");
        }
    }];
}

-(void)exitViewController:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
