//
//  DevelopManager.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import "DevelopManager.h"
#define LocaltionArrayKey @"LocaltionArrayKey"
#define ProductModelArrayKey @"ProductModelArrayKey"



@interface DevelopManager()
@property(nonatomic,copy)NSMutableArray *timeCountArray;

@end

@implementation DevelopManager


+(instancetype)shareInstance{
    static DevelopManager *instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[DevelopManager alloc] init];
    }) ;
    return instance;
    
}

-(NSMutableArray *)modelPointList{
    if (!_modelPointList) {
        _modelPointList = [NSMutableArray array];
    }
    return _modelPointList;;
}


-(NSMutableArray *)pointList{
    if (!_pointList) {
        _pointList = [NSMutableArray array];
    }
    return _pointList;;
}


-(NSMutableArray *)timeCountArray{
    if (!_timeCountArray) {
        _timeCountArray = [NSMutableArray array];
    }
    return _timeCountArray;
}


-(BOOL)isShowDevelop{
    if (self.timeCountArray.count > 9) {
        [self.timeCountArray removeObjectAtIndex:0];
    }
    [self.timeCountArray addObject:[DevelopManager getNowTimeTimestamp]];
    if (self.timeCountArray.count < 10) {
        return NO;
    }else{
        return [self isShow];
    }
}



-(BOOL)isShow{
    NSInteger firstTime = [[self.timeCountArray objectAtIndex:0] intValue];
    NSInteger secondTime = [[self.timeCountArray objectAtIndex:9] intValue];
    if ((secondTime - firstTime) < 5) {
        return YES;
    }
    
    return NO;
}



+(void)saveLocationArrayWithNewArray:(NSArray *)locationArray Image:(UIImage *)image{
    NSArray *localArray = [[NSUserDefaults standardUserDefaults] objectForKey:ProductModelArrayKey];
    NSMutableArray *newArray;
    if (locationArray) {
        newArray = [NSMutableArray arrayWithArray:localArray];
    }else{
        newArray = [NSMutableArray array];
    }
    NSString *saveImageKey = [DevelopManager getCurrentHourAndMinuteTime];
    [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:saveImageKey];
    
    NSDictionary * saveObject = @{
        @"locationArray":locationArray,
        @"imageKey":saveImageKey
    };
    [newArray addObject:saveObject];
    [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:ProductModelArrayKey];
    [DevelopManager saveImageToCache:image ImageKey:saveImageKey];
}

+(void)saveImageToCache:(UIImage *)image ImageKey:(NSString *)imageKey{
    NSArray  *pathes     = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *path       = [pathes objectAtIndex:0];//???????????????????????????Library/Caches
    NSString *finishPath = [NSString stringWithFormat:@"%@/MxDraw/prductImage/",path];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:finishPath]) {
        [fileManager createDirectoryAtPath:finishPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [finishPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",imageKey]];
    BOOL result = [UIImagePNGRepresentation(image) writeToFile: filePath atomically:YES]; // ?????????????????????YES
    if (result) {
        NSLog(@"??????????????????ImageKey:%@",imageKey);
    }else{
        NSLog(@"??????????????????");
    }
}

+(void)deleteLocationArrayWithIndex:(int)index{
    NSArray *localArray = [[NSUserDefaults standardUserDefaults] objectForKey:ProductModelArrayKey];
    if (localArray.count > index) {
        NSDictionary *locationObject = [localArray objectAtIndex:index];
        NSString *imageKey = [locationObject objectForKey:@"imageKey"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:imageKey];
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:localArray];
        [newArray removeObjectAtIndex:index];
        [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:ProductModelArrayKey];
    }
    
}

+(void)updateAllProductData:(NSArray *)array{
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:ProductModelArrayKey];
}

+(NSArray *)getLocalProductArray{
    return [[NSUserDefaults standardUserDefaults] objectForKey:ProductModelArrayKey];
}

//??????????????????,????????????yyyyMMddHHmmssSSS
+(NSString * )getCurrentHourAndMinuteTime{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    // ????????????????????????hh???HH?????????:????????????12?????????,24?????????

    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];

    NSDate *dateNow = [NSDate date];

    //???NSDate???formatter????????????NSString

    NSString *currentTime = [formatter stringFromDate:dateNow];

    return currentTime;

}

+(NSString *)getNowTimeTimestamp{

    NSDate *datenow = [NSDate date];//????????????,???????????????????????????????????????

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];

    return timeSp;

}
@end
