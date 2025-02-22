//
//  RGGoodsAttributesGroup.h
//  RosegalGoodsAttributedHelper
//
//  Created by Bill liu on 2019/8/23.
//  Copyright © 2019 Mzying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGGoodsAttributesItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface RGGoodsAttributesGroup : NSObject

/**
 属性名称
 */
@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSArray<RGGoodsAttributesItem *> *list;

@property (nonatomic, strong, readonly) NSArray<NSString *> *attrValues;

@property (nonatomic, assign, readonly) NSUInteger defaultIndex;

@end

NS_ASSUME_NONNULL_END
