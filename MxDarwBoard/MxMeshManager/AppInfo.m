//
//  AppInfo.m
//  MeshSDKDemo
//
//  Created by 华峰 on 2021/5/7.
//

#import "AppInfo.h"

@implementation AppInfo

+ (instancetype)sharedInstance {
    static AppInfo *info = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        info = [[[self class] alloc] init];
    });
    
    return info;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.deviceList = [[NSMutableArray alloc] initWithCapacity:1];
        self.netWorkKey = @"DE128B9A8DE65F72AAA5450054D173C8";
        
        self.networkKey2 = @"DE128B9A8DE65F72AAA5450054D173CA";
    }
    return self;
}

@end
