//
//  AppDelegate.m
//  Product
//
//  Created by Xlink on 15/11/30.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "AppDelegate.h"
#import "DeviceHelper.h"
#import "NotificationHandler.h"
#import "NSData+Extension.h"
#import "UMMobClick/MobClick.h"
#import "QingNiuSDK.h"
#import "DeviceStateListener.h"
#import "DeviceConnectStateCheckService.h"
#import "Product-Swift.h"
#import "AutoLoginManager.h"
#import "HeziSDKManager.h"
#import "TCHealthManager.h"
#import "GuidanceViewController.h"
#import "TCFastLoginViewController.h"
#import "BaseNavigationController.h"
#import "SSKeychain.h"
#import "UIDevice+Extend.h"
#import <AlipaySDK/AlipaySDK.h>

//shareSDK分享
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//腾讯开放平台（对应QQ和QQ空间）SDK文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//微信SDK头文件
#import "WXApi.h"
//新浪微博SDK头文件
#import "WeiboSDK.h"



@interface AppDelegate ()<UIAlertViewDelegate,XlinkExportObjectDelegate,WXApiDelegate>{
    UIAlertView *notificationAlert;
}


@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initSDK];       //初始化SDK
    
    //注册通知中心
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    BOOL hasShowGuidance=[[[NSUserDefaults standardUserDefaults] objectForKey:@"hasShowGuidance"] boolValue];
    if (!hasShowGuidance) {
        GuidanceViewController *guidanceVC=[[GuidanceViewController alloc] init];
        self.window.rootViewController=guidanceVC;
    }else{
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        self.window.rootViewController=[storyboard instantiateInitialViewController];
    }
     [self.window makeKeyAndVisible];
    
    if ([AutoLoginManager shareManager].hasLogin&&kIsLogined) {
        MyLog(@"自动登陆");
        [self configCommunication];      //登录到Xlink
        [self refleshToken];
    }
    
     [XLinkExportObject sharedObject].delegate = self;
    
    //上传设备信息
    [self uploadAppInfo];
    
    [self performSelector:@selector(refleshToken) withObject:nil afterDelay:3600];     //刷新token
    
    
    return YES;
}


#pragma mark - 接收本地推送（AppDelegate.m中添加）
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    if ([notification.alertBody containsString:@"向您分享了设备"]) {
       UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:notification.alertBody delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"接受",@"拒绝", nil];
        alertView.tag=99;  //标记为分享的alert
        
        [alertView show];
    }else if ([notification.alertBody containsString:@"喝水量"]){
       //喝水提醒
        NSString *time=[notification.userInfo objectForKey:@"time"];
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:time message:notification.alertBody delegate:self cancelButtonTitle:nil otherButtonTitles:@"我没喝",@"我喝了", nil];
        alertView.tag=98;  //标记为喝水提醒的alert
        [alertView show];
    }else{
        if (!notificationAlert) {
            notificationAlert= [[UIAlertView alloc] initWithTitle:@"提示" message:notification.alertBody delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [notificationAlert show];
        }else{
            notificationAlert.message=notification.alertBody ;
            [notificationAlert show];
        }
        application.applicationIconBadgeNumber -= 1;
        notification.applicationIconBadgeNumber-=1;

    }
  }


#pragma mark -- 监听点击状态栏返回顶部的方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event  {
    if ([touches.anyObject locationInView:nil].y > 20) return;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"click" object:nil];
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    self.isBackground=NO;
}

#pragma mark APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.isBackground=YES;
    
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"001" type:3];
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnAppStateChanged object:nil userInfo:nil];
    application.applicationIconBadgeNumber=0;
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"clearNotiIconNum" object:nil];
    //注册后台
    __block UIBackgroundTaskIdentifier task = [application beginBackgroundTaskWithExpirationHandler:^{
        // 当申请的后台运行时间已经结束（过期），就会调用这个block
        // 赶紧结束任务
        [application endBackgroundTask:task];
    }];
    
}

#pragma mark APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application {
    MyLog(@"applicationWillEnterForeground");
    
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"001" type:4];
#endif
    
    self.isBackground=NO;
    application.applicationIconBadgeNumber=0;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"clearNotiIconNum" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnAppStateChanged object:nil userInfo:nil];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    MyLog(@"applicationDidBecomeActive");
    
    application.applicationIconBadgeNumber=0;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"clearNotiIconNum" object:nil];

     [self loadHealthStepAndDistance];  //获取步数和距离
    
    //刷新用户凭证
    if (kIsLogined) {
        [[NetworkTool sharedNetworkTool] refreshUserTokenSuccess:^(id json) {
            [[NetworkTool sharedNetworkTool] requestUserInfo];  //获取用户信息
            [self uploadUserStep];
        }];
    }
    
    
    if ([TJYHelper sharedTJYHelper].isGotoWifiSet) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kResetWifiNotification object:nil];
        [TJYHelper sharedTJYHelper].isGotoWifiSet=NO;
    }
}

