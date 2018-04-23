//
//  OrderDetailsViewController.m
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "OrderDetailsViewController.h"
#import "OrdersGoodsCell.h"
#import "SubscriberInfoCell.h"
#import "OrderDetailsCell.h"
#import "CheckLogisticsViewController.h"
#import "OrderInfoModel.h"
#import "OrderConsigneeModel.h"
#import "OrderItemsModel.h"
#import "PayOrderViewController.h"
#import "ShopCartViewController.h"
#import "QLCoreTextManager.h"
#import "QLAlertView.h"

@interface OrderDetailsViewController ()<UITableViewDelegate,UITableViewDataSource,OrderDetailCellDelegate>
{
    NSTimer *_orderTime;
}
@property (nonatomic,strong) UITableView *orderDetailsTab;
/// 底部工具栏视图
@property (nonatomic ,strong) UIView *toolbarView;
/// 左功能按钮
@property (nonatomic ,strong) UIButton *leftBtn;
/// 右功能按钮
@property (nonatomic ,strong) UIButton *rightBtn;
/// 拨打电话
@property (nonatomic ,strong) UIButton *callPhoneBtn;
/// 订单价格
@property (nonatomic ,strong) UILabel *orderPriceLab;
/// 商品数据
@property (nonatomic ,strong) NSMutableArray *itemsArray;
/// 订单模型
@property (nonatomic ,strong) OrderInfoModel *orderInfoModel;
/// 地址信息
@property (nonatomic ,strong) OrderConsigneeModel *orderConsigneeModel;
/// 倒计时
@property (nonatomic ,strong) UILabel *countdownLab;

@end

