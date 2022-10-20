//
//  MxMeshManager.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/28.
//

#import "MxMeshManager.h"
#import "AppInfo.h"
#import "MxDrawBoardManager.h"
@import MeshSDK;

@interface MxMeshManager()<MeshSDKProvisionDelegate,MeshSDKOOBProvisioningDelegate>

@property(nonatomic,copy)NSMutableArray *deviceList;



@end

@implementation MxMeshManager

-(NSMutableArray *)deviceList{
    if (!_deviceList) {
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}

+(instancetype)shareInstance{
    
    static MxMeshManager *instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[MxMeshManager alloc] init];
    }) ;
    return instance;
    
}

+(void)initMeshManager{
    BOOL isNetworkKeyExisted = [MxMeshManager isNetworkKeyExistsWithNetworkKey:[AppInfo sharedInstance].netWorkKey];
    if (!isNetworkKeyExisted) {
        //创建家庭的mesh网络key，一个家庭一个ApplicationKey
        [MxMeshManager createNetworkKeyWithKey:[AppInfo sharedInstance].netWorkKey];
    }
    [MxMeshManager setCurrentNetworkKeyWithKey:[AppInfo sharedInstance].netWorkKey];
    
    [MxMeshManager exportMeshNetworkWithCallback:^(NSString * _Nonnull jsonStr) {
          DLog(@"mesh json = %@",jsonStr);
    }];
    [MxMeshManager subscribeMeshConnectStatusWithCallback:^(NSInteger status) {
          DLog(@"mesh connectStatus %ld", status);
        if ([[MxMeshManager shareInstance].delegate respondsToSelector:@selector(subscribeMeshConnectStatus:)]) {
            [[MxMeshManager shareInstance].delegate subscribeMeshConnectStatus:status];
        }
        if (status == 1) {
            //发送同步消息
            [MxMeshManager sendSyncMessageWithNetworkKey:[AppInfo sharedInstance].netWorkKey];
            [MxMeshManager addGroup];
        }
    }];

    //添加seq需要更新的监听
    [MxMeshManager subscribeMeshSequencesUpdateWithCallback:^() {
        UInt32 seq = [MxMeshManager getMeshNetworkSequence];
          DLog(@"需要更新seq到云端 seq = %u",seq);
    }];
    [[AppInfo sharedInstance].deviceList removeAllObjects];
    [[MxMeshManager shareInstance].deviceList removeAllObjects];
    
    if ([AppInfo sharedInstance].deviceList.count == 0) {
        NSArray *devicesList = [MxMeshManager fetchAllNodeUUID];
        for (NSString *uuid in devicesList) {
            NSDictionary *nodeInfo = [MxMeshManager getNodeInfoWithUuid:uuid];
            NSMutableDictionary *newNode = [NSMutableDictionary dictionaryWithDictionary:nodeInfo];
            [newNode setObject:[NSNumber numberWithBool:[MxMeshManager checkDeviceIsOnlineWithUuid:uuid]] forKey:@"isOnline"];
            [newNode setObject:uuid forKey:@"nodeUUID"];
            [newNode setObject:[[MxMeshManager getDeviceMacAddressWithUuid:uuid] stringByReplacingOccurrencesOfString:@":" withString:@""] forKey:@"nodeMac"];
            [[AppInfo sharedInstance].deviceList addObject:newNode];
        }
        
    }
    if ([MxMeshManager.shareInstance.delegate respondsToSelector:@selector(hasBindDeviceCount:)]) {
        [MxMeshManager.shareInstance.delegate hasBindDeviceCount:[AppInfo sharedInstance].deviceList.count];
    }
    [[MxMeshManager shareInstance].deviceList addObjectsFromArray:[AppInfo sharedInstance].deviceList];
    [MxMeshManager connect];
}

+(void)addGroup{
    NSDictionary * needAddGroupData = [MxDrawBoardManager getNeedAddGroupData];
    if ([needAddGroupData  allKeys].count) {
        for (NSDictionary *deviceInfo in [MxMeshManager shareInstance].deviceList) {
            NSString * macStr = [deviceInfo objectForKey:@"nodeMac"];
            if ([needAddGroupData objectForKey:macStr]) {
                [MxMeshManager addGroupWithMacStr:macStr];
            }
        }
    }
}



