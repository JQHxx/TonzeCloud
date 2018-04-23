//
//  TJYFoodLibraryVC.m
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYFoodLibraryVC.h"
#import "TJYFoodMenuView.h"
#import "TJYFoodLibraryCell.h"
#import "TJYSearchFoodVC.h"
#import "TJYFoodDetailsVC.h"
#import "TJYFoodClassificationView.h"
#import "TJYFoodClassModel.h"
#import "TJYOrderbyView.h"
#import "UIButton+Extension.h"
#import "TonzeHelpTool.h"
#import "NutritionScaleViewController.h"

@interface TJYFoodLibraryVC()<TJYFoodMenuViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSInteger    _foodPage;/// 食物页数
    NSInteger       _index;/// 标识滑动的按钮位置
    NSInteger     _selectIndex;/// 所对应的页面
    BOOL _isShowFoodClassView;/// 记录是否显示了功效选择视图
    NSInteger effectArrayIndex;/// 功效选择
    UIButton *_orderbyBtn; /// 排序选择按钮
    UIButton *_sortBtn;// 高低排序按钮、
    NSString *_sortStr;// 排序字段
    BOOL _isSort;
    NSArray *_orderbyArray;
    NSInteger _orderbyIndex;
    NSArray *_orderbyStrArray;// 筛选字段
    NSInteger _effectId; /// 功效id
}
/// 滑动列表
@property (nonatomic ,strong) TJYFoodMenuView *foodMenuView;

@property (nonatomic ,strong) UITableView *foodTableView;
/// 食物分类 -- 标题
@property (nonatomic ,copy) NSMutableArray *titleArray;
/// 食物标识id
@property (nonatomic ,copy) NSMutableArray *foodIdArray;
/// 食物分类
@property (nonatomic ,strong) NSMutableArray *toolArray;
/// 食物功效选择视图
@property (nonatomic ,strong) TJYFoodClassificationView *foodClassView;
/// 功效数组数据（动态）
@property (nonatomic ,strong) NSMutableArray *effectArray;
/// 功效数据id
@property (nonatomic ,strong) NSMutableArray *effectIdArray;
/// 筛选
@property (nonatomic ,strong) TJYOrderbyView *orderbyView;
/// 无数据页面
@property (nonatomic ,strong) BlankView    *blankView;

@end

@implementation TJYFoodLibraryVC

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    self.isHiddenNavBar = YES;
    _foodPage = 1;
    _selectIndex = 0;
    _orderbyIndex = 0;
    _isSort = YES;
    _sortStr = @"asc";
    _isShowFoodClassView = NO;
    _orderbyArray = @[@"默认排序",@"热量",@"碳水化合物",@"脂肪",@"蛋白质",@"膳食纤维",@"维生素A",@"维生素C",@"维生素E",@"胆固醇"];
    _orderbyStrArray = @[@"id",@"energykcal",@"carbohydrate",@"fat",@"protein",@"insolublefiber",@"totalvitamin",@"vitaminC",@"vitaminE",@"cholesterol"];
    [self.foodIdArray addObject:@""];
    [self.titleArray addObject:@"全部"];
    
    [self setNavigation];
    [self setFoodLibraryUI];
    [self requestFoodLibaryData];
    [self changeMenuItem];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-02-01" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-02-01" type:2];
#endif
}

#pragma mark -- Navigation

