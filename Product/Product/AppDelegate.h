//
//  AppDelegate.h
//  Product
//
//  Created by Xlink on 15/11/30.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScaleListViewController.h"
#import "DeviceViewController.h"
#import "DeviceEntity.h"
#import "NSNotificationCenter+MainThread.h"
#import "XLinkExportObject.h"
#import "BTHelper.h"
#import "TIBLECBKeyfob.h"
#import "ControllerHelper.h"
#import "MainTabbarViewController.h"






@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (nonatomic, assign) BOOL isLogin;  //判断是否登录了SDK,注意：是否接受重新登录回调
@property(nonatomic,assign)BOOL isBackground ;//判断是否在后台
@property (strong, nonatomic) UIWindow *window;

@property (strong,nonatomic ) ScaleListViewController  *scaleListVC;
@property (strong, nonatomic) BTHelper                 *BTHelper;
@property (strong, nonatomic) TIBLECBKeyfob            *tiBT;
@property (nonatomic,strong ) DeviceEntity             *currentDevice;
@property (nonatomic,strong ) ControllerHelper         *controllHelper;

//更新用户凭证
-(void)updateAccessToken;


-(void)pushtoLoginVCWithStatus:(NSInteger)status message:(NSString *)message;

@end