@implementation OrderDetailsViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"订单详情";
    
    [self initOrderDetailsVC];
    [self requestOrderDetailsData];
}
#pragma mark ====== Build UI =======
- (void)initOrderDetailsVC{
    [self.view addSubview:self.orderDetailsTab];
    [self.view addSubview:self.toolbarView];
}
#pragma mark ====== Request Data =======
- (void)requestOrderDetailsData{
    [self.itemsArray removeAllObjects];
    
    NSString *memberId = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *body = [NSString stringWithFormat:@"member_id=%@&order_id=%@",memberId,_orderId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KShopOrderDetail body:body success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        NSDictionary *orderDataDic = [resultDic objectForKey:@"orderData"];
        //  -- 订单数据集合
        NSDictionary *orderInfoDic = [orderDataDic objectForKey:@"order_info"];
        OrderInfoModel *orderInfoModel = [OrderInfoModel new];
        [orderInfoModel setValues:orderInfoDic];
        weakSelf.orderInfoModel = orderInfoModel;
        //  -- 收件人信息
        NSDictionary *consigneeDic = [orderDataDic objectForKey:@"consignee"];
        weakSelf.orderConsigneeModel = [OrderConsigneeModel new];
        [weakSelf.orderConsigneeModel setValues:consigneeDic];
        
        //  -- 商品信息
        NSArray *orderItemsArray = [orderDataDic objectForKey:@"order_items"];
        if (kIsArray(orderItemsArray) && orderItemsArray.count > 0) {
            for (NSDictionary *dic in orderItemsArray) {
                OrderItemsModel *orderItemsModel = [OrderItemsModel new];
                [orderItemsModel setValues:dic];
                [weakSelf.itemsArray addObject:orderItemsModel];
            }
        }
        
        if ([weakSelf.orderInfoModel.order_status isEqualToString:@"unpayed"]) {
            weakSelf.orderPriceLab.hidden = NO;
            weakSelf.leftBtn.hidden = NO;
            weakSelf.rightBtn.hidden = NO;
            weakSelf.callPhoneBtn.hidden = YES;
            NSString *totalStr =  [NSString stringWithFormat:@"应付金额: ¥%@",[NSString notRounding:weakSelf.orderInfoModel.total_trade_fee afterPoint:2]];
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:totalStr];
            [QLCoreTextManager setAttributedValue:attStr text:@"应付金额:" font:kFontSize(15 * kScreenWidth/375) color:UIColorHex(0x999999)];
            weakSelf.orderPriceLab.attributedText = attStr;
    
            [weakSelf.rightBtn setTitleColor:UIColorHex(0xffffff) forState:UIControlStateNormal];
            weakSelf.rightBtn.backgroundColor = UIColorHex(0xf33f00);
            weakSelf.rightBtn.layer.borderColor = UIColorHex(0xf33f00).CGColor;
            [weakSelf.leftBtn setTitle:@"取消订单" forState:UIControlStateNormal];
            [weakSelf.rightBtn setTitle:@"立即付款" forState:UIControlStateNormal];
            [weakSelf createTimer];       // 倒计时
        }else if ([weakSelf.orderInfoModel.order_status isEqualToString:@"nodelivery"]){
            weakSelf.leftBtn.hidden = YES;
            weakSelf.rightBtn.hidden = NO;
            weakSelf.callPhoneBtn.hidden = YES;
            weakSelf.orderPriceLab.hidden = YES;
            [weakSelf.rightBtn setTitle:@"查看物流" forState:UIControlStateNormal];
        }else if ([weakSelf.orderInfoModel.order_status isEqualToString:@"noreceived"]){
            weakSelf.leftBtn.hidden = NO;
            weakSelf.rightBtn.hidden = NO;
            weakSelf.callPhoneBtn.hidden = YES;
            weakSelf.orderPriceLab.hidden = YES;
            [weakSelf.leftBtn setTitle:@"查看物流" forState:UIControlStateNormal];
            [weakSelf.rightBtn setTitle:@"确认收货" forState:UIControlStateNormal];
        }else if ([weakSelf.orderInfoModel.order_status isEqualToString:@"finish"]){
            weakSelf.leftBtn.hidden = YES;
            weakSelf.rightBtn.hidden = NO;
            weakSelf.callPhoneBtn.hidden = NO;
            weakSelf.orderPriceLab.hidden = NO;
            weakSelf.orderPriceLab.font = kFontSize(14);
            [weakSelf.rightBtn setTitle:@"再次购买" forState:UIControlStateNormal];
            NSString *totalStr = @"售后请联系客服：400-900-4288";
            weakSelf.orderPriceLab.textColor = kSystemColor;
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:totalStr];
            [QLCoreTextManager setAttributedValue:attStr text:@"售后请联系客服：" font:kFontSize(12) color:UIColorFromRGB(0x999999)];
            weakSelf.orderPriceLab.attributedText = attStr;
            [weakSelf.rightBtn setTitle:@"再次购买" forState:UIControlStateNormal];
        }else if ([weakSelf.orderInfoModel.order_status isEqualToString:@"dead"]){
            weakSelf.leftBtn.hidden = NO;
            weakSelf.rightBtn.hidden = NO;
            weakSelf.callPhoneBtn.hidden = YES;
            weakSelf.orderPriceLab.hidden = YES;
            [weakSelf.leftBtn setTitle:@"删除订单" forState:UIControlStateNormal];
            [weakSelf.rightBtn setTitle:@"重新购买" forState:UIControlStateNormal];
        }else{
            weakSelf.leftBtn.hidden = YES;
            weakSelf.rightBtn.hidden = YES;
            weakSelf.orderPriceLab.hidden = YES;
            weakSelf.callPhoneBtn.hidden = YES;
        }
        [weakSelf.orderDetailsTab reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== 刷新数据 =======

- (void)refreshOrderDetailsData{
    
    [_itemsArray removeAllObjects];
    [self requestOrderDetailsData];
}
#pragma mark ====== Countdown 倒计时 =======

- (void)createTimer{
    _orderTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFirMethod:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_orderTime forMode:NSRunLoopCommonModes];
}
#pragma mark ====== 倒计时计算 =======

-(void)timerFirMethod:(NSTimer *)theTimer{
    
    NSTimeInterval timeInterval = [[TJYHelper sharedTJYHelper] getOrderCountdownWithCreationTime:_orderInfoModel.created];

    int days = (int)(timeInterval/(3600*24));
    int hours = (int)((timeInterval-days*24*3600)/3600);
    int minutes = (int)(timeInterval-days*24*3600-hours*3600)/60;
    int seconds = timeInterval-days*24*3600-hours*3600-minutes*60;
    
    NSString *hoursStr;NSString *minutesStr;NSString *secondsStr;
    //小时
    hoursStr = [NSString stringWithFormat:@"%d",hours];
    //分钟
    if(minutes<10)
        minutesStr = [NSString stringWithFormat:@"0%d",minutes];
    else
        minutesStr = [NSString stringWithFormat:@"%d",minutes];
    //秒
    if(seconds < 10)
        secondsStr = [NSString stringWithFormat:@"0%d", seconds];
    else
        secondsStr = [NSString stringWithFormat:@"%d",seconds];
    if (hours<=0&&minutes<=0&&seconds<=0) {
        [_orderTime invalidate];    // 停止倒计时
        _orderTime  = nil;
        _countdownLab.hidden = YES;
        [TJYHelper sharedTJYHelper].isOrderListReload = YES;
        kSelfWeak;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [weakSelf requestOrderDetailsData];
        });
    }
    _countdownLab.text =  [NSString stringWithFormat:@"剩余：%@小时 %@分 %@秒",hoursStr , minutesStr,secondsStr];
}