- (void)setNavigation{
    UIView *navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    navigationView.backgroundColor  = kSystemColor;
    [self.view addSubview:navigationView];
    
    UIButton *backBtn = InsertButtonWithType(navigationView, CGRectMake(5, 22, 40, 40), 1000, self, @selector(leftButtonAction), UIButtonTypeCustom);
    [backBtn setImage:[UIImage drawImageWithName:@"back.png" size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
    
    UIButton *setBtn =  InsertButtonWithType(navigationView, CGRectMake(kScreenWidth - 40, 22 , 35, 40), 1000, self, @selector(rightButClick:), UIButtonTypeCustom);
    [setBtn setImage:[UIImage imageNamed:@"ic_top_screening"] forState:UIControlStateNormal];
    
    UIButton *serarchBtn = InsertButtonWithType(navigationView, CGRectMake(kScreenWidth - 70, 22 , 35, 40), 1001, self, @selector(rightButClick:), UIButtonTypeCustom);
    [serarchBtn setImage:[UIImage imageNamed:@"ic_top_search"] forState:UIControlStateNormal];
    
    UILabel * lblTitle = InsertLabel(navigationView, CGRectMake((SCREEN_WIDTH-150)/2, 20, 150, 44), NSTextAlignmentCenter, @"食物库", kFontSize(18), [UIColor whiteColor], NO);
    if (self.isFromNutritionScale) {
        lblTitle.text = self.strTitle;
    }
    /**
     *  隐藏排序
     */
    if (self.isFromNutritionScale) {
        setBtn.hidden = YES;
        serarchBtn.frame = CGRectMake(kScreenWidth - 40, 22 , 35, 40);
    }
}
#pragma mark -- Build UI
- (void)setFoodLibraryUI{
    [self.view addSubview:self.foodTableView];
    
    if (self.isFromNutritionScale) {
        self.foodTableView.frame = CGRectMake(self.foodTableView.left, self.foodTableView.top - 40, self.foodTableView.width, self.foodTableView.height + 40);
        return;
    }
    
    UIView *hearderView = [[UIView alloc]initWithFrame:CGRectMake(0, 64 + 49, kScreenWidth, 40)];
    hearderView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:hearderView];
    
    _orderbyBtn = InsertButtonWithType(hearderView, CGRectMake(15, 0, 130, 40), 1000, self, @selector(orderbyClidk:), UIButtonTypeCustom);
    [_orderbyBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
    _orderbyBtn.titleLabel.font = kFontSize(15);
    [_orderbyBtn setImage:[UIImage imageNamed:@"ic_pub_arrow_org"] forState:UIControlStateNormal];
    [_orderbyBtn setTitle:@"默认排序" forState:UIControlStateNormal];
    _orderbyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft; 
    [_orderbyBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:10];
    
    _sortBtn = InsertButtonWithType(hearderView, CGRectMake(kScreenWidth - 80, 0 , 50, 40), 1001, self, @selector(orderbyClidk:), UIButtonTypeCustom);
    _sortBtn.hidden = YES;
    [_sortBtn setTitle:@"低--高" forState:UIControlStateNormal];
    [_sortBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
    _sortBtn.titleLabel.font = kFontSize(15);
    /// 线条
    InsertView(hearderView, CGRectMake(0,hearderView.height - 0.5, kScreenWidth, 0.5), kLineColor);
}


#pragma mark -- Request data
- (void)requestFoodLibaryData{
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kFoodCategory body:nil success:^(id json) {
        NSDictionary *dic = [json objectForKey:@"result"];
        NSArray *ingredientcatArr = [dic objectForKey:@"ingredientcat"];
        if (ingredientcatArr.count > 0  && kIsArray(ingredientcatArr)) {
            for (NSDictionary  *dics  in ingredientcatArr) {
                TJYFoodClassModel *foodClass = [[TJYFoodClassModel alloc] init];
                [foodClass setValues:dics];
                [weakSelf.titleArray addObject:foodClass.name];
                [weakSelf.foodIdArray addObject:@(foodClass.id)];
            }
            [weakSelf.view addSubview:weakSelf.foodMenuView];
            weakSelf.foodMenuView.foodMenusArray = weakSelf.titleArray;//食物分类标题赋值
            [weakSelf requestfoodDetail:0];
        }
        /* 功效数据 */
        NSArray *effectArr = [dic objectForKey:@"effect"];
        if (effectArr.count > 0 && kIsArray(effectArr)) {
            for (NSDictionary *effectDic in effectArr) {
                TJYFoodClassModel *effectModel = [TJYFoodClassModel new];
                [effectModel setValues:effectDic];
                [weakSelf.effectArray addObject:effectModel.name];
                [weakSelf.effectIdArray addObject:@(effectModel.id)];
            }
        }
        [_foodTableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
/* 食物分类列表数据 */
- (void)requestfoodDetail:(NSInteger)index{
    NSString *urlStr;
    if (index == 0 && _orderbyIndex == 0) {
       urlStr =[NSString stringWithFormat:@"page_num=%ld&page_size=20&effect_id=%ld&orderby=%@",(long)_foodPage,(long)_effectId,_orderbyStr];
    }else{
       urlStr = [NSString stringWithFormat:@"page_num=%ld&page_size=20&cat_id=%@&sort=%@&orderby=%@&effect_id=%ld",(long)_foodPage,_foodIdArray[index],_sortStr,_orderbyStr,(long)_effectId];
    }
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postMethodWithURL:kFoodList body:urlStr success:^(id json) {
        NSArray *foodListArr = [json objectForKey:@"result"];
        NSDictionary *pagerDic = [json objectForKey:@"pager"];
        
        if (kIsDictionary(pagerDic)) {
            NSInteger totalNumber = [[pagerDic objectForKey:@"total"] integerValue];
            weakSelf.foodTableView.mj_footer.hidden=(totalNumber-_foodPage*20)<=0;
        }else{
            [weakSelf.toolArray removeAllObjects];
            [weakSelf.foodTableView reloadData];
            weakSelf.blankView.hidden = foodListArr.count > 0;
        }
        
        if (foodListArr.count > 0 && kIsArray(foodListArr)) {
            NSMutableArray *foodmutArray = [[NSMutableArray alloc]init];
            for (NSDictionary *foodDic in foodListArr) {
                TJYFoodListModel *listModel = [TJYFoodListModel new];
                [listModel setValues:foodDic];
                [foodmutArray addObject:listModel];
            }
            if (_foodPage == 1) {
                [weakSelf.toolArray removeAllObjects];
                weakSelf.toolArray = foodmutArray;
                weakSelf.blankView.hidden = foodListArr.count > 0;
            }else{
                [weakSelf.toolArray addObjectsFromArray:foodmutArray];
            }
        }else{
             weakSelf.foodTableView.mj_footer.hidden=YES;
            [weakSelf.foodTableView reloadData];
            weakSelf.blankView.hidden = foodListArr.count > 0;
        }
        [weakSelf.foodTableView reloadData];
        [weakSelf.foodTableView.mj_header endRefreshing];
        [weakSelf.foodTableView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.foodTableView.mj_header endRefreshing];
        [weakSelf.foodTableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark  TJYMenuViewDelegate
-(void)foodMenuView:(TJYFoodMenuView *)menuView actionWithIndex:(NSInteger)index{
#if !DEBUG
    NSString *targetId=[NSString stringWithFormat:@"004-02-02-%@",_foodIdArray[index]];
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:targetId];
#endif
    
    _selectIndex = index;
    _foodPage = 1;
    _selectIndex = index;
    [self requestfoodDetail:_selectIndex];
    /* 滑动分类让tableview滑动到顶部 */
    [self.foodTableView setContentOffset:CGPointMake(0,0) animated:NO];
}
#pragma mark -- UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.toolArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"foodcell";
    TJYFoodLibraryCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TJYFoodLibraryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.isFromNutritionScale = self.isFromNutritionScale;
    [cell initWithFoodListModel:self.toolArray[indexPath.row]orderbyStr:_orderbyStr];
    cell.selectionStyle = UITableViewCellAccessoryNone;
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    TJYFoodListModel *listModel  = _toolArray[indexPath.row];

    /**
     *  选择食物后返回
     */
    if (self.isFromNutritionScale) {
        if (self.selectBlock) {
            [self.navigationController popViewControllerAnimated:YES];
            self.selectBlock(listModel);
        }
        return;
    }
    
    TJYFoodDetailsVC *foodDetailsVC = [TJYFoodDetailsVC  new];
    foodDetailsVC.food_id = listModel.id;
#if !DEBUG
    NSString *targetId=[NSString stringWithFormat:@"004-02-04-%ld",(long)listModel.id];
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:targetId];
#endif
    
    [self push:foodDetailsVC];
}
#pragma mark -- rightBtn Action

- (void)rightButClick:(UIButton *)btn{
    switch (btn.tag) {
        case 1000:
        {
            if (!_isShowFoodClassView) {
                 [self.orderbyView removeFromSuperview];
                 [self.view addSubview:self.foodClassView];
            }else{
                kSelfWeak;
                [UIView animateWithDuration:0.5 animations:^{
                    [weakSelf.foodClassView removeFromSuperview];
                } completion:^(BOOL finished) {
                }];
            }
            _isShowFoodClassView =!_isShowFoodClassView;
        }break;
        case 1001:
        {// 跳转到搜索
            if (_isShowFoodClassView) {
                [self.foodClassView removeFromSuperview];
                [self.orderbyView removeFromSuperview];
                _isShowFoodClassView = !_isShowFoodClassView;
            }
            [TonzeHelpTool sharedTonzeHelpTool].searchType=FoodSearchType;
            TJYSearchFoodVC *search = [TJYSearchFoodVC new];
            search.searchType = FoodSearchType;
            if (self.isFromNutritionScale) {
                __weak typeof(self) weakSelf = self;
                search.searchType = FoodSelectSearchType;
                search.selectBlock = ^(TJYFoodListModel * model){
                    [weakSelf foodSelectSearch:model];
                };
            }
            [self push:search];
        }break;
        default:
            break;
    }
}

/**
 * 返回搜索到的食物
 */

-(void)foodSelectSearch:(TJYFoodListModel *)model
{
    if (self.selectBlock) {
        UIViewController * toVC = nil;
        for (UIViewController * controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[NutritionScaleViewController class]]) {
                toVC = controller;
                break;
            }
        }
        if (toVC) {
            [self.navigationController popToViewController:toVC animated:YES];
        }
        self.selectBlock(model);
    }
}


// -- 高低筛选
- (void)orderbyClidk:(UIButton *)sender{
    switch (sender.tag - 1000) {
        case 0:
        {
            [self.view addSubview:self.orderbyView];
            self.orderbyView.index = _orderbyIndex;
        }break;
         case 1:
        {
            if (_isSort) {
                [_sortBtn setTitle:@"高--低" forState:UIControlStateNormal];
                _sortStr = @"desc";
                _foodPage = 1;
                [self requestfoodDetail:_selectIndex];
            }else{
                _foodPage = 1;
                [_sortBtn setTitle:@"低--高" forState:UIControlStateNormal];
                _sortStr = @"asc";
                [self requestfoodDetail:_selectIndex];
            }
            _isSort = !_isSort;
        }break;
        default:
            break;
    }
}
#pragma mark -- 滑动按钮

-(void)changeMenuItem{
    UIButton *btn;
    for (UIView  *view in _foodMenuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_index+101)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [_foodMenuView changeFoodViewWithButton:btn];
}

#pragma mark -- Event Response

-(void)swipArticleTableView:(UISwipeGestureRecognizer *)gesture{
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
        {
            _selectIndex++;
            if (_selectIndex>_titleArray.count-1) {
                _selectIndex=_titleArray.count;
                return;
            }
        }break;
        case UISwipeGestureRecognizerDirectionRight:
        {
            _selectIndex--;
            if (_selectIndex<0) {
                _selectIndex=0;
                return;
            }
        }break;
        default:
            break;
    }
    
    UIButton *btn;
    for (UIView  *view in _foodMenuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_selectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [_foodMenuView changeFoodViewWithButton:btn];
}
#pragma mark 加载最新食材
-(void)loadNewFoodData{
    _foodPage=1;
    // 加载数据
    [self requestfoodDetail:_selectIndex];
}

#pragma mark 加载更多食材
-(void)loadMoreFoodData{
    _foodPage++;
    // 加载数据
    [self requestfoodDetail:_selectIndex];
}

#pragma mark -- getter --
/* 分类菜单 */
-(TJYFoodMenuView *)foodMenuView{
    if (_foodMenuView==nil) {
        _foodMenuView=[[TJYFoodMenuView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 49)];
        _foodMenuView.backgroundColor = [UIColor whiteColor];
        _foodMenuView.delegate = self;
    }
    return _foodMenuView;
}
- (UITableView *)foodTableView{
    if (!_foodTableView) {
        _foodTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,64 + 49 + 40, kScreenWidth, kScreenHeight - 64 - 49 -40) style:UITableViewStylePlain];
        _foodTableView.delegate = self;
        _foodTableView.dataSource = self;
        _foodTableView.tableFooterView = [UIView new];
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_foodTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_foodTableView addGestureRecognizer:swipGestureRight];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewFoodData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _foodTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreFoodData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _foodTableView.mj_footer = footer;
        footer.hidden = YES;
        [_foodTableView addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return _foodTableView;
}
/// 功效筛选
- (TJYFoodClassificationView *)foodClassView{
    if (!_foodClassView) {
        kSelfWeak;
        _foodClassView = [[TJYFoodClassificationView alloc]initWithFrame:CGRectMake(0 ,64 , kScreenWidth, kBodyHeight)effectArray:_effectArray btnSelectBlock:^(NSInteger index) {
            MyLog(@"----%ld",index);
            _foodPage = 1;
            if (index != 0) {
                _effectId = [weakSelf.effectIdArray[index-1] integerValue];
            }else{
                _effectId = 0;
            }
            [weakSelf requestfoodDetail:_selectIndex];
            [weakSelf.foodClassView removeFromSuperview];
        }];
    }
    return _foodClassView;
}
/// 排序筛选
-(TJYOrderbyView *)orderbyView
{
    if (!_orderbyView) {
        kSelfWeak;
        _orderbyView = [[TJYOrderbyView alloc]initWithFrame:CGRectMake(0, 153, kScreenWidth, kScreenHeight - 153) orderbyArray:_orderbyArray  orderbySelectBlock:^(NSInteger index) {
            [_orderbyBtn setTitle:_orderbyArray[index] forState:UIControlStateNormal];
            MyLog(@"-------%ld",index);
            _orderbyIndex = index;
            _foodPage = 1;
            _orderbyStr = _orderbyStrArray[index];
            [weakSelf requestfoodDetail:_selectIndex];
            [weakSelf.orderbyView removeFromSuperview];
            if (index==0) {
                _sortBtn.hidden =YES;
            } else {
                _sortBtn.hidden =NO;
            }
        }];
    }
    return _orderbyView;
}
- (BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc]initWithFrame:CGRectMake(0,0 , kScreenWidth, kScreenHeight - 64 + 49 + 40) img:@"img_tips_no" text:@"暂无相关食物"];
        _blankView.hidden = YES;
    }
    return _blankView;
}
- (NSMutableArray *)toolArray{
    if (!_toolArray) {
        _toolArray = [NSMutableArray array];
    }
    return _toolArray;
}
- (NSMutableArray *)titleArray{
    if (!_titleArray) {
        _titleArray = [NSMutableArray array];
    }
    return _titleArray;
}
-(NSMutableArray *)foodIdArray{
    if (!_foodIdArray) {
        _foodIdArray = [NSMutableArray array];
    }
    return _foodIdArray;
}
- (NSMutableArray *)effectIdArray{
    if (!_effectIdArray) {
        _effectIdArray = [NSMutableArray array];
    }
    return _effectIdArray;
}
- (NSMutableArray *)effectArray{
    if (!_effectArray) {
        _effectArray = [NSMutableArray array];
    }
    return _effectArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
