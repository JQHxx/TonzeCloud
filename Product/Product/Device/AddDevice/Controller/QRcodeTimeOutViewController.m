//
//  QRcodeTimeOutViewController.m
//  LEEDARSON_SmartHome
//
//  Created by xtmac02 on 16/1/21.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import "QRcodeTimeOutViewController.h"
#import "AppDelegate.h"

@interface QRcodeTimeOutViewController (){

    __weak IBOutlet UILabel *_failedLabel;
    __weak IBOutlet UILabel *_tipsLabel;
}

@end

@implementation QRcodeTimeOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setLanguage];

}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)setLanguage{
    self.navigationItem.title = @"扫描二维码";
    _failedLabel.text = @"添加失败";
    _tipsLabel.text = @"该二维码已失效，请重新向管理员获取";
}


@end
