//
//  MXDrawView.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/17.
//

#import <UIKit/UIKit.h>
#import "MxPointModel.h"
#import "LocationModel.h"
NS_ASSUME_NONNULL_BEGIN
@class MXDrawView;
typedef NS_ENUM(NSInteger,DrawOpeaType) {
    AddPoint = 0,
    DeletPoint = 1
};

typedef NS_ENUM(NSInteger,PaintingMode) {
    PaintingModeThen = 0,//灵感模式
    PaintingModeCreat = 1,//创作模式
    PaintingModeAddColor
};

@protocol MxDrawViewDelegate <NSObject>

//-(void)changePoint:(CGPoint )point Color:(UIColor *)color OpeaType:(DrawOpeaType )opeaType DrawView:(MXDrawView *)drawView;
//改变某个点
-(void)changeLocation:(int)location LocationModel:(LocationModel *)locationModel DrawOpeaType:(DrawOpeaType)drawOpeaType;

//改变一组点（一个手势的结束出发）
-(void)changeLocationArray:(NSArray <LocationModel *>*)locationArray OpeaType:(DrawOpeaType)opeaType;

@end

@interface MXDrawView : UIView

@property(nonatomic,weak) id<MxDrawViewDelegate>delegate;

@property (nonatomic,assign) NSInteger Width;

@property(nonatomic,assign) BOOL isDebug;

@property(nonatomic,assign) PaintingMode patinModel;

//绘画
-(void)draw;
//清除
- (void)clear;
//撤销
-(void)undo;
//橡皮擦
-(void)earear;
//设置线的宽度
-(void)setLineWidth:(NSInteger )width;
//设置线的颜色
- (void)setLineColor:(UIColor *)color;

//-(void)updateViewWithLocation:(NSInteger)location Color:(UIColor *)color;

-(void)loadProductWithLocationArray:(NSArray *)locationArray;

-(void)setAllPointWihtColor:(UIColor *)color;

-(void)setModelType:(NSInteger )modeType;

-(void)drawPointWtithLocation:(NSInteger )location Color:(UIColor *)color Complete:(void(^)(BOOL isUpdate,int location))comPlete;
@end

NS_ASSUME_NONNULL_END
