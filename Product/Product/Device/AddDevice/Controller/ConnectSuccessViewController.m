//
//  ConnectSuccessViewController.m
//  Product
//
//  Created by Xlink on 15/12/17.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "ConnectSuccessViewController.h"
#import "AppDelegate.h"
#import "DeviceViewController.h"
#import "AutoLoginManager.h"

@interface ConnectSuccessViewController ()

@end

@implementation ConnectSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"添加设备";
    self.leftImageName = @"";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    [self initConnectSuccessView];
    
    
     if (![self.productID isEqualToString:THERMOMETER_PRODUCT_ID ]&&![self.productID isEqualToString:CLINK_BPM_PRODUCT_ID]&&![self.productID isEqualToString:SCALE_PRODUCT_ID]) {
        [[XLinkExportObject sharedObject] initDevice:self.device];
        NSInteger result=[[XLinkExportObject sharedObject] connectDevice:self.device andAuthKey:self.device.accessKey];
        MyLog(@"连接设备:%ld",result);
        [[ControllerHelper shareHelper] insertConnectArr:self.device];
        [TJYHelper sharedTJYHelper].isReloadDeviceList=YES;
         [[AutoLoginManager shareManager] getDeviceList];
         
         if ([self.productID isEqualToString:CLOUD_KETTLE_PRODUCT_ID]) {
             if (self.isScanQR) {
                 [[AutoLoginManager shareManager] checkAndAddReminds:self.device.getMacAddressSimple];
             }else{
                 [[AutoLoginManager shareManager] andAddRemindsWithOutCheck:self.device.getMacAddressSimple];
             }
         }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-03-11" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-03-11" type:2];
#endif

    [TJYHelper sharedTJYHelper].isReloadDeviceList=YES;
}

#pragma mark -- Event Response
-(void)leftButtonAction{

}

-(void)completeConnectDevice{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-03-12"];
#endif
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark -- Private Methods
-(void)initConnectSuccessView{
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 300)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UIImageView *successImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-89)/2, 70+64, 89, 89)];
    successImageView.image=[UIImage imageNamed:@"pub_ic_right"];
    [self.view addSubview:successImageView];
    
    UILabel *lab1=[[UILabel alloc] initWithFrame:CGRectMake(80, successImageView.bottom+20, kScreenWidth-160, 20)];
    lab1.text=@"添加成功";
    lab1.font=[UIFont boldSystemFontOfSize:18];
    lab1.textAlignment=NSTextAlignmentCenter;
    lab1.textColor=[UIColor colorWithHexString:@"0xff9630"];
    [self.view addSubview:lab1];
    
    UILabel *tipsLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, lab1.bottom+10, kScreenWidth-80, 20)];
    tipsLbl.text=@"恭喜，您的设备已成功添加！";
    tipsLbl.font=[UIFont boldSystemFontOfSize:14];
    tipsLbl.textAlignment=NSTextAlignmentCenter;
    tipsLbl.textColor=[UIColor colorWithHexString:@"0x959595"];
    [self.view addSubview:tipsLbl];
    
    UIButton *completeBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, bgView.bottom+26, kScreenWidth-80, 40)];
    completeBtn.backgroundColor=[UIColor colorWithHexString:@"0xff9630"];
    completeBtn.layer.cornerRadius=20;
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(completeConnectDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:completeBtn];
    
}

@end
