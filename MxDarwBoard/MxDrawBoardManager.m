//
//  MxDrawBoardManager.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/17.
//

#import "MxDrawBoardManager.h"

#define SaveLightInfoKey @"SaveLightInfoKey"

#define NeedAddGroupKey @"NeedAddGroupKey"

@interface MxDrawBoardManager()

@property(nonatomic,strong)UIColor *recodColor;

@end

@implementation MxDrawBoardManager

+(instancetype)shareInstance{
    static MxDrawBoardManager *instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[MxDrawBoardManager alloc] init];
    }) ;
    return instance;
    
}

+(void)saveRecordColor:(UIColor *)color{
    [MxDrawBoardManager shareInstance].recodColor = color;
}

+(UIColor *)getRecordColor{
    return [MxDrawBoardManager shareInstance].recodColor;
}


-(NSMutableArray *)pointXList{
    if (!_pointXList) {
        _pointXList = [NSMutableArray array];
    }
    return _pointXList;;
}

-(NSMutableArray *)pointYList{
    if (!_pointYList) {
        _pointYList = [NSMutableArray array];
    }
    return _pointYList;;
}

-(NSMutableArray *)pointList{
    if (!_pointList) {
        _pointList = [NSMutableArray array];
    }
    return _pointList;;
}

-(NSMutableDictionary *)lightLocationInfo{
    if (!_lightLocationInfo) {
        _lightLocationInfo = [NSMutableDictionary dictionary];
    }
    return _lightLocationInfo;
}

-(NSMutableDictionary *)needAddGroup{
    if (!_needAddGroup) {
        _needAddGroup = [NSMutableDictionary dictionary];
    }
    return _needAddGroup;
}

+(void)needAddGroupWithValue:(NSString *)value Key:(NSString *)key{
    NSDictionary *needAddGroupData = [[NSUserDefaults standardUserDefaults] objectForKey:NeedAddGroupKey];
    NSMutableDictionary * newDic = [NSMutableDictionary dictionaryWithDictionary:needAddGroupData];
    [newDic setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:NeedAddGroupKey];
}



+(NSDictionary *)getNeedAddGroupData{
    NSDictionary *needAddGroupData = [[NSUserDefaults standardUserDefaults] objectForKey:NeedAddGroupKey];
    return needAddGroupData;
}

+(void)deleteNeedAddGroupDaraWithKey:(NSString *)key{
    NSDictionary *needAddGroupData = [[NSUserDefaults standardUserDefaults] objectForKey:NeedAddGroupKey];
    NSMutableDictionary * newDic = [NSMutableDictionary dictionaryWithDictionary:needAddGroupData];
    [newDic removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:NeedAddGroupKey];
}
-(NSInteger)addPoint:(CGPoint )point ColorString:(NSString *)clorString LineWidth:(NSInteger )lineWidth{
    NSInteger location = [self getLocationFromPoint:point LineWidth:lineWidth];
      DLog(@"location:%ld",location);
    return location;
}


+(void)saveLightInfoWithInfo:(NSDictionary *)info Location:(int)location{
    NSString * key = [NSString stringWithFormat:@"%d",location];
    NSDictionary *lightLocationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:SaveLightInfoKey];
    NSMutableDictionary * newDic = [NSMutableDictionary dictionaryWithDictionary:lightLocationInfo];
    [newDic setObject:info forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:SaveLightInfoKey];
}
+(NSString *)getDeviceUUIDWithLocation:(int)location{
    NSString * key = [NSString stringWithFormat:@"%d",location];
    NSDictionary *lightLocationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:SaveLightInfoKey];
    NSDictionary *info = [lightLocationInfo objectForKey:key];
    return [info objectForKey:@"uuid"];;
}

+(NSString *)getMacAdressWithLocation:(int)location{
    NSString * key = [NSString stringWithFormat:@"%d",location];
    NSDictionary *lightLocationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:SaveLightInfoKey];
    NSDictionary *info = [lightLocationInfo objectForKey:key];
    return [info objectForKey:@"mac"];;
}



+(NSDictionary *)getLightInfoWithLocaiton:(int)location{
    NSString * key = [NSString stringWithFormat:@"%d",location + 1];//+1是纠正灯的实际位置
    return [[MxDrawBoardManager shareInstance].lightLocationInfo objectForKey:key];
}

