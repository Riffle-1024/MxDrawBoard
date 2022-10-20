//
//  MxDrawModelViewController.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import <UIKit/UIKit.h>

@protocol MxDrawModelViewControllerDelegate <NSObject>

-(void)didSelectLocationArray:(NSArray *_Nullable)locationArray;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MxDrawModelViewController : UIViewController

@property(nonatomic,assign) BOOL  isDebug;

@property(nonatomic,weak) id<MxDrawModelViewControllerDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
