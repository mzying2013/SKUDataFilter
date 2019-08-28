//
//  RGGoodsAttributesItem.h
//  RosegalGoodsAttributedHelper
//
//  Created by Bill liu on 2019/8/23.
//  Copyright © 2019 Mzying. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 属性的状态

 - RGGoodsAttributesItemSelected: 选中
 - RGGoodsAttributesItemUnSelected: 未选中
 - RGGoodsAttributesItemUnmatched: 未匹配
 */
typedef NS_ENUM(NSUInteger, RGGoodsAttributesItemStatus){
    RGGoodsAttributesItemSelected = 0,
    RGGoodsAttributesItemUnselected,
    RGGoodsAttributesItemUnmatched
};


@interface RGGoodsAttributesItem : NSObject


/**
 属性值
 */
@property (nonatomic, strong) NSString *attr_value;

/**
 是否选中
 */
@property (nonatomic, assign) BOOL selected;

/**
 是否未匹配
 */
@property (nonatomic, assign) BOOL unmatched;


/**
 根据 selected 和 unmatched 结果返回状态
 */
@property (nonatomic, assign, readonly) RGGoodsAttributesItemStatus status;

/**
 缩略图
 */
@property (nonatomic, strong) NSString *goods_thumb;

/**
 尺码提示
 */
@property (nonatomic, strong) NSString *data_tips;


@end

NS_ASSUME_NONNULL_END