+(NSDictionary *)getAllBindLightInfo{
    NSDictionary *lightLocationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:SaveLightInfoKey];
    return lightLocationInfo;
}

-(void)deletPoint:(CGPoint )point LineWidth:(NSInteger )lineWidth{
    
}



//通过point找到对应的灯的位置点，如果位置点大于400，或者小于0，说明不存在灯，无需做任何处理
-(NSInteger)getLocationFromPoint:(CGPoint )point LineWidth:(NSInteger )lineWidth{
    NSInteger pointX = round(point.x);
    NSInteger pointY = round(point.y);
//    if (lineWidth == 0) {
//        if (pointX >=0 && pointX <= FIT_TO_IPAD_VER_VALUE(570)) {
//            if (pointY >= 0 && pointY <= FIT_TO_IPAD_VER_VALUE(570)) {
//                if (pointX %30 == 0 || pointX == 0) {
//                    if (pointY %30 == 0 || pointY == 0) {
//                        return [self getLocationWithPointX:pointX pointY:pointY];
//                    }
//                }
//            }
//        }
//        return 1000;
//    }

    if (pointX + lineWidth/2 < 0 || pointX - lineWidth/2 > FIT_TO_IPAD_VER_VALUE(600)) {
        return 1000;
    }
    if (pointY + lineWidth/2 < 0 || pointY - lineWidth/2 > FIT_TO_IPAD_VER_VALUE(600)) {
        return 1000;
    }
    NSMutableArray *lineArray = [NSMutableArray arrayWithArray:@[@(0)]];
    for (int i = 0; i < lineWidth/2 ; i++) {
        NSInteger line = i - lineWidth/2;
        [lineArray addObject:@(line)];
    }
    for (int i = 0; i < lineWidth/2; i++) {
        [lineArray addObject:@(i)];
    }
    NSInteger newPointX = 0;
    NSInteger newPointY = 0;
    BOOL getNewPointSuccess = NO;
    for (int i = 0; i < lineArray.count; i++) {
        getNewPointSuccess = NO;
        NSInteger line = [[lineArray objectAtIndex:i] integerValue];
        newPointX = pointX + line;
        if (newPointX == 0 || newPointX %15 ==0) {//符合条件的X轴坐标，开始筛选Y轴坐标
            for (int j = 0; j < lineArray.count; j++) {
                NSInteger line = [[lineArray objectAtIndex:j] integerValue];
                newPointY = pointY + line;
                if (newPointY == 0 || newPointY %15 == 0) {//符合条件Y轴坐标，此时可以结束循环
                    getNewPointSuccess = YES;
                    break;
                }
            }
        }
        if (getNewPointSuccess) {
            break;
        }
    }
    if (getNewPointSuccess) {
       NSInteger location  = [self getLocationWithPointX:newPointX pointY:newPointY];
          DLog(@"*****************location is %ld",location);
        return location;
    }else{
        return 1000;
    }
    
}


-(NSInteger)getLocationWithPointX:(NSInteger )pointX pointY:(NSInteger)pointY{
    NSInteger i = (pointY - 15) / 30;
    NSInteger j = (pointX - 15) / 30;
    return i * 20 + j;
}


-(void)getAllPoint{
    if (DrawBoardType == 0) {
        for (int i = 0; i < 400; i++) {
            NSInteger pointX = 15 + i % 20 * 30 + 3;
            NSInteger pointY = 15 + i/20 * 30 + 3;
            CGPoint point = CGPointMake(pointX, pointY);
            [[MxDrawBoardManager shareInstance].pointList addObject:NSStringFromCGPoint(point)];
        }
    }else if (DrawBoardType == 1){
        for (int i = 0; i < 200; i++) {
            NSInteger pointX = 15 + i % 20 * 30 + 3;
            NSInteger pointY = 15 + i/20 * 30 + 3;
            CGPoint point = CGPointMake(pointX, pointY);
            [[MxDrawBoardManager shareInstance].pointList addObject:NSStringFromCGPoint(point)];
        }
    }

      DLog(@"pointList:%@",[MxDrawBoardManager shareInstance].pointList);
}
@end
