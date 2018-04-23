//
//  ConnectingViewController.m
//  Product
//
//  Created by Xlink on 15/12/17.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "ConnectingViewController.h"
#import "HFSmartLink.h"
#import "ConnectSuccessViewController.h"
#import "RepeatViewController.h"
#import "MainDeviceInfo.h"

@interface ConnectingViewController (){
    UIImageView   *connectImg;
    UIImageView   *connectAnimation;
    
    UIImageView   *scanAnimation;
    UIImageView   *scanImg;
    
    UIImageView   *subscribeAnimation;
    UIImageView   *subscribeImg;
    
    HFSmartLink   *smtlk;
    
    NSInteger     userAccessKey;//用户传入的accessKey
    NSInteger     subAccessKey;

    MainDeviceInfo *mainDevice;
    NSMutableDictionary *dic;
    
    NSTimer *progressTimer;
    
    DeviceEntity *connectDeviceEntity;
    
    BOOL     isScanSuccess;
    BOOL     isSetAccessKey;
    BOOL     isSubDevice;
    
    int      aResult;
}


@property (nonatomic,strong)UIImageView  *actImageView;

@end

@implementation ConnectingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"添加设备";
    dic=[[NSMutableDictionary alloc] init];
    mainDevice=[[MainDeviceInfo alloc] init];
    
    [self initConnectingView];
    [self startConnectWifiDevice];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnGotDeviceByScan:) name:kOnGotDeviceByScan object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetDeviceAccessKey:) name:kOnSetDeviceAccessKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetDeviceSubKey:) name:kOnGotSubkey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSubscription:) name:kOnSubscription object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-03-10" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-03-10" type:2];
#endif
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    
    [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
        
    }];
    [smtlk closeWithBlock:^(NSString *closeMsg, BOOL isOK) {
        
    }];
    
    if (progressTimer) {
        [progressTimer invalidate];
        progressTimer=nil;
    }
    
}

#pragma mark -- 通知中心回调
#pragma mark SDK扫描到的设备结果回调
-(void)OnGotDeviceByScan:(NSNotification *)notify{
    DeviceEntity *device=notify.object;
    MyLog(@"扫描设备回调 mac = %@ accesskey = %@ ,macStr:%@",device.getMacAddressSimple,device.accessKey,mainDevice.macAddr);
    if ([device.productID isEqualToString:mainDevice.productID]&&[[device getMacAddressSimple] isEqualToString:mainDevice.macAddr]) {
        if (progressTimer) {
            [progressTimer invalidate];
            progressTimer=nil;
        }
        MyLog(@"扫描成功");
        
        if ([device isDeviceInitted]&&device.accessKey.integerValue>0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                RepeatViewController *repeatVC=[[RepeatViewController alloc] init];
                [self.navigationController pushViewController:repeatVC animated:YES];
            });
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [connectAnimation stopAnimating];
                    connectImg.hidden =NO;
                    [subscribeAnimation startAnimating];
                    
                    connectDeviceEntity=device;
                    
                    if (!progressTimer) {
                        progressTimer=[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(setAccessKeyForDevice) userInfo:nil repeats:YES];
                    }
                });
            });
        }
    }
}

#pragma mark 设置设备AccessKey回调
-(void)OnSetDeviceAccessKey:(NSNotification *)notify{
    NSDictionary *dics=notify.object;
    int result=[[dics objectForKey:@"result"]intValue];
    DeviceEntity *device=[dics objectForKey:@"device"];
    
    MyLog(@"设置accesskey回调 ,result:%d",result);
    if ([device.productID isEqualToString:mainDevice.productID]&&[[device getMacAddressSimple]isEqualToString:mainDevice.macAddr]) {
        if (result==0) {
            if (progressTimer) {
                [progressTimer invalidate];
                progressTimer=nil;
            }
            
            MyLog(@"设置accesskey成功");
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    connectDeviceEntity=device;
                    
                    if ([mainDevice.productID isEqualToString:CABINETS_PRODUCT_ID]) {
                        if (!progressTimer) {
                            progressTimer=[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(getSubKeyForDevice) userInfo:nil repeats:YES];
                        }
                    }else{
                        if (!progressTimer) {
                            progressTimer=[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(subDevice) userInfo:nil repeats:YES];
                        }
                    }
                });
            });
        }
    }
}

