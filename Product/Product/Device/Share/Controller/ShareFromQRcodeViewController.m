//
//  ShareFromQRcodeViewController.m
//  Product
//
//  Created by Feng on 16/2/3.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "ShareFromQRcodeViewController.h"
#import "Transform.h"
#import "DeviceHelper.h"
#import "AppDelegate.h"


@interface ShareFromQRcodeViewController ()<UIAlertViewDelegate>{
    AppDelegate *appDelegate;
}

@end

@implementation ShareFromQRcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"二维码分享";
    
    appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self creatQRcode];
}


-(void)creatQRcode{
   //生成二维码字段,20分钟
    [HttpRequest shareDeviceInQRcodeWithDeviceID:@(self.model.deviceID) withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] withExpire:@(60*20) didLoadData:^(id result, NSError *err) {
        if (!err) {
            NSDictionary *dic = (NSDictionary *)result;
            NSString *invite_code = [@"tianji-" stringByAppendingString:dic[@"invite_code"]];
            [self performSelectorOnMainThread:@selector(configCodeImageView:) withObject:invite_code waitUntilDone:YES];
        }else{
            if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }
            [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        }
    }];
    
}

#pragma mark  生成二维码
-(void)configCodeImageView:(NSString *)str{
    QRcodeView.image = [QRCodeGenerator qrImageForString:str imageSize:(int)QRcodeView.frame.size.height Topimg:nil];
}






@end
