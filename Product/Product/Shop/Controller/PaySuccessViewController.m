//
//  PaySuccessViewController.m
//  Product
//
//  Created by vision on 17/12/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "PaySuccessViewController.h"
#import "OrderViewController.h"
#import "OrderDetailsViewController.h"

@interface PaySuccessViewController ()

@end

@implementation PaySuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"支付成功";
    self.isHiddenBackBtn=YES;
    
    [self initSuccessView];
    [TJYHelper sharedTJYHelper].isOrderListReload = YES; // 刷新订单列表
}

#pragma mark -- Event Response
#pragma mark 查看订单
-(void)getPayOrderAciton{
    OrderDetailsViewController *orderDetailVC=[[OrderDetailsViewController alloc] init];
    orderDetailVC.orderId=self.orderSn;
    [self.navigationController pushViewController:orderDetailVC animated:YES];
}

#pragma mark 回到首页
-(void)backToHomeAciton{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark 初始化界面
- (void)initSuccessView{
    UIImageView *successImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-60)/2, kNewNavHeight +24, 60, 60)];
    successImgView.layer.cornerRadius = 45;
    successImgView.image = [UIImage imageNamed:@"pub_ic_order_right"];
    [self.view addSubview:successImgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, successImgView.bottom+16, kScreenWidth, 30)];
    label.text = @"订单支付成功";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18];
    label.textColor  = [UIColor colorWithHexString:@"#ff9630"];
    [self.view addSubview:label];
    
    NSArray *icons=@[@"pd_ic_lite_pay",@"pd_ic_lite_money"];
    NSArray *namesArr=@[@"支付方式",@"支付金额"];
    NSArray *detailsArr=@[self.payWayStr,[NSString stringWithFormat:@"¥%.2f",self.totalPrice]];
    for (NSInteger i=0; i<2; i++) {
        UIImageView *iconImageView=[[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2-80, label.bottom+16+i*30, 20, 20)];
        iconImageView.image=[UIImage imageNamed:icons[i]];
        [self.view addSubview:iconImageView];
        
        UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right+10, iconImageView.top, 75, 20)];
        nameLabel.text=namesArr[i];
        nameLabel.textColor=[UIColor lightGrayColor];
        nameLabel.font=[UIFont systemFontOfSize:14];
        [self.view addSubview:nameLabel];
        
        UILabel *detailLabel=[[UILabel alloc] initWithFrame:CGRectMake(nameLabel.right, iconImageView.top, 75, 20)];
        detailLabel.text=detailsArr[i];
        detailLabel.textColor=[UIColor redColor];
        detailLabel.font=[UIFont systemFontOfSize:14];
        [self.view addSubview:detailLabel];
    }
    
    UIButton *serviceButton = [[UIButton alloc] initWithFrame:CGRectMake(18,label.bottom+90,kScreenWidth/2-27, 41)];
    serviceButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [serviceButton setTitle:@"查看订单" forState:UIControlStateNormal];
    [serviceButton setTitleColor:[UIColor colorWithHexString:@"#626262"] forState:UIControlStateNormal];
    serviceButton.layer.cornerRadius=3.0;
    serviceButton.layer.borderColor=[UIColor colorWithHexString:@"#dcdcdc"].CGColor;
    serviceButton.layer.borderWidth=1;
    serviceButton.clipsToBounds=YES;
    [serviceButton addTarget:self action:@selector(getPayOrderAciton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:serviceButton];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2+9,label.bottom+90,kScreenWidth/2-27, 41)];
    backButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [backButton setTitle:@"返回首页" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithHexString:@"#626262"] forState:UIControlStateNormal];
    backButton.layer.borderWidth=1.0;
    backButton.layer.cornerRadius=3.0;
    backButton.layer.borderColor=[UIColor colorWithHexString:@"#dcdcdc"].CGColor;
    backButton.clipsToBounds=YES;
    [backButton addTarget:self action:@selector(backToHomeAciton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

@end
