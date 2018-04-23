//
//  PayOrderViewController.m
//  Product
//
//  Created by vision on 17/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "PayOrderViewController.h"
#import "PaySuccessViewController.h"
#import "PayWayTool.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "ShopCartViewController.h"
#import "ShopDetailViewController.h"
#import "OrderViewController.h"

@interface PayOrderViewController (){
    UILabel      *timerLab;
    PayWayTool   *weiPayTool;  //微信支付
    PayWayTool   *alipayTool;  //微信支付
    NSInteger    payWay;  //1.支付宝支付 2.微信支付
    
    NSTimer      *aTimer;
    NSInteger    count;
}

@end

@implementation PayOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"支付订单";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    payWay=1;
    
    [self initPayOrderView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySuccessAction) name:kPaySuccessNotification object:nil];
    
    count=2*60*60;
    if (!aTimer) {
        aTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(payCountDownAction) userInfo:nil repeats:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (aTimer) {
        [aTimer invalidate];
        aTimer=nil;
    }
}

#pragma mark -- Event Response
#pragma mark 选择支付方式
-(void)didSelectPayWayActionForSender:(UIButton *)sender{
    if (sender.tag==100) {
        alipayTool.isWaySelected=YES;
        weiPayTool.isWaySelected=NO;
    }else{
        alipayTool.isWaySelected=NO;
        weiPayTool.isWaySelected=YES;
    }
    payWay=sender.tag-100+1;
}

#pragma mark 支付
-(void)payOrderAction{
    kSelfWeak;
    NSInteger memberId=[[NSUserDefaultInfos getValueforKey:USER_ID] integerValue];
    NSString *body=[NSString stringWithFormat:@"member_id=%ld&order_id=%@&pay_app_id=%@",(long)memberId,self.order_id,payWay==1?@"alipayApp":@"wxpayApp"];
    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:kGetShopOrderInfo body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            if (payWay==1) {
                NSString *payment_id=[result valueForKey:@"payment_id"];
                [NSUserDefaultInfos putKey:@"paymentId" andValue:payment_id];
                
                NSString *orderInfo=[result valueForKey:@"uri"];
                [[AlipaySDK defaultService] payOrder:orderInfo fromScheme:kAppScheme callback:^(NSDictionary *resultDic) {
                    MyLog(@"result:%@",resultDic);
                    NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
                    if (resultStatus==9000) {
                        NSString *body=[NSString stringWithFormat:@"payment_id=%@",payment_id];
                        [[NetworkTool sharedNetworkTool] postShopMethodWithoutLoadingURL:kOrderAliPayBack body:body success:^(id json) {
                            [weakSelf paySuccessAction];
                        } failure:^(NSString *errorStr) {
                            
                        }];
                    }else if(resultStatus==6001){
                        [weakSelf.view makeToast:@"用户取消支付" duration:1.0 position:CSToastPositionCenter];
                    }else{
                        [weakSelf.view makeToast:@"订单支付失败" duration:1.0 position:CSToastPositionCenter];
                    }
                }];
            }else{
                 PayReq* req             = [[PayReq alloc] init];
                 req.openID              = [result valueForKey:@"appid"];
                 req.partnerId           = [result valueForKey:@"partnerid"];
                 req.prepayId            = [result valueForKey:@"prepayid"];
                 req.nonceStr            = [result valueForKey:@"noncestr"];
                 req.timeStamp           = [[result valueForKey:@"timestamp"] intValue];
                 req.package             = [result valueForKey:@"package"];
                 req.sign                = [result valueForKey:@"sign"];
                 
                 [WXApi sendReq:req];
                
                 NSString *payment_id=[result valueForKey:@"payment_id"];
                [NSUserDefaultInfos putKey:@"paymentId" andValue:payment_id];
            }
        }
    } failure:^(NSString *errorStr) {
        
    }];
    
    
}