//跳转其他应用回调
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSString *hostStr=[[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    MyLog(@"applicationOpenURL---host:%@",hostStr);
    
    if ([hostStr isEqualToString:@"safepay"]) { //支付宝支付
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            MyLog(@"支付宝支付回调结果－result : %@",resultDic);
            NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
            if (resultStatus==9000) {
                NSString *paymentId=[NSUserDefaultInfos getValueforKey:@"paymentId"];
                NSString *body=[NSString stringWithFormat:@"payment_id=%@",paymentId];
                [[NetworkTool sharedNetworkTool] postShopMethodWithoutLoadingURL:kOrderAliPayBack body:body success:^(id json) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPaySuccessNotification object:nil];
                } failure:^(NSString *errorStr) {
                    
                }];
            }else if(resultStatus==6001){
                [self.window makeToast:@"用户取消支付" duration:1.0 position:CSToastPositionCenter];
            }else{
                [self.window makeToast:@"订单支付失败" duration:1.0 position:CSToastPositionCenter];
            }
        }];
    }else if ([hostStr isEqualToString:@"pay"]){  //微信支付
        [WXApi handleOpenURL:url delegate:self];
    }else{
        //活动盒子 解析 url
        [[HeziSDKManager sharedInstance] dealWithUrl:url];
    }
    return YES;
}

// 跳转其他应用回调 （9.0以后使用新API接口）
-(BOOL)application:(UIApplication *)app openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options{
    NSString *hostStr=[[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MyLog(@"iOS9以上 applicationOpenURL---host:%@",hostStr);
    
    if ([hostStr isEqualToString:@"safepay"]) { //支付宝支付
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            MyLog(@"支付宝支付回调结果－result : %@",resultDic);
            NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
            if (resultStatus==9000) {
                NSString *paymentId=[NSUserDefaultInfos getValueforKey:@"paymentId"];
                NSString *body=[NSString stringWithFormat:@"payment_id=%@",paymentId];
                [[NetworkTool sharedNetworkTool] postShopMethodWithoutLoadingURL:kOrderAliPayBack body:body success:^(id json) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPaySuccessNotification object:nil];
                } failure:^(NSString *errorStr) {
                    
                }];
            }else if(resultStatus==6001){
                [self.window makeToast:@"用户取消支付" duration:1.0 position:CSToastPositionCenter];
            }else{
                [self.window makeToast:@"订单支付失败" duration:1.0 position:CSToastPositionCenter];
            }
        }];
    }else if ([hostStr isEqualToString:@"pay"]){  //微信支付
        [WXApi handleOpenURL:url delegate:self];
    }else{
        //活动盒子 解析 url
        [[HeziSDKManager sharedInstance]dealWithUrl:url];
    }
    return YES;
}



#pragma mark -- Private Methods
#pragma mark 获取健康数据
-(void)loadHealthStepAndDistance{
    //今日步数
    [[TCHealthManager sharedTCHealthManager] getStepCountWithDays:1 complete:^(NSMutableArray *valuesArray, NSError *error) {
        if (!error) {
            if (kIsArray(valuesArray)&&valuesArray.count>0) {
                NSDictionary *dict=valuesArray[0];
                NSString *currentDate=[[TJYHelper sharedTJYHelper] getCurrentDate];
                NSNumber *value=[dict valueForKey:currentDate];
                [NSUserDefaultInfos putKey:kStepKey andValue:value];
            }
        }
    }];
    
    // 一周步数
    [[TCHealthManager sharedTCHealthManager] getStepCountWithDays:7 complete:^(NSMutableArray *valuesArray, NSError *error) {
        if (!error) {
            if (kIsArray(valuesArray)&&valuesArray.count>0) {
                [NSUserDefaultInfos putKey:kWeekStepKey andValue:valuesArray];
            }
        }
    }];
    
    //今日距离
    [[TCHealthManager sharedTCHealthManager] getDistance:^(double value, NSError *error) {
        if (!error) {
            if (value>0.01) {
                [NSUserDefaultInfos putKey:kDistanceKey andValue:[NSNumber numberWithInteger:(long)(value*1000+0.5)]];
            }
        }
    }];
}


