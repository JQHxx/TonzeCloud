//
//  SetWiFiViewController.m
//  Product
//
//  Created by Xlink on 15/12/8.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "SetWiFiViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ConnectingViewController.h"

#define iOS10 ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0)

@interface SetWiFiViewController ()<ConnectingViewControllerDelegate,UITextFieldDelegate>{
    UIScrollView       *rootView;
    UILabel      *wifiNameLbl;
    UITextField  *wifiPwdTF;
    UIButton     *setPwdSeenBtn;
    UIButton     *connectBtn;
    
    UILabel      *connectFailLbl;
    
    NSString     *wifiName;
}



@end

@implementation SetWiFiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"添加设备";
    
    [self initSetWifiView];
    [self loadViewWithWifiData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadViewWithWifiData) name:kResetWifiNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-03-08" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-03-08" type:2];
#endif
    connectFailLbl.hidden=YES;
}


#pragma mark --ConnectingViewControllerDelegate
-(void)connectingViewControllerNetworkFailed{
    connectFailLbl.hidden=NO;
    rootView.contentSize = CGSizeMake(kScreenWidth, connectFailLbl.bottom+20);
}

-(void)connectingViewControllerScanDeviceFailed{
    [self showAlertWithTitle:@"设备扫描失败" Message:@"请确保设备已被解绑后，再重新尝试"];
}

-(void)connectingViewControllerSubDeviceFailedWithCode:(NSInteger)code{
    NSString *errorMessage=nil;
    if (code==CODE_DEVICE_CLOUD_OFFLINE){
        errorMessage=[NSString stringWithFormat:@"错误码:%ld,%@",(long)code,@"设备处于离线状态,请开启设备后重新订阅"];
    }else if (code==CODE_TIMEOUT){  //超时
        errorMessage=[NSString stringWithFormat:@"错误码:%ld,%@",(long)code,@"设备订阅超时，请重新订阅"];
    }else if(code==CODE_UNAVAILABLE_ID){
        errorMessage=[NSString stringWithFormat:@"错误码:%ld,%@",(long)code,@"设备ID没有加到管理台，请与服务商联系"];
    }else if (code==CODE_DEVICE_OFFLINE){
        errorMessage=[NSString stringWithFormat:@"错误码:%ld,%@",(long)code,@"设备不在线,请开启设备后重新订阅"];
    }else{
        errorMessage=[NSString stringWithFormat:@"错误码:%ld,%@",(long)code,@"请重新尝试订阅或联系客服"];
    }
    
    [self showAlertWithTitle:@"设备订阅失败" Message:errorMessage];
}


#pragma mark --Response Methods
#pragma mark 连接Wi-Fi
-(void)startConnectDevice{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-03-09"];
#endif
    NSString * pswdStr = wifiPwdTF.text;
    ConnectingViewController *viewController = [[ConnectingViewController alloc] init];
    viewController.delegate=self;
    viewController.pwd=pswdStr;
    viewController.wifiName =wifiName;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark 设置密码可见性
-(void)setPwdVisibility:(id)sender{
    wifiPwdTF.secureTextEntry=!wifiPwdTF.secureTextEntry;
    UIButton *btn=sender;
    btn.selected=!btn.selected;
    
    NSString *tempString = wifiPwdTF.text;
    wifiPwdTF.text=@"";
    wifiPwdTF.text = tempString;
}

#pragma mark 退出编辑
-(void)backupEdit{
    NSTimeInterval animationDuration = 0.30f;
    //self.view移回原位置
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGRect frame = rootView.frame;
    frame.origin.y =64;
    rootView.frame = frame;

    [UIView commitAnimations];
    [wifiPwdTF resignFirstResponder];
}

#pragma mark 跳转到设置Wi-Fi页
-(void)gotoSystemSetAction{
    //宏定义，判断是否是 iOS10.0以上
    NSString * urlStr = @"App-Prefs:root=WIFI";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        [TJYHelper sharedTJYHelper].isGotoWifiSet=YES;
    }
}

