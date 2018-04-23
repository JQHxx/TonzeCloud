//
//  DisconnectWifiViewController.m
//  Product
//
//  Created by Xlink on 15/12/11.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "DisconnectWifiViewController.h"
@interface DisconnectWifiViewController ()

@end

@implementation DisconnectWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"添加设备";
}

- (IBAction)confirmConnectWiFI:(id)sender {
    if ([[NetworkTool sharedNetworkTool] isConnectedToNet]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self showAlertWithTitle:@"提示" Message:@"请先连接WiFi"];
    }
}



@end
