//
//  MxMeshManager.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol MesManagerConnectDelegate <NSObject>

-(void)subscribeMeshConnectStatus:(NSInteger)status;

-(void)hasBindDeviceCount:(NSInteger)count;

@end

@protocol MeshManagerProvisionDelegate <NSObject>

- (void)inputPublicKeyWithHandler:(void (^ _Nonnull)(NSString * _Nonnull))handler;
- (void)inputUnicastAddressWithElementNum:(NSInteger)elementNum handler:(void (^ _Nonnull)(NSInteger))handler;
- (void)meshProvisionProcessWithStep:(NSInteger)step;
- (void)meshProvisionFinishWithError:(NSError * _Nullable)error;

@end


@protocol MeshManagerOOBProvisioningDelegate <NSObject>

- (void)inputExchangeInformationWithConfirmationKey:(NSString * _Nonnull)confirmationKey handler:(void (^ _Nonnull)(NSString * _Nullable, NSString * _Nullable, NSString * _Nullable))handler;
- (void)checkStaticOOBDeviceInfoWithProvisionerRandom:(NSString * _Nonnull)provisionerRandom deviceConfirmation:(NSString * _Nonnull)deviceConfirmation deviceRandom:(NSString * _Nonnull)deviceRandom handler:(void (^ _Nonnull)(BOOL))handler;

@end

@interface MxMeshManager : NSObject

@property(nonatomic,weak) id<MeshManagerProvisionDelegate>provisionDelegate;

@property(nonatomic,weak) id<MeshManagerOOBProvisioningDelegate>OOBProvisionDelegate;

@property(nonatomic,weak) id<MesManagerConnectDelegate>delegate;

+(void)initMeshManager;

+(instancetype)shareInstance;

+(void)setupWithConfig:(NSDictionary *_Nullable)config;

+(BOOL)isNetworkKeyExistsWithNetworkKey:(NSString * _Nullable)networkKey;

+(BOOL)createNetworkKeyWithKey:(NSString * _Nullable)networkKey;

+(void)setCurrentNetworkKeyWithKey:(NSString * _Nullable)networkKey;


+ (void)exportMeshNetworkWithCallback:( void (^ _Nonnull)(NSString * _Nonnull))callback;

+ (void)importMeshNetworkWithJsonString:(NSString *)jsonSring WithCallback:( void (^ _Nonnull)(BOOL))callback;

+ (void)subscribeMeshConnectStatusWithCallback:(void (^ _Nonnull)(NSInteger))callback;

+ (void)sendSyncMessageWithNetworkKey:(NSString * _Nonnull)networkKey;

+ (void)subscribeDeviceStatusWithCallback:(void (^ _Nonnull)(NSDictionary<NSString *, NSArray<NSString *> *> * _Nonnull))callback;

+ (void)subscribeMeshSequencesUpdateWithCallback:(void (^ _Nonnull)(void))callback;

+ (uint32_t)getMeshNetworkSequence;

+ (NSDictionary<NSString *, id> * _Nullable)getNodeInfoWithUuid:(NSString * _Nonnull)uuid;

+ (BOOL)checkDeviceIsOnlineWithUuid:(NSString * _Nonnull)uuid;

+ (NSString * _Nonnull)getDeviceMacAddressWithUuid:(NSString * _Nonnull)uuid;

+ (void)resetProvisionerUnicastAddressWithAddress:(uint16_t)address;

+ (void)setMeshNetworkSequenceWithSeq:(uint32_t)seq updateInterval:(uint32_t)updateInterval;

+ (void)stopScan;

+ (void)scanDeviceWithMac:(NSString * _Nullable)mac timeout:(NSInteger)timeout callback:(void (^ _Nonnull)(NSArray<NSDictionary<NSString *, id> *> * _Nonnull))callback;

+ (void)disconnect;

+ (void)subscribeMeshDownMessageWithCallback:(void (^ _Nonnull)(NSDictionary<NSString *, id> * _Nonnull))callback;

+ (void)setDevicePropertiesWithOpcode:(NSString * _Nonnull)opcode uuid:(NSString * _Nonnull)uuid retryNum:(NSInteger)retryNum properties:(NSDictionary<NSString *, id> * _Nonnull)properties callback:(void (^ _Nonnull)(NSDictionary<NSString *, id> * _Nonnull))callback;

+ (void)addNetworkKeyToNodeWithUuid:(NSString * _Nonnull)uuid networkKey:(NSString * _Nonnull)networkKey appKey:(NSString * _Nullable)appKey callback:(void (^ _Nonnull)(BOOL))callback;

+ (void)sendMeshMessageWithOpCode:(NSString * _Nonnull)opCode uuid:(NSString * _Nonnull)uuid elementIndex:(NSInteger)elementIndex Tid:(NSString * _Nullable)Tid message:(id _Nonnull)message retryCount:(NSInteger)retryCount timeout:(NSTimeInterval)timeout isHoldCallback:(BOOL)isHoldCallback networkKey:(NSString * _Nullable)networkKey callback:(void (^ _Nullable)(NSDictionary<NSString *, id> * _Nonnull))callback;

+ (void)sendGroupMessageWithAddress:(NSString * _Nonnull)address opCode:(NSString * _Nonnull)opCode uuid:(NSString * _Nullable)uuid elementIndex:(NSInteger)elementIndex message:(id _Nonnull)message networkKey:(NSString * _Nonnull)networkKey repeatNum:(NSInteger)repeatNum;

+(void)resetPhaseToIdling;

+ (BOOL)deleteNodeWithUuid:(NSString * _Nonnull)uuid;

+ (void)startUnprovisionedDeviceProvisionWithMac:(NSString * _Nonnull)mac networkKey:(NSString * _Nonnull)networkKey provisioningDelegate:(id <MeshManagerProvisionDelegate> _Nullable)provisioningDelegate oobDelegate:(id <MeshManagerOOBProvisioningDelegate> _Nullable)oobDelegate;

+(void)groupAddDeviceWithUuid:(NSString * _Nonnull)uuid elementIndex:(NSInteger)elementIndex service:(NSInteger)service address:(NSString * _Nonnull)address isMaster:(BOOL)isMaster callback:(void (^ _Nonnull)(BOOL))callback;

+ (NSArray<NSString *> * _Nonnull)fetchAllNodeUUID;

+ (void)connect;
@end

NS_ASSUME_NONNULL_END
