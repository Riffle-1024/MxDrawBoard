//
//  MxPointModel.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/17.
//

#import "MxPointModel.h"

@implementation MxPointModel

-(NSMutableArray *)colorArray{
    if (!_colorArray) {
        _colorArray = [NSMutableArray array];
    }
    return _colorArray;
}

@end