#pragma mark 上传步数
-(void)uploadUserStep{
    NSString *value=[NSUserDefaultInfos getValueforKey:kStepKey];
    NSString *body=[NSString stringWithFormat:@"step=%@",value];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kAddDailyStep body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        MyLog(@"addstep--error:%@",errorStr);
    }];
}

#pragma mark  添加应用设备信息
-(void)uploadAppInfo{
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    
    NSString *body=[NSString stringWithFormat:@"sn=%@&app_version=%@&phone_sn=%@&phone_version=%@&country=%@&province=&city=&language=%@&network=%@&request_platform=iOS",uuid,[UIDevice getSoftwareVer],[UIDevice iphoneType],[UIDevice getSystemVersion],[UIDevice getCountry],[UIDevice getLanguage],[UIDevice getNetworkType]];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kUploadDeviceInfo body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        
    }];
}


#pragma mark --初始化SDK
-(void)initSDK{
    /**活动盒子**/
    [[HeziSDKManager sharedInstance] configureKey:@"2d137de047e2a9cc314118ac39e60cd4"];        // 设置KEY
    [[HeziSDKManager sharedInstance] configureServerDomain:@"http://emma.360tj.com/"];
    [[HeziSDKManager sharedInstance] openDebug:YES];              // 是否开启debug模式
    
#ifdef DEBUG

#else
    /*****友盟统计*****/
    UMConfigInstance.appKey = @"584e4b014544cb49a2000be6";
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];            //配置以上参数后调用此方法初始化SDK！
    [MobClick setAppVersion:[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]];
    
    [MobClick setCrashReportEnabled:YES];
    
    [MobClick setLogEnabled:YES];
    
#endif
    
    /***注册轻牛SDK*****/
    [QingNiuSDK registerApp:QINGNIU_APPID registerAppBlock:^(QingNiuRegisterAppState qingNiuRegisterAppState) {
        NSLog(@"%ld",(long)qingNiuRegisterAppState);
        
    }];
    
    /******shareSD初始化******/
    [ShareSDK registerApp:@"天际云健康"
          activePlatforms:@[
                            @(SSDKPlatformSubTypeWechatSession),
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformSubTypeWechatTimeline),
                            @(SSDKPlatformTypeQQ),
                            ]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType) {
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
                 
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         switch (platformType) {
             case SSDKPlatformTypeSinaWeibo:
                 [appInfo SSDKSetupSinaWeiboByAppKey:kWeiboAPPKey appSecret:kWeiboAppSecret redirectUri:kWeiboRedirectUri authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:kWechatAppKey appSecret:kWechatAppSecret];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:kTencentAppKey appKey:kTencentAppSecret authType:SSDKAuthTypeBoth];
                 break;
                 
             default:
                 break;
         }
         
     }];
    
    /***注册微信***/
    [WXApi registerApp:kWechatAppKey];
    
    //获取健康权限
    [[TCHealthManager sharedTCHealthManager] authorizeHealthKit:^(BOOL success, NSError *error) {
        if (!success) {
            MyLog(@"获取健康权限失败，error:%@",error.localizedDescription);
        }
        [NSUserDefaultInfos putKey:kIsSynchoriseHealth andValue:[NSNumber numberWithBool:success]];
    }];
}

#pragma mark --登录到Xlink
- (void)configCommunication{
    NSMutableDictionary *result=[NSMutableDictionary dictionaryWithDictionary:[NSUserDefaultInfos getDicValueforKey:USER_DIC]];
    if (kIsDictionary(result)&&result.count>0) {
        NSString *authorize=[result objectForKey:@"authorize"];
        NSString *user_id=[result objectForKey:@"user_id"];
        
        [[XLinkExportObject sharedObject] start];
        [[XLinkExportObject sharedObject] setSDKProperty:SDK_DOMAIN withKey:PROPERTY_CM_SERVER_ADDR];
        [[XLinkExportObject sharedObject] loginWithAppID:user_id.intValue andAuthStr:authorize];
        self.isLogin = YES;
    }
}


