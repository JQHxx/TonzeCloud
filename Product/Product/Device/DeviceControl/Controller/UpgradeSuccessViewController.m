//
//  UpgradeSuccessViewController.m
//  socket
//
//  Created by xtmac02 on 15/11/18.
//  Copyright © 2015年 jz. All rights reserved.
//

#import "UpgradeSuccessViewController.h"
#import "AppDelegate.h"
#import "UpgradeViewController.h"

//手动重置弹框
#import "DeviceViewController.h"
#import "DeviceConnectStateCheckService.h"
#import "DeviceHelper.h"

@interface UpgradeSuccessViewController ()<UIAlertViewDelegate>{
    
    __weak IBOutlet UILabel *newestLabel;
    __weak IBOutlet UIButton *doneButton;
    __weak IBOutlet UIImageView *deviceIV;
}

@end

@implementation UpgradeSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"固件升级";
    
    [self initUI];
    
}



- (IBAction)done:(id)sender {
    
    
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isMemberOfClass:[UpgradeViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
    
}

- (void)inforNavi{
    
}

- (void)initUI{
    
    
    doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    doneButton.layer.cornerRadius = 20.0f;
    doneButton.clipsToBounds = YES;
    
    switch (self.deviceType) {
        case CLOUD_COOKER:
            [deviceIV setImage:[UIImage imageNamed:@"add云炖锅"]];
            break;
        case ELECTRIC_COOKER:
            [deviceIV setImage:[UIImage imageNamed:@"add电饭煲"]];
            break;
        case WATER_COOKER:
            [deviceIV setImage:[UIImage imageNamed:@"add隔水炖"]];
            break;
        case CLOUD_KETTLE:
            [deviceIV setImage:[UIImage imageNamed:@"add云水壶"]];
            break;
        case COOKFOOD_KETTLE:
            [deviceIV setImage:[UIImage imageNamed:@"自动烹饪锅"]];
            break;
        default:
            break;
    }
    
}

-(IBAction)backToView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



@end