#pragma mark -- Private Methods
-(void)initSetWifiView{
    rootView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight)];
    rootView.backgroundColor=[UIColor whiteColor];
    rootView.userInteractionEnabled=YES;
    [self.view insertSubview:rootView atIndex:0];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupEdit)];
    [rootView addGestureRecognizer:tap];
    
    UIImageView *wifiImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-90)/2, 20, 90, 75)];
    wifiImageView.image=[UIImage imageNamed:@"wifi-icon"];
    [rootView addSubview:wifiImageView];
    
    UILabel   *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, wifiImageView.bottom+10, kScreenWidth-40, 30)];
    lab.font=[UIFont systemFontOfSize:12];
    lab.text=@"请选择WiFi（暂不支持5GHz WiFi）";
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor=[UIColor colorWithHexString:@"0xc3c3c3"];
    [rootView addSubview:lab];
    
    wifiNameLbl=[[UILabel alloc] initWithFrame:CGRectMake(38, lab.bottom+10, kScreenWidth-76, 36)];
    wifiNameLbl.layer.cornerRadius=18.0;
    wifiNameLbl.layer.borderColor=kLineColor.CGColor;
    wifiNameLbl.textAlignment = NSTextAlignmentCenter;
    wifiNameLbl.textColor = [UIColor colorWithHexString:@"0xff9d38"];
    wifiNameLbl.font = [UIFont systemFontOfSize:15];
    wifiNameLbl.layer.borderWidth=1.0;
    wifiNameLbl.clipsToBounds=YES;
    wifiNameLbl.userInteractionEnabled=YES;
    [rootView addSubview:wifiNameLbl];
    
    UITapGestureRecognizer *wifiNameTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoSystemSetAction)];
    [wifiNameLbl addGestureRecognizer:wifiNameTap];
    
    UIView *pwdView=[[UIView alloc] initWithFrame:CGRectMake(38, wifiNameLbl.bottom+15, kScreenWidth-76, 36)];
    pwdView.layer.cornerRadius=18;
    pwdView.layer.borderColor=kLineColor.CGColor;
    pwdView.layer.borderWidth=1.0;
    [rootView addSubview:pwdView];
    
    wifiPwdTF=[[UITextField alloc] initWithFrame:CGRectMake(30, 3, kScreenWidth-145, 30)];
    wifiPwdTF.delegate=self;
    wifiPwdTF.placeholder = @"请输入WiFi密码";
    wifiPwdTF.textAlignment = NSTextAlignmentCenter;
    wifiPwdTF.textColor = [UIColor colorWithHexString:@"0xc3c3c3"];
    wifiPwdTF.font = [UIFont systemFontOfSize:15];
    wifiPwdTF.clearsOnBeginEditing=YES;
    wifiPwdTF.secureTextEntry=YES;
    [pwdView addSubview:wifiPwdTF];
    
    UIButton *setWifiPwdBtn=[[UIButton alloc] initWithFrame:CGRectMake(wifiPwdTF.right+5, 5.5, 25, 25)];
    [setWifiPwdBtn setImage:[UIImage imageNamed:@"ic_login_noeye"] forState:UIControlStateNormal];
    [setWifiPwdBtn setImage:[UIImage imageNamed:@"ic_login_eye"] forState:UIControlStateSelected];
    [setWifiPwdBtn addTarget:self action:@selector(setPwdVisibility:) forControlEvents:UIControlEventTouchUpInside];
    [pwdView addSubview:setWifiPwdBtn];
    
    
    connectFailLbl=[[UILabel alloc] initWithFrame:CGRectMake(30, pwdView.bottom+20, kScreenWidth-60, 120)];
    connectFailLbl.numberOfLines=0;
    connectFailLbl.text=@"配网失败：\n1、请确保设备已进入配网状态\n2、请检查路由器网络是否畅通\n3、请确认WiFi密码无误\n4、请确保路由器设置是2.4GHz网络\n5、确保无线路由器已关闭黑白名单（mac地址过滤）功能";
    connectFailLbl.font=[UIFont systemFontOfSize:14];
    connectFailLbl.textColor=kSystemColor;
    [rootView addSubview:connectFailLbl];
    connectFailLbl.hidden=YES;
    
    
    connectBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, connectFailLbl.bottom+10, kScreenWidth-80, 40)];
    connectBtn.backgroundColor=[UIColor colorWithHexString:@"0xfec72f"];
    connectBtn.layer.cornerRadius=5;
    [connectBtn setTitle:@"下一步" forState:UIControlStateNormal];
    connectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [connectBtn setTitleColor:[UIColor colorWithHexString:@"0xf8fbfb"] forState:UIControlStateNormal];
    [connectBtn addTarget:self action:@selector(startConnectDevice) forControlEvents:UIControlEventTouchUpInside];
    [rootView addSubview:connectBtn];
    
    
    rootView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight-64);
}




#pragma mark 初始化wifi帐号和密码
-(void)loadViewWithWifiData{
    NSDictionary *ifs = (NSDictionary *)[self fetchSSIDInfo];
    wifiName = [ifs objectForKey:@"SSID"];
    if (wifiName.length>0) {
        wifiNameLbl.text=[NSString stringWithFormat:@"%@",wifiName];
    }else{
        wifiNameLbl.text = @"请连接WiFi";
    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [user objectForKey:@"WIFI"];
    NSString *wifiPwdStr=[dic objectForKey:wifiName];
    wifiPwdTF.text =kIsEmptyString(wifiPwdStr)?@"":wifiPwdStr;
}

#pragma mark 获取当前WiFi名称
- (NSString *)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    MyLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    MyLog(@"%@",info);
    return info;
}




#pragma mark--UITextField Delegate
#pragma mark 键盘高度处理
-(void) textFieldDidBeginEditing:(UITextField *)textField{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-03-08"];
#endif
    
    CGRect textFrame =  connectBtn.frame;
    float textY = textFrame.origin.y+textFrame.size.height;
    float bottomY = rootView.frame.size.height-textY;
    if(bottomY>=216)  //判断当前的高度是否已经有216，如果超过了就不需要再移动主界面的View高度
    {
        return;
    }
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    float moveY = 216-bottomY;
    CGRect frame = rootView.frame;
    frame.origin.y -=moveY;//view的Y轴上移
    rootView.frame = frame;
    [UIView commitAnimations];//设置调整界面的动画效果
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (rootView.frame.origin.y<64) {
        NSTimeInterval animationDuration = 0.30f;
        //self.view移回原位置
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        CGRect frame = rootView.frame;
        if(textField == wifiPwdTF){   //还原界面
            frame.origin.y =64;
            rootView.frame = frame;
        }
        [UIView commitAnimations];
    }
     [wifiPwdTF resignFirstResponder];
    return YES;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kResetWifiNotification object:nil];
}

@end
