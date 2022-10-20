//
//  MXProvisionViewController.h
//  MeshSDKDemo
//
//  Created by 华峰 on 2021/6/7.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@import MeshSDK;

NS_ASSUME_NONNULL_BEGIN

@interface MXProvisionViewController : UIViewController



//@property(nonatomic, strong) UnprovisionedDevice *device;
@property(nonatomic, strong) CBPeripheral * peripheral;
@property(nonatomic, copy) NSString *deviceUUID;
@property(nonatomic, copy) NSString *macStr;
@property(nonatomic, copy) NSString *rssiStr;
@property(nonatomic, copy) NSString *nameStr;
@property(nonatomic, copy) NSString *productIdStr;
@property(nonatomic, strong) UnprovisionedDevice *device;
@end

NS_ASSUME_NONNULL_END
