//
//  TJYSearchFoodVC.m
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYSearchFoodVC.h"
#import "TCSearchTableView.h"
#import "NSUserDefaultInfos.h"
#import "TJYSearchResultVC.h"
#import "NSUserDefaultInfos.h"
#import "TJYFoodDetailsVC.h"
#import "TJYFoodListModel.h"
#import "TJYArticleModel.h"
#import "BasewebViewController.h"
#import "DietRecordViewController.h"
#import "TJYMenuDetailsVC.h"
#import "TJYMenuListModel.h"
#import "TonzeHelpTool.h"
#import "FoodAddModel.h"

@interface TJYSearchFoodVC ()<TJYSearchTableViewDelegate,UISearchBarDelegate,TJYSearchResultViewControllerDelegate>{

    NSInteger seletedPage;
    NSString *resultStr;
}
/// 食材历史搜索记录
@property (nonatomic ,strong)  NSMutableArray     *foodHistoryArray;
/// 百科搜索历史
@property (nonatomic ,strong)  NSMutableArray     *articleHistoryArray;
/// 搜索框
@property (nonatomic,strong)    UISearchBar         *mySearchBar;
/// 热门搜索和历史记录
@property (nonatomic,strong)    TCSearchTableView   *searchTableView;
/// 搜索显示
@property (nonatomic ,strong)   TJYSearchResultVC *searchResultVC;
/// 菜谱历史搜索记录
@property (nonatomic ,strong) NSMutableArray *menuHistoryArray;

@end

@implementation TJYSearchFoodVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.mySearchBar becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
#if !DEBUG
    if ([TonzeHelpTool sharedTonzeHelpTool].searchType==MenuSearchType) {
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-03-05" type:1];
    }else if([TonzeHelpTool sharedTonzeHelpTool].searchType==FoodSearchType){
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-04-02" type:1];
    }else if([TonzeHelpTool sharedTonzeHelpTool].searchType==FoodAddSearchType){
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-01-16" type:1];
    }
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    if ([TonzeHelpTool sharedTonzeHelpTool].searchType==MenuSearchType) {
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-03-05" type:2];
    }else if([TonzeHelpTool sharedTonzeHelpTool].searchType==FoodSearchType){
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-04-02" type:2];
    }else if([TonzeHelpTool sharedTonzeHelpTool].searchType==FoodAddSearchType){
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-01-16" type:1];
    }
#endif
    [self.mySearchBar becomeFirstResponder];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.isHiddenBackBtn=YES;
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    seletedPage = 1;
    
    [self loadData];
    [self buildUI];
    
    if (!kIsEmptyString(self.keyword)) {
        self.mySearchBar.text=self.keyword;
        [self.mySearchBar becomeFirstResponder];
        [self searchBar:self.mySearchBar textDidChange:self.keyword];
    }
}
#pragma mark -- Build UI

