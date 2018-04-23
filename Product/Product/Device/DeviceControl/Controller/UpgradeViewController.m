//
//  UpgradeViewController.m
//  socket
//
//  Created by xtmac02 on 15/11/18.
//  Copyright © 2015年 jz. All rights reserved.
//

#import "UpgradeViewController.h"

#import "AppDelegate.h"
#import "NewestVersionViewController.h"
#import "UpgradeSuccessViewController.h"
#import "XLinkExportObject.h"
#import "DeviceHelper.h"
#import "Transform.h"

//手动重置弹框
#import "DeviceViewController.h"
#import "DeviceConnectStateCheckService.h"
#import "DeviceHelper.h"

@interface UpgradeViewController ()<UIAlertViewDelegate>{

    __weak IBOutlet UILabel *nowLabel;
    __weak IBOutlet UILabel *versionLabel;
    __weak IBOutlet UIButton *updataButton;
    __weak IBOutlet UIImageView *deviceIV;
    
  
    BOOL _touch;
    
    AppDelegate *appDelegate;
    
}

@end

@implementation UpgradeViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"固件升级";
    
    [self initUI];
    _touch = NO;
    appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    [self getCurrentVersion];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeSyncData object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
   
}

#pragma mark --获取当前固件版本
-(void)getCurrentVersion{
    if ([[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"]) {
        if (self.device && self.device.deviceID>0 && self.device.productID && self.device.productID.length > 0) {
            [HttpRequest getVersionWithDeviceID:[NSString stringWithFormat:@"%d",self.device.deviceID] withProduct_id:self.device.productID withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                if (err) {
                    if (err.code==4031003) {
                        [appDelegate updateAccessToken];
                    }
                    [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
                } else {
                    NSDictionary *dic = (NSDictionary *)result;
                    NSInteger current = [[dic objectForKey:@"current"] integerValue];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //1.5 更新界面显示
                        versionLabel.text = [NSString stringWithFormat:@"V%ld",(long)current];
                    });
                }
            }];
        }
    }
}

-(void)OnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    if ([[device getMacAddressSimple ]isEqualToString:[self.device getMacAddressSimple]]) {
        ///查询状态命令
        uint8_t cmd_data[30];
        uint32_t cmd_len = (uint32_t)[recvData length];
        memset(cmd_data, 0, 30);
        [recvData getBytes:(void *)cmd_data length:cmd_len];
        if (cmd_data[0]==0x10) {
            [DeviceHelper putFeedbackDeviceToLocal:[device getMacAddressSimple] Data:recvData];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSDictionary *dic=[NSUserDefaultInfos getDicValueforKey:[device getMacAddressSimple]];
                    versionLabel.text=[NSString stringWithFormat:@"v %@",[dic objectForKey:@"firmwareVersion"]];
                });
            });
        }
    }
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
        case CABINETS:
            [deviceIV setImage:[UIImage imageNamed:@"ic_storage"]];
            break;
        default:
            break;
    }
    
}

- (IBAction)chackVersion:(id)sender {
    [HttpRequest getVersionWithDeviceID:[NSString stringWithFormat:@"%d",self.device.deviceID] withProduct_id:self.device.productID withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        if (err) {
            if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }
            [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        } else {
            NSDictionary *dic = (NSDictionary *)result;
            [self performSelectorOnMainThread:@selector(show:) withObject:dic waitUntilDone:YES];
        }
    }];
}

- (void)show:(NSDictionary *)dic{
    //1.判断是否为升级完成
    NSInteger current = [[dic objectForKey:@"current"] integerValue];
    NSInteger newVersion = [[dic objectForKey:@"newest"] integerValue];
    //1.5 更新界面显示
    versionLabel.text = [NSString stringWithFormat:@"V%ld",(long)current];
    
    if (current < newVersion) {
       [self performSelectorOnMainThread:@selector(pushToNewestVersionViewController:) withObject:dic waitUntilDone:YES];
    }else if (current >= newVersion){
       [self performSelectorOnMainThread:@selector(pushToUpgradeSuccessViewController) withObject:nil waitUntilDone:YES];
    }
}

- (void)pushToNewestVersionViewController:(NSDictionary *)dict{
    NewestVersionViewController *view = [[NewestVersionViewController alloc] initWithNibName:@"NewestVersionViewController" bundle:nil];
    view.dict = dict;
    view.device=self.device;
    view.deviceType=self.deviceType;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)pushToUpgradeSuccessViewController{
    UpgradeSuccessViewController *view = [[UpgradeSuccessViewController alloc] initWithNibName:@"UpgradeSuccessViewController" bundle:nil];
     view.deviceType=self.deviceType;
    view.device = self.device;
    [self.navigationController pushViewController:view animated:YES];
}


@end