#pragma mark 获取subkey回调
-(void)OnSetDeviceSubKey:(NSNotification *)notify{
    NSDictionary *dics=notify.object;
    int result=[[dics objectForKey:@"result"]intValue];
    DeviceEntity *device=[dics objectForKey:@"device"];
    NSNumber *subkey=[dics objectForKey:@"subkey"];
    MyLog(@"获取subkey回调 ,result:%d,subkeey:%d",result,[subkey intValue]);
    if ([device.productID isEqualToString:mainDevice.productID]&&[[device getMacAddressSimple]isEqualToString:mainDevice.macAddr]) {
        if (result==CODE_SUCCEED) {
            if (progressTimer) {
                [progressTimer invalidate];
                progressTimer=nil;
            }
            
            subAccessKey=[subkey integerValue];
            MyLog(@"获取subkey回调成功,subkey:%ld",(long)subAccessKey);
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    connectDeviceEntity=device;
                    if (!progressTimer) {
                        progressTimer=[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(subDevice) userInfo:nil repeats:YES];
                    }
                });
            });
        }
    }
}

#pragma mark 设备订阅状态回调
-(void)OnSubscription:(NSNotification *)noti{
    NSDictionary *dics = noti.object;
    DeviceEntity *device=[dics objectForKey:@"device"];
    int result=[[dics objectForKey:@"result"] intValue];
    MyLog(@"设备订阅状态回调 ,result:%d",result);
    if ([device.productID isEqualToString:mainDevice.productID]&&[[device getMacAddressSimple]isEqualToString:mainDevice.macAddr]) {
        if (result==CODE_SUCCEED) {
            if (progressTimer) {
                [progressTimer invalidate];
                progressTimer=nil;
            }
            MyLog(@"设备订阅成功");
            
            if (device.accessKey.integerValue <= 0) {
                device.accessKey = @(userAccessKey);
            }
            
            //设置设备的默认名称，保存到设备扩展属性中
            NSString *key = [NSString stringWithFormat:@"%@name", device.getMacAddressSimple];
            NSDictionary *properties = @{
                                         key: [DeviceHelper productDefaultName:device.productID]
                                         };
            [HttpRequest setDevicePropertyDictionary:properties withDeviceID:@(device.deviceID) withProductID:device.productID withAccessToken:XL_USER_TOKEN didLoadData:^(id result, NSError *err) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [subscribeAnimation stopAnimating];
                    subscribeImg.hidden = NO;
                    
                    ConnectSuccessViewController *connectSuccessVC=[[ConnectSuccessViewController alloc] init];
                    connectSuccessVC.device=device;
                    connectSuccessVC.productID=mainDevice.productID;
                    [self.navigationController pushViewController:connectSuccessVC animated:YES];
                    
                });
            }];
        }else{
            aResult=result;
        }
    }
}


#pragma mark -- Private Methods
#pragma mark 开始连接设备
-(void)startConnectWifiDevice{
    //初始化配网模块
    smtlk = [HFSmartLink shareInstence];
    smtlk.isConfigOneDevice = true;  //每次只配置一个设备
    smtlk.waitTimers = 30;
    
    MyLog(@"wifi-pwd:%@",self.pwd);
    
    userAccessKey =(int)(100000000 + (arc4random() % (999999999 - 100000000 + 1)));//获取一个随机整数
    MyLog(@"userAccessKey = %ld",(long)userAccessKey);
    
    mainDevice=[TJYHelper sharedTJYHelper].selectDevice;
    MyLog(@"deviceName:%@,productID:%@",mainDevice.deviceName,mainDevice.productID);
    
    [self startConnect];  //开始配网
}

