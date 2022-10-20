//
//  AppInfo.h
//  MeshSDKDemo
//
//  Created by 华峰 on 2021/5/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppInfo : NSObject

@property (nonatomic, strong) NSMutableArray *deviceList;
@property (nonatomic, copy) NSString *netWorkKey;

@property (nonatomic, copy) NSString *networkKey2;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
