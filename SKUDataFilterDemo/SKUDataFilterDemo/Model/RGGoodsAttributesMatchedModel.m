//
//  RGGoodsAttributesMatchedModel.m
//  SKUDataFilterDemo
//
//  Created by Bill liu on 2019/8/27.
//  Copyright © 2019 OrangesAL. All rights reserved.
//

#import "RGGoodsAttributesMatchedModel.h"
#import <YYModel/YYModel.h>


static NSString *const kAttributesSeparator = @";";


@implementation RGGoodsAttributesMatchedItemModel

- (NSArray *)contitions{
    return [self.contition componentsSeparatedByString:kAttributesSeparator];
}

@end



@interface RGGoodsAttributesMatchedModel ()

@property (nonatomic, strong) NSArray *allSameGoodList;
@property (nonatomic, strong) NSArray *attributedNames;

@end


@implementation RGGoodsAttributesMatchedModel

- (instancetype)initWithAllSameGoodList:(NSArray *)allSameGoodList attributedNames:(NSArray *)attributedNames{
    
    self = [super init];
    
    if (self) {
        _allSameGoodList = allSameGoodList;
        _attributedNames = attributedNames;
        
        NSArray *formatterData = [self.class formatterToMatchingCombination:_allSameGoodList attributedNames:_attributedNames];
        
        self.list = [NSArray yy_modelArrayWithClass:RGGoodsAttributesMatchedItemModel.class json:formatterData];
    }
    return self;
    
}


+ (NSArray *)formatterToMatchingCombination:(NSArray *)allSameGoodsList attributedNames:(NSArray *)attributedNames{
    
    NSMutableArray *tempMArray = [NSMutableArray array];
    //遍历所有可以匹配的数据
    [allSameGoodsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *item = (NSDictionary *)obj;
        
        //抽离 Key
        NSMutableDictionary *tempMDictionary = [NSMutableDictionary dictionary];
        NSMutableString *tempMString = [NSMutableString string];
        
        [attributedNames enumerateObjectsUsingBlock:^(id  _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *attributedName = (NSString *)name;
            NSString *value = item[attributedName];
            
            if (value != nil) {
                if (tempMString.length > 0) {
                    [tempMString appendString:kAttributesSeparator];
                }
                [tempMString appendString:value];
            }
            
            //重新组装数据
            tempMDictionary[@"contition"] = [tempMString copy];
            tempMDictionary[@"goods_id"] = item[@"goods_id"];
        }];
        
        [tempMArray addObject:[tempMDictionary copy]];
    }];
    
    return [tempMArray copy];
}




@end
