//
//  MxPointModel.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MxPointModel : NSObject


@property(nonatomic,strong)NSMutableArray <UIColor *>*colorArray;//该点的颜色记录

@property(nonatomic,assign)int index;//当前是第几个颜色

@property(nonatomic,assign)int location;//当前点的位置号


@end

NS_ASSUME_NONNULL_END