+(void)addGroupWithMacStr:(NSString *)macStr{
    [MxMeshManager groupAddDeviceWithUuid:macStr elementIndex:0 service:0 address:@"C100" isMaster:YES callback:^(BOOL isSuccess) {
        if (isSuccess) {
            DLog(@"加入群组成功：%@",macStr);
            [MxDrawBoardManager deleteNeedAddGroupDaraWithKey:macStr];
        }else{
            DLog(@"加入群组失败");
        }
    }];
}

+(void)setupWithConfig:(NSDictionary *_Nullable)config{
    [[MeshSDK sharedInstance] setupWithConfig:config];
}

+(BOOL)isNetworkKeyExistsWithNetworkKey:(NSString * _Nullable)networkKey{
    return  [[MeshSDK sharedInstance] isNetworkKeyExistsWithNetworkKey:networkKey];
}

+(BOOL)createNetworkKeyWithKey:(NSString * _Nullable)networkKey{
    return  [[MeshSDK sharedInstance] createNetworkKeyWithKey:networkKey];
}

+(void)setCurrentNetworkKeyWithKey:(NSString * _Nullable)networkKey{
    [[MeshSDK sharedInstance] setCurrentNetworkKeyWithKey:networkKey];
}


+ (void)exportMeshNetworkWithCallback:( void (^ _Nonnull)(NSString * _Nonnull))callback{
    [[MeshSDK sharedInstance] exportMeshNetworkWithCallback:^(NSString * _Nonnull jsonStr) {
        callback(jsonStr);
    }];
}

+ (void)importMeshNetworkWithJsonString:(NSString *)jsonSring WithCallback:( void (^ _Nonnull)(BOOL))callback{
    [[MeshSDK sharedInstance] importMeshNetworkWithJsonString:jsonSring callback:^(BOOL isSuccess) {
        callback(isSuccess);
    }];
}

+ (void)subscribeMeshConnectStatusWithCallback:(void (^ _Nonnull)(NSInteger))callback{
    [MeshSDK.sharedInstance subscribeMeshConnectStatusWithCallback:^(NSInteger status) {
        callback(status);
    }];
}

+ (void)sendSyncMessageWithNetworkKey:(NSString * _Nonnull)networkKey{
    [[MeshSDK sharedInstance] sendSyncMessageWithNetworkKey:networkKey];

}

+ (void)subscribeDeviceStatusWithCallback:(void (^ _Nonnull)(NSDictionary<NSString *, NSArray<NSString *> *> * _Nonnull))callback{
    [[MeshSDK sharedInstance] subscribeDeviceStatusWithCallback:^(NSDictionary * _Nonnull result) {
        callback(result);
    }];
}


+ (void)subscribeMeshSequencesUpdateWithCallback:(void (^ _Nonnull)(void))callback{
    [MeshSDK.sharedInstance subscribeMeshSequencesUpdateWithCallback:^() {
        callback();
    }];
}


+ (uint32_t)getMeshNetworkSequence{
    return [MeshSDK.sharedInstance getMeshNetworkSequence];
}

+ (NSDictionary<NSString *, id> * _Nullable)getNodeInfoWithUuid:(NSString * _Nonnull)uuid {
    return [[MeshSDK sharedInstance] getNodeInfoWithUuid:uuid];
}

+ (BOOL)checkDeviceIsOnlineWithUuid:(NSString * _Nonnull)uuid {
    return [[MeshSDK sharedInstance] checkDeviceIsOnlineWithUuid:uuid];
}

+ (NSString * _Nonnull)getDeviceMacAddressWithUuid:(NSString * _Nonnull)uuid {
    return [[MeshSDK sharedInstance] getDeviceMacAddressWithUuid:uuid];
}

+ (void)resetProvisionerUnicastAddressWithAddress:(uint16_t)address{
    [MeshSDK.sharedInstance resetProvisionerUnicastAddressWithAddress:address];
}

+ (void)setMeshNetworkSequenceWithSeq:(uint32_t)seq updateInterval:(uint32_t)updateInterval{
    [MeshSDK.sharedInstance setMeshNetworkSequenceWithSeq:seq updateInterval:updateInterval];
}

