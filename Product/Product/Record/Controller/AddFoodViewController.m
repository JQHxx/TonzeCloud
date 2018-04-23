//
//  AddFoodViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddFoodViewController.h"
#import "FoodMenuView.h"
#import "AddFoodTableViewCell.h"
#import "FoodAddModel.h"
#import "FoodMenuScale.h"
#import "FoodAddTool.h"
#import "FoodSelectView.h"
#import "TJYSearchFoodVC.h"
#import "FoodClassModel.h"
#import "EstimateWeightViewController.h"
#import "TJYFoodDetailsVC.h"
#import "TJYMenuDetailsVC.h"

@interface AddFoodViewController ()<FoodMenuViewDelegate,UITableViewDelegate,UITableViewDataSource,FoodMenuScaleViewDelegate,FoodSelectViewDelegate,UISearchBarDelegate>{

    NSMutableArray *menuArray;
    NSMutableArray *foodArray;
    NSInteger      isMenuFood;
    
    NSNumber            *category_id;      //分类
    NSInteger           page;
    NSInteger           selectIndex;

    UIView              *coverView;
    NSInteger           dietCount;
    UIButton            *foodBtn;
    UILabel             *countLabel;        //已选食物数量
    
    UIButton *confirmButton;
    UILabel *line;
    NSMutableArray      *selectaddFoodArr;
}
@property (nonatomic,strong)UISegmentedControl *menuSegmented;          //菜单
@property(nonatomic,strong)UISearchBar        *mySearchBar;
@property (nonatomic,strong)FoodMenuView      *menuView;          //菜单栏
@property (nonatomic,strong)UITableView       *foodTableView;     //食物列表
@property (nonatomic,strong)FoodSelectView    *foodSelectView;    //已选食物视图
@property (nonatomic,strong)UIView            *bottomView;        //底部视图
@property (nonatomic,strong)BlankView         *foodBlankView;

@end

@implementation AddFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isMenuFood = 1;
    dietCount=0;
    page=1;
    selectIndex=0;
    selectaddFoodArr =[FoodAddTool sharedFoodAddTool].selectFoodArray;
    
    [self initAddFoodView];
    [self requestFoodMenuData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSMutableArray *selectFoodArr=[FoodAddTool sharedFoodAddTool].selectFoodArray;

    dietCount=selectFoodArr.count;
    [self reloadFoodAddView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-01-10" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-01-10" type:1];
#endif
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return foodArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdntifier=@"AddFoodTableViewCell";
    AddFoodTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdntifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"AddFoodTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    FoodAddModel *foodModel= foodArray[indexPath.row];
    [cell cellDisplayWithFood:foodModel];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-10"];
#endif
    FoodAddModel *food=foodArray[indexPath.row];
    FoodMenuScale *scaleView = nil;
    scaleView=[[FoodMenuScale alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300) model:food type:isMenuFood];
    scaleView.foodMenuScaleDelegate=self;
    [scaleView scaleViewShowInView:self.view];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark -- UISearchBarDelegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-16"];
#endif
    TJYSearchFoodVC *searchVC=[[TJYSearchFoodVC alloc] init];
    if (isMenuFood==1) {
        searchVC.searchType=FoodAddSearchType;
        searchVC.type=1;
    } else {
        searchVC.searchType=FoodAddSearchType;
        searchVC.type=2;
    }
    [self.navigationController pushViewController:searchVC animated:YES];

}
#pragma mark -- Custom Delegate
#pragma mark  ScaleViewDelegate
- (void)foodMenuScaleView:(FoodMenuScale *)scaleView didSelectFood:(FoodAddModel *)food{
    if ([food.isSelected boolValue]) {
        [[FoodAddTool sharedFoodAddTool] updateFood:food];
    }else{
        food.isSelected=[NSNumber numberWithBool:YES];
        [[FoodAddTool sharedFoodAddTool] insertFood:food];
    }
    for (FoodAddModel *foodModel in foodArray) {
        if (foodModel.type==YES) {
            if (foodModel.id==food.id) {
                foodModel.isSelected=[NSNumber numberWithBool:YES];
                foodModel.weight=food.weight;
            }

        } else {
            if (foodModel.cook_id==food.cook_id) {
                foodModel.isSelected=[NSNumber numberWithBool:YES];
                foodModel.weight=food.weight;
            }
  
        }
    }
    [self.foodTableView reloadData];
    
    NSMutableArray *tempArr=[FoodAddTool sharedFoodAddTool].selectFoodArray;
    dietCount=tempArr.count;
    
    [self reloadFoodAddView];
}
- (void)foodMenuScaleView:(FoodMenuScale *)scaleView{
    
    EstimateWeightViewController *estimateWeightVC = [[EstimateWeightViewController alloc] init];
    [self.navigationController pushViewController:estimateWeightVC animated:YES];
}
- (void)foodMenuNextScaleView:(FoodMenuScale *)scaleNextView didSelectFood:(FoodAddModel *)food{

    if (isMenuFood==1) {
        TJYFoodDetailsVC *foodDetailsVC = [TJYFoodDetailsVC  new];
        foodDetailsVC.food_id = food.id;
        [self push:foodDetailsVC];
    } else {
        TJYMenuDetailsVC *menuDetailsVC = [TJYMenuDetailsVC  new];
        menuDetailsVC.menuid = food.cook_id;
        [self push:menuDetailsVC];

    }
}
#pragma mark TCFoodSelectViewDelegate
#pragma mark 清空已选食物列表
-(void)foodSelectViewDismissAction{
    for (FoodAddModel *model in foodArray) {
        model.isSelected=[NSNumber numberWithBool:NO];
        model.weight=[NSNumber numberWithInteger:100];
    }
    [self.foodTableView reloadData];
    dietCount=0;
    [self reloadFoodAddView];
    [self closeFoodViewAction];
}

