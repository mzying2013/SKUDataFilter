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

NS_ASSUME_NONNULL_BEGIN

@interface RGGoodsAttributedHelper : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSArray<NSDictionary *> * _Nullable)matchingWithKey:(NSString *)key;

@property (nonatomic, strong, readonly) NSArray <RGGoodsAttributesGroup *> *attributesList;
@property (nonatomic, strong, readonly) RGGoodsAttributesMatchedModel *matchedModel;

@end

NS_ASSUME_NONNULL_END
