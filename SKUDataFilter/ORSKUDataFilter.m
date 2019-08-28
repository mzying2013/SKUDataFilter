//
//  ORSKUDataFilter.m
//  SKUFilterfilter
//
//  Created by OrangesAL on 2017/12/3.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import "ORSKUDataFilter.h"

@interface ORSKUDataFilter() {
    ORSKUCondition *_defaultSku;
}

@property (nonatomic, strong) NSSet <ORSKUCondition *> *conditions;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *selectedIndexPaths;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *availableIndexPathsSet;

//全可用的
@property (nonatomic, strong) NSSet <NSIndexPath *> *allAvailableIndexPaths;

@property (nonatomic, strong) id  currentResult;

@end

@implementation ORSKUDataFilter

- (instancetype)initWithDataSource:(id<ORSKUDataFilterDataSource>)dataSource
{
    self = [super init];
    if (self) {
        _dataSource = dataSource;
        _selectedIndexPaths = [NSMutableSet set];
        [self initPropertiesSkuListData];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _selectedIndexPaths = [NSMutableSet set];
    }
    return self;
}

- (void)reloadData {
    [_selectedIndexPaths removeAllObjects];
    _defaultSku = nil;
    [self initPropertiesSkuListData];
    [self updateCurrentResult];
}

#pragma mark -- public method
//选中某个属性
- (void)didSelectedPropertyWithIndexPath:(NSIndexPath *)indexPath {
    
    if (![_availableIndexPathsSet containsObject:indexPath]) {
        //不可选
        return;
    }
    
    if (indexPath.section > [_dataSource numberOfSectionsForPropertiesInFilter:self] || indexPath.item >= [[_dataSource filter:self propertiesInSection:indexPath.section] count]) {
        //越界
        NSLog(@"indexPath is out of range");
        return;
    }
    
    if ([_selectedIndexPaths containsObject:indexPath]) {
        //已被选
        [_selectedIndexPaths removeObject:indexPath];
        
        [self updateAvailableIndexPaths];
        [self updateCurrentResult];
        return;
    }
    
    __block NSIndexPath *lastIndexPath = nil;
    
    [_selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        if (indexPath.section == obj.section) {
            lastIndexPath = obj;
        }
    }];
    
    if (!lastIndexPath) {
        //添加新属性
        //在对属性有新操作时，只有新增属性可以基于当前可选属性集合过滤，其他情况需要重新计算
        [_selectedIndexPaths addObject:indexPath];
        //取交集
        [_availableIndexPathsSet intersectSet:[self availableIndexPathsFromSelctedIndexPath:indexPath sectedIndexPaths:_selectedIndexPaths]];
        [self updateCurrentResult];
        return;
    }
    
    if (lastIndexPath.item != indexPath.item) {
        //切换属性
        [_selectedIndexPaths addObject:indexPath];
        [_selectedIndexPaths removeObject:lastIndexPath];
        [self updateAvailableIndexPaths];
        [self updateCurrentResult];
    }
    
}


#pragma mark -- private method

//获取初始数据
- (void)initPropertiesSkuListData {
    
    NSMutableSet *modelSet = [NSMutableSet set];

    for (int i = 0; i < [_dataSource numberOfConditionsInFilter:self]; i ++) {
        
        ORSKUCondition *model = [ORSKUCondition new];
        NSArray * conditions = [_dataSource filter:self conditionForRow:i];
        
        //检查匹配值的属性数量是否等于所有属性组的数量
        if (![self checkConformToSkuConditions:conditions]) {
            NSLog(@"第 %d 个 condition 不完整 \n %@", i, conditions);
            continue;
        }
        
        model.properties = [self propertiesWithConditionRawData:conditions];
        
//        NSMutableString *tempMString = [NSMutableString string];
//        for (ORSKUProperty *p in model.properties) {
//            [tempMString appendFormat:@"%@ (%ld,%ld)",p.value,(long)p.indexPath.item,(long)p.indexPath.section];
//
//            if (tempMString.length > 0) {
//                [tempMString appendString:@";"];
//            }
//        }
//        NSLog(@"%@",[tempMString copy]);
        
        
        //匹配值的附加参数
        model.result = [_dataSource filter:self resultOfConditionForRow:i];
        
        if (self.selectedIndexPaths.count == 0 && _needDefaultValue && !_defaultSku) {
            _defaultSku = model;
        }
        
        [modelSet addObject:model];
    }
    
    //建立所有条件式的坐标系
    /*
     M (1,0);G (1,1);X (1,2);
     F (0,0);G (1,1);S (2,2);
     F (0,0);R (0,1);X (1,2);
     */
    _conditions = [modelSet copy];
    
    //获取初始可选的所有IndexPath
    //在未选中任何属性值的情况下，所有条件式里的属性都可选
    /*
     F (0,0)
     G (1,1)
     S (2,2)
     M (1,0)
     X (1,2)
     R (0,1)
     */
    [self getAllAvailableIndexPaths];
    
    if (_defaultSku) {
        [_defaultSku.properties enumerateObjectsUsingBlock:^(ORSKUProperty * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self didSelectedPropertyWithIndexPath:obj.indexPath];
        }];
    }
}

