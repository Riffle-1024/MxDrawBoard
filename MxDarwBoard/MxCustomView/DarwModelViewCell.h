//
//  DarwModelViewCell.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DarwModelViewCell : UICollectionViewCell

@property(nonatomic,copy)NSString *titleString;

@property(nonatomic,strong)UIButton * deleteBtn;


-(void)isSelected:(BOOL)isSelect;

-(void)refleshView;

//-(void)updateViewWithLocationArray:(NSArray *)locationArray;

-(void)updateViewWithLocationData:(NSDictionary *)locationData;

@end

NS_ASSUME_NONNULL_END
