//
//  TJYFoodNutritionVC.m
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYFoodNutritionVC.h"
#import "TJYFoodNutritionCell.h"

@interface TJYFoodNutritionVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
/// 元素类型
@property (nonatomic, copy) NSArray *titleArray;
/// 质量
@property (nonatomic, copy) NSMutableArray *qualityArry;
/// 能量数据
@property (nonatomic ,strong) NSMutableArray *parameterArray;

@end

@implementation TJYFoodNutritionVC

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.baseTitle = @"营养成分详情";
  
    [self buildUI];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-02-08" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-02-08" type:2];
#endif
}

#pragma mark -- request Data

- (void)loadData{
    
    _parameterArray = [NSMutableArray array];
    
    _titleArray=@[@"热量",@"碳水化合物",@"脂肪",@"蛋白质",@"膳食纤维",@"维生素A",@"维生素B1",@"维生素B2",@"维生素B3",@"维生素C",@"维生素E",@"胡萝卜素",@"胆固醇",@"钠",@"钙",@"铁",@"钾",@"锌",@"镁",@"铜",@"锰",@"磷",@"碘",@"硒"];
    [_parameterArray addObject:[NSString stringWithFormat:@"%ld千卡/100克",(long)_foodDetailsModel.energykcal]];
    [_parameterArray addObject:[self string:_foodDetailsModel.carbohydrate unit:@"克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.fat unit:@"克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.protein unit:@"克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.insolublefiber unit:@"克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.totalvitamin unit:@"微克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.thiamine unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.riboflavin unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.magnesium unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.vitaminC unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.vitaminE unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.carotene unit:@"微克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.cholesterol unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.sodium unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.calcium unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.iron unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.potassium unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.zinc unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.magnesium unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.copper unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.manganese unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.phosphorus unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.iodine unit:@"毫克"]];
    [_parameterArray addObject:[self string:_foodDetailsModel.selenium unit:@"微克"]];
}
#pragma mark -- Build UI

- (void)buildUI{
    [self.view addSubview:self.tableView];
}
#pragma tableHeaderView (头部视图)
- (UIView *)tableHeaderView{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    headerView.backgroundColor = kBackgroundColor;
    
    InsertLabel(headerView, CGRectMake(15, 10, kScreenWidth, 20), NSTextAlignmentLeft, @"营养成分(每100克)", kFontSize(14), UIColorHex(0x999999), NO);
    return headerView;
}

#pragma mark -- UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _parameterArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identiifer = @"cell";
    TJYFoodNutritionCell *cell = [tableView dequeueReusableCellWithIdentifier:identiifer];
    if (!cell) {
        cell = [[TJYFoodNutritionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identiifer];
    }
    cell.ingredientNameLab.text = _titleArray[indexPath.row];
    cell.parameterLab.text = _parameterArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark -- 拼接字符串
- (NSString *)string:(NSInteger)intvalue unit:(NSString *)unit{
    NSString *string = [[NSString alloc] init];
    string = intvalue==0?[NSString stringWithFormat:@"--%@",unit]:[NSString stringWithFormat:@"%ld%@",(long)intvalue,unit];
    return string;
}

#pragma mark -- Getter --

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [self tableHeaderView];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