#pragma mark 刷新accessToken
- (void)refleshToken{
    NSString * token= [NSUserDefaultInfos getValueforKey:kThirdToken];
    __weak typeof(self) weakSelf = self;
    if (token&&token.length!=0) {
        NSDictionary *result=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
        NSString *token=[result objectForKey:@"access_token"];
        NSString *refresh=[result objectForKey:@"refresh_token"];
        if (token && refresh && token.length > 0 && refresh.length > 0) {
            [HttpRequest refreshAccessToken:token withRefreshToken:refresh didLoadData:^(id result, NSError *err) {
                if (err) {
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        [weakSelf performSelector:@selector(refleshToken) withObject:nil afterDelay:1];
                    });
                }else{
                    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] initWithDictionary:[NSUserDefaultInfos getDicValueforKey:USER_DIC]];
                    [userDict setValue:[result objectForKey:@"access_token"] forKey:@"access_token"];
                    [userDict setValue:[result objectForKey:@"refresh_token"] forKey:@"refresh_token"];
                    [NSUserDefaultInfos putKey:USER_DIC andValue:userDict];
                    [weakSelf performSelector:@selector(refleshToken) withObject:nil afterDelay:3600];
                }
            }];
        }
    }
}

#pragma mark 重新获取accessToken
-(void)updateAccessToken{
    NSString *token = [NSUserDefaultInfos getValueforKey:kThirdToken];
    if (!kIsEmptyString(token)) {
        NSString *openId=[Transform tokenToAccountId:token];
        [HttpRequest thirdAuthWithOpenID:openId withToken:token didLoadData:^(NSDictionary *result, NSError *err) {
            if (!err) {
                if (kIsDictionary(result)&&result.count>0) {
                    [NSUserDefaultInfos putKey:USER_DIC andValue:result];
                }
            }
        }];
    }
}

#pragma mark 跳转到登录页
-(void)pushtoLoginVCWithStatus:(NSInteger)status message:(NSString *)message{
    //清除数据
    [[AutoLoginManager shareManager] clearAllUserData];
    self.isLogin = NO;
    [NSUserDefaultInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:NO]];
    
    if (status==10000) {
        __weak typeof(self) weakSelf=self;
        [[NetworkTool sharedNetworkTool] refreshUserTokenSuccess:^(id json) {
            [[NetworkTool sharedNetworkTool] requestUserInfo];  //获取用户信息
            [weakSelf uploadUserStep];
        }];
    }else{
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView==notificationAlert) {
        notificationAlert=nil;
    }else if (alertView.tag==99){
        if (buttonIndex==1) {
            //接受分享
            [[NotificationHandler shareHendler] acceptShare];
        }else if(buttonIndex==2){
            [[NotificationHandler shareHendler] refuseShare];
        }
    }else if (alertView.tag==98){
        if (buttonIndex==1) {
            //插入喝水量
            [[NotificationHandler shareHendler] insertRemindRecord];
        }
    }else{
        [TJYHelper sharedTJYHelper].isRootWindowIn=YES;
        TCFastLoginViewController  *fastLoginVC=[[TCFastLoginViewController alloc] init];
        BaseNavigationController *nav=[[BaseNavigationController alloc] initWithRootViewController:fastLoginVC];
        self.window.rootViewController=nav;
    }
}

#pragma mark WXApiDelegate
#pragma mark 收到一个来自微信的处理结果。
//调用一次sendReq后会收到onResp。
-(void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass: [PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
            {
                //服务器端查询支付通知或查询API返回的结果再提示成功
                MyLog(@"支付成功");
                
                NSString *paymentId=[NSUserDefaultInfos getValueforKey:@"paymentId"];
                NSString *body=[NSString stringWithFormat:@"payment_id=%@",paymentId];
                [[NetworkTool sharedNetworkTool] postShopMethodWithoutLoadingURL:kOrderWxPayCallBack body:body success:^(id json) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPaySuccessNotification object:nil];
                } failure:^(NSString *errorStr) {
                    
                }];
            }
                break;
            default:
                MyLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
}

#pragma mark XLinkExportObject Delegate
#pragma mark 登录状态回调
-(void)onLogin:(int)result{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnLogin object:@{@"result" : [NSNumber numberWithInt:result]}];
    MyLog(@"登录状态回调 onLogin: %d",result);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (self.isLogin) {
                if (result==CODE_SERVER_KICK_DISCONNECT) {//被踢下线
                    //清除数据
                    [[AutoLoginManager shareManager] clearAllUserData];
                    
                    self.isLogin = NO;
                    
                    UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"提示" message:@"你的帐号已在别处登录，请重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                    
                }else if (result==CODE_SUCCEED){
                    self.isLogin = YES;
                }else if (result != CODE_STATE_KICK_OFFLINE){
                    NSString * token= [NSUserDefaultInfos getValueforKey:USER_ID];
                    if (!token||token.length==0) {
                        NSDictionary *result=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
                        NSString *authorize=[result objectForKey:@"authorize"];
                        NSString *user_id=[result objectForKey:@"user_id"];
                        
                        if (authorize && user_id && authorize.integerValue > 0 && user_id.integerValue > 0) {
                            [[XLinkExportObject sharedObject] loginWithAppID:user_id.intValue andAuthStr:authorize];
                        }
                    }
                }
            }
        });
    });
}