- (void)buildUI{
    [self.view addSubview:self.mySearchBar];
    [self.view addSubview:self.searchTableView];
}
#pragma mark -- Network Methods
#pragma mark 加载热门搜索关键词和历史搜索记录
-(void)requestHotSearchWords{
    NSInteger way=1;
    if (_searchType==FoodSearchType ||
        _searchType==FoodSelectSearchType) {
        NSArray *tempArr=[NSUserDefaultInfos getValueforIdKey:@"foodHistory"];
        if (kIsArray(tempArr)) {
            _foodHistoryArray=[[NSMutableArray alloc] initWithArray:tempArr];
            self.searchTableView.historyRecordsArray=_foodHistoryArray;
        }
        way=2;
    }else if(_searchType==FoodAddSearchType){
        if (self.type==1) {
            NSArray *tempArr=[NSUserDefaultInfos getValueforIdKey:@"foodHistory"];
            if (kIsArray(tempArr)) {
                _foodHistoryArray=[[NSMutableArray alloc] initWithArray:tempArr];
                self.searchTableView.historyRecordsArray=_foodHistoryArray;
            }
            way=2;
        } else {
            NSArray *tempArr=[NSUserDefaultInfos getValueforIdKey:@"menuHistory"];
            if (kIsArray(tempArr)) {
                _menuHistoryArray=[[NSMutableArray alloc] initWithArray:tempArr];
                self.searchTableView.historyRecordsArray=_menuHistoryArray;
            }
             way=3;
        }
    }else if(_searchType==KnowledgeSearchType){
        NSArray *tempArr=[NSUserDefaultInfos getValueforIdKey:@"articleHistory"];
        if (kIsArray(tempArr)) {
            _articleHistoryArray=[[NSMutableArray alloc] initWithArray:tempArr];
            self.searchTableView.historyRecordsArray=_articleHistoryArray;
        }
        way=1;
    }else if (_searchType== MenuSearchType){
        NSArray *tempArr=[NSUserDefaultInfos getValueforIdKey:@"menuHistory"];
        if (kIsArray(tempArr)) {
            _menuHistoryArray=[[NSMutableArray alloc] initWithArray:tempArr];
            self.searchTableView.historyRecordsArray=_menuHistoryArray;
        }
        way=3;
    }
    /*way:1为文章，2为热门食材,3为菜谱*/
    self.searchTableView.searchType=_searchType;
    NSString *body=[NSString stringWithFormat:@"way=%ld",(long)way];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kHotKeyword body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (result.count>0) {
            NSArray *dataArray = [result valueForKey:@"keyword"];
            weakSelf.searchTableView.hotSearchWordsArray=[NSMutableArray arrayWithArray:dataArray];
            [weakSelf.searchTableView reloadData];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- Request Data

- (void)loadData{
    _foodHistoryArray = [NSMutableArray array];
    _articleHistoryArray = [NSMutableArray array];
    _menuHistoryArray = [NSMutableArray array];
    
    [self requestHotSearchWords];
}

#pragma mark -- UISearchBarDelegate
#pragma mark 搜索框编辑开始
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self.mySearchBar setShowsCancelButton:YES animated:YES];
    [self setSearchBarCancelButton];
}

#pragma mark 搜索框文字变化时
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSString *text = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!kIsEmptyString(text)) {
        if (_searchResultVC==nil) {
            _searchResultVC=[[TJYSearchResultVC alloc] init];
        }
        resultStr = text;

        _searchResultVC.view.frame=CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
        _searchResultVC.controllerDelegate=self;
        _searchResultVC.type=_searchType;
        _searchResultVC.searchType = self.type;
        _searchResultVC.keyword=searchText;
        [self.view addSubview:_searchResultVC.view];
    }
}

#pragma mark  TCSearchTableViewDelegate
-(void)searchTableViewWillBeginDragging:(TCSearchTableView *)searchTableView{
    [self.mySearchBar resignFirstResponder];
    [self setSearchBarCancelButton];
}

