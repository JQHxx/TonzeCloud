//
//  ShopViewController.m
//  Product
//
//  Created by vision on 17/12/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopViewController.h"
#import "ShopCartViewController.h"
#import "ShopNavView.h"
#import "YBPopupMenu.h"
#import "ShopModel.h"
#import "ShopTableViewCell.h"
#import "TJYMenuView.h"
#import "ShopDetailViewController.h"
#import "OnlineServiceViewController.h"
#import "ShopSearchViewController.h"
#import "OrderViewController.h"
#import "AddressManagerViewController.h"
#import "ShopGoodsModel.h"
#import "PPBadgeView.h"
#import "QLSearchBar.h"

@interface ShopViewController ()<UISearchBarDelegate,YBPopupMenuDelegate,UITableViewDelegate,UITableViewDataSource,TJYMenuViewDelegate>{

    NSMutableArray *shopArray;
    NSMutableArray *shopGoodsArr;
    NSInteger       seleteIndex;
    NSInteger       orderByIndex;
    NSInteger       page;
    
    UIButton       *defaultButton;
    UIButton       *pricrButton;
    
    NSDictionary   *param;
    NSMutableArray *shopListArray;
}

@property (nonatomic ,strong)ShopNavView *navView;

@property (nonatomic ,strong)QLSearchBar *mySearchBar;

@property (nonatomic ,strong)UITableView *shopTab;

