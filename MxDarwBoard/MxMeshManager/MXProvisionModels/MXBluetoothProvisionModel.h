//
//  MXBluetoothProvisionModel.h
//  IMSDomain
//
//  Created by zhujia on 2020/7/2.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MXBluetoothProvisionModelStatus) {
    MXBluetoothProvisionModelStatusSuccess = 0,
    MXBluetoothProvisionModelStatusProcessing,
    MXBluetoothProvisionModelStatusFailed,
    MXBluetoothProvisionModelStatusIdling
};

@interface MXBluetoothProvisionModel : NSObject

@property (nonatomic, copy) NSString *remindTitle;

//@property (nonatomic, assign) NSInteger status; // 1、为正在loading的 2、为已经完成加载
@property (nonatomic, assign) MXBluetoothProvisionModelStatus status;

@end


