//
//  RGGoodsAttributedHelper.m
//  RosegalGoodsAttributedHelper
//
//  Created by Bill liu on 2019/8/26.
//  Copyright © 2019 Mzying. All rights reserved.
//

#import "RGGoodsAttributedHelper.h"
#import <YYModel/YYModel.h>

@interface RGGoodsAttributedHelper ()

/**
 所有的可能组合
 */
@property (nonatomic, strong) NSArray *sameGoodsList;
/**
 所有匹配的组合
 */
@property (nonatomic, strong) NSArray *allSameGoodsList;
/**
 所有属性名称
 */
@property (nonatomic, strong) NSArray *attributedNames;

@end

@implementation RGGoodsAttributedHelper

#pragma mark - Life Cycle

- (instancetype)initWithSameGoodsList:(NSArray *)sameGoodList allSameGoodsList:(NSArray *)allSameGoodsList{
    
    self = [super init];
    
    if (self) {
        _sameGoodsList = sameGoodList;
        _allSameGoodsList = allSameGoodsList;
        
        _attributesModel = [[RGGoodsAttributesModel alloc] initWithSameGoodList:_sameGoodsList];
        _matchedModel = [[RGGoodsAttributesMatchedModel alloc] initWithAllSameGoodList:_allSameGoodsList attributedNames:self.attributedNames];
    }
    return self;
}

#pragma mark - Property Method

- (NSArray *)attributedNames{
    
    if (!_attributedNames) {
        NSMutableArray *tempMArray = [NSMutableArray array];
        
        [self.sameGoodsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dic = (NSDictionary *)obj;
            [tempMArray addObject:dic[@"name"]];
        }];
        
        _attributedNames = [tempMArray copy];
    }
    return _attributedNames;
    
}



@end
