//
//  MxMessageManager.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/7/7.
//

#import <Foundation/Foundation.h>
#import "LocationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MxMessageManager : NSObject


+(void)setMeshNetWorkIsConnect:(BOOL)isConnect;

+(void)addLocationModel:(LocationModel *)model;


+(void)sendMessageWithLocalModel:(LocationModel *)locationModel;

//调试使用的接口
+(void)sendDebugMessageWithLocalModel:(LocationModel *)locationModel;

+(void)sendDrawAllLightMessagezWithColro:(UIColor *)color Complete:(void(^)(LocationModel *locationModel))complete;

+(void)cleanLightWithLocalModel:(LocationModel *)locationModel;

//一键投屏
+(void)showScreen;

//一键清屏
+(void)cleanScreen;

+(NSInteger)getWaitSendMessageCount;


+(void)sendGroupMessage:(NSString*)hsvColor;

+(void)cleanAllMessage;

+(void)newAddLocationModel:(LocationModel *)model;

+(void)inOrderDrawAllLightWithColro:(UIColor *)color Complete:(void(^)(NSInteger location,BOOL isNext))callBack;


+(void)setDrawType:(NSInteger)drawType;//0:普通模式（预制色），1：实时绘画模式

@end

NS_ASSUME_NONNULL_END
