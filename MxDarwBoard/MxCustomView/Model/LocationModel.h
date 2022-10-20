//
//  LocationColor.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/3/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationModel : NSObject

@property(nonatomic,copy)NSString *hexColor;//颜色，16进制

@property(nonatomic,copy)NSString *hsvColor;//颜色，16进制

@property(nonatomic,assign)int location;//当前点的位置号

@property(nonatomic,assign)BOOL isOpen;//灯是否打卡



-(instancetype)initWithLocation:(int)location Color:(UIColor *)color IsOpen:(BOOL)isOpen;



@end

NS_ASSUME_NONNULL_END