+ (void)stopScan{
    [[MXMeshDeviceScan sharedInstance] stopScan];
}

+ (void)scanDeviceWithMac:(NSString * _Nullable)mac timeout:(NSInteger)timeout callback:(void (^ _Nonnull)(NSArray<NSDictionary<NSString *, id> *> * _Nonnull))callback{
    [[MXMeshDeviceScan sharedInstance] scanDeviceWithMac:mac timeout:timeout callback:^(NSArray<NSDictionary<NSString *,id> *> * _Nonnull devices) {
        callback(devices);
    }];
}

+ (void)disconnect{
    [[MeshSDK sharedInstance] disconnect];
}

+ (void)subscribeMeshDownMessageWithCallback:(void (^ _Nonnull)(NSDictionary<NSString *, id> * _Nonnull))callback{
    [[MeshSDK sharedInstance] subscribeMeshDownMessageWithCallback:^(NSDictionary<NSString *,id> * _Nonnull dict) {
        callback(dict);
    }];
}

+ (void)setDevicePropertiesWithOpcode:(NSString * _Nonnull)opcode uuid:(NSString * _Nonnull)uuid retryNum:(NSInteger)retryNum properties:(NSDictionary<NSString *, id> * _Nonnull)properties callback:(void (^ _Nonnull)(NSDictionary<NSString *, id> * _Nonnull))callback{
//    [[MXMeshDeviceScan sharedInstance] setDevicePropertiesWithOpcode:opcode uuid:uuid retryNum:retryNum properties:properties callback:^(NSDictionary<NSString *,id> * _Nonnull result) {
//        callback(result);
//    }];
}

+ (void)addNetworkKeyToNodeWithUuid:(NSString * _Nonnull)uuid networkKey:(NSString * _Nonnull)networkKey appKey:(NSString * _Nullable)appKey callback:(void (^ _Nonnull)(BOOL))callback{
    [MeshSDK.sharedInstance addNetworkKeyToNodeWithUuid:uuid networkKey:networkKey appKey:appKey callback:^(BOOL isSuccess) {
        callback(isSuccess);
    }];
}
+ (void)sendMeshMessageWithOpCode:(NSString * _Nonnull)opCode uuid:(NSString * _Nonnull)uuid elementIndex:(NSInteger)elementIndex Tid:(NSString * _Nullable)Tid message:(id _Nonnull)message retryCount:(NSInteger)retryCount timeout:(NSTimeInterval)timeout isHoldCallback:(BOOL)isHoldCallback networkKey:(NSString * _Nullable)networkKey callback:(void (^ _Nullable)(NSDictionary<NSString *, id> * _Nonnull))callback{
    if (elementIndex == 0) {
        DLog(@"elementIndex = 0");
    }
    [[MeshSDK sharedInstance] sendMeshMessageWithOpCode:opCode uuid:uuid elementIndex:elementIndex Tid:Tid message:message retryCount:retryCount timeout:timeout isHoldCallback:isHoldCallback networkKey:networkKey callback:^(NSDictionary * _Nullable result) {
        callback(result);
    }];
}

+ (void)sendGroupMessageWithAddress:(NSString * _Nonnull)address opCode:(NSString * _Nonnull)opCode uuid:(NSString * _Nullable)uuid elementIndex:(NSInteger)elementIndex message:(id _Nonnull)message networkKey:(NSString * _Nonnull)networkKey repeatNum:(NSInteger)repeatNum{
    [[MeshSDK sharedInstance] sendGroupMessageWithAddress:address opCode:opCode uuid:uuid elementIndex:elementIndex message:message networkKey:networkKey repeatNum:repeatNum];
}

+(void)resetPhaseToIdling{
    [[MeshSDK sharedInstance] resetPhaseToIdling];
}


+ (BOOL)deleteNodeWithUuid:(NSString * _Nonnull)uuid{
    return [[MeshSDK sharedInstance] deleteNodeWithUuid:uuid];
}

