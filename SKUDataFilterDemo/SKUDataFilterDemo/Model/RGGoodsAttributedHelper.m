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
@property (nonatomic, strong) NSArray<NSArray *> *allCombination;

/**
 所有匹配的组合
 */
@property (nonatomic, strong) NSArray *allSameGoodsList;
@property (nonatomic, strong) NSDictionary *matchingCombination;

/**
 所有属性名称
 */
@property (nonatomic, strong) NSArray *attributedNames;

/**
 缓存数据，防止重复计算
 */
@property (nonatomic, strong) NSMutableDictionary *cacheData;

@property (nonatomic, strong) NSArray <RGGoodsAttributesGroup *> *attributesList;
@property (nonatomic, strong) RGGoodsAttributesMatchedModel *matchedModel;

@end

@implementation RGGoodsAttributedHelper

#pragma mark - Life Cycle

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    
    self = [super init];
    
    if (self) {
        _cacheData = [NSMutableDictionary dictionary];
        
        _sameGoodsList = dictionary[@"same_goods_list"];
        _allSameGoodsList = dictionary[@"all_same_goods_list"];
        _allCombination = [self.class formatterToAllCombination:_sameGoodsList];
        _matchingCombination = [self.class formatterToMatchingCombination:_allSameGoodsList attributedNames:self.attributedNames];
        
        _attributesList = [NSArray yy_modelArrayWithClass:RGGoodsAttributesGroup.class json:_sameGoodsList];
        
        _matchedModel = [[RGGoodsAttributesMatchedModel alloc] initWithAllSameGoodList:_allSameGoodsList attributedNames:self.attributedNames];
        
        [self updateStatus];
    }
    return self;
    
}



#pragma mark - Update Status

- (void)updateStatus{
    
}



#pragma mark - Matching

- (NSArray<NSDictionary *> * _Nullable)matchingWithKey:(NSString *)key{
    
    NSMutableArray *n = [NSMutableArray array];
    
    if (self.cacheData[key] != nil) {
        return self.cacheData[key];
    }
    
    //分隔参数
    NSArray *components = [key componentsSeparatedByString:@";"];
    NSMutableArray *keyBySeparated = [NSMutableArray arrayWithArray:components];
    
    NSUInteger i,j,m;
    NSMutableArray *result = [NSMutableArray array];
    
    if (keyBySeparated.count == self.allCombination.count) {
        NSDictionary *value = self.matchingCombination[key];
        if (value != nil){
            return @[value];
        }else{
            return nil;
        }
    }
    
    //下面算法只针对属性选择数量少于所有属性的时候
    for (i = 0; i < self.allCombination.count; i++) {
        for (j = 0; j < self.allCombination[i].count && keyBySeparated.count > 0 ; j++) {
            if ([self.allCombination[i][j] isEqualToString:keyBySeparated.firstObject]) {
                break;
            }
        }
        
        if (j < self.allCombination[i].count && keyBySeparated.count > 0) {
            [n addObject:keyBySeparated.firstObject];
            [keyBySeparated removeObjectAtIndex:0];
        }else{
            for (m = 0; m < self.allCombination[i].count; m ++) {
                NSMutableArray *tempMArray = [NSMutableArray arrayWithArray:[n copy]];
                [tempMArray addObject:self.allCombination[i][m]];
                [tempMArray addObjectsFromArray:keyBySeparated];
                NSString *_key = [[tempMArray copy] componentsJoinedByString:@";"];
                
                id _result = [self matchingWithKey:_key];
                
                if (_result != nil) {
                    [result addObject:_result];
                }
            }
            break;
        }
    }
    
    self.cacheData[key] = [result copy];
    return [result copy];
    
}



#pragma mark - Formatter

+ (NSArray<NSArray *> *)formatterToAllCombination:(NSArray *)sameGoodsList{
    NSMutableArray *tempMArray= [NSMutableArray array];
    
    [sameGoodsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *list = ((NSDictionary *)obj)[@"list"];
        //TODO:allKeys需要排序
        [tempMArray addObject:list.allKeys];
    }];
    
    return [tempMArray copy];
}


+ (NSDictionary *)formatterToMatchingCombination:(NSArray *)allSameGoodsList attributedNames:(NSArray *)attributedNames{
    
    NSMutableDictionary *tempMDictionary = [NSMutableDictionary dictionary];
    //遍历所有可以匹配的数据
    [allSameGoodsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *item = (NSDictionary *)obj;
        
        //抽离 Key
        NSMutableString *tempMString = [NSMutableString string];
        
        [attributedNames enumerateObjectsUsingBlock:^(id  _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *attributedName = (NSString *)name;
            NSString *value = item[attributedName];
            
            if (value != nil) {
                if (tempMString.length > 0) {
                    [tempMString appendString:@";"];
                }
                [tempMString appendString:value];
            }
        }];
        
        //重新组装数据
        NSString *key = [tempMString copy];
        NSDictionary *value = item;
        
        tempMDictionary[key] = value;
    }];
    
    return [tempMDictionary copy];
}



#pragma mark - Property Method

- (NSArray *)attributedNames{
    
    if (!_attributedNames) {
        NSMutableArray *tempMArray = [NSMutableArray array];
        
        [self.sameGoodsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dic = (NSDictionary *)obj;
            [tempMArray addObject:dic[@"nameEn"]];
        }];
        
        _attributedNames = [tempMArray copy];
    }
    return _attributedNames;
    
}



@end
