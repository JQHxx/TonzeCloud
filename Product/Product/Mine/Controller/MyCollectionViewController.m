//
//  MyCollectionViewController.m
//  Product
//
//  Created by vision on 17/4/18.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "TJYFoodLibraryCell.h"
#import "TJYArticleTableViewCell.h"
#import "TJYRelatedRecipesCell.h"
#import "TJYFoodListModel.h"
#import "TJYArticleModel.h"
#import "ClickViewGroup.h"
#import "BlankView.h"
#import "MenuCollectModel.h"
#import "TJYFoodDetailsVC.h"
#import "TJYMenuDetailsVC.h"
#import "BasewebViewController.h"
#import "OrdersGoodsCell.h"
#import "GoodsFavoriteModel.h"
#import "ShopDetailViewController.h"

@interface MyCollectionViewController ()<ClickViewGroupDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSInteger           goodsPage;    //商品记录页数
    NSInteger           foodPage;    //血糖记录页数
    NSInteger           menuPage;     //饮食记录页数
    NSInteger           articlePage;    //运动记录页数
    NSMutableArray      *goodsArray;       //商品
    NSMutableArray      *foodArray;        //食物
    NSMutableArray      *cookMenuArray;    //菜谱
    NSMutableArray      *articleArray;     //文章

    NSArray             *cateArray;
    NSArray             *typeArray;
    NSInteger           selectedIndex;
}

@property (nonatomic,strong)ClickViewGroup  *itemGroupView;
@property (nonatomic,strong)UITableView     *collectTableView;
@property (nonatomic,strong)BlankView       *blankView;

@end