#pragma mark -- Private Methods
#pragma mark 设置取消按钮
-(void)setSearchBarCancelButton{
    for (id cc in [self.mySearchBar.subviews[0] subviews]) {
        if ([cc isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)cc;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.enabled=YES;
        }
    }
}
#pragma mark 清除历史记录
-(void)searchTableViewDidDeleteAllHistory:(TCSearchTableView *)searchTableView{
    switch (self.searchType) {
        case FoodSearchType:
        case FoodSelectSearchType:
        {
            [NSUserDefaultInfos removeObjectForKey:@"foodHistory"];
            [_foodHistoryArray removeAllObjects];
            self.searchTableView.historyRecordsArray=_foodHistoryArray;
        }break;
        case KnowledgeSearchType:
        {
            [NSUserDefaultInfos removeObjectForKey:@"articleHistory"];
            [_articleHistoryArray removeAllObjects];
            self.searchTableView.historyRecordsArray=_articleHistoryArray;
        }break;
        case MenuSearchType:
        {
            [NSUserDefaultInfos removeObjectForKey:@"menuHistory"];
            [_menuHistoryArray removeAllObjects];
            self.searchTableView.historyRecordsArray=_menuHistoryArray;
        
        }break;
        default:
            break;
    }
    [self.searchTableView reloadData];
}
#pragma mark TCSearchResultViewControllerDelegate
#pragma mark 选择搜索结果
-(void)searchResultViewControllerDidSelectModel:(id)model withType:(SearchType)searchType{
    NSString * searchText = self.mySearchBar.text;
    switch (self.searchType) {
        case FoodSearchType:
        case FoodSelectSearchType:
        {
            if (![_foodHistoryArray containsObject:searchText]) {
                [_foodHistoryArray addObject:searchText];
                [NSUserDefaultInfos putKey:@"foodHistory" andValue:_foodHistoryArray];
            }
        }break;
            
        case KnowledgeSearchType:
        {
            if (![_articleHistoryArray containsObject:searchText]) {
                [_articleHistoryArray addObject:searchText];
                [NSUserDefaultInfos putKey:@"articleHistory" andValue:_articleHistoryArray];
            }
        }break;
            
        case MenuSearchType:
        {
            if (![_menuHistoryArray containsObject:searchText]) {
                [_menuHistoryArray addObject:searchText];
                [NSUserDefaultInfos putKey:@"menuHistory" andValue:_menuHistoryArray];
            }
        }break;
        case FoodAddSearchType:
        {
            if (self.type==1) {
                if (![_foodHistoryArray containsObject:searchText]) {
                    [_foodHistoryArray addObject:searchText];
                    [NSUserDefaultInfos putKey:@"foodHistory" andValue:_foodHistoryArray];
                }
                
            } else {
                if (![_menuHistoryArray containsObject:searchText]) {
                    [_menuHistoryArray addObject:searchText];
                    [NSUserDefaultInfos putKey:@"menuHistory" andValue:_menuHistoryArray];
                }
                
            }
        }break;
        default:
            break;
    }
    
    if (searchType==FoodSearchType) {   //食物详情
        TJYFoodListModel *foodListModel=(TJYFoodListModel *)model;
        TJYFoodDetailsVC  *foodDetailVC=[[TJYFoodDetailsVC alloc] init];
        foodDetailVC.food_id=foodListModel.id;
        [self.navigationController pushViewController:foodDetailVC animated:YES];
    }else if (searchType==KnowledgeSearchType){   //详情
        TJYArticleModel *article=(TJYArticleModel *)model;
        NSString *urlStr = [NSString stringWithFormat:@"article/%ld",(long)article.article_management_id];
        NSString *urlString=[NSString stringWithFormat:kHostURL,urlStr];
        BasewebViewController *webVC=[[BasewebViewController alloc] init];
        webVC.titleText=@"文章详情";
        webVC.articleId = article.article_management_id;
        webVC.urlStr=urlString;
        webVC.isCollect = article.is_collection;
        webVC.titleName = article.title;
        webVC.imageUrl = article.image_url;
        
        webVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:webVC animated:YES];
    }else if (searchType==FoodAddSearchType){  //添加食物
        [self.mySearchBar resignFirstResponder];
        [self setSearchBarCancelButton];
    }else if (searchType==MenuSearchType){  //菜谱列表
        TJYMenuDetailsVC *menuDetailsVC = [TJYMenuDetailsVC new];
        TJYMenuListModel *menuListModel = (TJYMenuListModel *)model;
        menuDetailsVC.menuid = menuListModel.cook_id;
        [self push:menuDetailsVC];
    }else if (searchType==FoodSelectSearchType)
    {
        if(self.selectBlock)
        {
            FoodAddModel * addModel = (FoodAddModel *)model;
            TJYFoodListModel *foodListModel = [[TJYFoodListModel alloc] init];
            foodListModel.id = addModel.id;
            foodListModel.energykcal = addModel.energykcal;
            foodListModel.name = addModel.name;
            foodListModel.image_url = addModel.image_url;
            self.selectBlock(foodListModel);
        }
    }
}

#pragma amrk 选择搜索词
-(void)searchtableView:(TCSearchTableView *)searchTableView didSelectKeyword:(NSString *)keyword{
    
    if (_searchResultVC==nil) {
        _searchResultVC=[[TJYSearchResultVC alloc] init];
    }
    _searchResultVC.searchType = self.type;
    _searchResultVC.type = self.searchType;
    self.mySearchBar.text=keyword;
    [self searchBarSearchButtonClicked:self.mySearchBar];
}