//检查数据是否正确
- (BOOL)checkConformToSkuConditions:(NSArray *)conditions {
    if (conditions.count != [_dataSource numberOfSectionsForPropertiesInFilter:self]) {
        return NO;
    }
    
    __block BOOL  flag = YES;
    [conditions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *properties = [_dataSource filter:self propertiesInSection:idx];
        if (![properties containsObject:obj]) {
            flag = NO;
            *stop = YES;
        }
    }];
    return flag;
}

//获取属性
- (NSArray<ORSKUProperty *> *)propertiesWithConditionRawData:(NSArray *)data {
    
    NSMutableArray *array = [NSMutableArray array];
    [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:[self propertyOfValue:obj inSection:idx]];
    }];
    
    return array;
}

- (ORSKUProperty *)propertyOfValue:(id)value inSection:(NSInteger)section {
    
    NSArray *properties = [_dataSource filter:self propertiesInSection:section];
    
    NSString *str = [NSString stringWithFormat:@"Properties for %ld dosen‘t exist %@", (long)section, value];
    NSAssert([properties containsObject:value], str);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[properties indexOfObject:value] inSection:section];
    
    return [[ORSKUProperty alloc] initWithValue:value indexPath:indexPath];
}


//获取初始可选的所有IndexPath
- (NSMutableSet<NSIndexPath *> *)getAllAvailableIndexPaths {

    NSMutableSet *set = [NSMutableSet set];
    [_conditions enumerateObjectsUsingBlock:^(ORSKUCondition * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.conditionIndexs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
            
//            NSUInteger count = set.count;
            
            [set addObject:[NSIndexPath indexPathForItem:obj1.integerValue inSection:idx1]];
            
//            if (count != set.count) {
//                NSString *string = obj.properties[idx1].value;
//                NSLog(@"%@ (%ld,%ld)",string,(long)obj1.integerValue,(long)idx1);
//            }
        }];
    }];
    
    _availableIndexPathsSet = set;
    
    _allAvailableIndexPaths = [set copy];
    
    return set;
}

//选中某个属性时 根据已选中的系列属性 获取可选的IndexPath
- (NSMutableSet<NSIndexPath *> *)availableIndexPathsFromSelctedIndexPath:(NSIndexPath *)selectedIndexPath sectedIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    
    NSMutableSet *set = [NSMutableSet set];
    [_conditions enumerateObjectsUsingBlock:^(ORSKUCondition * _Nonnull obj, BOOL * _Nonnull stop) {
        
        //下列判断意思为，筛选当次选中的相关的条件式
        /*
         例如，当前选择 X 的时候，则查找：
         M (1,0);G (1,1);X (1,2);
         F (0,0);R (0,1);X (1,2);
         */
        
        if ([obj.conditionIndexs objectAtIndex:selectedIndexPath.section].integerValue == selectedIndexPath.item) {
            
            [obj.properties enumerateObjectsUsingBlock:^(ORSKUProperty * _Nonnull property, NSUInteger idx2, BOOL * _Nonnull stop1) {
                
//                NSLog(@"__ %@:%ld==%ld %@",property.value,(long)property.indexPath.section,(long)selectedIndexPath.section,(property.indexPath.section == selectedIndexPath.section)?@"等于":@"不等于");
                
                //从condition中添加种类不同的属性时，需要根据已选中的属性过滤
                //过滤方式为 condition要么包含已选中 要么和已选中属性是同级
                
                /*
                 1. condition要么包含已选中：
                    X (1,2);
                 
                 2. 不包含已选中：
                    M (1,0);G (1,1);
                    F (0,0);R (0,1);
                 */
                
                if (property.indexPath.section != selectedIndexPath.section) {
                    
                    __block BOOL flag = YES;
                    
                    //indexPaths 表示所有选中的坐标
                    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj1, BOOL * _Nonnull stop) {
                        //所有选中的坐标需要满足下列条件之一
                        //1. 条件式能满足已选属性
                        //2. 条件式属性跟已选择属性是兄弟属性
                        
                        // 条件式满足已选属性
                        /*
                         已选属性 X 满足下面的条件式，所以 M, G, F, R 可选。
                         M (1,0);G (1,1);X (1,2);
                         F (0,0);R (0,1);X (1,2);
                         */
                        BOOL b1 = [obj.conditionIndexs[obj1.section] integerValue] == obj1.row;
                        
                        //条件式属性跟已选择属性是兄弟属性
                        /*
                         假如，当前选择为 X, G 的时候，且最后选中为 G，所以能匹配的条件式为：
                         F (0,0);G (1,1);S (2,2);
                         M (1,0);G (1,1);X (1,2);
                         
                         当遍历使用选中的 X 来匹配的时候，X 在它的相关条件式里面是匹配不到 S 属性的（因为一个条件式里面不可能存在兄弟属性）。但是 S 作为 X 的兄弟属性，是可选的。
                         */
                        BOOL b2 = (obj1.section == property.indexPath.section);
                        
                        flag = (b1 || b2) && flag;
                    }];
                    
                    if (flag) {
                        //所有条件式相关的
                        [set addObject:property.indexPath];
                    }
                    
                }else {
                    //添加本身
                    [set addObject:property.indexPath];
                }
            }];
        }
    }];
    
