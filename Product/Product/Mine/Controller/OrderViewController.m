//
//  OrderViewController.m
//  Product
//
//  Created by vision on 17/12/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "OrderViewController.h"
#import "TJYMenuView.h"
#import "OrdersGoodsCell.h"
#import "OrderDetailsViewController.h"
#import "CheckLogisticsViewController.h"
#import "PayOrderViewController.h"
#import "CheckLogisticsViewController.h"
#import "OrderModer.h"
#import "OrderItemsModel.h"
#import "ShopCartViewController.h"
#import "QLAlertView.h"

@interface OrderViewController ()<TJYMenuViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSInteger   _page;
    NSInteger   _indexPath;
}
/// 菜单栏
@property(nonatomic,strong) TJYMenuView *menuView;
/// 菜单标题
@property (nonatomic ,strong) NSMutableArray *menuTitleArray;
///
@property (nonatomic ,strong) UITableView *orderTableView;
///
@property (nonatomic ,strong) NSMutableArray *orderListArray;
/// 订单类型
@property (nonatomic ,strong) NSArray *orderStatusArray;
/// 订单商品数据
@property (nonatomic ,strong) NSMutableArray *itemArray;
/// 暂无数据
@property (nonatomic ,strong) BlankView *blankView;

@end

@implementation OrderViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([TJYHelper sharedTJYHelper].isOrderListReload) {
        [TJYHelper sharedTJYHelper].isOrderListReload = NO;
        [self loadNewOrderData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"我的订单";
    
    _page = 1;
    [self initQrderVC];
//    [self requestQrderDataWithIndexStatus:_indexStatu];
    [self changeMenuItem];
}
#pragma mark ====== Build UI =======

- (void)initQrderVC{
    _orderStatusArray = @[@"all",@"unpayed",@"nodelivery",@"noreceived",@"finish",@"dead"],
    [self.view addSubview:self.menuView];
     self.menuView.menusArray = self.menuTitleArray;
    [self.view addSubview:self.orderTableView];
}
-(void)changeMenuItem{
    UIButton *btn;
    for (UIView  *view in _menuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_indexStatu+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [_menuView changeViewWithButton:btn];
}
#pragma mark ====== Request Data =======

- (void)requestQrderDataWithIndexStatus:(NSInteger)indexStatus{

    NSString *orderStatuStr = self.orderStatusArray[indexStatus];
    NSString *memberId = [NSUserDefaultInfos getValueforKey:USER_ID];
    
    NSString *body = [NSString stringWithFormat:@"member_id=%@&page_num=%ld&page_size=15&order_status=%@",memberId,_page,orderStatuStr];
    
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KShopOrderList body:body success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        NSArray *orderData = [resultDic objectForKey:@"orderData"];
        NSDictionary *pageDic = [resultDic objectForKey:@"pager"];
        NSInteger total = [[pageDic objectForKey:@"total"]integerValue];
        
        if (orderData.count > 0) {
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *dic in orderData) {
                OrderModer *orderModer = [[OrderModer alloc]init];
                [orderModer setValues:dic];
                [weakSelf.itemArray addObject:orderModer.item];
                [weakSelf.orderListArray addObject:orderModer];
            }
            weakSelf.orderTableView.mj_footer.hidden = (total - _page * 15) <= 0;
        }else{
            weakSelf.blankView.hidden = NO;
        }
        [weakSelf.orderTableView reloadData];
        [weakSelf.orderTableView.mj_footer endRefreshing];
        [weakSelf.orderTableView.mj_header endRefreshing];
    } failure:^(NSString *errorStr) {
         weakSelf.blankView.hidden = NO;
        [weakSelf.orderTableView.mj_footer endRefreshing];
        [weakSelf.orderTableView.mj_header endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== Event Reposon =======
// (取消订单，查看物流，确认收货，删除订单，，重新购买，再次购买，立即付款)
- (void)editShop:(UIButton *)sender{
    OrderModer *orderModer = [OrderModer new];
    if (sender.tag < 1999) {
        orderModer  = self.orderListArray[sender.tag - 1000];
    }else{
        orderModer  = self.orderListArray[sender.tag - 2000];
    }
    
    if ([orderModer.order_status isEqualToString:@"unpayed"]) {
        // 待付款
        if (sender.tag  < 1999) {// 取消订单
            QLAlertView *alertView = [[QLAlertView alloc]initWithTitle:@"" message:@"确定要取消该订单吗？" sureBtn:@"取消" cancleBtn:@"确定"];
            kSelfWeak;
            alertView.resultIndex = ^(NSInteger index){
                NSString *body = [NSString stringWithFormat:@"order_id=%@&status=dead",orderModer.order_id];
                
                [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KStatusUpdate body:body success:^(id json) {
                    
                    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
                    alertView.backgroundColor =  [[UIColor blackColor] colorWithAlphaComponent:0.8];
                    alertView.layer.cornerRadius = 10;
                    
                    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((150-30)/2, 15, 30, 30)];
                    imgView.image = [UIImage imageNamed:@"pd_ic_add_finish"];
                    [alertView addSubview:imgView];
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom+10, 150, 20)];
                    titleLabel.text = @"订单已取消";
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    titleLabel.textColor = [UIColor whiteColor];
                    titleLabel.font = [UIFont systemFontOfSize:14];
                    [alertView addSubview:titleLabel];
                    
                    [weakSelf.view showToast:alertView duration:1.0 position:CSToastPositionCenter];
                    [weakSelf loadNewOrderData];
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            };
            [alertView showQLAlertView];
        }else{  // 立即付款
            PayOrderViewController *payOrderVC = [PayOrderViewController new];
            payOrderVC.payAmount = [orderModer.amount doubleValue];
            payOrderVC.order_id = orderModer.order_id;
            payOrderVC.isOrderIn=YES;
            payOrderVC.createTimeStr=orderModer.createtime;
            [self.navigationController pushViewController:payOrderVC animated:YES];
        }
    }else if ([orderModer.order_status isEqualToString:@"nodelivery"]){
        // 待发货 -- 查看物流
        CheckLogisticsViewController *checkLogisticsVC = [CheckLogisticsViewController new];
        checkLogisticsVC.orderId = orderModer.order_id;
        checkLogisticsVC.orderStatus = orderModer.order_status;
        [self.navigationController pushViewController:checkLogisticsVC animated:YES];
        
    }else if ([orderModer.order_status isEqualToString:@"noreceived"]){
        // 等待收货
        if (sender.tag < 1999) {// 查看物流
            CheckLogisticsViewController *checkLogisticsVC = [CheckLogisticsViewController new];
            checkLogisticsVC.orderId = orderModer.order_id;
            checkLogisticsVC.orderStatus = orderModer.order_status;
            [self.navigationController pushViewController:checkLogisticsVC animated:YES];
        }else{// 确认收货
            QLAlertView *alertView = [[QLAlertView alloc]initWithTitle:@"" message:@"是否确认收货？" sureBtn:@"取消" cancleBtn:@"确定"];
            kSelfWeak;
            alertView.resultIndex = ^(NSInteger index){
                NSString *body = [NSString stringWithFormat:@"member_id=%@&order_id=%@",[NSUserDefaultInfos getValueforKey:USER_ID],orderModer.order_id];
                [[NetworkTool sharedNetworkTool]postShopMethodWithURL:kOrderReceive body:body success:^(id json) {
                    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
                    alertView.backgroundColor =  [[UIColor blackColor] colorWithAlphaComponent:0.8];
                    alertView.layer.cornerRadius = 10;
                    
                    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((150-30)/2, 15, 30, 30)];
                    imgView.image = [UIImage imageNamed:@"pd_ic_add_finish"];
                    [alertView addSubview:imgView];
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom+10, 150, 20)];
                    titleLabel.text = @"已确认收货";
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    titleLabel.textColor = [UIColor whiteColor];
                    titleLabel.font = [UIFont systemFontOfSize:14];
                    [alertView addSubview:titleLabel];
                    
                    [weakSelf.view showToast:alertView duration:1.0 position:CSToastPositionCenter];
                    
                    [weakSelf loadNewOrderData];
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];

            };
            [alertView showQLAlertView];
        }
    }else if ([orderModer.order_status isEqualToString:@"finish"]){
        // 交易完成 -- 再次购买（点击进入购物车页面，并自动在购物车中生成与该订单一致的商品（包括规格、数量））
        NSString *memberId = [NSUserDefaultInfos getValueforKey:USER_ID];
        NSString *body = [NSString stringWithFormat:@"member_id=%@&order_id=%@",memberId,orderModer.order_id];
        kSelfWeak;
        [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KBuyAgain body:body success:^(id json) {
            
            ShopCartViewController *shopCartVC = [ShopCartViewController new];
            [weakSelf.navigationController pushViewController:shopCartVC animated:YES];
            
        } failure:^(NSString *errorStr) {
           [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }else if ([orderModer.order_status isEqualToString:@"dead"]){
        // 交易取消
        if (sender.tag < 1999) {// 删除订单
            QLAlertView *alertView = [[QLAlertView alloc]initWithTitle:@"" message:@"确定要删除订单吗？" sureBtn:@"取消" cancleBtn:@"确定"];
            kSelfWeak;
            alertView.resultIndex = ^(NSInteger index){
                NSString *body = [NSString stringWithFormat:@"order_id=%@",orderModer.order_id];
                [[NetworkTool sharedNetworkTool]postShopMethodWithURL:kDeleaterOrder body:body success:^(id json) {
                    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
                    alertView.backgroundColor =  [[UIColor blackColor] colorWithAlphaComponent:0.8];
                    alertView.layer.cornerRadius = 10;
                    
                    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((150-30)/2, 15, 30, 30)];
                    imgView.image = [UIImage imageNamed:@"pd_ic_add_finish"];
                    [alertView addSubview:imgView];
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom+10, 150, 20)];
                    titleLabel.text = @"订单已删除";
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    titleLabel.textColor = [UIColor whiteColor];
                    titleLabel.font = [UIFont systemFontOfSize:14];
                    [alertView addSubview:titleLabel];
                    
                    [weakSelf.view showToast:alertView duration:1.0 position:CSToastPositionCenter];

                    [weakSelf loadNewOrderData];
                    
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            };
            [alertView showQLAlertView];
            
        }else{// 重新购买 -- （判断该商品是否还在，不在则提示用户）
            if (kIsArray(orderModer.item) && orderModer.item.count > 0) {
                NSString *memberId = [NSUserDefaultInfos getValueforKey:USER_ID];
                NSString *body = [NSString stringWithFormat:@"member_id=%@&order_id=%@",memberId,orderModer.order_id];
                kSelfWeak;
                [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KBuyAgain body:body success:^(id json) {
                    ShopCartViewController *shopCartVC = [ShopCartViewController new];
                    [weakSelf.navigationController pushViewController:shopCartVC animated:YES];
                    
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            }else{
                [self.view makeToast:@"该商品已失效" duration:1.0 position:CSToastPositionCenter];
            }
        }
    }
}
- (void)swipOrderTableView:(UISwipeGestureRecognizer *)gesture
{
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
        {
            _indexStatu++;
            if (_indexStatu>_orderStatusArray.count-1) {
                _indexStatu=_orderStatusArray.count;
                return;
            }
        }break;
        case UISwipeGestureRecognizerDirectionRight:
        {
            _indexStatu--;
            if (_indexStatu<0) {
                _indexStatu=0;
                return;
            }
        }
        default:
            break;
    }
    UIButton *btn;
    for (UIView  *view in _menuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_indexStatu+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [_menuView changeViewWithButton:btn];
}

#pragma mark ====== TJYMenuViewDelegate =======

- (void)menuView:(TJYMenuView *)menuView actionWithIndex:(NSInteger)index{
    self.orderTableView.mj_footer.hidden = YES;
    _page = 1;
    _indexStatu = index;
    [self.orderListArray removeAllObjects];
    [self.orderTableView reloadData];
    [self requestQrderDataWithIndexStatus:index];
}
#pragma mark ====== MJRefresh Data =======

- (void)loadNewOrderData{
    _page = 1;
    [self.orderListArray removeAllObjects];
    [self.itemArray removeAllObjects];
    [self requestQrderDataWithIndexStatus:_indexStatu];
}
- (void)loadMoreOrderData{
    _page ++;
    [self requestQrderDataWithIndexStatus:_indexStatu];
}
#pragma mark ====== UITableViewDataSource =======

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  _orderListArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    OrderModer *orderModel = self.orderListArray[section];
    if (kIsArray(orderModel.item) && orderModel.item.count > 0) {
        return orderModel.item.count;
    }else{
        return 0;
    }
}
#pragma mark ====== UITableViewDelegate =======

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100 * kScreenWidth/375;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 48;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 76;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0,0,kScreenWidth, 48)];
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    
    UILabel *intervalLens = [[UILabel alloc]initWithFrame:CGRectMake(0,0, kScreenWidth, 10)];
    intervalLens.backgroundColor =[UIColor bgColor_Gray];;
    [sectionHeaderView addSubview:intervalLens];
    
    UILabel *orderNoLab = [[UILabel alloc]initWithFrame:CGRectMake(15, intervalLens.bottom + 10, 200, 20)];
    orderNoLab.font = kFontSize(12);
    orderNoLab.textColor = UIColorHex(0x999999);
    [sectionHeaderView addSubview:orderNoLab];
    
    UILabel *orderTypeLab = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 115, orderNoLab.top, 100, 20)];
    orderTypeLab.textAlignment = NSTextAlignmentRight;
    orderTypeLab.font = kFontSize(12);
    [sectionHeaderView addSubview:orderTypeLab];
    
    if (kIsArray(self.orderListArray) && self.orderListArray.count > 0) {
        OrderModer *orderModer = self.orderListArray[section];
        orderNoLab.text =[NSString stringWithFormat:@"订单编号:%@",orderModer.order_id];
        orderTypeLab.text = [self getOrderStatusWithStatusStr:orderModer.order_status];
        orderTypeLab.textColor = [self getOrderStatusWithStatusTextColor:orderModer.order_status];
    }
    
    CALayer *line = [[CALayer alloc]init];
    line.frame = CGRectMake(15, sectionHeaderView.height - 0.5, kScreenWidth - 15, 0.5);
    line.backgroundColor = UIColorHex(0xe5e5e5).CGColor;
    [sectionHeaderView.layer addSublayer:line];
    
    return  sectionHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *sectionFooterView = [[UIView alloc]initWithFrame:CGRectMake(0,0,kScreenWidth, 76)];
    sectionFooterView.backgroundColor = [UIColor whiteColor];
    
    UILabel *totalLab = [[UILabel alloc]initWithFrame:CGRectMake(15, (sectionFooterView.height/2 - 20)/2, kScreenWidth - 30, 20)];
    totalLab.font = kFontSize(12);
    totalLab.textAlignment = NSTextAlignmentRight;
    totalLab.textColor = UIColorHex(0x999999);
    [sectionFooterView addSubview:totalLab];
    
    CALayer *line = [[CALayer alloc]init];
    line.frame = CGRectMake(15, sectionFooterView.height/2, kScreenWidth - 15, 0.5);
    line.backgroundColor = UIColorHex(0xe5e5e5).CGColor;
    [sectionFooterView.layer addSublayer:line];
    
    UIButton  *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(kScreenWidth - 177 , CGRectGetMaxY(line.frame) + 6, 76, 26);
    leftBtn.titleLabel.font = kFontSize(13);
    [leftBtn setTitleColor:UIColorHex(0x626262) forState:UIControlStateNormal];
    leftBtn.layer.borderWidth = 0.5;
    leftBtn.layer.cornerRadius = 5;
    leftBtn.tag = 1000 + section;
    [leftBtn addTarget:self action:@selector(editShop:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.layer.borderColor = UIColorHex(0x626262).CGColor;
    [sectionFooterView addSubview:leftBtn];
    
    UIButton  *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(leftBtn.right + 10, leftBtn.top, leftBtn.width, leftBtn.height);
    rightBtn.titleLabel.font = kFontSize(13);
    [rightBtn setTitleColor:UIColorHex(0x626262) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(editShop:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.layer.borderWidth = 0.5;
    rightBtn.layer.cornerRadius = 5;
    rightBtn.tag = 2000 + section;
    rightBtn.layer.borderColor = UIColorHex(0x626262).CGColor;
    [sectionFooterView addSubview:rightBtn];
    
    if (kIsArray(_orderListArray) && _orderListArray.count > 0) {
        OrderModer *orderModer  = self.orderListArray[section];
        
        if ([orderModer.order_status isEqualToString:@"unpayed"]) {
            // 待付款
            [leftBtn setTitle:@"取消订单" forState:UIControlStateNormal];
            [rightBtn setTitle:@"立即付款" forState:UIControlStateNormal];
            rightBtn.backgroundColor = UIColorHex(0xf33f00);
            [rightBtn setTitleColor:UIColorHex(0xffffff) forState:UIControlStateNormal];
            rightBtn.layer.borderColor =UIColorHex(0xf33f00).CGColor;
            
        }else if ([orderModer.order_status isEqualToString:@"nodelivery"]){
            // 待发货
            leftBtn.hidden = YES;
            [rightBtn setTitle:@"查看物流" forState:UIControlStateNormal];
            
        }else if ([orderModer.order_status isEqualToString:@"noreceived"]){
            // 等待收货
            [leftBtn setTitle:@"查看物流" forState:UIControlStateNormal];
            [rightBtn setTitle:@"确认收货" forState:UIControlStateNormal];
            
        }else if ([orderModer.order_status isEqualToString:@"finish"]){
            // 交易完成
            leftBtn.hidden = YES;
            [rightBtn setTitle:@"再次购买" forState:UIControlStateNormal];
            
        }else if ([orderModer.order_status isEqualToString:@"dead"]){
            // 交易取消
            [leftBtn setTitle:@"删除订单" forState:UIControlStateNormal];
            [rightBtn setTitle:@"重新购买" forState:UIControlStateNormal];
        }else{
            leftBtn.hidden = YES;
            rightBtn.hidden = YES;
        }
        // 订单总计
        totalLab.text = [NSString stringWithFormat:@"共计%@件商品 合计：¥%@",orderModer.itemnum,[NSString notRounding:orderModer.amount afterPoint:2]];
        
    }
    
    return  sectionFooterView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *orderCellIdentifier = @"ordersGoodsCellIdentifier";
    OrdersGoodsCell *ordersCell = [tableView dequeueReusableCellWithIdentifier:orderCellIdentifier];
    if (!ordersCell) {
        ordersCell = [[OrdersGoodsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderCellIdentifier];
    }
    if (kIsArray(_orderListArray) && _orderListArray.count > 0) {
        OrderModer *orderModel = self.orderListArray[indexPath.section];
        NSDictionary *itemDic= orderModel.item[indexPath.row];
        OrderItemsModel *orderItemsModel = [OrderItemsModel new];
        [orderItemsModel setValues:itemDic];
        [ordersCell cellWithModel:orderItemsModel];
    }
    
    return ordersCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.orderListArray.count > 0 && kIsArray(_orderListArray)) {
        OrderModer *orderModel = self.orderListArray[indexPath.section];
        OrderDetailsViewController *orderDetailsVC =[[OrderDetailsViewController alloc]init];
        orderDetailsVC.orderId = orderModel.order_id;
        [self.navigationController pushViewController:orderDetailsVC animated:YES];
    }
}
#pragma mark ====== 转换订单状态 =======

- (NSString *)getOrderStatusWithStatusStr:(NSString *)str{
    NSString *status;
    if ([str isEqualToString:@"unpayed"]) {
        status = @"等待付款";
    }else if ([str isEqualToString:@"nodelivery"]){
        status = @"等待发货";
    }else if ([str isEqualToString:@"noreceived"]){
        status = @"等待收货";
    }else if ([str isEqualToString:@"finish"]){
        status = @"交易完成";
    }else if ([str isEqualToString:@"dead"]){
        status = @"交易关闭";
    }
    return status;
}
- (UIColor *)getOrderStatusWithStatusTextColor:(NSString *)str{
    UIColor *color;
    if ([str isEqualToString:@"unpayed"]) {
        color = UIColorHex(0xf39800);
    }else {
        color = UIColorHex(0x626262);
    }
    return color;
}
- (UIView *)tableFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    footerView.backgroundColor = [UIColor bgColor_Gray];
    return footerView;
}

#pragma mark ====== Setter =======
- (TJYMenuView *)menuView{
    if (!_menuView) {
        _menuView = [[TJYMenuView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 49)];
        _menuView.delegate = self;
    }
    return _menuView;
}
- (UITableView *)orderTableView{
    if (!_orderTableView) {
        _orderTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight  + 49, kScreenWidth, kBodyHeight - _menuView.height) style:UITableViewStyleGrouped];
        _orderTableView.delegate = self;
        _orderTableView.dataSource = self;
        _orderTableView.backgroundColor = [UIColor bgColor_Gray];
        _orderTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _orderTableView.tableFooterView = [self tableFooterView];
        _orderTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipOrderTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_orderTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipOrderTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_orderTableView addGestureRecognizer:swipGestureRight];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewOrderData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _orderTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreOrderData)];
        footer.automaticallyRefresh = NO;
        _orderTableView.mj_footer = footer;
        footer.hidden=YES;
        
        [_orderTableView addSubview:self.blankView];
    }
    return _orderTableView;
}
- (BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc]initWithFrame:CGRectMake(0,90, kScreenWidth, kBodyHeight - 90) unOrderImg:@"pd_ic_order_none" tipText:@"暂无相关的订单记录" chooseText:@"去挑选几件喜欢的商品吧"];
        _blankView.hidden = YES;
    }
    return _blankView;
}
- (NSMutableArray *)menuTitleArray{
    if (!_menuTitleArray) {
        _menuTitleArray = [NSMutableArray arrayWithObjects:@"全部",@"待付款",@"待发货",@"待收货",@"已完成",@"已取消", nil];
    }
    return _menuTitleArray;
}
- (NSMutableArray *)orderListArray{
    if (!_orderListArray) {
        _orderListArray = [NSMutableArray array];
    }
    return _orderListArray;
}
- (NSMutableArray *)itemArray{
    if (!_itemArray) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
