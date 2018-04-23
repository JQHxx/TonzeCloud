//
//  TJYSearchResultVC.m
//  Product
//
//  Created by zhuqinlu on 2017/4/28.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYSearchResultVC.h"
#import "TJYFoodLibraryCell.h"
#import "TJYFoodListModel.h"
#import "TJYArticleModel.h"
#import "TJYArticleTableViewCell.h"
#import "FoodSelectView.h"
#import "FoodAddTool.h"
#import "FoodMenuScale.h"
#import "AddFoodTableViewCell.h"
#import "TJYRelatedRecipesCell.h"


@interface TJYSearchResultVC ()<UITableViewDelegate,UITableViewDataSource,FoodSelectViewDelegate,FoodMenuScaleViewDelegate>{

    NSInteger           dietCount;
    
    UIView              *coverView;
    UIButton            *foodBtn;
    UILabel             *countLabel;        //已选食物数量
}

@property (nonatomic, assign) NSInteger page;
/// 数据源
@property (nonatomic ,strong) NSMutableArray     *resultData;
@property (nonatomic,strong)FoodSelectView  *foodSelectView;    //已选食物视图
@property (nonatomic,strong)UITableView       *tableView;
@property (nonatomic,strong)UIView            *bottomView;        //底部视图
@property (nonatomic ,strong) BlankView *blankView;

@end