#pragma mark 删除已选食物
-(void)foodSelectViewDeleteFood:(FoodAddModel *)food{
    for (FoodAddModel *model in foodArray) {
        if (food.id==model.id) {
            model.isSelected=[NSNumber numberWithBool:NO];
            model.weight=[NSNumber numberWithInteger:100];
        }
    }
    [self.foodTableView reloadData];
    
    NSMutableArray *tempArr=[FoodAddTool sharedFoodAddTool].selectFoodArray;
    dietCount=tempArr.count;
    [self reloadFoodAddView];
}
#pragma mark 编辑食物
-(void)foodSelectViewDidSelectFood:(FoodAddModel *)food{
    [self closeFoodViewAction];
    
    FoodMenuScale *scaleView=[[FoodMenuScale alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300) model:food type:isMenuFood];
    scaleView.foodMenuScaleDelegate=self;
    [scaleView scaleViewShowInView:self.view];
}

#pragma mark  TCMenuViewDelegate
-(void)foodMenuView:(FoodMenuView *)menuView actionWithIndex:(NSInteger)index{
    selectIndex=index;
    FoodClassModel *foodClass=menuArray[index];
    category_id=foodClass.id;
    page=1;
    [self requestFoodData];

}
#pragma mark -- Event Response
#pragma mark -- 左／右滑
-(void)swipFoodTableView:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        selectIndex++;
        if (selectIndex>menuArray.count-1) {
            selectIndex=menuArray.count;
            return;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        selectIndex--;
        if (selectIndex<0) {
            selectIndex=0;
            return;
        }
    }
    UIButton *btn;
    for (UIView *view in self.menuView.rootScrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&(view.tag == selectIndex+100)) {
            btn = (UIButton*)view;
        }
    }
    [self.menuView changeFoodViewWithButton:btn];
}
#pragma mark -- 食物／菜谱
- (void)menuSegmented:(UISegmentedControl *)sender{

    if (sender.selectedSegmentIndex==0) {
#if !DEBUG
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-07"];
#endif
        isMenuFood = 1;
        [self requestFoodMenuData];
    } else {
#if !DEBUG
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-08"];
#endif
        selectIndex = 0;
        isMenuFood = 2;
        [self requestMenuData];
    }
}
#pragma mark 显示已选食物视图
-(void)showSelectedFoodList{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-13"];
#endif
    if (dietCount>0) {
        if (coverView==nil) {
            coverView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kAllHeight-50)];
            coverView.backgroundColor=[UIColor blackColor];
            coverView.alpha=0.3;
            coverView.userInteractionEnabled=YES;
            
            
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeFoodViewAction)];
            [coverView addGestureRecognizer:tap];
        }
        [self.view insertSubview:coverView belowSubview:self.foodSelectView];
        
        self.foodSelectView.foodSelectArray=[FoodAddTool sharedFoodAddTool].selectFoodArray;
        [self.foodSelectView.tableView reloadData];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.foodSelectView.frame=CGRectMake(0, kAllHeight-50-220, kScreenWidth, 220);
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark 关闭已选食物视图
-(void)closeFoodViewAction{
    [UIView animateWithDuration:0.3 animations:^{
        self.foodSelectView.frame=CGRectMake(0, kAllHeight-50, kScreenWidth, 50);
    } completion:^(BOOL finished) {
        [coverView removeFromSuperview];
    }];
}
#pragma mark 刷新页面
-(void)reloadFoodAddView{
    foodBtn.selected=dietCount>0;
    line.backgroundColor=dietCount>0?kSystemColor:[UIColor lightGrayColor];
    confirmButton.backgroundColor=dietCount>0?kSystemColor:[UIColor lightGrayColor];

    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已选食物：%ld",(long)dietCount]];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:kRGBColor(244, 182, 123) range:NSMakeRange(5, attributeStr.length-5)];
    countLabel.attributedText=attributeStr;
}
#pragma mark -- 获取食物分类数据
- (void)requestFoodMenuData{
    foodArray = [[NSMutableArray alloc] init];
    menuArray = [[NSMutableArray alloc] init];
    
    NSString *body = @"";
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kFoodCategory body:body success:^(id json) {
        
        NSArray *dataArray = [[json objectForKey:@"result"] objectForKey:@"ingredientcat"];
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        NSMutableArray *cateArr=[[NSMutableArray alloc] init];
        for (int i=0; i<dataArray.count; i++) {
            NSDictionary *dataDic = dataArray[i];
            FoodClassModel *foodClass = [[FoodClassModel alloc] init];
            [foodClass setValues:dataDic];
            [tempArr addObject:foodClass];
            [cateArr addObject:foodClass.name];
        }
        menuArray=tempArr;
        weakSelf.menuView.foodMenusArray=cateArr;
        
        FoodClassModel *foodClass=menuArray[0];
        category_id=foodClass.id;
        [weakSelf requestFoodData];

    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark 加载食物列表
-(void)requestFoodData{
    self.menuView.hidden = NO;
    self.foodTableView.frame =CGRectMake(0,self.menuView.bottom, kScreenWidth, kAllHeight-self.menuView.bottom-50);

    NSMutableArray *selectFoodArr=[FoodAddTool sharedFoodAddTool].selectFoodArray;
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&cat_id=%@",(long)page,category_id];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kFoodList body:body success:^(id json) {
        NSDictionary *pager=[json objectForKey:@"pager"];
        if (kIsDictionary(pager)&&pager.count>0) {
            NSInteger totalValues=[[pager valueForKey:@"total"] integerValue];
            weakSelf.foodTableView.mj_footer.hidden=(totalValues-page*20)<=0;
        }
        
        NSArray *list=[json objectForKey:@"result"];
        if (list.count>0) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in list) {
                FoodAddModel *model=[[FoodAddModel alloc] init];
                model.type = 1;
                [model setValues:dict];
                model.weight=[NSNumber numberWithInteger:0];
                model.isSelected=[NSNumber numberWithBool:NO];
                for (FoodAddModel *food in selectFoodArr) {
                    if (food.id==model.id) {
                        model.weight=food.weight;
                        model.isSelected=[NSNumber numberWithBool:YES];
                    }
                }
                [tempArr addObject:model];
            }
            if (page==1) {
                foodArray=tempArr;
                weakSelf.foodBlankView.hidden=foodArray.count>0;
            }else{
                [foodArray addObjectsFromArray:tempArr];
            }
        }else{
            if (page==1) {
                [foodArray removeAllObjects];
                weakSelf.foodBlankView.hidden=NO;
            }
            weakSelf.foodTableView.mj_footer.hidden=YES;
        }
        [weakSelf.foodTableView reloadData];
        
        [weakSelf.foodTableView.mj_header endRefreshing];
        [weakSelf.foodTableView.mj_footer endRefreshing];
        
        dietCount=selectFoodArr.count;
        [weakSelf reloadFoodAddView];

    } failure:^(NSString *errorStr) {
        [weakSelf.foodTableView.mj_header endRefreshing];
        [weakSelf.foodTableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];

    }];
}
#pragma mark 加载菜谱列表  
- (void)requestMenuData{
    self.menuView.hidden = YES;
    NSMutableArray *selectFoodArr=[FoodAddTool sharedFoodAddTool].selectFoodArray;
    self.foodTableView.frame =CGRectMake(0,self.mySearchBar.bottom, kScreenWidth, kAllHeight-_mySearchBar.bottom-50);
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20",page];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kMenuDetailList body:body success:^(id json) {
        
        NSDictionary *pager=[json objectForKey:@"pager"];
        if (kIsDictionary(pager)&&pager.count>0) {
            NSInteger totalValues=[[pager valueForKey:@"total"] integerValue];
            weakSelf.foodTableView.mj_footer.hidden=(totalValues-page*20)<=0;
        }
        
        NSArray *list=[json objectForKey:@"result"];
        if (list.count>0) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in list) {
                FoodAddModel *model=[[FoodAddModel alloc] init];
                model.type = 2;
                [model setValues:dict];
                model.weight=[NSNumber numberWithInteger:0];
                model.isSelected=[NSNumber numberWithBool:NO];
                for (FoodAddModel *food in selectFoodArr) {
                    if (food.cook_id==model.cook_id) {
                        model.weight=food.weight;
                        model.isSelected=[NSNumber numberWithBool:YES];
                    }
                }
                [tempArr addObject:model];
            }
            if (page==1) {
                foodArray=tempArr;
                weakSelf.foodBlankView.hidden=foodArray.count>0;
            }else{
                [foodArray addObjectsFromArray:tempArr];
            }
        }else{
            if (page==1) {
                [foodArray removeAllObjects];
                weakSelf.foodBlankView.hidden=NO;
            }
            weakSelf.foodTableView.mj_footer.hidden=YES;
        }
        [weakSelf.foodTableView reloadData];
        
        [weakSelf.foodTableView.mj_header endRefreshing];
        [weakSelf.foodTableView.mj_footer endRefreshing];
        
        dietCount=selectFoodArr.count;
        [weakSelf reloadFoodAddView];

    } failure:^(NSString *errorStr) {
        
    }];
    foodArray = [[NSMutableArray alloc] init];
    [self.foodTableView reloadData];
}
#pragma mark 加载最新食材
-(void)loadAddNewFoodData{
    page=1;
    if (isMenuFood==2) {
        [self requestMenuData];
    }else{
    [self requestFoodData];
    }
}

