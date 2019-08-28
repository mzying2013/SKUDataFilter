//
//  ViewController.m
//  SKUDataFilterDemo
//
//  Created by OrangesAL on 2017/12/4.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import "ViewController.h"
#import "ORSKUDataFilter.h"
#import "RGGoodsAttributedHelper.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,ORSKUDataFilterDataSource>

@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (weak, nonatomic) IBOutlet UILabel *storeL;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *skuData;;
@property (nonatomic, strong) NSMutableArray <NSIndexPath *>*selectedIndexPaths;;

@property (nonatomic, strong) ORSKUDataFilter *filter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Test 测试 API
    NSMutableSet *set1 = [NSMutableSet setWithObjects:@"a",@"b",nil];
    NSSet *set2 = [NSSet setWithObjects:@"1",@"2",@"b",nil];
    [set1 intersectsSet:set2];
    [set1 intersectSet:set2];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"goods" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSArray *sameGoodsList = JSON[@"same_goods_list"];
    NSArray *allSameGoodsList = JSON[@"all_same_goods_list"];
    
    
    NSArray *dataSource = @[@{@"name" : @"款式",
                              @"value" : @[@"male", @"famale"]},
                            @{@"name" : @"颜色",
                              @"value" : @[@"red", @"green", @"blue"]},
                            @{@"name" : @"尺寸",
                              @"value" : @[@"XXL", @"XL", @"L", @"S", @"M"]},
                            @{@"name" : @"test",
                              @"value" : @[@"A", @"B", @"C"]},];
    _dataSource = dataSource;
    
    _selectedIndexPaths = [NSMutableArray array];
    
    _skuData = @[
                 @{@"contition":@"male,red,XL,A",
                   @"price":@"1120",
                   @"store":@"167"},
                 @{@"contition":@"male,red,M,B",
                   @"price":@"1200",
                   @"store":@"289"},
                 @{@"contition":@"male,green,L,A",
                   @"price":@"889",
                   @"store":@"300"},
                 @{@"contition":@"male,green,M,B",
                   @"price":@"991",
                   @"store":@"178"},
                 @{@"contition":@"famale,red,XL,A",
                   @"price":@"1000",
                   @"store":@"200"},
                 @{@"contition":@"famale,blue,L,B",
                   @"price":@"880",
                   @"store":@"12"},
                 @{@"contition":@"famale,blue,XXL,C",
                   @"price":@"1210",
                   @"store":@"300"},
                 @{@"contition":@"male,blue,L,C",
                   @"price":@"888",
                   @"store":@"121"},
                 @{@"contition":@"famale,green,M,C",
                   @"price":@"1288",
                   @"store":@"125"},
                 @{@"contition":@"male,blue,L,A",
                   @"price":@"1210",
                   @"store":@"123"}
                 ];
    
    
    RGGoodsAttributedHelper *helper = [[RGGoodsAttributedHelper alloc] initWithSameGoodsList:sameGoodsList allSameGoodsList:allSameGoodsList];
    _dataSource = helper.attributesModel.list;
    _skuData = helper.matchedModel.list;
    
    
    _filter = [[ORSKUDataFilter alloc] initWithDataSource:self];
    
    //当数据更新的时候 需要reloadData
//    [_filter reloadData];
//    [self.collectionView reloadData];
    
    
    //默认选中
    _filter.needDefaultValue = YES;
    [self.collectionView reloadData]; //更新UI显示
    [self action_complete:nil];       //更新结果查询

    
}

#pragma mark -- collectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    RGGoodsAttributesGroup *group = (RGGoodsAttributesGroup *)_dataSource[section];
    return group.list.count;
    
//    return [_dataSource[section][@"value"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        
    PropertyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PropertyCell" forIndexPath:indexPath];
    
    RGGoodsAttributesGroup *group = (RGGoodsAttributesGroup *)_dataSource[indexPath.section];
//    NSArray *data = _dataSource[indexPath.section][@"value"];
    NSArray<RGGoodsAttributesItem *> * data = group.list;
//    cell.propertyL.text = data[indexPath.row];
    cell.propertyL.text = data[indexPath.row].attr_value;
    
    if ([_filter.availableIndexPathsSet containsObject:indexPath]) {
        [cell setTintStyleColor:[UIColor blackColor]];
    }else {
        [cell setTintStyleColor:[UIColor lightGrayColor]];
    }
    
    if ([_filter.selectedIndexPaths containsObject:indexPath]) {
        [cell setTintStyleColor:[UIColor redColor]];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        PropertyHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerIdf" forIndexPath:indexPath];
        
        RGGoodsAttributesGroup *group = (RGGoodsAttributesGroup *)_dataSource[indexPath.section];
        NSString *name = group.name;
        
//        view.headernameL.text = _dataSource[indexPath.section][@"name"];
        view.headernameL.text = name;
        return view;

    }else {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footerIdf" forIndexPath:indexPath];
        
        return view;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [_filter didSelectedPropertyWithIndexPath:indexPath];
    
    [collectionView reloadData];
    [self action_complete:nil];
}

#pragma mark -- ORSKUDataFilterDataSource

- (NSInteger)numberOfSectionsForPropertiesInFilter:(ORSKUDataFilter *)filter {
    return _dataSource.count;
}

- (NSArray *)filter:(ORSKUDataFilter *)filter propertiesInSection:(NSInteger)section {
//    return _dataSource[section][@"value"];
    RGGoodsAttributesGroup *group = (RGGoodsAttributesGroup *)_dataSource[section];
    return group.attrValues;
}

- (NSInteger)numberOfConditionsInFilter:(ORSKUDataFilter *)filter {
    return _skuData.count;
}

- (NSArray *)filter:(ORSKUDataFilter *)filter conditionForRow:(NSInteger)row {
//    NSString *condition = _skuData[row][@"contition"];
//    return [condition componentsSeparatedByString:@","];
    
    NSArray<RGGoodsAttributesMatchedItemModel *> *list = _skuData;
    RGGoodsAttributesMatchedItemModel *model = list[row];
    return model.contitions;
}

- (id)filter:(ORSKUDataFilter *)filter resultOfConditionForRow:(NSInteger)row {
    
    NSArray<RGGoodsAttributesMatchedItemModel *> *list = _skuData;
    return list[row];
    
//    NSDictionary *dic = _skuData[row];
//    return @{@"price": dic[@"price"],
//             @"store": dic[@"store"]};
}

#pragma mark -- action
- (IBAction)action_complete:(id)sender {
    
//    NSLog(@"%@", _filter.currentAvailableResutls);

//    NSDictionary *dic = _filter.currentResult;
//
//    if (dic == nil) {
//        NSLog(@"请选择完整 属性");
//        _priceL.text = @"￥0";
//        _storeL.text = @"库存0件";
//        return;
//    }
    
    id result = _filter.currentResult;
    
    if (result == nil) {
        NSLog(@"请选择完整 属性");
        return;
    }
    
    _priceL.text = ((RGGoodsAttributesMatchedItemModel *)result).goods_id;
//    _storeL.text = [NSString stringWithFormat:@"库存%@件",dic[@"store"]];
    
}



@end


@implementation PropertyCell

- (void)setTintStyleColor:(UIColor *)color {
    self.layer.borderColor = color.CGColor;
    self.propertyL.textColor = color;
}

@end

@implementation PropertyHeader

@end