@property (nonatomic ,strong)TJYMenuView *shopMenuView;
/// 购物车消息图标
@property (nonatomic ,strong) PPBadgeLabel  *cartMessageNumLab;
/// 更多消息图标
@property (nonatomic ,strong) PPBadgeLabel  *moreMessageNumLab;
/// 订单消息图标
@property (nonatomic ,strong) PPBadgeLabel  *orderMessageNumLab;
/// 无数据页面
@property (nonatomic ,strong) BlankView    *blankView;
@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"商城";
    self.isHiddenBackBtn=YES;

    shopArray = [[NSMutableArray alloc] init];
    shopGoodsArr = [[NSMutableArray alloc] init];
    orderByIndex = 1;
    seleteIndex = 0;
    page = 1;
    
    [self initShopView];
    [self loadShopMenuData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (kIsLogined) {
        [self loadCartShopNum];
        [self loadOrderShopNum];
    }else{
        self.orderMessageNumLab.hidden = YES;
        self.moreMessageNumLab.hidden = YES;
        self.cartMessageNumLab.hidden = YES;
    }
}
#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return shopArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentfy = @"ShopTableViewCell";
    ShopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfy];
    if (cell==nil) {
        cell = [[ShopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentfy];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ShopModel *shopModel = shopArray[indexPath.row];
    [cell CellShopModel:shopModel];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ShopModel *shopModel = shopArray[indexPath.row];
    ShopDetailViewController *shopDetailVC = [[ShopDetailViewController alloc] init];
    shopDetailVC.product_id = [shopModel.default_product_id integerValue];
    shopDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:shopDetailVC animated:YES];

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return shopArray.count>0?90:45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSInteger orderBy = [[param objectForKey:@"orderBy_id"] integerValue];
    
    UIView *shopHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, shopArray.count>0?90:45)];
    shopHeadView.backgroundColor = [UIColor whiteColor];
    [shopHeadView addSubview:self.shopMenuView];
    
    if (shopArray.count>0) {
        defaultButton =[[UIButton alloc] initWithFrame:CGRectMake(0, self.shopMenuView.bottom, kScreenWidth/2, 44)];
        [defaultButton setTitle:@"综合排序" forState:UIControlStateNormal];
        [defaultButton setTitleColor:[UIColor colorWithHexString:orderBy==1?@"0xf39800":@"0x626262"] forState:UIControlStateNormal];
        defaultButton.titleLabel.font = [UIFont systemFontOfSize:15];
        defaultButton.tag = 100;
        [defaultButton addTarget:self action:@selector(defaultButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [shopHeadView addSubview:defaultButton];
        
        pricrButton =[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2, self.shopMenuView.bottom, kScreenWidth/2, 44)];
        [pricrButton setTitle:@"价格排序" forState:UIControlStateNormal];
        [pricrButton setTitleColor:[UIColor colorWithHexString:orderBy==1?@"0x626262":@"0xf39800"] forState:UIControlStateNormal];
        pricrButton.titleLabel.font = [UIFont systemFontOfSize:15];
        pricrButton.tag = 101;
        [pricrButton addTarget:self action:@selector(defaultButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        if (orderBy==1) {
            [pricrButton setImage:[UIImage imageNamed:@"pd_ic_sort_nor"] forState:UIControlStateNormal];
        }else{
            [pricrButton setImage:[UIImage imageNamed:orderBy==5?@"pd_ic_sort_high":@"pd_ic_sort_low"] forState:UIControlStateNormal];
        }
        [pricrButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:4];
        [shopHeadView addSubview:pricrButton];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, self.shopMenuView.bottom+10, 1, 20)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [shopHeadView addSubview:lineLabel];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, pricrButton.bottom, kScreenWidth, 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [shopHeadView addSubview:line];
        
    }
    return shopHeadView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    return nil;
}
#pragma mark -- UISearchBarDelegate
#pragma mark -- 搜索
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [TJYHelper sharedTJYHelper].isSearchKeyboard = YES;
    ShopSearchViewController *shopSearchVC = [[ShopSearchViewController alloc] init];
    shopSearchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:shopSearchVC animated:YES];
}
#pragma mark -- YBPopupMenuDelegate
#pragma mark -- 更多
- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu{
    
    if (index==0) {
        OnlineServiceViewController *onlineServiceVC=[[OnlineServiceViewController alloc] init];
        onlineServiceVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:onlineServiceVC animated:YES];
    }else if (index==1){
        if (kIsLogined) {
            OrderViewController *orderVC = [[OrderViewController alloc] init];
            orderVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:orderVC animated:YES];
        } else {
            [self pushToFastLogin];
        }
    }else{
        if (kIsLogined) {
            AddressManagerViewController *AddressManagerVC = [[AddressManagerViewController alloc] init];
            AddressManagerVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:AddressManagerVC animated:YES];
        } else {
            [self pushToFastLogin];
        }
    }
}
#pragma mark -- TJYMenuViewDelegate
#pragma mark -- 选择分类菜单
-(void)menuView:(TJYMenuView *)menuView actionWithIndex:(NSInteger)index{
    seleteIndex = index;
    ShopGoodsModel *model = shopGoodsArr[index];
    [self loadShopData:model.cat_id orderBy:orderByIndex];
}
#pragma mark -- Event response
#pragma mark -- 获取商品列表数据
- (void)loadShopData:(NSInteger)cat_id orderBy:(NSInteger)order{
    
    NSString *body = [NSString stringWithFormat:@"page_num=%ld&page_size=20&cat_id=%ld&orderBy_id=%ld",(long)page,cat_id,order];
    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopGoodsList body:body success:^(id json) {
        NSArray *result = [[json objectForKey:@"result"] objectForKey:@"goods"];
        NSInteger total = 0;
        NSDictionary *pager =[json objectForKey:@"pager"];
        if (kIsDictionary(pager)) {
            total= [[pager objectForKey:@"total"] integerValue];
        }
        param = [json objectForKey:@"param"];
        if (kIsArray(result)) {
            NSMutableArray *shopListArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in result) {
                ShopModel *model = [[ShopModel alloc] init];
                [model setValues:dict];
                [shopListArr addObject:model];
            }
            if (page==1) {
                shopArray = shopListArr;
                self.blankView.hidden = shopListArr.count > 0;
            } else {
                [shopArray addObjectsFromArray:shopListArr];
            }
            self.shopTab.mj_footer.hidden=(total -page*20)<=0;
        }
        [self.shopTab.mj_header endRefreshing];
        [self.shopTab.mj_footer endRefreshing];
        [_shopTab reloadData];
    } failure:^(NSString *errorStr) {
        [self.shopTab.mj_header endRefreshing];
        [self.shopTab.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 获取商品分类
- (void)loadShopMenuData{

    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopGoods body:@"" success:^(id json) {
        NSArray *result = [json objectForKey:@"result"];
        shopListArray = [[NSMutableArray alloc] init];
        if (kIsArray(result)&&result.count>0) {
            for (NSDictionary *dict in result) {
                ShopGoodsModel *model = [[ShopGoodsModel alloc] init];
                [model setValues:dict];
                [shopListArray addObject:model.cat_name];
                [shopGoodsArr addObject:model];
            }
        }
        self.shopMenuView.shopMenusArray = shopListArray;
        ShopGoodsModel *model = shopGoodsArr[0];
        [self loadShopData:model.cat_id orderBy:orderByIndex];
    } failure:^(NSString *errorStr) {
        [self.shopTab.mj_header endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 获取购物车商品数量
- (void)loadCartShopNum{
    NSString *user_id = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *body=[NSString stringWithFormat:@"member_id=%@",user_id];
   
    [[NetworkTool sharedNetworkTool] getShopMethodWithURL:kShopCartGoodsList body:body isLoading:NO success:^(id json) {
        NSDictionary *cartInfo=[json objectForKey:@"result"];
        if (kIsDictionary(cartInfo)) {
            self.cartMessageNumLab.hidden = [[cartInfo objectForKey:@"total_num"] integerValue]>0?NO:YES;
            self.cartMessageNumLab.text =[[cartInfo objectForKey:@"total_num"] integerValue]>99?@"99+":[NSString stringWithFormat:@"%ld",[[cartInfo objectForKey:@"total_num"] integerValue]];
        }else{
            self.cartMessageNumLab.hidden = YES;
        }
    } failure:^(NSString *errorStr) {

    }];
}
#pragma mark -- 获取订单数量
- (void)loadOrderShopNum{
    NSString *user_id = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *body = [NSString stringWithFormat:@"member_id=%@",user_id];
    [[NetworkTool sharedNetworkTool] postShopMethodWithoutLoadingURL:kShopOrderNum body:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            
            NSInteger order_count =[[result objectForKey:@"nopayed_count"] integerValue]+[[result objectForKey:@"nodelivery_count"] integerValue]+[[result objectForKey:@"noreceived_count"] integerValue];
            
            self.moreMessageNumLab.hidden = order_count>0?NO:YES;
            self.orderMessageNumLab.hidden =order_count>0?NO:YES;
            self.moreMessageNumLab.text =order_count>99?@"99+":[NSString stringWithFormat:@"%ld",order_count];
            self.orderMessageNumLab.text =order_count>99?@"99+":[NSString stringWithFormat:@"%ld",order_count];
        }
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark -- 综合排序／价格排序
- (void)defaultButtonAction:(UIButton *)button{
    if (button.tag==100) {
        orderByIndex = 1;
    } else {
        if (orderByIndex==5) {
            orderByIndex=4;
        } else {
            orderByIndex = 5;
        }
    }
    ShopGoodsModel *model = shopGoodsArr[seleteIndex];
    [self loadShopData:model.cat_id orderBy:orderByIndex];
}
#pragma mark -- 左右侧滑
-(void)swipShopTableView:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        page=1;
        seleteIndex++;
        if (seleteIndex+1> shopListArray.count) {
            seleteIndex= shopListArray.count-1;
            return;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        page=1;
        seleteIndex--;
        if (seleteIndex<0) {
            seleteIndex=0;
            return;
        }
    }
    UIButton *btn;
    for (UIView  *view in self.shopMenuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)seleteIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [self.shopMenuView changeViewWithButton:btn];
}
#pragma mark -- 加载最新数据
-(void)loadNewShopData{
    page =1;
    if (shopGoodsArr.count>0) {
        ShopGoodsModel *model = shopGoodsArr[seleteIndex];
        [self loadShopData:model.cat_id orderBy:orderByIndex];
    }else{
        [self loadShopMenuData];
    }
}
#pragma mark -- 加载更多数据
-(void)loadMoreShopData{
    page++;
    ShopGoodsModel *model = shopGoodsArr[seleteIndex];
    [self loadShopData:model.cat_id orderBy:orderByIndex];
    
}
#pragma mark -- private Methons
#pragma mark -- 初始化商城界面
- (void)initShopView{
    [self.view addSubview:self.navView];
    [self.view addSubview:self.mySearchBar];
    [self.view addSubview:self.shopTab];
}

#pragma mark -- 更多
-(void)getMoreListAction{
    
    [YBPopupMenu showRelyOnView:self.navView.rightBtn titles:@[@"客服",@"我的订单",@"收货地址管理"] icons:nil menuWidth:120 otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.priorityDirection = YBPopupMenuPriorityDirectionTop;
        popupMenu.borderWidth = 0.5;
        popupMenu.borderColor = UIColorHex(0xeeeeeee);
        popupMenu.delegate = self;
        popupMenu.textColor = UIColorHex(0x626262);
        popupMenu.fontSize = 14;
        
        [popupMenu addSubview:self.orderMessageNumLab];
    }];
}
#pragma mark -- setters or getters
#pragma mark -- 导航栏／搜索／购物车／更多
- (ShopNavView *)navView{
    if (_navView==nil) {
        _navView = [[ShopNavView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNewNavHeight)];
        kSelfWeak;
        _navView.navBtnClickBlock = ^(NSInteger tag) {
            switch (tag) {
                case 1000:
                {
                    if (kIsLogined) {
                        ShopCartViewController *cartVC=[[ShopCartViewController alloc] init];
                        cartVC.hidesBottomBarWhenPushed=YES;
                        [weakSelf.navigationController pushViewController:cartVC animated:YES];
                    } else {
                        [self pushToFastLogin];
                    }
                }break;
                case 1001:
                {
                    [weakSelf getMoreListAction];
                }break;
                default:
                    break;
            }
        };
        [_navView addSubview:self.cartMessageNumLab];
        [_navView addSubview:self.moreMessageNumLab];
    }
    return _navView;
}
#pragma mark -- 搜索框
-(UISearchBar *)mySearchBar{
    if (_mySearchBar==nil) {
        _mySearchBar=[[QLSearchBar alloc] initWithFrame:CGRectMake(18,  KStatusHeight + (kNavigationHeight - 30)/2, kScreenWidth-115, 30) leftImage:[UIImage imageNamed:@"ic_shop_search"] placeholderColor:[UIColor whiteColor]];
        _mySearchBar.delegate=self;
        _mySearchBar.placeholder =@"输入商品关键词";
        _mySearchBar.hasCentredPlaceholder = NO;
        _mySearchBar.backgroundImage = [UIImage imageWithColor:UIColorFromRGB(0xf9c877) size:_mySearchBar.bounds.size];
        _mySearchBar.layer.cornerRadius = 15;
        _mySearchBar.layer.masksToBounds = YES;
    }
    return _mySearchBar;
}
#pragma mark -- 商城
- (UITableView *)shopTab{
    if (_shopTab==nil) {
        _shopTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight- kNewNavHeight-kTabbarHeight) style:UITableViewStylePlain];
        _shopTab.backgroundColor = [UIColor bgColor_Gray];
        _shopTab.delegate = self;
        _shopTab.dataSource = self;
        _shopTab.tableFooterView = [[UIView alloc] init];
        _shopTab.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);

        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipShopTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_shopTab addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipShopTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_shopTab addGestureRecognizer:swipGestureRight];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewShopData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _shopTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreShopData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _shopTab.mj_footer = footer;
        footer.hidden=YES;
        
        [_shopTab addSubview:self.blankView];
    }
    return _shopTab;
}
#pragma mark -- 商品分类
- (TJYMenuView *)shopMenuView{
    if (_shopMenuView==nil) {
        _shopMenuView=[[TJYMenuView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 45)];
        _shopMenuView.delegate = self;
    }
    return _shopMenuView;
}
#pragma mark ====== 购物车消息图标 =======
-(PPBadgeLabel *)cartMessageNumLab{
    if (!_cartMessageNumLab) {
        _cartMessageNumLab = [[PPBadgeLabel alloc]initWithFrame:CGRectMake( kScreenWidth-65, 26, 16, 16)];
        _cartMessageNumLab.hidden = YES;
    }
    return _cartMessageNumLab;
}
#pragma mark ====== 更多消息图标 =======
-(PPBadgeLabel *)moreMessageNumLab{
    if (!_moreMessageNumLab) {
        _moreMessageNumLab = [[PPBadgeLabel alloc]initWithFrame:CGRectMake( kScreenWidth-25, 26, 16, 16)];
        _moreMessageNumLab.hidden = YES;
    }
    return _moreMessageNumLab;
}
#pragma mark ====== 订单消息图标 =======
-(PPBadgeLabel *)orderMessageNumLab{
    if (!_orderMessageNumLab) {
        _orderMessageNumLab = [[PPBadgeLabel alloc]initWithFrame:CGRectMake( 90, 60, 16, 16)];
        _orderMessageNumLab.hidden = YES;
    }
    return _orderMessageNumLab;
}
- (BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc]initWithFrame:CGRectMake(0,64 , kScreenWidth, kScreenHeight - 64 -49-45) img:@"img_tips_no" text:@"暂无相关商品"];
        _blankView.hidden = YES;
    }
    return _blankView;
}
@end