#pragma mark 配网
-(void)startConnect{
    [self.actImageView startAnimating];
    [scanAnimation startAnimating];
    
    kSelfWeak;
    
    [smtlk startWithKey:self.pwd processblock:^(NSInteger process) {
        MyLog(@"progress===%li",(long)process);  //配网进度，暂不用
    } successBlock:^(HFSmartLinkDeviceInfo *dev) {
        MyLog(@"设备 mac = %@配网成功",dev.mac);
        
        [scanAnimation stopAnimating];
        scanImg.hidden = NO;
        [connectAnimation startAnimating];
        
        //当给设备配网成功之后保存Wi-Fi密码
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        dic = [userDefaults objectForKey:@"WIFI"];
        dic = [dic mutableCopy];
        if (dic == nil) {
            NSMutableDictionary *dics = [[NSMutableDictionary alloc] init];
            [dics setObject:_pwd forKey:_wifiName];
            [userDefaults setObject:dics forKey:@"WIFI"];
        } else {
            [dic setObject:_pwd forKey:_wifiName];
            [userDefaults setObject:dic forKey:@"WIFI"];
        }
        
        if (!kIsEmptyString(mainDevice.macAddr)) {
            if ([dev.mac isEqualToString:mainDevice.macAddr]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        if (!progressTimer) {
                            progressTimer=[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(scanDevice) userInfo:nil repeats:YES];
                        }
                    });
                });
            }else{
                [weakSelf leftButtonAction];
                if ([_delegate respondsToSelector:@selector(connectingViewControllerScanDeviceFailed)]) {
                    [_delegate connectingViewControllerScanDeviceFailed];
                }
            }
        }else{
            mainDevice.macAddr=dev.mac;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (!progressTimer) {
                        progressTimer=[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(scanDevice) userInfo:nil repeats:YES];
                    }
                });
            });
        }
    } failBlock:^(NSString *failmsg) {
        MyLog(@"failmsg:%@",failmsg);
        [weakSelf.actImageView stopAnimating];
        [weakSelf leftButtonAction];
        if ([_delegate respondsToSelector:@selector(connectingViewControllerNetworkFailed)]) {
            [_delegate connectingViewControllerNetworkFailed];
        }
    } endBlock:^(NSDictionary *deviceDic) {
        MyLog(@"deviceDic:%@",deviceDic);
        [[HFSmartLink shareInstence] closeWithBlock:^(NSString *closeMsg, BOOL isOK) {
            
        }];
    }];
}

#pragma mark 扫描设备
-(void)scanDevice{
    MyLog(@"扫描设备productID:%@",mainDevice.productID);
    [[XLinkExportObject sharedObject] scanByDeviceProductID:mainDevice.productID];
}

#pragma mark 设置access key
-(void)setAccessKeyForDevice{
    MyLog(@"设置设备accesskey:%ld",(long)userAccessKey);
    [[XLinkExportObject sharedObject] setAccessKey:@(userAccessKey) withDevice:connectDeviceEntity];
}

#pragma mark 获取subkey（需要在内网使用）
-(void)getSubKeyForDevice{
    [[XLinkExportObject sharedObject] getSubKeyWithDevice:connectDeviceEntity withAccesskey:@(userAccessKey)];
}

#pragma mark 订阅设备
- (void)subDevice{
    NSNumber *authKey=subAccessKey>0?[NSNumber numberWithInteger:subAccessKey]:[NSNumber numberWithInteger:userAccessKey];
    MyLog(@"订阅设备 mac:%@,accesskey:%@",[connectDeviceEntity getMacAddressSimple],authKey);
    [[XLinkExportObject sharedObject] subscribeDevice:connectDeviceEntity andAuthKey:authKey andFlag:YES];
    
}

#pragma mark 扫描设备
-(void)conncetDeviceScanFailAction{
    
}

#pragma mark 订阅设备失败处理
-(void)conncetDeviceSubFailAction{
    [self leftButtonAction];
    if ([_delegate respondsToSelector:@selector(connectingViewControllerSubDeviceFailedWithCode:)]) {
        [_delegate connectingViewControllerSubDeviceFailedWithCode:aResult];
    }
}