#pragma mark 加载更多食材
-(void)loadAddMoreFoodData{
    page++;
    if (isMenuFood==2) {
        [self requestMenuData];
    }else{
        [self requestFoodData];
    }
}
#pragma mark 返回按钮事件
-(void)leftButtonAction{
    NSMutableArray *DataArray =[FoodAddTool sharedFoodAddTool].selectFoodArray;
    if (DataArray.count>0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确认放弃此次记录编辑" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[FoodAddTool sharedFoodAddTool] removeAllFood];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark --确定
- (void)confirmAddFoodAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-12"];
#endif
    [TJYHelper sharedTJYHelper].isAddFood=YES;
    [TJYHelper sharedTJYHelper].isHistoryDiet=NO;
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 初始化界面
- (void)initAddFoodView{
    [self.view addSubview:self.menuSegmented];
    [self.view addSubview:self.mySearchBar];
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.foodTableView];
    [self.foodTableView addSubview:self.foodBlankView];
    _foodBlankView.hidden = YES;
    [self.view addSubview:self.foodSelectView];
    [self.view addSubview:self.bottomView];
}

#pragma mark -- Getters and Setters
#pragma mark 标题
-(UISegmentedControl *)menuSegmented{
    if (_menuSegmented==nil) {
        NSArray *titleArray = @[@"食材",@"菜谱"];
        _menuSegmented = [[UISegmentedControl alloc] initWithItems:titleArray];
        _menuSegmented.backgroundColor =kSystemColor;
        [_menuSegmented setTintColor:[UIColor whiteColor]];
        _menuSegmented.layer.cornerRadius = 5;
        _menuSegmented.frame = CGRectMake((kScreenWidth-140)/2, 20+7, 140, kNavigationHeight-14);
        [_menuSegmented setSelectedSegmentIndex:0];
        [_menuSegmented addTarget:self action:@selector(menuSegmented:) forControlEvents:UIControlEventValueChanged];
    }
    return _menuSegmented;
}
#pragma mark 搜索框
-(UISearchBar *)mySearchBar{
    if (_mySearchBar==nil) {
        _mySearchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kNavigationHeight)];
        _mySearchBar.delegate=self;
        _mySearchBar.placeholder=@"请输入搜索关键词";
    }
    return _mySearchBar;
}
#pragma mark 菜单栏
-(FoodMenuView *)menuView{
    if (_menuView==nil) {
        _menuView=[[FoodMenuView alloc] initWithFrame:CGRectMake(0, _mySearchBar.bottom, kScreenWidth, 40)];
        _menuView.delegate=self;
    }
    return _menuView;
}
#pragma mark 食物列表
-(UITableView *)foodTableView{
    if (_foodTableView==nil) {
        _foodTableView=[[UITableView alloc] initWithFrame:CGRectMake(0,self.menuView.bottom, kScreenWidth, kAllHeight-self.menuView.bottom-50) style:UITableViewStylePlain];
        _foodTableView.dataSource=self;
        _foodTableView.delegate=self;
        _foodTableView.showsVerticalScrollIndicator=NO;
        _foodTableView.tableFooterView=[[UIView alloc] init];
        
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadAddNewFoodData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _foodTableView.mj_header=header;
        
        // 上拉加载更多
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadAddMoreFoodData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _foodTableView.mj_footer = footer;
        footer.hidden=YES;

        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipFoodTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_foodTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipFoodTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_foodTableView addGestureRecognizer:swipGestureRight];
    }
    return _foodTableView;
}
#pragma mark 已选食物视图
-(FoodSelectView *)foodSelectView{
    if (_foodSelectView==nil) {
        _foodSelectView=[[FoodSelectView alloc] initWithFrame:CGRectMake(0, kAllHeight-50, kScreenWidth, 50)];
        _foodSelectView.delegate=self;
    }
    return _foodSelectView;
}
#pragma mark 无数据空白页
-(BlankView *)foodBlankView{
    if (_foodBlankView==nil) {
        _foodBlankView=[[BlankView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 200) img:@"img_tips_no" text:@"该分类下暂无食材"];
    }
    return _foodBlankView;
}

