//
//  RGGoodsAttributesItem.m
//  RosegalGoodsAttributedHelper
//
//  Created by Bill liu on 2019/8/23.
//  Copyright © 2019 Mzying. All rights reserved.
//

#import "RGGoodsAttributesItem.h"

@implementation RGGoodsAttributesItem

#pragma mark - Property Method

- (RGGoodsAttributesItemStatus)status{
    
    if (self.selected) {
        return RGGoodsAttributesItemSelected;
    }else{
        if (self.unmatched) {
            return RGGoodsAttributesItemUnmatched;
        }else{
            return RGGoodsAttributesItemUnselected;
        }
    }
}


@end
