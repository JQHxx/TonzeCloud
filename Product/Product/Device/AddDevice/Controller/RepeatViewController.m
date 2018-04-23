//
//  RepeatViewController.m
//  Product
//
//  Created by Xlink on 16/2/18.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "RepeatViewController.h"
#import "WiFiTipsViewController.h"
#import "MainDeviceInfo.h"

@interface RepeatViewController (){
    UIImageView *deviceIV;
}

@end

@implementation RepeatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"重新配置";

    [self initRepeatView];
    
}


#pragma mark -- Private methods
-(void)initRepeatView{
    deviceIV=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, 90, 200, 200)];
    [deviceIV setImage: [UIImage imageNamed:@"add云炖锅"]];
    [self.view addSubview:deviceIV];
    
    MainDeviceInfo *mainDevice=[TJYHelper sharedTJYHelper].selectDevice;
    NSString*productID=mainDevice.productID;
    NSString *tempStr=nil;
    if ([productID isEqualToString:CLOUD_COOKER_PRODUCT_ID]) {
        [deviceIV setImage: [UIImage imageNamed:@"add云炖锅"]];
        tempStr=@"【功能/取消】";
    }else  if ([productID isEqualToString:WATER_COOKER_PRODUCT_ID]) {
        [deviceIV setImage: [UIImage imageNamed:@"add隔水炖"]];
        tempStr=@"【功能/取消】";
    }else  if ([productID isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]) {
        [deviceIV setImage: [UIImage imageNamed:@"add隔水炖16AIG"]];
        tempStr=@"【功能/取消】";
    }else  if ([productID isEqualToString:CLOUD_KETTLE_PRODUCT_ID]) {
        [deviceIV setImage: [UIImage imageNamed:@"add云水壶"]];
        tempStr=@"【功能/取消】";
    }else  if ([productID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]) {
        [deviceIV setImage: [UIImage imageNamed:@"自动烹饪锅"]];
        tempStr=@"【开关】";
    }else if ([productID isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]){
        [deviceIV setImage: [UIImage imageNamed:@"add电饭煲"]];
        tempStr=@"【功能/选择】";
    }else if ([productID isEqualToString:CABINETS_PRODUCT_ID]){
        [deviceIV setImage: [UIImage imageNamed:@"ic_add_storage"]];
        tempStr=@"【＋】";
    }else{
        tempStr=@"【功能/取消】";
    }
    
    UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, deviceIV.bottom+20, kScreenWidth-100, 20)];
    textLabel.text=@"该设备已被绑定";
    textLabel.font=[UIFont systemFontOfSize:16];
    textLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:textLabel];
    
    UILabel *tipsLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, textLabel.bottom+30, kScreenWidth-40, 100)];
    tipsLabel.numberOfLines=0;;
    tipsLabel.text=[NSString stringWithFormat:@"1、若您需要使用该设备，可让该设备主帐号向您分享；\n2、若要将设备与APP解绑，请按住设备“WIFI”键再按%@键，蜂鸣三声即为解除绑定成功。",tempStr];
    tipsLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:tipsLabel];
    
}

#pragma mark -- Event Response
-(void)leftButtonAction{
    NSArray *vcArray = self.navigationController.viewControllers;
    for(UIViewController *vc in vcArray){
        if ([vc isKindOfClass:[WiFiTipsViewController class]]){
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}
@end
