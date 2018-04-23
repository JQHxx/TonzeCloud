//
//  TJYRecommendedDietVC.m
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYRecommendedDietVC.h"
#import "TJYPushRecipesCell.h"
#import "TJYFoodDistributionCell.h"
#import "TJYMealPagodaVC.h"
#import "TJYFoodRecommendModel.h"
#import "TJYPieChartView.h"
#import "TJYRecommentDateView.h"
#import "TJYFoodDetailsVC.h"
#import "TJYMenuDetailsVC.h"

@interface TJYRecommendedDietVC ()<UITableViewDataSource,UITableViewDelegate>
{
    UILabel *_timeLabel;     /// 用餐时间
    UILabel *_energyLabel;   /// 能量
    UILabel *_totalLable;    /// 总计能量
    UIButton *_selectedBtn;  // 选择按钮
    BOOL _isTodayClick;      /// 记录是否点击今天
    BOOL _isShowEat;        /// 是否显示吃了
    NSInteger _total_calorie;    /// 总能量
    NSInteger _oil;             /// 油脂
    NSInteger _milk;             /// 牛奶能量（用户加餐）
    NSInteger _morningTotalCalorie;  /// 早餐总能量
    NSInteger _lunchTotalCalorie;
    NSInteger _dinnerTotalCalorie;
    NSInteger _snackfTotalCalorie;
    NSArray *_sectionTitleArr;
    NSArray *_timeSlotArray;
}
@property (nonatomic, strong) UITableView *tableView;
/// 推荐食疗数据源
@property (nonatomic ,strong) NSMutableArray *recommendDataSouce;
/// 7天日期
@property (nonatomic ,strong) NSMutableArray * dateDaysArr;
/// 图形数据
@property (nonatomic ,strong) NSMutableDictionary *chartViewDic;
/// 图形视图
@property (nonatomic ,strong) TJYPieChartView *chartView;
///
@property (nonatomic ,strong) NSMutableArray *recommendArray;
///
@property (nonatomic ,strong) TJYRecommentDateView *dateView;
@end

@implementation TJYRecommendedDietVC

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"食疗推荐";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    _sectionTitleArr= @[@"早餐",@"午餐",@"晚餐",@"加餐"];
    _timeSlotArray = @[@"breakfast",@"lunch",@"dinner",@"supper"];
    _isShowEat = YES;
    
    [self recommendDietSetUI];
    [self recommendRequestData];
}
#pragma mark -- request Data