@implementation MyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"我的收藏";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    foodPage=menuPage=articlePage=goodsPage=1;
    
    foodArray=[[NSMutableArray alloc] init];
    cookMenuArray=[[NSMutableArray alloc] init];
    articleArray=[[NSMutableArray alloc] init];
    goodsArray = [[NSMutableArray alloc]init];
    cateArray=[NSArray arrayWithObjects:@"商品",@"食材",@"菜谱",@"营养百科",nil];
    
    typeArray=@[@"ingredient",@"ingredient",@"cook",@"article"];
    
    [self initMyCollectionView];
    
    [self getMyCollectList];
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (selectedIndex == 0) {
        return goodsArray.count;
    }else if (selectedIndex==1) {
        return foodArray.count;
    }else if (selectedIndex==2){
        return cookMenuArray.count;
    }else{
        return articleArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ordersGoodsCellIdentifier = @"ordersGoodsCellIdentifier";
    if (selectedIndex == 0) {
        OrdersGoodsCell  *ordersGoodsCell = [tableView dequeueReusableCellWithIdentifier:ordersGoodsCellIdentifier];
        if (!ordersGoodsCell) {
            ordersGoodsCell = [[OrdersGoodsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ordersGoodsCellIdentifier];
        }
        ordersGoodsCell.selectionStyle=UITableViewCellSelectionStyleNone;
        GoodsFavoriteModel *goodsModel = goodsArray[indexPath.row];
        [ordersGoodsCell initWithShopFavoriteModel:goodsModel];
        return ordersGoodsCell;
    }else if (selectedIndex==1) {
        static NSString *cellIdentifier=@"TJYFoodLibraryCell";
        TJYFoodLibraryCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TJYFoodLibraryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        TJYFoodListModel *foodModel=foodArray[indexPath.row];
        [cell initWithFoodListModel:foodModel orderbyStr:@"id"];
        return cell;
    }else if (selectedIndex==2){
        static NSString *cellIdentifier=@"TJYMenuTableViewCell";
        TJYRelatedRecipesCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TJYRelatedRecipesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        MenuCollectModel *menuModel=cookMenuArray[indexPath.row];
        [cell menuCellDisplayWithModel:menuModel];
        return cell;
    }else{
        static NSString *cellIdentifier=@"TJYArticleTableViewCell";
        TJYArticleTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[TJYArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        TJYArticleModel *article=articleArray[indexPath.row];
        [cell cellDisplayWithModel:article type:0 searchText:@""];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (selectedIndex == 0) {
        return 100;
    }else if (selectedIndex==1) {
        return 58;
    }else if (selectedIndex==2){
        return 90 *kScreenWidth/320;
    }else{
       return 100 * kScreenWidth/320;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 0.01;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (selectedIndex == 0) {
        // 商品详情
        GoodsFavoriteModel *goodsModel = goodsArray[indexPath.row];
        if ([goodsModel.is_del integerValue]==1) {
            [self.view makeToast:@"该货品已不存在" duration:1.0 position:CSToastPositionCenter];
        } else {
            ShopDetailViewController *shopDetailVC = [[ShopDetailViewController alloc] init];
            shopDetailVC.product_id =  goodsModel.product_id;
            [self.navigationController pushViewController:shopDetailVC animated:YES];
        }

    }else if (selectedIndex==1) {
        TJYFoodListModel *foodModel=foodArray[indexPath.row];
        TJYFoodDetailsVC  *foodDetailsVC=[[TJYFoodDetailsVC alloc] init];
        foodDetailsVC.food_id=foodModel.target_id;
        [self.navigationController pushViewController:foodDetailsVC animated:YES];
    }else if (selectedIndex==2){
        MenuCollectModel *menuModel=cookMenuArray[indexPath.row];
        TJYMenuDetailsVC *menuDetailsVC=[[TJYMenuDetailsVC alloc] init];
        menuDetailsVC.menuid=menuModel.target_id;
        [self.navigationController pushViewController:menuDetailsVC animated:YES];
    }else{
        TJYArticleModel *article=articleArray[indexPath.row];
        BasewebViewController *webVC=[[BasewebViewController alloc] init];
        webVC.titleText=@"文章详情";
        NSString *tempUrlStr=[NSString stringWithFormat:@"article/%ld",(long)article.target_id];
        webVC.urlStr=[NSString stringWithFormat:kHostURL,tempUrlStr];
        webVC.articleId = article.target_id;
        webVC.isCollect = article.is_collection;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}
//侧滑允许编辑cell
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (selectedIndex==0) {
        return YES;
    }
    return NO;
}
//执行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
   
    GoodsFavoriteModel *goodsModel = goodsArray[indexPath.row];
    NSString *user_id = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *body = [NSString stringWithFormat:@"member_id=%@&gid=%ld",user_id,(long)goodsModel.gnotify_id];
    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopDelFavorite body:body success:^(id json) {
        NSMutableArray *shopArray = [[NSMutableArray alloc] init];
        for ( GoodsFavoriteModel *Model in goodsArray) {
            if (Model.gnotify_id != goodsModel.gnotify_id) {
                [shopArray addObject:Model];
            }
        }
        goodsArray = shopArray;
        self.blankView.hidden = goodsArray.count>0;
        [self.collectTableView reloadData];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
//侧滑出现的文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"删除";
}

#pragma mark -- TJYMenuViewDelegate
-(void)ClickViewGroupActionWithIndex:(NSUInteger)index{
    selectedIndex=index;
    [self getMyCollectList];
}

#pragma mark -- Event Response
-(void)swipRecordTableView:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        selectedIndex++;
        if (selectedIndex+1>cateArray.count) {
            selectedIndex=cateArray.count-1;
            return;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        selectedIndex--;
        if (selectedIndex<0) {
            selectedIndex=0;
            return;
        }
    }
    UIButton *btn;
    for (UIView *view in self.itemGroupView.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&(view.tag == selectedIndex+100)) {
            btn = (UIButton*)view;
        }
    }
    [self.itemGroupView changeViewWithButton:btn];
}


#pragma mark -- Private Methods
#pragma mark 初始化视图
-(void)initMyCollectionView{
    [self.view addSubview:self.itemGroupView];
    [self.view addSubview:self.collectTableView];
    [self.collectTableView addSubview:self.blankView];
    self.blankView.hidden=YES;
}

#pragma mark 加载最新收藏
-(void)loadNewRecordData{
    if (selectedIndex==0) {
        goodsPage = 1;
    }else if (selectedIndex==1) {
        foodPage=1;
    }else if (selectedIndex==2){
        menuPage=1;
    }else{
        articlePage=1;
    }
    [self getMyCollectList];
}

#pragma mark 加载更多收藏
-(void)loadMoreRecordData{
    if (selectedIndex==0) {
        goodsPage++;
    }else if (selectedIndex==1) {
        foodPage++;
    }else if (selectedIndex==2){
        menuPage++;
    }else{
        articlePage++;
    }
    [self getMyCollectList];
}

#pragma mark 获取我的收藏列表
-(void)getMyCollectList{
    if (selectedIndex==0) {
        NSString *user_id = [NSUserDefaultInfos getValueforKey:USER_ID];
        NSString *body = [NSString stringWithFormat:@"member_id=%@&page_num=%ld&page_size=20",user_id,foodPage];
        __weak typeof(self) weakSelf=self;
        [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopFavoriteList body:body success:^(id json) {
            NSArray *result = [[json objectForKey:@"result"] objectForKey:@"aProduct"];
            NSInteger total = 0;
            NSDictionary *pager =[[json objectForKey:@"result"] objectForKey:@"pager"];
            if (kIsDictionary(pager)) {
                total= [[pager objectForKey:@"total"] integerValue];
            }
            if (kIsArray(result)&&result.count>0) {
                NSMutableArray *goodsArr = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in result) {
                    GoodsFavoriteModel *model = [[GoodsFavoriteModel alloc] init];
                    [model setValues:dict];
                    [goodsArr addObject:model];
                }
                weakSelf.blankView.hidden = goodsArr.count>0;
                if (goodsPage==1) {
                    goodsArray = goodsArr;
                } else {
                    [goodsArray addObjectsFromArray:goodsArr];
                }
                weakSelf.collectTableView.mj_footer.hidden=(total -goodsPage*20)<=0;
            }else{
                weakSelf.blankView.hidden=NO;
            }
            [weakSelf.collectTableView reloadData];
            [weakSelf.collectTableView.mj_header endRefreshing];
            [weakSelf.collectTableView.mj_footer endRefreshing];
        } failure:^(NSString *errorStr) {
            [weakSelf.collectTableView.mj_header endRefreshing];
            [weakSelf.collectTableView.mj_footer endRefreshing];
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }else{
        NSString *targetType=typeArray[selectedIndex];
        NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=10&target_type=%@",(long)foodPage,targetType];
        __weak typeof(self) weakSelf=self;
        [[NetworkTool sharedNetworkTool] postMethodWithURL:kGetCollectList body:body success:^(id json) {
            NSArray *result=[json objectForKey:@"result"];
            if (kIsArray(result)&&result.count>0) {
                weakSelf.blankView.hidden=YES;
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                if (selectedIndex==1) {
                    for (NSDictionary *dict in result) {
                        TJYFoodListModel *food=[[TJYFoodListModel alloc] init];
                        [food setValues:dict];
                        [tempArr addObject:food];
                    }
                    if (foodPage==1) {
                        foodArray=tempArr;
                    }else{
                        [foodArray addObjectsFromArray:tempArr];
                    }
                }else if (selectedIndex==2){
                    for (NSDictionary *dict in result) {
                        MenuCollectModel *menu=[[MenuCollectModel alloc] init];
                        [menu setValues:dict];
                        [tempArr addObject:menu];
                    }
                    if (menuPage==1) {
                        cookMenuArray=tempArr;
                    }else{
                        [cookMenuArray addObjectsFromArray:tempArr];
                    }
                }else{
                    for (NSDictionary *dict in result) {
                        TJYArticleModel *article=[[TJYArticleModel alloc] init];
                        [article setValues:dict];
                        [tempArr addObject:article];
                    }
                    if (articlePage==1) {
                        articleArray=tempArr;
                    }else{
                        [articleArray addObjectsFromArray:tempArr];
                    }
                }
            }else{
                weakSelf.blankView.hidden=NO;
            }
            [weakSelf.collectTableView reloadData];
            [weakSelf.collectTableView.mj_header endRefreshing];
            [weakSelf.collectTableView.mj_footer endRefreshing];
        } failure:^(NSString *errorStr) {
            [weakSelf.collectTableView.mj_header endRefreshing];
            [weakSelf.collectTableView.mj_footer endRefreshing];
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];

    }
}

#pragma mark -- Setters 
#pragma mark  标签栏
-(ClickViewGroup *)itemGroupView{
    if (_itemGroupView==nil) {
        _itemGroupView=[[ClickViewGroup alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 40) titles:cateArray color:kSystemColor];
        _itemGroupView.viewDelegate=self;
        
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(0, 39, kScreenWidth, 1)];
        lab.backgroundColor=kLineColor;
        [_itemGroupView addSubview:lab];
    }
    return _itemGroupView;
}

#pragma mark 主视图
-(UITableView *)collectTableView{
    if (!_collectTableView) {
        _collectTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, self.itemGroupView.bottom+5, kScreenWidth, kBodyHeight-70) style:UITableViewStylePlain];
        _collectTableView.backgroundColor=[UIColor bgColor_Gray];
        _collectTableView.dataSource=self;
        _collectTableView.delegate=self;
        _collectTableView.showsVerticalScrollIndicator=NO;
        _collectTableView.tableFooterView=[[UIView alloc] init];
        _collectTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewRecordData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _collectTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreRecordData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _collectTableView.mj_footer = footer;
        footer.hidden=YES;
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipRecordTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_collectTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipRecordTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_collectTableView addGestureRecognizer:swipGestureRight];
    }
    return _collectTableView;
}

#pragma mark 无数据空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView=[[BlankView alloc] initWithFrame:self.collectTableView.bounds img:@"img_pub_none" text:@"暂无收藏"];
    }
    return _blankView;
}

@end
