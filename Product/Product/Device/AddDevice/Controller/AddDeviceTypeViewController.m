//
//  AddDeviceTypeViewController.m
//  Product
//
//  Created by Xlink on 15/12/15.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "AddDeviceTypeViewController.h"
#import "DeviceModel.h"
#import "WiFiTipsViewController.h"
#import "AppDelegate.h"
#import "Product-swift.h"
#import "BTHelper.h"
#import "TIBLECBKeyfob.h"
#import "BTManager.h"
#import "ScaleViewController.h"
#import "RepeatViewController.h"
#import "MainDeviceInfo.h"
#import "ScaleListViewController.h"
#import "NutritionScaleViewController.h"

@interface AddDeviceTypeViewController ()

@property (nonatomic, assign) DeviceType chooseDeviceType;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation AddDeviceTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"添加设备";
    
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    _scrollView.contentSize = CGSizeMake(320, 824);
    _scrollView.showsVerticalScrollIndicator=NO;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-03" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-03" type:2];
#endif
     [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CBCentralManagerStatePoweredOn" object:nil];
}


//现在的流程是：当客户点击脂肪秤按钮就初始化蓝牙，当收到蓝牙开启的通知时才跳转页面
-(void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(toScaleListView) name:@"CBCentralManagerStatePoweredOn" object:nil];
    
}

#pragma mark -- NSNotification
-(void)toScaleListView{
    [self performSegueWithIdentifier:@"toScaleListView" sender:nil];
}


#pragma mark  Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toScaleListView"]) {
        ScaleListViewController *scaleVC = segue.destinationViewController;
        scaleVC.deviceType = _chooseDeviceType;
    }
}

#pragma mark -- Event Response
#pragma mark 血压计
- (IBAction)sphygmomanometerBtnClick:(id)sender {
    _chooseDeviceType = DeviceTypeBPMeter;
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.BTHelper =[[BTHelper alloc]init];
    [appDelegate.BTHelper initParam];
}

#pragma mark 体温计
- (IBAction)thermometerBtnClick:(id)sender {
    _chooseDeviceType = DeviceTypeThermometer;
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.BTHelper =[[BTHelper alloc]init];
    [appDelegate.BTHelper initParam];
}

#pragma mark wifi设备连接
-(IBAction)ToWifiTipsView:(id)sender{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-03-04"];
#endif
    UIButton *btn=sender;
    WiFiTipsViewController *tipsVC=[[WiFiTipsViewController alloc] init];
    MainDeviceInfo *device=[[MainDeviceInfo alloc] init];
    if (btn.tag==WATER_COOKER) {
        device.deviceName=@"云智能隔水电炖锅";
        device.productID = WATER_COOKER_PRODUCT_ID;
    }else if (btn.tag==WATER_COOKER_16AIG){
        device.deviceName=@"云智能隔水电炖锅16AIG";
        device.productID = WATER_COOKER_16AIG_PRODUCT_ID;
    }else if (btn.tag==ELECTRIC_COOKER){
        device.deviceName=@"云智能电饭煲";
        device.productID = ELECTRIC_COOKER_PRODUCT_ID;
    }else if (btn.tag==COOKFOOD_KETTLE){
        device.deviceName=@"云智能健康大厨";
        device.productID = COOKFOOD_COOKER_PRODUCT_ID;
    }else if (btn.tag==CLOUD_COOKER){
        device.deviceName=@"云智能电炖锅";
        device.productID = CLOUD_COOKER_PRODUCT_ID;
    }else if (btn.tag==CLOUD_KETTLE){
        device.deviceName=@"云智能私享壶";
        device.productID = CLOUD_KETTLE_PRODUCT_ID;
    }else if (btn.tag==CABINETS){
        device.deviceName=@"智能厨物柜";
        device.productID=CABINETS_PRODUCT_ID;
    }
    device.deviceType=btn.tag;
    [TJYHelper sharedTJYHelper].selectDevice=device;
    [self.navigationController pushViewController:tipsVC animated:YES];
}

#pragma mark 健康体质分析仪
- (IBAction)gotoScaleVC:(id)sender {
    TJYUserModel *userModel=[TonzeHelpTool sharedTonzeHelpTool].user;
    NSInteger age=[[TonzeHelpTool sharedTonzeHelpTool] getPersonAgeWithBirthdayString:userModel.birthday];
    if (userModel.sex<1||userModel.sex>2||[userModel.height integerValue]<50||age<10) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ScalePersonInfoViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        
        ScaleViewController *scaleVc=[[ScaleViewController alloc] init];
        [self.navigationController pushViewController:scaleVc animated:YES];
    }
}


/**
 *  云智能营养秤
 */
- (IBAction)gotoNutritionScaleVC:(id)sender {
    
    NutritionScaleViewController * nutritionScaleVC = [[NutritionScaleViewController alloc] init];
    nutritionScaleVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nutritionScaleVC animated:YES];
}


@end