#pragma mark  滑动搜素结果界面
-(void)searchResultViewControllerBeginDraggingAction{
    [self.mySearchBar resignFirstResponder];
    [self setSearchBarCancelButton];
}
#pragma mark 确定添加
-(void)searchResultViewControllerConfirmAction{
    MyLog(@"controllers:%@",self.navigationController.viewControllers);
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[DietRecordViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            [TJYHelper sharedTJYHelper].isAddFood=YES;
        }
    }
}
#pragma mark 点击取消按钮
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.mySearchBar resignFirstResponder];
    [self setSearchBarCancelButton];
    
    NSString *searchText=[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    searchBar.text=searchText;
    if (kIsEmptyString(searchText)) {
        searchBar.text=@"";
        [self showAlertWithTitle:@"" Message:@"请输入关键词"];
    }else{
        if (_searchResultVC==nil) {
            _searchResultVC=[[TJYSearchResultVC alloc] init];
        }
        _searchResultVC.view.frame=CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
        _searchResultVC.controllerDelegate=self;
        _searchResultVC.type=_searchType;
        _searchResultVC.searchType = self.type;
        _searchResultVC.keyword=searchText;

        [self.view addSubview:_searchResultVC.view];
        
        switch (self.searchType) {
            case FoodSearchType:
            case FoodSelectSearchType:
            {
                if (![_foodHistoryArray containsObject:searchText]) {
                    [_foodHistoryArray addObject:searchText];
                    [NSUserDefaultInfos putKey:@"foodHistory" andValue:_foodHistoryArray];
                }
            }break;
                
            case KnowledgeSearchType:
            {
                if (![_articleHistoryArray containsObject:searchText]) {
                    [_articleHistoryArray addObject:searchText];
                    [NSUserDefaultInfos putKey:@"articleHistory" andValue:_articleHistoryArray];
                }
            }break;
                
            case MenuSearchType:
            {
                if (![_menuHistoryArray containsObject:searchText]) {
                    [_menuHistoryArray addObject:searchText];
                    [NSUserDefaultInfos putKey:@"menuHistory" andValue:_menuHistoryArray];
                }
            }break;
            case FoodAddSearchType:
            {
                if (self.type==1) {
                    if (![_foodHistoryArray containsObject:searchText]) {
                        [_foodHistoryArray addObject:searchText];
                        [NSUserDefaultInfos putKey:@"foodHistory" andValue:_foodHistoryArray];
                    }

                } else {
                    if (![_menuHistoryArray containsObject:searchText]) {
                        [_menuHistoryArray addObject:searchText];
                        [NSUserDefaultInfos putKey:@"menuHistory" andValue:_menuHistoryArray];
                    }
 
                }
            }break;
            default:
                break;
        }
    }
}

#pragma mark -- getter --

- (UISearchBar *)mySearchBar{
    if (!_mySearchBar) {
        _mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 20, kScreenWidth, kNavigationHeight)];
        _mySearchBar.delegate=self;
        if (_searchType==FoodSearchType ||
            _searchType==FoodSelectSearchType) {
            _mySearchBar.placeholder=@"请输入食物名称";
        }else if (_searchType==FoodAddSearchType){
            if (self.type==1) {
                _mySearchBar.placeholder=@"请输入食物名称";
            } else {
                _mySearchBar.placeholder=@"请输入菜谱名称";
            }
        }else if (_searchType==KnowledgeSearchType){
            _mySearchBar.placeholder=@"请输入搜索关键词";
        }else if (_searchType==MenuSearchType){
            _mySearchBar.placeholder=@"请输入菜谱名称";
        }
        [_mySearchBar setBackgroundImage:[UIImage imageWithColor:kSystemColor size:CGSizeMake(kScreenWidth, kNavigationHeight)]];
    }
    return _mySearchBar;
}

#pragma mark 热门搜索和历史记录
-(TCSearchTableView *)searchTableView{
    if (_searchTableView==nil) {
        _searchTableView=[[TCSearchTableView alloc] initWithFrame:CGRectMake(0, kNavigationHeight + 20, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _searchTableView.searchDelegate=self;
    }
    return _searchTableView;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
