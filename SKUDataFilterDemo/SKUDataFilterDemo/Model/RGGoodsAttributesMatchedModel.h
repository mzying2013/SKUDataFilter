//
//  RGGoodsAttributesMatchedModel.h
//  SKUDataFilterDemo
//
//  Created by Bill liu on 2019/8/27.
//  Copyright © 2019 OrangesAL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface RGGoodsAttributesMatchedItemModel : NSObject

@property (nonatomic, strong) NSString *contition;
@property (nonatomic, strong, readonly) NSArray *contitions;

@property (nonatomic, strong) NSString *goods_id;

@end



@interface RGGoodsAttributesMatchedModel : NSObject

- (instancetype)initWithAllSameGoodList:(NSArray *)allSameGoodList attributedNames:(NSArray *)attributedNames;

@property (nonatomic, strong) NSArray<RGGoodsAttributesMatchedItemModel *> *list;

@end

NS_ASSUME_NONNULL_END
