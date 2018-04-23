//
//  NewestVersionViewController.m
//  socket
//
//  Created by xtmac02 on 15/11/18.
//  Copyright © 2015年 jz. All rights reserved.
//

#import "NewestVersionViewController.h"
#import "AppDelegate.h"

//手动重置弹框
#import "DeviceViewController.h"
#import "DeviceConnectStateCheckService.h"
#import "DeviceHelper.h"

@interface NewestVersionViewController ()<UIAlertViewDelegate>{

    __weak IBOutlet UILabel *newLabel;
    __weak IBOutlet UILabel *versionLabel;
    __weak IBOutlet UILabel *versionHeaderLabel;
    __weak IBOutlet UILabel *versionDetailLabel;
    __weak IBOutlet UIButton *updataButton;
    __weak IBOutlet UIButton *cancleButton;
     __weak IBOutlet UIImageView *deviceIV;
    
    AppDelegate *appDelegate;
}

@end

@implementation NewestVersionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"固件升级";
    
    [self initUI];
    
    NSInteger newVersion = [[self.dict objectForKey:@"new_version"] integerValue];
    if (self.dict[@"description"] != nil && ![self.dict[@"description"] isKindOfClass:[NSNull class]]) {
        versionDetailLabel.text = self.dict[@"description"];
    }else{
        versionDetailLabel.text = @"";
    }
    versionLabel.text = [NSString stringWithFormat:@"V%ld",(long)newVersion];
    
    appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
}



- (void)initUI{
   
    updataButton.titleLabel.font = [UIFont systemFontOfSize:16];
    updataButton.layer.cornerRadius = 20.0f;
    updataButton.clipsToBounds = YES;

    
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

- (IBAction)cancleUpgrade:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doUpgrade:(UIButton *)sender {

    [HttpRequest upgradeWithDeviceID:[NSString stringWithFormat:@"%d",self.device.deviceID] withProduct_id:self.device.productID withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        if (err) {
            [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        } else {
            if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }
        }
    }];
    

}





@end