#pragma mark 底部视图
-(UIView *)bottomView{
    if (_bottomView==nil) {
        _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kAllHeight-50, kScreenWidth, 50)];
        _bottomView.backgroundColor=[UIColor whiteColor];
        
        line=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        line.backgroundColor=selectaddFoodArr.count>0?kSystemColor:[UIColor lightGrayColor];
        [_bottomView addSubview:line];
        
        //点击查看已选食物
        foodBtn=[[UIButton alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        [foodBtn setImage:[UIImage imageNamed:@"ic_n_meal_nor"] forState:UIControlStateNormal];
        [foodBtn setImage:[UIImage imageNamed:@"ic_n_meal_sel"] forState:UIControlStateSelected];
        [foodBtn addTarget:self action:@selector(showSelectedFoodList) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:foodBtn];
        foodBtn.selected=dietCount>0;
        
        countLabel=[[UILabel alloc] initWithFrame:CGRectMake(foodBtn.right+5, 10, 100, 30)];
        countLabel.textColor=[UIColor blackColor];
        countLabel.font=[UIFont systemFontOfSize:14.0f];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已选食物：%ld",(long)dietCount]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:kRGBColor(244, 182, 123) range:NSMakeRange(5, attributeStr.length-5)];
        countLabel.attributedText=attributeStr;
        [_bottomView addSubview:countLabel];
        
        confirmButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 1, 100, 49)];
        confirmButton.backgroundColor=selectaddFoodArr.count>0?kSystemColor:[UIColor lightGrayColor];;
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmAddFoodAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:confirmButton];
    }
    return _bottomView;
}

@end
