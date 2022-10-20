//
//  DevelopManager.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevelopManager : UIView

@property(nonatomic,copy) NSMutableArray *modelPointList;//模版下灯位置集合（400个）


@property(nonatomic,copy) NSMutableArray *pointList;//预览模式下灯位置集合（400个）

+(instancetype)shareInstance;

+(void)saveLocationArrayWithNewArray:(NSArray *)locationArray Image:(UIImage *)image;

+(void)saveImageToCache:(UIImage *)image ImageKey:(NSString *)imageKey;

+(void)deleteLocationArrayWithIndex:(int)index;

+(void)updateAllProductData:(NSArray *)array;

+(NSArray *)getLocalProductArray;

-(BOOL)isShowDevelop;

@end

NS_ASSUME_NONNULL_END
