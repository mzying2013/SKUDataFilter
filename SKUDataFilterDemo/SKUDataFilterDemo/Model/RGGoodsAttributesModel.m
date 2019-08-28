//
//  RGGoodsAttributesModel.m
//  SKUDataFilterDemo
//
//  Created by Bill liu on 2019/8/28.
//  Copyright © 2019 OrangesAL. All rights reserved.
//

#import "RGGoodsAttributesModel.h"
#import <YYModel/YYModel.h>

@interface RGGoodsAttributesModel ()

@property (nonatomic, strong) NSArray *sameGoodsList;

@end


@implementation RGGoodsAttributesModel

- (instancetype)initWithSameGoodList:(NSArray *)sameGoodList{
    
    self = [super init];
    
    if (self) {
        _sameGoodsList = sameGoodList;
        _list = [NSArray yy_modelArrayWithClass:RGGoodsAttributesGroup.class json:_sameGoodsList];
    }
    return self;
}


@end