@implementation TJYSearchResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    _page = 1;
    
    _resultData=[[NSMutableArray alloc] init];
    [self reloadAddView];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_type) {
        case FoodSearchType:
        case FoodSelectSearchType:
        {
            static NSString *cellIdntifier=@"TCFoodTableViewCell";
            TJYFoodLibraryCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdntifier];
            if (cell==nil) {
                cell=[[TJYFoodLibraryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdntifier];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            TJYFoodListModel *food=_resultData[indexPath.row];
            [cell setdataWithFoodListModel:food searchText:_keyword];
            return cell;
            
        }break;
        case MenuSearchType:
        {
            static NSString *menuHistoryListCellIdentifier =@"menuHistoryListCell";
            TJYRelatedRecipesCell *menuHistoryListCell = [tableView dequeueReusableCellWithIdentifier:menuHistoryListCellIdentifier];
            if (!menuHistoryListCell) {
                menuHistoryListCell = [[TJYRelatedRecipesCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:menuHistoryListCellIdentifier];
            }
            [menuHistoryListCell cellInitWithData:_resultData[indexPath.row] searchText:_keyword];
            menuHistoryListCell.selectionStyle=UITableViewCellSelectionStyleNone;
            return menuHistoryListCell;
        }break;
        case FoodAddSearchType:
        {
            static NSString *cellIdntifier=@"AddFoodTableViewCell";
            AddFoodTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdntifier];
            if (cell==nil) {
                cell=[[[NSBundle mainBundle] loadNibNamed:@"AddFoodTableViewCell" owner:self options:nil] objectAtIndex:0];
            }
            cell.cellType=0;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            FoodAddModel *food=_resultData[indexPath.row];
            food.type=self.type;
            [cell cellDisplayWithFood:food];
            return cell;
        }
        default:
            break;
    }
    
    static  NSString *articleCellIdentifier = @"TJYArticleTableViewCell";
    TJYArticleTableViewCell *articleCell = [tableView dequeueReusableCellWithIdentifier:articleCellIdentifier];
    if (!articleCell) {
        articleCell = [[TJYArticleTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:articleCellIdentifier];
    }
    articleCell.selectionStyle=UITableViewCellSelectionStyleNone;
    [articleCell cellDisplayWithModel:_resultData[indexPath.row] type:1 searchText:_keyword];
    return articleCell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (_type) {
        case KnowledgeSearchType:
        {
            return 100 *kScreenWidth/320;
        }break;
            case MenuSearchType:
        {
            return  90 * kScreenWidth/320;
        }break;
        default:
            break;
    }
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id  model=_resultData[indexPath.row];

    if (_type==FoodAddSearchType) {
        if ([_controllerDelegate respondsToSelector:@selector(searchResultViewControllerDidSelectModel:withType:)]) {
            [_controllerDelegate searchResultViewControllerDidSelectModel:model withType:_type];
        }
        
        FoodAddModel *food=(FoodAddModel*)model;
        FoodMenuScale *scaleView=[[FoodMenuScale alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 364) model:food type:1];
        scaleView.foodMenuScaleDelegate=self;
        [scaleView scaleViewShowInView:self.view];
        
    }else{
        if ([_controllerDelegate respondsToSelector:@selector(searchResultViewControllerDidSelectModel:withType:)]) {
            [_controllerDelegate searchResultViewControllerDidSelectModel:model withType:_type];
        }
        // --- 处理点击阅读量问题
        if (_type ==MenuSearchType ) {
            NSMutableArray *arr = [NSMutableArray array];
            for (NSInteger i = 0; i < _resultData.count ; i++) {
                TJYMenuListModel *model = _resultData[i];
                if (i == indexPath.row) {
                    model.reading_number = model.reading_number + 1;
                }
                [arr addObject:model];
            }
            _resultData = arr;
            [_tableView reloadData];
        }else if (_type == KnowledgeSearchType){
            NSMutableArray *arr = [NSMutableArray array];
            for (NSInteger i = 0; i < _resultData.count ; i++) {
                TJYArticleModel *model = _resultData[i];
                if (i == indexPath.row) {
                    model.reading_number = model.reading_number + 1;
                }
                [arr addObject:model];
            }
            _resultData = arr;
            [_tableView reloadData];
        }
    }
}

#pragma mark -- UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([_controllerDelegate respondsToSelector:@selector(searchResultViewControllerBeginDraggingAction)]) {
        [_controllerDelegate searchResultViewControllerBeginDraggingAction];
    }
}
#pragma mark  FoodMenuScaleViewDelegate
-(void)foodMenuScaleView:(FoodMenuScale *)scaleView didSelectFood:(FoodAddModel *)food{
//    if ([food.isSelected boolValue]) {
//        [[FoodAddTool sharedFoodAddTool] updateFood:food];
//    }else{
//        food.isSelected=[NSNumber numberWithBool:YES];
//        [[FoodAddTool sharedFoodAddTool] insertFood:food];
//    }
//    for (FoodAddModel *foodModel in _resultData) {
//        if (foodModel.id==food.id) {
//            foodModel.isSelected=[NSNumber numberWithBool:YES];
//            foodModel.weight=food.weight;
//        }
//    }
    if ([food.isSelected boolValue]) {
        [[FoodAddTool sharedFoodAddTool] updateFood:food];
    }else{
        food.isSelected=[NSNumber numberWithBool:YES];
        [[FoodAddTool sharedFoodAddTool] insertFood:food];
    }
    for (FoodAddModel *foodModel in _resultData) {
        if (self.searchType==YES) {
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

    [self.tableView reloadData];
    
    NSMutableArray *tempArr=[FoodAddTool sharedFoodAddTool].selectFoodArray;
    dietCount=tempArr.count;
    
    [self reloadFoodAddView];
}

-(void)setKeyword:(NSString *)keyword{
    _keyword=keyword;
    [_resultData removeAllObjects];
    
    [self requestSearchData:_keyword];
}
#pragma mark -- 获取搜索数据
- (void)requestSearchData:(NSString *)keyword{

    NSString *url=nil;
    NSString *body=nil;
    if (_type==FoodAddSearchType) {
        if (self.searchType==1) {
            url=kFoodList;
            body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&name=%@",(long)_page,keyword];
        } else {
            url = kMenuList;
            body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&keywords=%@",(long)_page,keyword];
        }
    }else if (_type==FoodSearchType ||
              _type==FoodSelectSearchType){
        url=kFoodList;
        body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&name=%@",(long)_page,keyword];
    }else if (_type==KnowledgeSearchType){
            url=kArticleList;
            body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&title=%@",(long)_page,keyword];
    }else if (_type== MenuSearchType){
            url = kMenuList;
            body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&keywords=%@",(long)_page,keyword];
    }
    
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:url body:body success:^(id json) {
        NSDictionary *pager=[json objectForKey:@"pager"];
        if (kIsDictionary(pager)&&pager.count>0) {
            NSInteger totalValues=[[pager valueForKey:@"total"] integerValue];
            weakSelf.tableView.mj_footer.hidden=(totalValues-_page*20)<=0;
        }

        NSArray *list=[json objectForKey:@"result"];
        weakSelf.blankView.hidden = NO;
        if (list.count>0 && kIsArray(list)) {
            weakSelf.blankView.hidden = list.count > 0;
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            if (self.type==FoodSearchType ||
                self.type==FoodSelectSearchType ||
                self.type==FoodAddSearchType)
            {
                NSMutableArray *selectFoodArr=[FoodAddTool sharedFoodAddTool].selectFoodArray;
                for (NSDictionary *dict in list) {
                    FoodAddModel *foodModel=[[FoodAddModel alloc] init];
                    [foodModel setValues:dict];
                    
                    if (self.type == FoodAddSearchType||self.type==FoodSearchType) {
                        if (self.searchType==1) {
                            for (FoodAddModel *food in selectFoodArr) {
                                if (food.id==foodModel.id) {
                                    foodModel.weight=food.weight;
                                    foodModel.type =1;
                                    foodModel.isSelected=[NSNumber numberWithBool:YES];
                                }
                            }
                        }else{
                            for (FoodAddModel *food in selectFoodArr) {
                                if (food.cook_id==foodModel.cook_id) {
                                    foodModel.weight=food.weight;
                                    foodModel.type =1;
                                    foodModel.isSelected=[NSNumber numberWithBool:YES];
                                }
                            }
                        }
                        [tempArr addObject:foodModel];
                    }
                }
            }else if (weakSelf.type==KnowledgeSearchType){
                for (NSDictionary *dict in list) {
                    TJYArticleModel *articleModel = [TJYArticleModel new];
                    [articleModel setValues:dict];
                    [tempArr addObject:articleModel];
                }
            }else if (weakSelf.type == MenuSearchType){
                
                for (NSDictionary *dic  in list) {
                    TJYMenuListModel *menuListModel = [TJYMenuListModel new];
                    [menuListModel setValues:dic];
                    [tempArr addObject:menuListModel];
                }
            }
            if (_page==1) {
                weakSelf.resultData=tempArr;
            }else{
                [weakSelf.resultData addObjectsFromArray:tempArr];
            }
        }
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSString *errorStr) {
        weakSelf.blankView.hidden = NO;
        [_resultData removeAllObjects];
        [weakSelf.tableView reloadData];
    }];

}
#pragma mark -- 已添加的事物
- (void)reloadAddView{

    NSMutableArray *selectFoodArr=[FoodAddTool sharedFoodAddTool].selectFoodArray;
    dietCount=selectFoodArr.count;
    [self reloadFoodAddView];
}
#pragma mark --Custom Delegate
#pragma mark TCFoodSelectViewDelegate
#pragma mark 清空已选食物列表
-(void)foodSelectViewDismissAction{
    for (FoodAddModel *model in _resultData) {
        model.isSelected=[NSNumber numberWithBool:NO];
        model.weight=[NSNumber numberWithInteger:100];
    }
    [self.tableView reloadData];
    
    dietCount=0;
    [self reloadFoodAddView];
    [self closeFoodViewAction];
}

#pragma mark 删除已选食物
-(void)foodSelectViewDeleteFood:(FoodAddModel *)food{
    for (FoodAddModel *model in _resultData) {
        if (food.id==model.id) {
            model.isSelected=[NSNumber numberWithBool:NO];
            model.weight=[NSNumber numberWithInteger:100];
        }
    }
    [self.tableView reloadData];
    
    NSMutableArray *tempArr=[FoodAddTool sharedFoodAddTool].selectFoodArray;
    dietCount=tempArr.count;
    [self reloadFoodAddView];
}

#pragma mark 编辑食物
-(void)foodSelectViewDidSelectFood:(FoodAddModel *)food{
    [self closeFoodViewAction];
    
    FoodMenuScale *scaleView=[[FoodMenuScale alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 364) model:food type:0];
    scaleView.foodMenuScaleDelegate=self;
    [scaleView scaleViewShowInView:self.view];
}

#pragma mark  TCScaleViewDelegate
-(void)scaleView:(FoodMenuScale *)scaleView didSelectFood:(FoodAddModel *)food{
    if ([food.isSelected boolValue]) {
        [[FoodAddTool sharedFoodAddTool] updateFood:food];
    }else{
        food.isSelected=[NSNumber numberWithBool:YES];
        [[FoodAddTool sharedFoodAddTool] insertFood:food];
    }
    for (FoodAddModel *foodModel in _resultData) {
        if (foodModel.id==food.id) {
            foodModel.isSelected=[NSNumber numberWithBool:YES];
            foodModel.weight=food.weight;
        }
    }
    [self.tableView reloadData];
    
    NSMutableArray *tempArr=[FoodAddTool sharedFoodAddTool].selectFoodArray;
    dietCount=tempArr.count;
    
    [self reloadFoodAddView];
}
#pragma mark -- Private Methods
#pragma mark 刷新页面
-(void)reloadFoodAddView{
    foodBtn.selected=dietCount>0;
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已选食物：%ld",(long)dietCount]];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:kRGBColor(244, 182, 123) range:NSMakeRange(5, attributeStr.length-5)];
    countLabel.attributedText=attributeStr;
}
#pragma mark -- Event Rersponse
#pragma mark 显示已选食物视图
-(void)showSelectedFoodList{
    if (dietCount>0) {
        if (coverView==nil) {
            coverView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight-50)];
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
            self.foodSelectView.frame=CGRectMake(0, kRootViewHeight-50-220, kScreenWidth, 220);
        } completion:^(BOOL finished) {
            
        }];
    }
}
#pragma mark 关闭已选食物视图
-(void)closeFoodViewAction{
    [UIView animateWithDuration:0.3 animations:^{
        self.foodSelectView.frame=CGRectMake(0, kScreenHeight-50, kScreenWidth, 50);
    } completion:^(BOOL finished) {
        [coverView removeFromSuperview];
    }];
}
#pragma mark 确定
-(void)confirmAddFoodAction:(UIButton *)sender{
    if ([_controllerDelegate respondsToSelector:@selector(searchResultViewControllerConfirmAction)]) {
        [_controllerDelegate searchResultViewControllerConfirmAction];
    }
}
#pragma mark -- Setters and Getters
-(void)setType:(SearchType)type{
    _type=type;
    if (self.type==FoodAddSearchType) {
        self.tableView.frame=CGRectMake(0, 0, kScreenWidth, kRootViewHeight-50+20);
        [self.view addSubview:self.foodSelectView];
        [self.view addSubview:self.bottomView];
    }
}
#pragma mark -- 加载最新数据
-(void)loadNewSearchFoodData{
    _page =1;
    [self requestSearchData:_keyword];
    
}
#pragma mark -- 加载更多数据
-(void)loadMoreSearchFoodData{
    _page++;
    [self requestSearchData:_keyword];
    
}
-(UITableView *)tableView{
    if (_tableView==nil) {
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.backgroundColor=[UIColor bgColor_Gray];
        _tableView.tableFooterView=[[UIView alloc] init];
        [_tableView addSubview:self.blankView];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewSearchFoodData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _tableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreSearchFoodData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _tableView.mj_footer = footer;
        footer.hidden=YES;

    }
    return _tableView;
}
#pragma mark 已选食物视图
-(FoodSelectView *)foodSelectView{
    if (_foodSelectView==nil) {
        _foodSelectView=[[FoodSelectView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _foodSelectView.delegate=self;
    }
    return _foodSelectView;
}

#pragma mark 底部视图
-(UIView *)bottomView{
    if (_bottomView==nil) {
        _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kRootViewHeight-50, kScreenWidth, 50)];
        _bottomView.backgroundColor=[UIColor whiteColor];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        line.backgroundColor=kSystemColor;
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
        
        UIButton *confirmButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 1, 100, 49)];
        confirmButton.backgroundColor=kSystemColor;
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmAddFoodAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:confirmButton];
    }
    return _bottomView;
}
#pragma mark -- getter --

- (BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc]initWithFrame:CGRectMake(0, 100, kScreenWidth, kBodyHeight - 100) Searchimg:@"img_sch_none" text:@"什么都没搜到哦"];
        _blankView.hidden = YES;
    }
    return _blankView;
}

@end
