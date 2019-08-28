//
//  RGGoodsAttributesGroup.m
//  RosegalGoodsAttributedHelper
//
//  Created by Bill liu on 2019/8/23.
//  Copyright © 2019 Mzying. All rights reserved.
//

#import "RGGoodsAttributesGroup.h"

@implementation RGGoodsAttributesGroup


#pragma mark - YYModel

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass{
    return @{@"list":[RGGoodsAttributesItem class]};
}

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic{
    
    NSString *listKey = @"list";
    NSDictionary *list = dic[listKey];
    NSMutableArray *tempMList = [NSMutableArray array];
    
    //TODO:如果是 Size 则需要排序
    [list.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempMList addObject:list[obj]];
    }];
    
    NSMutableDictionary *tempMDictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    tempMDictionary[listKey] = [tempMList copy];
    
    return [tempMDictionary copy];
}


#pragma mark - Property Method

- (NSArray<NSString *> *)attrValues{
    NSMutableArray *tempMArray = [NSMutableArray array];
    
    [self.list enumerateObjectsUsingBlock:^(RGGoodsAttributesItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempMArray addObject:obj.attr_value];
    }];
    
    return [tempMArray copy];
}


@end