//    for (NSIndexPath *indexPath in set) {
//        NSLog(@"> (%ld,%ld)",(long)indexPath.row,(long)indexPath.section);
//    }
    
    //合并当次选中的本行数据
    /*
    假如，当前选择 X, G 的时候，查找到的可选属性为：
     M (1,0)
     X (1,2)
     S (2,2)
     G (1,1)
     */
     
    [_allAvailableIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.section == selectedIndexPath.section) {
            [set addObject:obj];
        }
    }];
    
    /*
     假如，当前选择 X, G 的时候，合并当次选中的兄弟属性后的可选属性为：
     M (1,0)
     X (1,2)
     S (2,2)
     G (1,1)
     
     R (0,1)
     */
    
//    for (NSIndexPath *indexPath in set) {
//        NSLog(@">> (%ld,%ld)",(long)indexPath.row,(long)indexPath.section);
//    }
    
    return set;
}

//当前可用的
- (void)updateAvailableIndexPaths {
    
    if (_selectedIndexPaths.count == 0) {
        
        _availableIndexPathsSet = [_allAvailableIndexPaths mutableCopy];
        return ;
    }
    
    __block NSMutableSet *set = [NSMutableSet set];
    
    NSMutableSet *seleted = [NSMutableSet setWithCapacity:_selectedIndexPaths.count];
    
    [_selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        
        [seleted addObject:obj];
        
        NSMutableSet *tempSet = nil;
        
        tempSet = [self availableIndexPathsFromSelctedIndexPath:obj sectedIndexPaths:seleted];
        
        if (set.count == 0) {
            set = [tempSet mutableCopy];
        }else {
            [set intersectSet:tempSet];
        }
        
    }];
    
    _availableIndexPathsSet = set;

    
}

// 当前结果
- (void)updateCurrentResult {
    
    if (_selectedIndexPaths.count != [_dataSource numberOfSectionsForPropertiesInFilter:self]) {
        _currentResult = nil;
        return;
    }
    [_conditions enumerateObjectsUsingBlock:^(ORSKUCondition * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.conditionIndexPaths isEqualToSet:self.selectedIndexPaths]) {
            self.currentResult = obj.result;
            *stop = YES;
        }
    }];
}

- (NSArray *)currentAvailableResutls {
    
    if (_selectedIndexPaths.count == [_dataSource numberOfSectionsForPropertiesInFilter:self]) {
        return @[_currentResult];
    }
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:_conditions.count];
    [_conditions enumerateObjectsUsingBlock:^(ORSKUCondition * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self.selectedIndexPaths isSubsetOfSet:obj.conditionIndexPaths]) {
            [results addObject:obj.result];
        }
    }];
    return results;
}

#pragma mark -- setter
- (void)setDataSource:(id<ORSKUDataFilterDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setNeedDefaultValue:(BOOL)needDefaultValue {
    
    _needDefaultValue = needDefaultValue;
    
    if (_selectedIndexPaths.count > 0 || !needDefaultValue) {
        return;
    }
    
    [self reloadData];
}

@end

@implementation ORSKUCondition

- (void)setProperties:(NSArray<ORSKUProperty *> *)properties {
    
    _properties = properties;
    NSMutableArray *conditionIndexs = [NSMutableArray arrayWithCapacity:properties.count];
    NSMutableSet *conditionIndexPaths = [NSMutableSet setWithCapacity:properties.count];
    
    [properties enumerateObjectsUsingBlock:^(ORSKUProperty * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [conditionIndexs addObject:@(obj.indexPath.item)];
        [conditionIndexPaths addObject:obj.indexPath];
    }];
    
    _conditionIndexs = conditionIndexs.copy;
    _conditionIndexPaths = conditionIndexPaths.copy;
}

@end

@implementation ORSKUProperty

- (instancetype)initWithValue:(id)value indexPath:(NSIndexPath *)indexPath
{
    self = [super init];
    if (self) {
        _value = value;
        _indexPath = indexPath;
    }
    return self;
}

@end