#pragma mark ====== Event Reponse =======
// 拨打电话
- (void)callPhoneAction{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt:%@",@"4009004288"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
- (void)toolbarAction:(UIButton *)sender{
    
    if (sender.tag == 1000) {
        if ([_orderInfoModel.order_status isEqualToString:@"unpayed"]) {
            // 待付款 - 取消订单
            QLAlertView *alertView = [[QLAlertView alloc]initWithTitle:@"" message:@"确定要取消该订单吗？" sureBtn:@"取消" cancleBtn:@"确定"];
            kSelfWeak;
            alertView.resultIndex = ^(NSInteger index){
                NSString *body = [NSString stringWithFormat:@"order_id=%@&status=dead",_orderId];
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
                    // 刷新
                    [weakSelf refreshOrderDetailsData];
                    
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            };
            [alertView showQLAlertView];
        }else if ([_orderInfoModel.order_status isEqualToString:@"noreceived"]){
            // 待收货 - 查看物流
            CheckLogisticsViewController *checkLogisticsVC = [[CheckLogisticsViewController alloc]init];
            checkLogisticsVC.orderId = _orderInfoModel.order_id;
            checkLogisticsVC.orderStatus = _orderInfoModel.order_status;
            [self.navigationController pushViewController:checkLogisticsVC animated:YES];
        
        }else if ([_orderInfoModel.order_status isEqualToString:@"dead"]){
            // 已取消 - 删除订单
            QLAlertView *alertView = [[QLAlertView alloc]initWithTitle:@"" message:@"确定要删除该订单吗？" sureBtn:@"取消" cancleBtn:@"确定"];
            kSelfWeak;
            alertView.resultIndex = ^(NSInteger index){
                NSString *body = [NSString stringWithFormat:@"order_id=%@",_orderId];
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
                    
                    [TJYHelper sharedTJYHelper].isOrderListReload = YES;
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            };
            [alertView showQLAlertView];
        }
    }else{
        if ([_orderInfoModel.order_status isEqualToString:@"unpayed"]) {
            // 等待付款 - 立即付款
            PayOrderViewController *payOrderVC = [PayOrderViewController new];
            payOrderVC.payAmount = [_orderInfoModel.total_trade_fee doubleValue];
            payOrderVC.order_id = _orderInfoModel.order_id;
            payOrderVC.createTimeStr=_orderInfoModel.created;
            payOrderVC.isOrderIn=YES;
            [self.navigationController pushViewController:payOrderVC animated:YES];
            
        }else if ([_orderInfoModel.order_status isEqualToString:@"nodelivery"]){
            // 待发货 - 查看物流
            CheckLogisticsViewController *checkLogisticsVC = [[CheckLogisticsViewController alloc]init];
            checkLogisticsVC.orderId = _orderInfoModel.order_id;
            checkLogisticsVC.orderStatus = _orderInfoModel.order_status;
            [self.navigationController pushViewController:checkLogisticsVC animated:YES];
            
        }else if ([_orderInfoModel.order_status isEqualToString:@"noreceived"]){
            // 待收货 - 确认收货
            QLAlertView *alertView = [[QLAlertView alloc]initWithTitle:@"" message:@"是否确认收货？" sureBtn:@"取消" cancleBtn:@"确定"];
            kSelfWeak;
            alertView.resultIndex = ^(NSInteger index){
                NSString *body = [NSString stringWithFormat:@"member_id=%@&order_id=%@",[NSUserDefaultInfos getValueforKey:USER_ID],_orderInfoModel.order_id];
                [[NetworkTool sharedNetworkTool]postShopMethodWithURL:kOrderReceive body:body success:^(id json) {
                    [TJYHelper sharedTJYHelper].isOrderListReload = YES;
                    
                    
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
                    
                    [weakSelf  refreshOrderDetailsData];
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            };
            [alertView showQLAlertView];
        }else if ([_orderInfoModel.order_status isEqualToString:@"finish"] || [_orderInfoModel.order_status isEqualToString:@"dead"]){
            // 交易关闭 - 再次购买
            NSString *memberId = [NSUserDefaultInfos getValueforKey:USER_ID];
            NSString *body = [NSString stringWithFormat:@"member_id=%@&order_id=%@",memberId,_orderId];
            kSelfWeak;
            [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KBuyAgain body:body success:^(id json) {
                
                ShopCartViewController *shopCartVC = [ShopCartViewController new];
                [weakSelf.navigationController pushViewController:shopCartVC animated:YES];
            } failure:^(NSString *errorStr) {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
        }
    }
}
#pragma mark ====== UITableViewDataSource =======

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0: // 收货信息、留言
        {
            if ([_orderInfoModel.order_status isEqualToString:@"dead"] ||[_orderInfoModel.order_status isEqualToString:@"unpayed"]) {
                return kIsEmptyString(_orderInfoModel.buyer_memo) ? 1 : 2;
            }else{
                return kIsEmptyString(_orderInfoModel.buyer_memo) ? 2 : 3;
            }
        }break;
        case 1: // 商品信息
        {
            return self.itemsArray.count;
        }break;
        case 2: // 订单信息
        {
            return 2;
        }break;
        case 3: // 订单详情
        {
            if ([_orderInfoModel.order_status isEqualToString:@"dead"] ||[_orderInfoModel.order_status isEqualToString:@"unpayed"]) {
                return 3;
            }else{
                return 5;
            }
        }break;
        default:
            break;
    }
    return 1;
}
#pragma mark ====== UITableViewDelegate =======

- (CGFloat )calculateHeightWithStr:(NSString *)str{
    
    CGSize addStrSize = [str boundingRectWithSize:CGSizeMake(kScreenWidth - 52, 100) withTextFont:kFontSize(13)];
    CGFloat cellHigth = addStrSize.height > 18 ? addStrSize.height + 3 : 18;
    return  cellHigth + 42;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            // 计算地址和留言高度
            if (![NSString isEmpty:_orderInfoModel.order_status]) {
                if ([_orderInfoModel.order_status isEqualToString:@"dead"] ||[_orderInfoModel.order_status isEqualToString:@"unpayed"]) {
                    if (kIsEmptyString(_orderInfoModel.buyer_memo)) {
                        return [self calculateHeightWithStr:_orderConsigneeModel.receiver_address];
                    }else{
                        switch (indexPath.row) {
                            case 0:
                            {
                                return [self calculateHeightWithStr:_orderConsigneeModel.receiver_address];
                            }break;
                            case 1:
                            {
                                return [self calculateHeightWithStr:_orderInfoModel.buyer_memo];
                            }break;
                            default:
                                break;
                        }
                    }
                }else if([_orderInfoModel.order_status isEqualToString:@"noreceived"] || [_orderInfoModel.order_status isEqualToString:@"finish"] || [_orderInfoModel.order_status isEqualToString:@"nodelivery"]){
                    switch (indexPath.row) {
                        case 0:
                        {
                            return 60;
                        }break;
                        case 1:
                        {
                          return  [self calculateHeightWithStr:_orderConsigneeModel.receiver_address];
                        }break;
                        case 2:
                        {
                          return [self calculateHeightWithStr:_orderInfoModel.buyer_memo];
                        }break;
                        default:
                            break;
                    }
                }
            }else{
                    return 60.0f;
            }
        }
            break;
        case 1:
        {
           return  100.0f* kScreenWidth/375;
        }
            break;
        case 2:
        {
            return 30.0f;
        }
            break;
        case 3:
        {
            return 30.0f;
        }
            break;
        default:
            break;
    }
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
        {
            return 90.0f;
        }
            break;
        case 1:
        {
            return 38.0f;
        }
            break;
        case 2:
        {
            return 40.0f;
        }
            break;
        case 3:
        {
            return 5.0f;
        }
            break;
        default:
            break;
    }
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if ( section == 3 || section == 2) {
        return 15;
    }else{
        return 10;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionHeaderView = [[UIView alloc]init];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, (38 - 20)/2, 200, 20)];
    titleLab.font = kFontSize(12);
    titleLab.textColor = UIColorHex(0x999999);
    [sectionHeaderView addSubview:titleLab];
    
    switch (section) {
        case 0:
        {
            sectionHeaderView.frame = CGRectMake(0, 0, kScreenWidth, 90);
            sectionHeaderView.backgroundColor = UIColorHex(0xffcc00);
            UIImageView *iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(15, (sectionHeaderView.height - 32/2)/2, 32/2, 32/2)];
            [sectionHeaderView addSubview:iconImg];
            
            titleLab.frame = CGRectMake(iconImg.right + 6, iconImg.top - 2, 150, 20);
            titleLab.font = kFontSize(15);
            titleLab.textColor = UIColorHex(0xffffff);
            
            if ([_orderInfoModel.order_status isEqualToString:@"unpayed"]) {
                [sectionHeaderView addSubview:self.countdownLab];
                titleLab.text = @"等待付款";
                iconImg.image = [UIImage imageNamed:@"pd_ic_ime"];
            }else if ([_orderInfoModel.order_status isEqualToString:@"nodelivery"]){
                titleLab.text = @"等待发货";
                iconImg.image = [UIImage imageNamed:@"pd_ic_send"];
            }else if ([_orderInfoModel.order_status isEqualToString:@"noreceived"]){
                 titleLab.text = @"等待收货";
                 iconImg.image = [UIImage imageNamed:@"pd_ic_sending"];
            }else if ([_orderInfoModel.order_status isEqualToString:@"finish"]){
                 titleLab.text = @"交易完成";
                 iconImg.image = [UIImage imageNamed:@"pd_ic_finish"];
            }else if ([_orderInfoModel.order_status isEqualToString:@"dead"]){
                 titleLab.text = @"交易关闭";
                 iconImg.image = [UIImage imageNamed:@"pd_ic_close"];
            }
        }break;
        case 1:
        {
            sectionHeaderView.frame = CGRectMake(0, 0, kScreenWidth, 38);
            sectionHeaderView.backgroundColor = [UIColor whiteColor];
            titleLab.text = @"商品信息";
            
            CALayer *lens = [[CALayer alloc]init];
            lens.frame = CGRectMake(15, sectionHeaderView.height - 0.5, kScreenWidth - 15, 0.5);
            lens.backgroundColor = UIColorFromRGB(0xe5e5e5).CGColor;
            [sectionHeaderView.layer addSublayer:lens];
        }break;
        case 2:
        {
            sectionHeaderView.frame = CGRectMake(0, 0, kScreenWidth, 40);
            sectionHeaderView.backgroundColor = [UIColor whiteColor];
            titleLab.text = @"订单信息";
            
            CALayer *lens = [[CALayer alloc]init];
            lens.frame = CGRectMake(15, sectionHeaderView.height - 0.5 - 2, kScreenWidth - 15, 0.5);
            lens.backgroundColor = UIColorFromRGB(0xe5e5e5).CGColor;
            [sectionHeaderView.layer addSublayer:lens];
            
            UILabel *whiteLens = [[UILabel alloc]initWithFrame:CGRectMake(0, sectionHeaderView.height - 2, kScreenWidth, 2)];
            whiteLens.backgroundColor = [UIColor whiteColor];
            [sectionHeaderView addSubview:whiteLens];
        }break;
        case 3:
        {
            sectionHeaderView.frame = CGRectMake(0, 0, kScreenWidth, 5);
            sectionHeaderView.backgroundColor = [UIColor whiteColor];
        }break;
        default:
            break;
    }
    return sectionHeaderView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *sectionFooterView = [[UIView alloc]init];
    sectionFooterView.backgroundColor = [UIColor bgColor_Gray];
    if (section == 3 || section == 2) {
        sectionFooterView.frame = CGRectMake(0, 0, kScreenWidth, 15);
        UILabel *lens = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 5)];
        lens.backgroundColor = [UIColor whiteColor];
        [sectionFooterView addSubview:lens];
    }else{
        sectionFooterView.frame = CGRectMake(0, 0, kScreenWidth, 10);
    }
    return sectionFooterView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *subscriberInfoCellIdentifier =@"subscriberInfoCellIdentifier";
    static NSString *goodsCellIdentifier = @"goodsCellIdentifier";
    static NSString *orderDetailsCellIdentifier = @"orderDetailsCellIdentifier";
    static NSString *ordersGoodsCellIdentifier = @"ordersGoodsCellIdentifier";
    
    switch (indexPath.section) {
        case 0:
        {
            SubscriberInfoCell *subscriberInfoCell = [tableView dequeueReusableCellWithIdentifier:subscriberInfoCellIdentifier];
            if (!subscriberInfoCell) {
                subscriberInfoCell = [[SubscriberInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subscriberInfoCellIdentifier];
            }
            
            if ([_orderInfoModel.order_status isEqualToString:@"unpayed"] || [_orderInfoModel.order_status isEqualToString:@"dead"]) {
                if (indexPath.row == 0) {
                    if (!kIsEmptyString(_orderConsigneeModel.receiver_name) && !kIsEmptyString(_orderConsigneeModel.receiver_phone)) {
                        subscriberInfoCell.iconImgStr = @"pd_ic_address";
                        NSString *tel = [_orderConsigneeModel.receiver_phone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                        NSString *useInfoStr = [NSString stringWithFormat:@"%@   %@",_orderConsigneeModel.receiver_name,tel];
                        subscriberInfoCell.titleStr = useInfoStr;
                        NSString *addressStr = [NSString stringWithFormat:@"%@",_orderConsigneeModel.receiver_address];
                        subscriberInfoCell.subStr = addressStr;
                    }
                }else{
                    if (!kIsEmptyString(_orderInfoModel.buyer_memo)) {
                        subscriberInfoCell.iconImgStr = @"pd_ic_msg";
                        subscriberInfoCell.titleStr = @"买家留言";
                        subscriberInfoCell.subStr = kIsEmptyString(_orderInfoModel.buyer_memo) ? @"" : _orderInfoModel.buyer_memo;
                    }
                }
            }else if([_orderInfoModel.order_status isEqualToString:@"noreceived"] || [_orderInfoModel.order_status isEqualToString:@"finish"] || [_orderInfoModel.order_status isEqualToString:@"nodelivery"]  ){
                if (indexPath.row == 0) {
                    subscriberInfoCell.titleStr = @"查看物流信息";
                    subscriberInfoCell.subStr = @"";
                    subscriberInfoCell.arrowImg.hidden = NO;
                    subscriberInfoCell.iconImgStr = @"pd_ic_wuliu";
                }else if (indexPath.row == 1){
                    if (!kIsEmptyString(_orderConsigneeModel.receiver_name) && !kIsEmptyString(_orderConsigneeModel.receiver_phone)) {
                        subscriberInfoCell.iconImgStr = @"pd_ic_address";
                        NSString *tel = [NSString ql_phoneNumberCodeText:_orderConsigneeModel.receiver_phone];
                        NSString *useInfoStr = [NSString stringWithFormat:@"%@   %@",_orderConsigneeModel.receiver_name,tel];
                        subscriberInfoCell.titleStr = useInfoStr;
                        NSString *addressStr = [NSString stringWithFormat:@"%@",_orderConsigneeModel.receiver_address];
                        subscriberInfoCell.subStr = addressStr;
                    }
                }else{
                    if (!kIsEmptyString(_orderInfoModel.buyer_memo)) {
                        subscriberInfoCell.iconImgStr = @"pd_ic_msg";
                        subscriberInfoCell.titleStr = @"买家留言";
                        subscriberInfoCell.subStr = kIsEmptyString(_orderInfoModel.buyer_memo) ? @"" : _orderInfoModel.buyer_memo;
                    }
                }
            }
                return subscriberInfoCell;
        }
            break;
        case 1:
        {
            OrdersGoodsCell *ordersGoodsCell = [tableView dequeueReusableCellWithIdentifier:ordersGoodsCellIdentifier];
            if (!ordersGoodsCell) {
                ordersGoodsCell = [[OrdersGoodsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ordersGoodsCellIdentifier];
            }
            if (_itemsArray.count > 0) {
                OrderItemsModel *orderItemsModel = self.itemsArray[indexPath.row];
                [ordersGoodsCell cellWithModel:orderItemsModel];
            }
            return ordersGoodsCell;
        }
            break;
        case 2:
        {
            OrderDetailsCell *goodsCell = [tableView dequeueReusableCellWithIdentifier:goodsCellIdentifier];
            if (!goodsCell) {
                goodsCell = [[OrderDetailsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:goodsCellIdentifier];
            }
            if (indexPath.row == 0) {
                goodsCell.titleLab.text = @"商品合计：";
                goodsCell.contentLab.text = kIsEmptyString(_orderInfoModel.total_goods_fee) ? @"" : [NSString stringWithFormat:@"¥%@",[NSString notRounding:_orderInfoModel.total_goods_fee afterPoint:2]];
            }else{
                goodsCell.titleLab.text = @"运费：";
                goodsCell.contentLab.text = kIsEmptyString(_orderInfoModel.shipping_fee) ? @"" : [NSString stringWithFormat:@"¥%@",[NSString notRounding:_orderInfoModel.shipping_fee afterPoint:2]];
            }
            return goodsCell;
        }
            break;
        case 3:
        {
            OrderDetailsCell *orderDetailsCell = [tableView dequeueReusableCellWithIdentifier:orderDetailsCellIdentifier];
            if (!orderDetailsCell) {
                orderDetailsCell = [[OrderDetailsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderDetailsCellIdentifier];
            }
            orderDetailsCell.delegate = self;
            
            if ([_orderInfoModel.order_status isEqualToString:@"unpayed"] || [_orderInfoModel.order_status isEqualToString:@"dead"]) {
                if (indexPath.row == 0 ) {
                    orderDetailsCell.pasteBtn.hidden = NO;
                    orderDetailsCell.titleLab.text = @"订单编号：";
                    orderDetailsCell.contentLab.text = kIsEmptyString(_orderInfoModel.order_id) ? @"" : _orderInfoModel.order_id;
                }else if (indexPath.row == 1 ){
                    orderDetailsCell.pasteBtn.hidden = YES;
                    orderDetailsCell.titleLab.text = @"提交时间：";
                     orderDetailsCell.contentLab.text = kIsEmptyString(_orderInfoModel.created) ? @"" :[[TJYHelper sharedTJYHelper]timeWithTimeIntervalString:_orderInfoModel.created format:@"yyyy-MM-dd HH:mm"];
                }else if (indexPath.row == 2){
                    orderDetailsCell.pasteBtn.hidden = YES;
                    orderDetailsCell.titleLab.text = @"支付方式：";
                    orderDetailsCell.contentLab.text = kIsEmptyString(_orderInfoModel.payment_type) ? @"" : _orderInfoModel.payment_type;
                }
            }else if([_orderInfoModel.order_status isEqualToString:@"nodelivery"] || [_orderInfoModel.order_status isEqualToString:@"noreceived"] ||[_orderInfoModel.order_status isEqualToString:@"finish"] ){
                if (indexPath.row == 0) {
                    orderDetailsCell.pasteBtn.hidden = NO;
                    orderDetailsCell.titleLab.text = @"订单编号：";
                    orderDetailsCell.contentLab.text = kIsEmptyString(_orderInfoModel.order_id) ? @"" :_orderInfoModel.order_id;
                }else if (indexPath.row == 1 ){
                    orderDetailsCell.pasteBtn.hidden = YES;
                    orderDetailsCell.titleLab.text = @"提交时间：";
                    orderDetailsCell.contentLab.text = kIsEmptyString(_orderInfoModel.created) ? @"" :[[TJYHelper sharedTJYHelper]timeWithTimeIntervalString:_orderInfoModel.created format:@"yyyy-MM-dd HH:mm"];
                }else if (indexPath.row == 2){
                    orderDetailsCell.pasteBtn.hidden = YES;
                    orderDetailsCell.titleLab.text = @"支付方式：";
                    orderDetailsCell.contentLab.text = kIsEmptyString(_orderInfoModel.payment_type) ? @"" : _orderInfoModel.payment_type;
                }else if (indexPath.row == 3){
                    orderDetailsCell.pasteBtn.hidden = YES;
                    orderDetailsCell.titleLab.text = @"实付金额：";
                    orderDetailsCell.contentLab.text = kIsEmptyString(_orderInfoModel.total_trade_fee) ? @"" : [NSString stringWithFormat:@"¥%@",[NSString notRounding:_orderInfoModel.total_trade_fee afterPoint:2]];
                }else if (indexPath.row == 4){
                    orderDetailsCell.pasteBtn.hidden = YES;
                    orderDetailsCell.titleLab.text = @"付款时间：";
                    orderDetailsCell.contentLab.text = kIsEmptyString(_orderInfoModel.lastmodify) ? @"" : [[TJYHelper sharedTJYHelper]timeWithTimeIntervalString:_orderInfoModel.lastmodify format:@"yyyy-MM-dd HH:mm"];
                }
            }
            return orderDetailsCell;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0 && !kIsEmptyString(_orderInfoModel.order_id)){
        // -- 查看物流
        if ([_orderInfoModel.order_status isEqualToString:@"nodelivery"] || [_orderInfoModel.order_status isEqualToString:@"noreceived"] ||[_orderInfoModel.order_status isEqualToString:@"finish"]) {
            CheckLogisticsViewController *checkLogisticsVC = [[CheckLogisticsViewController alloc]init];
            checkLogisticsVC.orderId = _orderInfoModel.order_id;
            checkLogisticsVC.orderStatus = _orderInfoModel.order_status;
            [self.navigationController pushViewController:checkLogisticsVC animated:YES];
        }
    }
}
#pragma mark ====== OrderDetailCellDelegate =======
- (void)didSelectDuplicateOrder{
    // --  复制订单编号
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _orderInfoModel.order_id;
    [self.view makeToast:@"订单编号已复制" duration:1.0 position:CSToastPositionCenter];
}

#pragma mark ====== Setter =======

- (UITableView *)orderDetailsTab{
    if (!_orderDetailsTab) {
        _orderDetailsTab = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kBodyHeight - 44) style:UITableViewStyleGrouped];
        _orderDetailsTab.delegate = self;
        _orderDetailsTab.dataSource = self;
        _orderDetailsTab.backgroundColor = [UIColor bgColor_Gray];
        _orderDetailsTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        _orderDetailsTab.tableFooterView = [self tableFooterView];
    }
    return _orderDetailsTab;
}
- (UIView *)tableFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    footerView.backgroundColor = [UIColor bgColor_Gray];
    return footerView;
}
#pragma mark ====== 底部确认相关功能按钮 =======

- (UIView *)toolbarView{
    if (!_toolbarView) {
        _toolbarView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight - 50,kScreenWidth , 50)];
        _toolbarView.backgroundColor = [UIColor whiteColor];
        
        UILabel *lens = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
        lens.backgroundColor = UIColorHex(0xe5e5e5);
        [_toolbarView addSubview:lens];
        
        _orderPriceLab = [[UILabel alloc]initWithFrame:CGRectMake(15, (_toolbarView.height - 20)/2, kScreenWidth - 80 - 30 , 20)];
        _orderPriceLab.textColor = UIColorHex(0xf33f00);
        _orderPriceLab.font = kFontSize(18 * kScreenWidth/375);
        _orderPriceLab.hidden = YES;
        [_toolbarView addSubview:_orderPriceLab];
        
        _callPhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _callPhoneBtn.backgroundColor = [UIColor clearColor];
        _callPhoneBtn.frame = CGRectMake(10, 0,kScreenWidth - 80 - 30 , 50);
        [_callPhoneBtn addTarget:self action:@selector(callPhoneAction) forControlEvents:UIControlEventTouchUpInside];
        _callPhoneBtn.hidden = YES;
        [_toolbarView addSubview:_callPhoneBtn];
        
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(kScreenWidth - 180 * kScreenWidth/375 , (_toolbarView.height - 26 * kScreenWidth/375)/2, 80 * kScreenWidth/375, 26 * kScreenWidth/375);
        _leftBtn.titleLabel.font = kFontSize(13);
        [_leftBtn setTitleColor:UIColorHex(0x626262) forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(toolbarAction:) forControlEvents:UIControlEventTouchUpInside];
        _leftBtn.layer.borderWidth = 0.5;
        _leftBtn.layer.cornerRadius = 5;
        _leftBtn.tag = 1000;
        _leftBtn.hidden = YES;
        _leftBtn.layer.borderColor = UIColorHex(0x626262).CGColor;
        [_toolbarView addSubview:_leftBtn];
        
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(_leftBtn.right + 10, _leftBtn.top, _leftBtn.width, _leftBtn.height);
        _rightBtn.titleLabel.font = kFontSize(13);
        [_rightBtn setTitleColor:UIColorHex(0x626262) forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(toolbarAction:) forControlEvents:UIControlEventTouchUpInside];
        _rightBtn.layer.borderWidth = 0.5;
        _rightBtn.layer.cornerRadius = 5;
        _rightBtn.tag = 1001;
        _rightBtn.hidden = YES;
        _rightBtn.layer.borderColor = UIColorHex(0x999999).CGColor;
        [_toolbarView addSubview:_rightBtn];
    }
    return _toolbarView;
}
- (NSMutableArray *)itemsArray{
    if (!_itemsArray) {
        _itemsArray = [NSMutableArray array];
    }
    return _itemsArray;
}
- (UILabel *)countdownLab{
    if (!_countdownLab) {
        _countdownLab =[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 210, (90 - 20)/2, 200, 20)];
        _countdownLab.font = kFontSize(15);
        _countdownLab.textAlignment = NSTextAlignmentRight;
        _countdownLab.textColor = UIColorHex(0xffffff);
    }
    return _countdownLab;
}
#pragma mark ====== dealloc =======

- (void)dealloc{
    [_orderTime invalidate];
    _orderTime = nil;
}



@end
