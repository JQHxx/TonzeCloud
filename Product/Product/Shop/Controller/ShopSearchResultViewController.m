//
//  ShopSearchResultViewController.m
//  Product
//
//  Created by 肖栋 on 17/12/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopSearchResultViewController.h"
#import "BlankView.h"
#import "ShopTableViewCell.h"
#import "ShopModel.h"

@interface ShopSearchResultViewController ()<UITableViewDelegate,UITableViewDataSource>{

    NSMutableArray      *searchResultArr;
    BlankView         *blankView;
}

@end

@implementation ShopSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    searchResultArr= [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.tableView];
}
#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return searchResultArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentfy = @"ShopTableViewCell";
    ShopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfy];
    if (cell==nil) {
        cell = [[ShopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentfy];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ShopModel *shopModel = searchResultArr[indexPath.row];
    [cell CellShopModel:shopModel];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShopModel *shopModel = searchResultArr[indexPath.row];

    if ([self.shopSearchDelegate respondsToSelector:@selector(seleteSearchShopID:)]) {
        [self.shopSearchDelegate seleteSearchShopID:shopModel.default_product_id];
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 0.01;
}

#pragma mark -- Private Methods
-(void)setKeyword:(NSString *)keyword{
    _keyword=keyword;
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&search_keywords=%@",(long)self.page,_keyword];

    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopGoodsList body:body success:^(id json) {
        NSArray *result = [[json objectForKey:@"result"] objectForKey:@"goods"];
        NSInteger total = 0;
        NSDictionary *pager =[json objectForKey:@"pager"];
        if (kIsDictionary(pager)) {
            total= [[pager objectForKey:@"total"] integerValue];
        }
        if (kIsArray(result)) {
            NSMutableArray *shopListArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                ShopModel *model = [[ShopModel alloc] init];
                [model setValues:dict];
                [shopListArr addObject:model];
            }
            if (_page==1) {
                searchResultArr = shopListArr;
                blankView.hidden = shopListArr.count>0;
            } else {
                [searchResultArr addObjectsFromArray:shopListArr];
                self.tableView.mj_footer.hidden=(total -_page*20)<=0;
            }
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    } failure:^(NSString *errorStr) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
    
}
#pragma mark -- 加载最新数据
-(void)loadNewSearchShopData{
    _page =1;
    [self setKeyword:_keyword];
    
}
#pragma mark -- 加载更多数据
-(void)loadMoreSearchShopData{
    _page++;
    [self setKeyword:_keyword];
    
}
#pragma mark -- Setters and Getters
-(UITableView *)tableView{
    if (_tableView==nil) {
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.backgroundColor=[UIColor bgColor_Gray];
        _tableView.tableFooterView=[[UIView alloc] init];
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewSearchShopData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _tableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreSearchShopData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _tableView.mj_footer = footer;
        footer.hidden=YES;
        
        blankView = [[BlankView alloc]initWithShopFrame:CGRectMake(0, 100, kScreenWidth, kBodyHeight - 100) Searchimg:@"img_sch_none"title:@"没有找到相关的商品" text:@"去挑选几件喜欢的商品吧"];
        blankView.hidden = YES;
        [_tableView addSubview:blankView];
        
    }
    return _tableView;
}

@end
