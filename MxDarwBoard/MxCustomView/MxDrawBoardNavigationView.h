//
//  MxDrawBoardNavigationView.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/23.
//

#import <UIKit/UIKit.h>

@protocol MxDrawBoardNavigationViewDelegate <NSObject>

-(void)colorSeletFinish:(UIColor *_Nullable)color;

-(void)selectPhotoBtnClick;

-(void)didSelectLocation:(NSArray *_Nullable)locationArray;

-(void)shareImage;

-(void)changeModelWithType:(NSInteger)modelType;



@end

NS_ASSUME_NONNULL_BEGIN

@interface MxDrawBoardNavigationView : UIView

@property(nonatomic,strong) UIViewController *viewController;

@property(nonatomic,copy) NSArray *colorArray;

@property(nonatomic,weak) id<MxDrawBoardNavigationViewDelegate>delegate;

-(void)isShowPhotoBtn:(BOOL)isShow;

-(void)updateNavigatonMeshConnectStatus:(NSInteger)connectStatus;

@end

NS_ASSUME_NONNULL_END
