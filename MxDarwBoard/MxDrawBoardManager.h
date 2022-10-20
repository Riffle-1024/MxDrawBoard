//
//  MxDrawBoardManager.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MxDrawBoardManager : NSObject

@property(nonatomic,copy) NSMutableArray *pointXList;//x轴坐标集合

@property(nonatomic,copy) NSMutableArray *pointYList;//y轴坐标集合

@property(nonatomic,copy) NSMutableArray *pointList;//灯位置集合（400个）

@property(nonatomic,copy) NSMutableDictionary *lightLocationInfo;//每个位置的灯信息，灯的位置为1~400对应实际位置0~399

@property(nonatomic,copy) NSMutableDictionary *needAddGroup;//需要加入组的灯


+(instancetype)shareInstance;

-(NSInteger )addPoint:(CGPoint )point ColorString:(NSString *)clorString LineWidth:(NSInteger )lineWidth;
+(void)needAddGroupWithValue:(NSString *)value Key:(NSString *)key;

+(NSDictionary *)getNeedAddGroupData;

+(void)deleteNeedAddGroupDaraWithKey:(NSString *)key;

+(void)saveLightInfoWithInfo:(NSDictionary *)info Location:(int)location;

+(NSString *)getDeviceUUIDWithLocation:(int)location;

+(NSString *)getMacAdressWithLocation:(int)location;

+(NSDictionary *)getLightInfoWithLocaiton:(int)location;

+(NSDictionary *)getAllBindLightInfo;




-(void)getAllPoint;
@end

NS_ASSUME_NONNULL_END
