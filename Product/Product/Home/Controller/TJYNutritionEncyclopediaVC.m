//
//  TJYNutritionEncyclopediaVC.m
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYNutritionEncyclopediaVC.h"
#import "TJYMenuView.h"
#import "TJYSearchFoodVC.h"
#import "TJYArticleTableView.h"
#import "BasewebViewController.h"
#import "TJYArticleclassModel.h"
#import "TJYArticleModel.h"
#import "TonzeHelpTool.h"

@interface TJYNutritionEncyclopediaVC ()<TJYMenuViewDelegate,TCArticleExpertDelegate>

@property (nonatomic ,copy)    NSMutableArray *titleArray;

@property (nonatomic ,copy)    NSMutableArray *idArray;

@property (nonatomic ,copy)    NSMutableArray  *articleArray;

@property (nonatomic ,assign)  NSInteger       selectIndex;

@property (nonatomic ,assign)  NSInteger       articlePage;

@property (nonatomic ,strong)  TJYMenuView *menuView;

@property (nonatomic ,strong)  TJYArticleTableView *articleTableView;

@property (nonatomic ,strong) BlankView *blankView;

@end

@implementation TJYNutritionEncyclopediaVC

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.baseTitle = @"营养百科";
    self.rightImageName = @"ic_top_search";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self loadData];
    [self buildUI];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([TJYHelper sharedTJYHelper].isReloadArticle==YES) {
        [self requestArticleList:_selectIndex];
        [TJYHelper sharedTJYHelper].isReloadArticle=NO;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:[NSString stringWithFormat:@"004-04-01-%02ld",(long)_selectIndex] type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:[NSString stringWithFormat:@"004-04-01-%02ld",(long)_selectIndex] type:2];
#endif
}

#pragma mark -- Right Btn

-(void)rightButtonAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-04-02"];
#endif
    [TonzeHelpTool sharedTonzeHelpTool].searchType=KnowledgeSearchType;
    TJYSearchFoodVC *search =[TJYSearchFoodVC new];
    search.searchType = KnowledgeSearchType;
    [self push:search];
}
#pragma mark -- Build UI

- (void)buildUI{
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.articleTableView];
}
#pragma mark -- Load Data