- (void)setIsLogin:(BOOL)isLogin{
    _isLogin = isLogin;
}

#pragma mark SDK扫描到的设备结果回调
-(void)onGotDeviceByScan:(DeviceEntity *)device{
    MyLog(@"onGotDeviceByScan,mac:%@",device.getMacAddressSimple);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnGotDeviceByScan object:device];
}

#pragma mark  设置设备AccessKey回调
-(void)onSetDeviceAccessKey:(DeviceEntity *)device withResult:(unsigned char)result withMessageID:(unsigned short)messageID{
    MyLog(@"onSetDeviceAccessKey,mac:%@",device.getMacAddressSimple);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSetDeviceAccessKey object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
}

#pragma mark 获取到SUBKEY
-(void)onGotSubKeyWithDevice:(DeviceEntity *)device withResult:(int)result withSubKey:(NSNumber *)subkey{
    MyLog(@"onGotSubKeyWithDevice,mac:%@,subkey:%ld",device.getMacAddressSimple,[subkey integerValue]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnGotSubkey object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"subkey" : subkey}];
}

#pragma mark 与设备订阅状态回调
-(void)onSubscription:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSubscription object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
    if (result == 0) {
        NSLog(@"订阅成功,MessageID = %d", messageID);
    }else{
        NSLog(@"订阅失败,MessageID = %d; Result = %d", messageID, result);
    }
}

#pragma mark 连接设备回调
-(void)onConnectDevice:(DeviceEntity *)device andResult:(int)result andTaskID:(int)taskID {
    MyLog(@"连接设备回调--onConnectDevice. result: %d", result);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnConnectDevice object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"taskID" : [NSNumber numberWithInt:taskID]}];
}

#pragma mark 设备上下线状态回调
-(void)onDeviceStatusChanged:(DeviceEntity *)device{
    MyLog(@"设备上下线状态回调,onDeviceStateChanged,DataLength mac:%@,connenct:%d", [device getMacAddressString],device.isConnected);
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:kOnDeviceStateChanged object:@{@"device":device}];
}


#pragma mark 发送云端透传数据结果
-(void)onSendPipeData:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    MyLog(@"发送云端透传数据结果----onSendPipeData:%d",result);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSendPipeData object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
}

#pragma mark 发送本地透传消息结果回调
-(void)onSendLocalPipeData:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID {
    MyLog(@"发送本地透传数据结果----onSendLocalPipeData:%d",result);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSendLocalPipeData object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
}

#pragma mark  接收本地设备发送的pipe包
-(void)onRecvLocalPipeData:(DeviceEntity *)device withPayload:(NSData *)payload{
    MyLog(@"onRecvLocalPipeData,DataLength %lu", (unsigned long)payload.length);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvLocalPipeData object:@{@"device" : device, @"payload" : payload}];
}

#pragma mark 接收到云端设备发送回来的pipe结构
-(void)onRecvPipeData:(DeviceEntity *)device withMsgID:(UInt16)msgID withPayload:(NSData *)payload{
    MyLog(@"onRecvPipeData,DataLength %lu", (unsigned long)payload.length);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvPipeData object:@{@"device" : device, @"payload" : payload}];
}

#pragma mark 接收到云端设备发送的PIPE_SYNC(PIPE_2)
-(void)onRecvPipeSyncData:(DeviceEntity *)device withPayload:(NSData *)payload{
    MyLog(@"onRecvPipeSyncData,DataLength %lu", (unsigned long)payload.length);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvPipeSyncData object:@{@"device" : device, @"payload" : payload}];
}

#pragma mark 数据端点数据回调（透传功能用不到）
-(void)onDataPointUpdata:(DeviceEntity *)device withIndex:(int)index withDataBuff:(NSData *)dataBuff withChannel:(int)channel{
    MyLog(@"数据端点数据回调--onDataPointUpdata,index:%d,channel:%d",index,channel);
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:kOnDataPointUpdata object:@{@"device" : device, @"index" : [NSNumber numberWithInt:index], @"databuff" : dataBuff, @"channel" : [NSNumber numberWithInt:channel]}];
}



@end