+ (void)startUnprovisionedDeviceProvisionWithMac:(NSString * _Nonnull)mac networkKey:(NSString * _Nonnull)networkKey provisioningDelegate:(id <MeshManagerProvisionDelegate> _Nullable)provisioningDelegate oobDelegate:(id <MeshManagerOOBProvisioningDelegate> _Nullable)oobDelegate{
    [MxMeshManager shareInstance].provisionDelegate = provisioningDelegate;
    [MxMeshManager shareInstance].OOBProvisionDelegate = oobDelegate;
    [[MeshSDK sharedInstance] startUnprovisionedDeviceProvisionWithMac:mac networkKey:networkKey provisioningDelegate:[MxMeshManager shareInstance] oobDelegate:[MxMeshManager shareInstance]];
}

+(void)groupAddDeviceWithUuid:(NSString * _Nonnull)uuid elementIndex:(NSInteger)elementIndex service:(NSInteger)service address:(NSString * _Nonnull)address isMaster:(BOOL)isMaster callback:(void (^ _Nonnull)(BOOL))callback{
//    [[MeshSDK sharedInstance] groupAddDeviceWithUuid:uuid elementIndex:elementIndex service:service address:address isMaster:isMaster callback:callback];
    [[MeshSDK sharedInstance] groupAddDeviceWithUuid:uuid groups:@[@{@"address":address,@"service":@(service),@"isMaster":@(NO)}] callback:callback];
}

#pragma mark - MeshSDKProvisionDelegate -
- (void)inputPublicKeyWithHandler:(void (^ _Nonnull)(NSString * _Nonnull))handler{
    if ([self.provisionDelegate respondsToSelector:@selector(inputPublicKeyWithHandler:)]) {
        [self.provisionDelegate inputPublicKeyWithHandler:^(NSString * _Nonnull result) {
            handler(result);
        }];
    }
}
- (void)inputUnicastAddressWithElementNum:(NSInteger)elementNum handler:(void (^ _Nonnull)(NSInteger))handler{
    if ([self.provisionDelegate respondsToSelector:@selector(inputUnicastAddressWithElementNum:handler:)]) {
//        [self.provisionDelegate inputUnicastAddressWithElementNum:elementNum handler:handler];
        [self.provisionDelegate inputUnicastAddressWithElementNum:elementNum handler:handler];
    }
}
- (void)meshProvisionProcessWithStep:(NSInteger)step{
    if ([self.provisionDelegate respondsToSelector:@selector(meshProvisionProcessWithStep:)]) {
        [self.provisionDelegate meshProvisionProcessWithStep:step];
    }
}
- (void)meshProvisionFinishWithError:(NSError * _Nullable)error{
    if ([self.provisionDelegate respondsToSelector:@selector(meshProvisionFinishWithError:)]) {
        [self.provisionDelegate meshProvisionFinishWithError:error];
    }
}

#pragma mark - MeshSDKOOBProvisioningDelegate -

- (void)inputExchangeInformationWithConfirmationKey:(NSString * _Nonnull)confirmationKey handler:(void (^ _Nonnull)(NSString * _Nullable, NSString * _Nullable, NSString * _Nullable))handler{
    if ([self.OOBProvisionDelegate respondsToSelector:@selector(inputExchangeInformationWithConfirmationKey:handler:)]) {
        [self.OOBProvisionDelegate inputExchangeInformationWithConfirmationKey:confirmationKey handler:handler];
    }
}
- (void)checkStaticOOBDeviceInfoWithProvisionerRandom:(NSString * _Nonnull)provisionerRandom deviceConfirmation:(NSString * _Nonnull)deviceConfirmation deviceRandom:(NSString * _Nonnull)deviceRandom handler:(void (^ _Nonnull)(BOOL))handler{
    if ([self.OOBProvisionDelegate respondsToSelector:@selector(checkStaticOOBDeviceInfoWithProvisionerRandom:deviceConfirmation:deviceRandom:handler:)]) {
        [self.OOBProvisionDelegate checkStaticOOBDeviceInfoWithProvisionerRandom:provisionerRandom deviceConfirmation:deviceConfirmation deviceRandom:deviceRandom handler:handler];
    }
}

+ (NSArray<NSString *> * _Nonnull)fetchAllNodeUUID{
    return [[MeshSDK sharedInstance] fetchAllNodeUUID];
}

+ (void)connect{
    [[MeshSDK sharedInstance] connect];
}
@end