#pragma mark 支付时间倒计时
-(void)payCountDownAction{
    NSTimeInterval timeInterval = [[TJYHelper sharedTJYHelper] getOrderCountdownWithCreationTime:self.createTimeStr];
    if (timeInterval<0) {
        timeInterval=0;
        if (aTimer) {
            [aTimer invalidate];
            aTimer=nil;
        }
    }
    
    NSInteger day = (NSInteger)(timeInterval/(3600*24));
    NSInteger hour = (NSInteger)((timeInterval-day*24*3600)/3600);
    NSInteger minute = (NSInteger)(timeInterval-day*24*3600-hour*3600)/60;
    NSInteger seconds = timeInterval-day*24*3600-hour*3600-minute*60;
    
    NSString *timeStr=[NSString stringWithFormat:@"请在%02ld小时%02ld分%02ld秒内完成支付",(long)hour,(long)minute,(long)seconds];
    NSMutableAttributedString *attibuteStr=[[NSMutableAttributedString alloc] initWithString:timeStr];
    [attibuteStr addAttribute:NSForegroundColorAttributeName value:kSystemColor range:NSMakeRange(2, 11)];
    timerLab.attributedText=attibuteStr;
}

#pragma mark  返回
-(void)leftButtonAction{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认要离开订单支付？" message:@"超过支付时效时订单将被取消，请尽快完成支付" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"继续支付"style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
        [self payOrderAction];
    }];
    [payAction setValue:[UIColor darkGrayColor] forKey:@"_titleTextColor"];
    [alert addAction:payAction];
    
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:@"确认离开"style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        if (!self.isOrderIn) {
            for (BaseViewController *controller in self.navigationController.viewControllers) {
                if (self.isFastBuy) {
                    if ([controller isKindOfClass:[ShopDetailViewController class]]) {
                        [self.navigationController popToViewController:controller animated:YES];
                        break;
                    }
                    
                }else{
                    if ([controller isKindOfClass:[ShopCartViewController class]]) {
                        [self.navigationController popToViewController:controller animated:YES];
                        [TJYHelper sharedTJYHelper].isPayOrderBack=YES;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPayOrderBackAction" object:nil];
                        break;
                    }
                }
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    [leaveAction setValue:kSystemColor forKey:@"_titleTextColor"];
    [alert addAction:leaveAction];
    [self presentViewController:alert animated:true completion:nil];
    
}

#pragma mark -- NSNotification
#pragma mark 支付回调
-(void)paySuccessAction{
    PaySuccessViewController *paySuccessVC=[[PaySuccessViewController alloc] init];
    paySuccessVC.totalPrice=self.payAmount;
    paySuccessVC.payWayStr=payWay==1?@"支付宝支付":@"微信支付";
    paySuccessVC.orderSn=self.order_id;
    [self.navigationController pushViewController:paySuccessVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 初始化支付订单页
-(void)initPayOrderView{
    UIView *bgHeaderView=[[UIView alloc] initWithFrame:CGRectZero];
    bgHeaderView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgHeaderView];
    
    CGFloat tempHeight=0.0;
    if (self.isOrderIn) {
        bgHeaderView.frame=CGRectMake(0, kNewNavHeight, kScreenWidth, 80);
        tempHeight=0.0;
    }else{
        bgHeaderView.frame=CGRectMake(0, kNewNavHeight, kScreenWidth, 220);
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-60)/2, 24, 60, 60)];
        imgView.image=[UIImage imageNamed:@"pub_ic_order_right"];
        [bgHeaderView addSubview:imgView];
        
        UILabel  *lab=[[UILabel alloc] initWithFrame:CGRectMake(30, imgView.bottom+17, kScreenWidth-60, 20)];
        lab.font=[UIFont boldSystemFontOfSize:18];
        lab.text=@"订单提交成功";
        lab.textAlignment=NSTextAlignmentCenter;
        lab.textColor=[UIColor blackColor];
        [bgHeaderView addSubview:lab];
        
        tempHeight=lab.bottom;
    }
    
    //倒计时
    timerLab=[[UILabel alloc] initWithFrame:CGRectMake(30, tempHeight+16, kScreenWidth-60, 20)];
    timerLab.font=[UIFont systemFontOfSize:14];
    timerLab.textColor=[UIColor grayColor];
    timerLab.textAlignment=NSTextAlignmentCenter;
    
    NSString *timeStr=self.isOrderIn?@"请在00小时00分00秒内完成支付":@"请在01小时59分59秒内完成支付";
    NSMutableAttributedString *attibuteStr=[[NSMutableAttributedString alloc] initWithString:timeStr];
    [attibuteStr addAttribute:NSForegroundColorAttributeName value:kSystemColor range:NSMakeRange(2, 11)];
    timerLab.attributedText=attibuteStr;
    [bgHeaderView addSubview:timerLab];
    
    //支付金额
    UILabel *priceLabel=[[UILabel alloc] initWithFrame:CGRectMake(30, timerLab.bottom, kScreenWidth-60, 30)];
    priceLabel.font=[UIFont systemFontOfSize:14];
    priceLabel.textColor=[UIColor lightGrayColor];
    priceLabel.textAlignment=NSTextAlignmentCenter;
    NSString *priceStr=[NSString stringWithFormat:@"支付金额：¥%.2f",self.payAmount];
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:priceStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5, priceStr.length-5)];
    priceLabel.attributedText=attributeStr;
    [bgHeaderView addSubview:priceLabel];
    
    UIView *payView=[[UIView alloc] initWithFrame:CGRectMake(0, bgHeaderView.bottom+10, kScreenWidth, 140)];
    payView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:payView];
    
    UILabel *payTitleLab=[[UILabel alloc] initWithFrame:CGRectMake(15, 10, 90, 20)];
    payTitleLab.text=@"支付方式";
    payTitleLab.font=[UIFont systemFontOfSize:14];
    payTitleLab.textColor=[UIColor lightGrayColor];
    [payView addSubview:payTitleLab];
    
    //支付宝支付
    alipayTool=[[PayWayTool alloc] initWithFrame:CGRectMake(0, payTitleLab.bottom+10, kScreenWidth, 50) iconName:@"pub_ic_zhifubao" title:@"支付宝支付"];
    alipayTool.isWaySelected=YES;
    alipayTool.tag=100;
    [alipayTool addTarget:self action:@selector(didSelectPayWayActionForSender:) forControlEvents:UIControlEventTouchUpInside];
    [payView addSubview:alipayTool];
    
    //微信支付
    weiPayTool=[[PayWayTool alloc] initWithFrame:CGRectMake(0, alipayTool.bottom, kScreenWidth, 50) iconName:@"pub_ic_weichat" title:@"微信支付"];
    weiPayTool.isWaySelected=NO;
    weiPayTool.tag=101;
    [weiPayTool addTarget:self action:@selector(didSelectPayWayActionForSender:) forControlEvents:UIControlEventTouchUpInside];
    [payView addSubview:weiPayTool];
    
    for (NSInteger i=0; i<2; i++) {
        UILabel *lineLab=[[UILabel alloc] initWithFrame:CGRectMake(0, payTitleLab.bottom+9+i*50, kScreenWidth, 1)];
        lineLab.backgroundColor=kLineColor;
        [payView addSubview:lineLab];
    }
    
    UIButton *payBtn=[[UIButton alloc] initWithFrame:CGRectMake(20, payView.bottom+30, kScreenWidth-40, 45)];
    [payBtn setTitle:@"支付" forState:UIControlStateNormal];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payBtn.backgroundColor=kSystemColor;
    payBtn.layer.cornerRadius=3;
    payBtn.clipsToBounds=YES;
    [payBtn addTarget: self action:@selector(payOrderAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
}





@end