- (void)loadData{
    _titleArray = [[NSMutableArray alloc] init];
    _idArray =  [[NSMutableArray alloc] init];
    _articleArray = [[NSMutableArray alloc] init];
    _articlePage = 1;
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postMethodWithURL:kArticleCategory body:nil success:^(id json) {
        NSArray *arr = [json objectForKey:@"result"];
        for (NSDictionary * dic in arr) {
            TJYArticleclassModel *articleclassModelmodel = [TJYArticleclassModel new];
            [articleclassModelmodel setValues:dic];
            [weakSelf.titleArray addObject:articleclassModelmodel.name];
            [weakSelf.idArray  addObject:articleclassModelmodel.article_classification_id];
        }
        weakSelf.menuView.menusArray = [NSMutableArray arrayWithArray:_titleArray];
        [weakSelf requestArticleList:0];
        
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark --- 请求文章列表数据

- (void)requestArticleList:(NSInteger)index{
    
    NSString *urlString = nil;
    NSString *classificationId = [NSString stringWithFormat:@"%@",_idArray[index]];
    urlString = [NSString stringWithFormat:@"page_num=%ld&page_size=20&classification_id=%@",(long)_articlePage,classificationId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kArticleList body:urlString success:^(id json) {
        NSDictionary *pager=[json objectForKey:@"pager"];
        if (kIsDictionary(pager)&&pager.count>0) {
            NSInteger totalValues=[[pager valueForKey:@"total"] integerValue];
            weakSelf.articleTableView.mj_footer.hidden=(totalValues-_articlePage*20)<=0;
        }
        NSArray *dataArray = [json objectForKey:@"result"];
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        if (dataArray.count>0 && kIsArray(dataArray)) {
            weakSelf.blankView.hidden = YES;
//            NSInteger totalValues = 0;
//            
//            weakSelf.articleTableView.mj_footer.hidden=(totalValues-_articlePage*20)<=0;
            for (int i=0; i<dataArray.count; i++) {
                
                TJYArticleModel *articleModel=[[TJYArticleModel alloc] init];
                [articleModel setValues:dataArray[i]];
                [tempArr addObject:articleModel];
            }
            if (_articlePage==1) {
                _articleArray = [[NSMutableArray alloc] init];
                _articleArray=tempArr;
            }else{
                [_articleArray addObjectsFromArray:tempArr];
            }
            weakSelf.articleTableView.articlesArray = _articleArray;
            [weakSelf.articleTableView reloadData];
            [weakSelf.articleTableView.mj_header endRefreshing];
            [weakSelf.articleTableView.mj_footer endRefreshing];
            
        } else {
            weakSelf.articleTableView.mj_footer.hidden=YES;
            weakSelf.articleTableView.mj_header.hidden = YES;
            tempArr = [[NSMutableArray alloc] init];
            _articleArray = [[NSMutableArray alloc] init];
            weakSelf.articleTableView.articlesArray = _articleArray;
            [weakSelf.articleTableView reloadData];
            _blankView.hidden=_articleArray.count>0;
        }
    } failure:^(NSString *errorStr) {
         weakSelf.blankView.hidden= NO;
        [weakSelf.articleTableView.mj_header endRefreshing];
        [weakSelf.articleTableView.mj_footer endRefreshing];
        [weakSelf.articleArray removeAllObjects];
        [weakSelf.articleTableView reloadData];
    }];
}
#pragma mark -- 加载最新数据
- (void)loadNewArticleData{
    _articlePage =1;
    [self requestArticleList:_selectIndex];
}
#pragma mark -- 加载更多数据
- (void)loadMoreArticleData{
    _articlePage++;
    [self requestArticleList:_selectIndex];
}
#pragma mark  TCMenuViewDelegate
- (void)menuView:(TJYMenuView *)menuView actionWithIndex:(NSInteger)index
{
    
#if !DEBUG
    if (_idArray.count>0) {
        NSString *targetId = [NSString stringWithFormat:@"004-04-01-%@",_idArray[index]];
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:targetId];
    }
#endif
    _articlePage=1;
    _selectIndex = index;
    [self requestArticleList:_selectIndex];
}
#pragma mark  TCArticleExpertDelegate

- (void)returnarticleIndex:(NSInteger)expert_id articleTitle:(NSString *)title isCollection:(BOOL)isCollection index:(NSInteger)index imgUrl:(NSString *)imgUrl{
    [TonzeHelpTool sharedTonzeHelpTool].viewType=WebViewTypeArticle;
    [TonzeHelpTool sharedTonzeHelpTool].article_id=expert_id;
    BasewebViewController *webVC=[[BasewebViewController alloc] init];
    webVC.titleText=@"文章详情";
    webVC.titleName = title;
    NSString *url = [NSString stringWithFormat:@"%@",kHostURL];
    url = [url stringByReplacingOccurrencesOfString:@"/%@" withString:@""];
    webVC.urlStr=[NSString stringWithFormat:@"%@/article/%ld",url,(long)expert_id];
    webVC.hidesBottomBarWhenPushed=YES;
    webVC.articleId = expert_id;
    webVC.isWebUrl = NO;
    webVC.isCollect = isCollection;
    webVC.imageUrl = imgUrl;
    [self.navigationController pushViewController:webVC animated:YES];
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
        }
        default:
            break;
    }
    
    UIButton *btn;
    for (UIView  *view in _menuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_selectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [_menuView changeViewWithButton:btn];
}

#pragma mark -- getter --
/* 分类菜单 */
-(TJYMenuView *)menuView{
    if (_menuView==nil) {
        _menuView=[[TJYMenuView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 49)];
        _menuView.delegate = self;
    }
    return _menuView;
}

-(TJYArticleTableView *)articleTableView{
    if (!_articleTableView) {
        _articleTableView=[[TJYArticleTableView alloc] initWithFrame:CGRectMake(0, 64+49, kScreenWidth, kScreenHeight-113) style:UITableViewStylePlain];
        _articleTableView.type=1;
        _articleTableView.articleDetagate = self;
        _articleTableView.scrollEnabled=YES;
        _articleTableView.backgroundColor=[UIColor bgColor_Gray];
        [_articleTableView addSubview:self.blankView];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewArticleData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _articleTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreArticleData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _articleTableView.mj_footer = footer;
        footer.hidden = YES;
        
        // 左右滑动
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_articleTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_articleTableView addGestureRecognizer:swipGestureRight];
    }
    return _articleTableView;
}
- (BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无数据"];
        _blankView.hidden = YES;
    }
    return _blankView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