- (void)recommendRequestData{
    _morningTotalCalorie = 0;
    _lunchTotalCalorie = 0;
    _dinnerTotalCalorie = 0;
    _snackfTotalCalorie = 0;
    _total_calorie = 0;
    _milk = 0;
    _oil = 0;
    [self.recommendArray removeAllObjects];
    [self.recommendDataSouce removeAllObjects];
    
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] getMethodWithURL:KRecommendMenu isLoading:YES success:^(id json) {
        _total_calorie = [[json objectForKey:@"total_calorie"] integerValue];
        _oil = [[json objectForKey:@"oil"] integerValue];
        _milk = [[json objectForKey:@"milk"] integerValue];
        
        NSDictionary *resultDic = [json objectForKey:@"result"];
        if (kIsDictionary(resultDic)) {
            [weakSelf loadrecommendDietDic:resultDic];
        }
        // 总能量
        _totalLable.text = [NSString stringWithFormat:@"总计%ld千卡",_total_calorie];
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- load recommend_diet  Data

- (void)loadrecommendDietDic:(NSDictionary *)recommendDietDic{
    //  早上
    NSArray *morningArr = [recommendDietDic objectForKey:@"breakfast"];
    if (morningArr.count > 0 && kIsArray(morningArr)) {
        NSMutableArray *morningData = [NSMutableArray array];
        for (NSDictionary *dic in morningArr) {
            TJYFoodRecommendModel *recommendModel = [TJYFoodRecommendModel new];
            [recommendModel  setValues:dic];
            _morningTotalCalorie +=recommendModel.energykcal;// 早餐总能量
            [morningData  addObject:recommendModel];
        }
        [self.recommendDataSouce addObject:morningData];
    }else{
        if (kIsArray(morningArr)) {
        [self.recommendDataSouce addObject:morningArr];
        }
    }
    //  中午
    NSArray *lunchArr = [recommendDietDic objectForKey:@"lunch"];
    if (lunchArr.count > 0 && kIsArray(lunchArr)) {
        NSMutableArray *lunchData = [NSMutableArray array];
        for (NSDictionary *dic in lunchArr) {
            TJYFoodRecommendModel *recommendModel = [TJYFoodRecommendModel new];
            [recommendModel  setValues:dic];
            _lunchTotalCalorie += recommendModel.energykcal;
            [lunchData  addObject:recommendModel];
        }
        [self.recommendDataSouce addObject:lunchData];
    }else{
        if (kIsArray(lunchArr)) {
        [self.recommendDataSouce addObject:lunchArr];
        }
    }
    //  晚饭
    NSArray *dinnerArr = [recommendDietDic objectForKey:@"dinner"];
    if (dinnerArr.count > 0 && kIsArray(dinnerArr)) {
        NSMutableArray *dinnerData = [NSMutableArray array];
        for (NSDictionary *dic in dinnerArr) {
            TJYFoodRecommendModel *recommendModel = [TJYFoodRecommendModel new];
            [recommendModel  setValues:dic];
            _dinnerTotalCalorie += recommendModel.energykcal;
            [dinnerData  addObject:recommendModel];
        }
        [self.recommendDataSouce addObject:dinnerData];
    }else{
        if (kIsArray(dinnerArr)) {
        [self.recommendDataSouce addObject:dinnerArr];
        }
    }
    //  加餐
    NSArray *snackArr = [recommendDietDic objectForKey:@"supper"];
    if (snackArr.count > 0 && kIsArray(snackArr)) {
        NSMutableArray *snackData = [NSMutableArray array];
        for (NSDictionary *dic in snackArr) {
            TJYFoodRecommendModel *recommendModel = [TJYFoodRecommendModel new];
            [recommendModel  setValues:dic];
            _snackfTotalCalorie += recommendModel.energykcal;
            [snackData  addObject:recommendModel];
        }
        [self.recommendDataSouce addObject:snackData];
    }else{
        if (kIsArray(snackArr)) {
        [self.recommendDataSouce addObject:snackArr];
        }
    }
    
    NSInteger totalAdd = _morningTotalCalorie +_lunchTotalCalorie + _dinnerTotalCalorie + _snackfTotalCalorie;
    // 每一餐的所占比:  （每一餐的总能量 + 油脂量 ）/ 总能量 2050 * 100  注：晚餐的"油脂“为”牛奶“含量
    double moringRandomValue =(double)_morningTotalCalorie/totalAdd * 100;
    NSString *morningDataStr = [NSString stringWithFormat:@"%.0f%%",moringRandomValue];
    double lunchRandomValue = (double)_lunchTotalCalorie/totalAdd * 100;
    NSString *lunchDataStr = [NSString stringWithFormat:@"%.0f%%",lunchRandomValue];
    double dinnerRandomValue =(double)_dinnerTotalCalorie/totalAdd * 100;
    NSString *dinnerDataStr = [NSString stringWithFormat:@"%.0f%%",dinnerRandomValue];
    double snackfRandomValue =(double)_snackfTotalCalorie/totalAdd *100;
    NSString *snackDataStr = [NSString stringWithFormat:@"%.0f%%",snackfRandomValue];
    
    [self.chartViewDic setObject:morningDataStr forKey:@"breakfast"];
    [self.chartViewDic setObject:lunchDataStr forKey:@"lunch"];
    [self.chartViewDic setObject:dinnerDataStr forKey:@"dinner"];
    [self.chartViewDic setObject:snackDataStr forKey:@"supper"];
    self.chartView.chartDataDic = self.chartViewDic;  /// 饼型图赋值
    [_tableView reloadData];
}
#pragma mark 刷新推荐的食疗

-(void)loadNewFoodData{
    [self recommendRequestData];
}
#pragma mark -- Build UI

- (void)recommendDietSetUI{
    [self.view addSubview:self.dateView];
    [self.view addSubview:self.tableView];
}
#pragma mark -- tableHearderView

- (UIView *)tableHearderView{
    UIView *hearderView =InsertView(nil, CGRectMake(0, 0, kScreenWidth, 236), [UIColor whiteColor]);
    /// 饼型图比例图
    [hearderView addSubview:self.chartView];
    
    InsertLabel(hearderView, CGRectMake(15, 10, 100, 15), NSTextAlignmentLeft, @"配餐比", kFontSize(16), UIColorHex(0x313131), NO);
    UIButton *pagodaBtn = InsertButtonWithType(hearderView, CGRectMake(kScreenWidth - 100, 10, 80, 25), 1000, self, @selector(pagodaBtnClick), UIButtonTypeCustom);
    [pagodaBtn setTitle:@"膳食宝塔" forState:UIControlStateNormal];
    pagodaBtn.titleLabel.font = kFontSize(14);
    pagodaBtn.layer.borderWidth = 0.5;
    pagodaBtn.layer.borderColor = kSystemColor.CGColor;
    pagodaBtn.layer.cornerRadius = 13;
    [pagodaBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
    
    /* 颜色标识说明 */
    NSArray *timeArray = @[@"早餐",@"午餐",@"晚餐",@"加餐"];
    NSArray *colorArray = @[@"FCD03F",@"FE6C6E",@"FF9E36",@"1CDEB1"];
    for (NSInteger i = 0; i < 4; i++) {
        UIView *colorlView = [[UIView alloc]initWithFrame:CGRectMake( i * 42 + 15, hearderView.height - 28 - 36, 15, 10)];
        colorlView.backgroundColor = [UIColor colorWithHexString:colorArray[i]];
        colorlView.layer.cornerRadius = 5;
        [hearderView addSubview:colorlView];
        
        UILabel *timeLable = [[UILabel alloc]initWithFrame:CGRectMake(i * 42 + 32, hearderView.height - 30 - 36, 30, 15)];
        timeLable.text = timeArray[i];
        timeLable.font = kFontSize(10);
        timeLable.textColor = UIColorHex(0x939393);
        [hearderView addSubview:timeLable];
    }
    /* 总计能量 */
    _totalLable = InsertLabel(hearderView, CGRectMake(kScreenWidth - 165, hearderView.height - 33 - 36, 150, 20), NSTextAlignmentRight, @"总计--千卡", kFontSize(15),kSystemColor , NO);
    /*提示文本*/
    UIView *tipTextView = InsertView(hearderView, CGRectMake(0, hearderView.height - 36, kScreenWidth, 36), UIColorHex(0xfefcec));
    InsertLabel(tipTextView, CGRectMake(0, 0, kScreenWidth, 36), NSTextAlignmentCenter, @"建议全天食用油不超过25克(225千卡)", kFontSize(13), UIColorHex(0xfd832b), NO);
    
    return hearderView;
}
#pragma mark -- Action
- (void)pagodaBtnClick{
    TJYMealPagodaVC *mealPagodaVC = [TJYMealPagodaVC new];
    mealPagodaVC.total_calorie = _total_calorie;
    [self push:mealPagodaVC];
}
// -- 记录饮食
- (void)eatbtnClick:(UIButton *)sender{
    if (kIsLogined) {
        NSString *timeSlotStr = nil;
        NSString *body = nil;
        
        NSMutableArray *tempArr =[NSMutableArray array];
        timeSlotStr = _timeSlotArray[sender.tag - 1000];
        for (TJYFoodRecommendModel *model  in _recommendDataSouce[sender.tag-1000]) {
            NSDictionary *dict=[[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:model.food_id],model.weight,[NSNumber numberWithInteger:model.energykcal],[NSNumber numberWithInteger:model.type]] forKeys:@[@"item_id",@"item_weight",@"item_calories",@"type"]];
            [tempArr addObject:dict];
        }
        
        NSString *todayDataStr =[[TJYHelper sharedTJYHelper]getCurrentDate];
        NSInteger timeSp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:todayDataStr format:@"yyyy-MM-dd"];
        NSString *jsonStr= [[NetworkTool sharedNetworkTool]getValueWithParams:tempArr];
        
        body=[NSString stringWithFormat:@"doSubmit=1&time_slot=%@&feeding_time=%ld&item=%@",timeSlotStr,(long)timeSp,jsonStr];
        
        kSelfWeak;
        [[NetworkTool sharedNetworkTool] postMethodWithURL:kDietRecordAdd body:body success:^(id json) {
            NSInteger status = [[json objectForKey:@"status"] integerValue];
            if (status == 1) {
                [weakSelf.view makeToast:@"已成功添加饮食记录" duration:1.0 position:CSToastPositionCenter];
                [TJYHelper sharedTJYHelper].isRecordDietReload = YES;
            }
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }else{
        [self pushToFastLogin];
    }
}
/// 日期按钮点击
-(void)dateBtnClick:(NSInteger )sender{
    if (sender == 3) {
        _isShowEat = YES;
        [self recommendRequestData];
    }else{
        _isShowEat = NO;
        [self recommendRequestData];
    }
    [_tableView reloadData];
}
#pragma mark -- UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _recommendDataSouce.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    self.recommendArray =self.recommendDataSouce[section];
    return self.recommendArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 58;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_isShowEat) {
        return 40;
    }else{
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSMutableArray *totlaArray = [NSMutableArray array];
    [totlaArray addObject:@(_morningTotalCalorie)];
    [totlaArray addObject:@(_lunchTotalCalorie)];
    [totlaArray addObject:@(_dinnerTotalCalorie)];
    [totlaArray addObject:@(_snackfTotalCalorie)];
    
    UIView *headerSectionView =InsertView(nil, CGRectMake(0, 0, kScreenWidth, 40), kBackgroundColor);
    UIView *sectionTitleView =InsertView(headerSectionView, CGRectMake(0, 10, kScreenWidth, 30), [UIColor whiteColor]);
    _timeLabel = InsertLabel(sectionTitleView, CGRectMake(15, 10/2 ,150 , 20), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x333333), NO);
    _energyLabel= InsertLabel(sectionTitleView, CGRectMake(kScreenWidth - 165, 15/2 ,150 , 15), NSTextAlignmentRight, @"", kFontSize(15), UIColorHex(0x959595), NO);
    _timeLabel.text = _sectionTitleArr[section];

    NSString *energykcalStr = [NSString stringWithFormat:@"%@千卡",totlaArray[section]];
    NSAttributedString *energyAtttext = [NSString ql_changeRangeText:energykcalStr noRangeInedex:2 changeColor:kSystemColor];
    _energyLabel.attributedText = energyAtttext;

    InsertView(headerSectionView, CGRectMake(15, 40 - 0.5, kScreenWidth - 15, 0.5), kLineColor);
    return headerSectionView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_isShowEat) {
        UIView *footerSectionView = InsertView(nil, CGRectMake(0, 0, kScreenWidth, 40), [UIColor whiteColor]);
        UIButton * eatBtn= InsertButtonWithType(footerSectionView, CGRectMake(20, 0, kScreenWidth - 40, 40), 1001, self, @selector(eatbtnClick:), UIButtonTypeCustom);
        eatBtn.tag = 1000 + section;
        [eatBtn setTitle:@"我吃了" forState:UIControlStateNormal];
        [eatBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
        eatBtn.titleLabel.font = kFontSize(15);
        
        return footerSectionView;
    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *foodDistributionIdentifier = @"pushRecipesCell";
    
    TJYFoodDistributionCell *foodDistributioncell = [tableView dequeueReusableCellWithIdentifier:foodDistributionIdentifier];
    if (!foodDistributioncell) {
        foodDistributioncell = [[TJYFoodDistributionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:foodDistributionIdentifier];
    }
    self.recommendArray =_recommendDataSouce[indexPath.section];
    [foodDistributioncell cellInitWithData:self.recommendArray[indexPath.row]];
    
    foodDistributioncell.selectionStyle = UITableViewCellSelectionStyleNone;
    return foodDistributioncell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.recommendArray = _recommendDataSouce[indexPath.section];
    TJYFoodRecommendModel *recommendModel = self.recommendArray[indexPath.row];
    switch (recommendModel.type) {
        case 1:
        {
            TJYFoodDetailsVC *foodDetailsVC = [TJYFoodDetailsVC new];
            foodDetailsVC.food_id = recommendModel.food_id;
            [self push:foodDetailsVC];
        }break;
         case 2:
        {
            TJYMenuDetailsVC *menuDetailsVC = [TJYMenuDetailsVC new];
            menuDetailsVC.menuid = recommendModel.food_id;
            [self push:menuDetailsVC];
        }break;
        default:
            break;
    }
}

#pragma mark -- Getter --

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 80 + 64, kScreenWidth, kBodyHeight - 80) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [self tableHearderView];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewFoodData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _tableView.mj_header=header;
    }
    return  _tableView;
}
- (TJYPieChartView *)chartView{
    if (!_chartView) {
        _chartView = [[TJYPieChartView alloc]initWithFrame:CGRectMake(0, 15, kScreenWidth, 160)];
    }
    return _chartView;
}
- (TJYRecommentDateView *)dateView{
    if (!_dateView) {
        _dateView =[[TJYRecommentDateView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, 60)];
        kSelfWeak;
        _dateView.dateBtnClickBlock = ^(NSInteger tag){
            [weakSelf dateBtnClick:tag];
        };
    }
    return _dateView;
}
- (NSMutableDictionary *)chartViewDic{
    if (!_chartViewDic) {
        _chartViewDic = [NSMutableDictionary dictionary];
    }
    return _chartViewDic;
}

- (NSMutableArray *)recommendDataSouce{
    if (!_recommendDataSouce) {
        _recommendDataSouce = [NSMutableArray array];
    }
    return _recommendDataSouce;
}
- (NSMutableArray *)recommendArray{
    if (!_recommendArray) {
        _recommendArray = [NSMutableArray array];
    }
    return _recommendArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