#pragma mark 初始化界面
- (void)initConnectingView{
    [self.view addSubview:self.actImageView];
    
    //连接设备
    UILabel *scanLbl = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2, self.actImageView.bottom+30,80, 30)];
    scanLbl.text = @"连接网络";
    scanLbl.font=[UIFont systemFontOfSize:16];
    [self.view addSubview:scanLbl];
    
    scanAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(scanLbl.right, self.actImageView.bottom+35, 20, 20)];
    scanAnimation.animationImages = [[NSArray alloc]initWithObjects:[UIImage imageNamed:@"con_01"],[UIImage imageNamed:@"con_02"],[UIImage imageNamed:@"con_03"],[UIImage imageNamed:@"con_04"],[UIImage imageNamed:@"con_05"],[UIImage imageNamed:@"con_06"],[UIImage imageNamed:@"con_07"],[UIImage imageNamed:@"con_08"], nil];
    scanAnimation.animationDuration=0.5f;
    [self.view addSubview:scanAnimation];
    
    scanImg = [[UIImageView alloc] initWithFrame:CGRectMake(scanAnimation.left, scanAnimation.top, scanAnimation.width, scanAnimation.height)];
    scanImg.image = [UIImage imageNamed:@"完成"];
    scanImg.hidden = YES;
    [self.view addSubview:scanImg];
    
    //扫描设备
    UILabel *connectLbl = [[UILabel alloc] initWithFrame:CGRectMake(scanLbl.left, scanLbl.bottom+10,scanLbl.width, scanLbl.height)];
    connectLbl.text = @"扫描设备";
    connectLbl.font=[UIFont systemFontOfSize:16];
    [self.view addSubview:connectLbl];
    
    connectAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(connectLbl.right, scanLbl.bottom+15, 20, 20)];
    connectAnimation.animationImages = [[NSArray alloc]initWithObjects:[UIImage imageNamed:@"con_01"],[UIImage imageNamed:@"con_02"],[UIImage imageNamed:@"con_03"],[UIImage imageNamed:@"con_04"],[UIImage imageNamed:@"con_05"],[UIImage imageNamed:@"con_06"],[UIImage imageNamed:@"con_07"],[UIImage imageNamed:@"con_08"], nil];
    connectAnimation.animationDuration=0.5f;
    [self.view addSubview:connectAnimation];
    
    connectImg = [[UIImageView alloc] initWithFrame:CGRectMake(connectAnimation.left, connectAnimation.top, connectAnimation.width, connectAnimation.height)];
    connectImg.image = [UIImage imageNamed:@"完成"];
    connectImg.hidden = YES;
    [self.view addSubview:connectImg];
    
    
    //订阅设备
    UILabel *subscribeLbl = [[UILabel alloc] initWithFrame:CGRectMake(connectLbl.left, connectLbl.bottom+10,connectLbl.width, connectLbl.height)];
    subscribeLbl.text = @"订阅设备";
    subscribeLbl.font=[UIFont systemFontOfSize:16];
    [self.view addSubview:subscribeLbl];
    
    subscribeAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(scanLbl.right, connectLbl.bottom+15, 20, 20)];
    subscribeAnimation.animationImages = [[NSArray alloc]initWithObjects:[UIImage imageNamed:@"con_01"],[UIImage imageNamed:@"con_02"],[UIImage imageNamed:@"con_03"],[UIImage imageNamed:@"con_04"],[UIImage imageNamed:@"con_05"],[UIImage imageNamed:@"con_06"],[UIImage imageNamed:@"con_07"],[UIImage imageNamed:@"con_08"], nil];
    subscribeAnimation.animationDuration=0.5f;
    [self.view addSubview:subscribeAnimation];
    
    subscribeImg = [[UIImageView alloc] initWithFrame:CGRectMake(subscribeAnimation.left, subscribeAnimation.top, subscribeAnimation.width, subscribeAnimation.height)];
    subscribeImg.image = [UIImage imageNamed:@"完成"];
    subscribeImg.hidden = YES;
    [self.view addSubview:subscribeImg];
    
}

#pragma mark -- Setters and Getters
-(UIImageView *)actImageView{
    if (!_actImageView) {
        _actImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, 75, 200, 200)];
        _actImageView.animationImages=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"wifi_progress_1"],[UIImage imageNamed:@"wifi_progress_2"],[UIImage imageNamed:@"wifi_progress_3"],[UIImage imageNamed:@"wifi_progress_4"],[UIImage imageNamed:@"wifi_progress_5"],[UIImage imageNamed:@"wifi_progress_6"], nil];
        _actImageView.animationDuration=1.0f;
    }
    return _actImageView;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnGotDeviceByScan object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnSetDeviceAccessKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnGotSubkey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnSubscription object:nil];
    
    
}


@end
