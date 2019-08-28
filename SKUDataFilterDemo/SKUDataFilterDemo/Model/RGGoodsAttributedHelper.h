//
//  RGGoodsAttributedHelper.h
//  RosegalGoodsAttributedHelper
//
//  Created by Bill liu on 2019/8/26.
//  Copyright © 2019 Mzying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGGoodsAttributesGroup.h"
#import "RGGoodsAttributesMatchedModel.h"
#import "RGGoodsAttributesModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RGGoodsAttributedHelper : NSObject

- (instancetype)initWithSameGoodsList:(NSArray *)sameGoodList allSameGoodsList:(NSArray *)allSameGoodsList;

@property (nonatomic, strong, readonly) RGGoodsAttributesModel *attributesModel;
@property (nonatomic, strong, readonly) RGGoodsAttributesMatchedModel *matchedModel;

@end

NS_ASSUME_NONNULL_END
