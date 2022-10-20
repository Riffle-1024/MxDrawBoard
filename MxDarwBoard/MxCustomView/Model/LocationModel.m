//
//  LocationColor.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/3/1.
//

#import "LocationModel.h"
#import "UIColor+Turn.h"

@implementation LocationModel

-(instancetype)initWithLocation:(int)location Color:(UIColor *)color IsOpen:(BOOL)isOpen{
    
    
    
    if (self = [super init]) {
        self.location = location;
        self.hexColor = [UIColor hexStringFromColor:color];
        self.hsvColor = [UIColor hsvStringFromColor:color];
        self.isOpen = isOpen;
    }
    return self;
}

@end
