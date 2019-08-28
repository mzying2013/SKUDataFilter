//
//  RGGoodsAttributesModel.h
//  SKUDataFilterDemo
//
//  Created by Bill liu on 2019/8/28.
//  Copyright © 2019 OrangesAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGGoodsAttributesGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface RGGoodsAttributesModel : NSObject

- (instancetype)initWithSameGoodList:(NSArray *)sameGoodList;

@property (nonatomic, strong, readonly) NSArray <RGGoodsAttributesGroup *> *list;
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *defaultIndexPaths;

@end

NS_ASSUME_NONNULL_END
