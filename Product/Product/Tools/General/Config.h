//
//  Config.h
//  Product
//
//  Created by vision on 17/4/13.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#ifndef Config_h
#define Config_h


#endif /* Config_h */


#define SDK_DOMAIN @"dev-link.360tj.com"

/************************产品ID**********************/
///云智能电炖锅
#define CLOUD_COOKER_PRODUCT_ID         @"160fa2ad504ed800160fa2ad504ed801"
///云智能IH电饭煲
#define ELECTRIC_COOKER_PRODUCT_ID      @"160fa2ad504e6000160fa2ad504e6001"
///云智能隔水炖
#define WATER_COOKER_PRODUCT_ID         @"160fa2ad4bf73800160fa2ad4bf73801"
///云智能私享壶
#define CLOUD_KETTLE_PRODUCT_ID         @"160fa2adcd1cb000160fa2adcd1cb001"
///云智能隔水炖16AIG
#define WATER_COOKER_16AIG_PRODUCT_ID   @"1607d2af9faabe001607d2af9faabe01"
///云智能健康大厨
#define COOKFOOD_COOKER_PRODUCT_ID      @"1607d2afae93fc001607d2afae93fc01"
///蓝牙智能血压计
#define CLINK_BPM_PRODUCT_ID            @"160fa2ae8575da00160fa2ae8575da01"
///蓝牙智能体温贴
#define THERMOMETER_PRODUCT_ID          @"160fa2ae85778a00160fa2ae85778a01"
//智能体质健康分析仪
#define SCALE_PRODUCT_ID                @"160fa2ae8aea0200160fa2ae8aea0201"
//智能厨物柜
#define CABINETS_PRODUCT_ID             @"1607d2b1941650001607d2b194165001"

//降糖饭煲
#define LOWERSUGARCOOKER_PRODUCT_ID    @"1607d2b1a4bdd8001607d2b1a4bdd801"

#define APP_ID            @"2e0fa2ae885fac00"
#define APP_ID_FOR_MENU   @"2e0fa2ae97450e00"                //用于云菜谱，食材的APPID

/************第三方key************/
#define QINGNIU_APPID     @"tjdq20160415104958"              //轻牛——秤  SDK
#define kWeiboAPPKey      @"3131949636"
#define kWeiboAppSecret   @"7005c0c423fb4926d460a6f8b08adf62"
#define kWeiboRedirectUri @"http://sns.whalecloud.com/sina2/callback"
#define kWechatAppKey     @"wx064143b1a3094f79"
#define kWechatAppSecret  @"fe403832f1fa8c2a3afda0a0be08fac5"
#define kTencentAppKey    @"1105411881"
#define kTencentAppSecret @"3rTdLT5L8WgFXQUC"
#define AMapKey           @"147d193728bfd34a51c3e7d25779a53a"// 高德地图key


/************通知中心*************/
#define KDelectDevice           @"KDelectDevice"                   //手动重置设备
#define kResetWifiNotification  @"kResetWifiNotification"          //重置wifi
#define kSetTargetNotification  @"kSetTargetNotification"


/************宏定义*************/
#define kAppID                    @"J2uq9KcA8JAJv8qK"                         //app标识ID
#define kAppSecret                @"KY70hHsSxXX88X7PP7UX7u9xxPs20QQu"         //app密钥

/************************/
#define kShopAuthoriseCode        @"23df0021bf6866af2a7e3e23a7a7845a"    //商城授权码

#define kUserID                   @"kUserID"
#define kUserKey                  @"kUserKey"        //用户key
#define kUserSecret               @"kUserSecret"     //用户secret
#define kUserToken                @"kUserToken"      //用户token
#define kUserPhone                @"kUserPhone"      //用户登陆手机号
#define kUserPwd                  @"kUserPwd"        //用户登陆密码
#define kThirdToken               @"kThirdToken"     //云智易平台token
#define kIsLogin                  @"kIsLogin"        //是否登录
#define kDailyEnergy              @"kDailyEnergy"    //每日能量摄入值

#define kDeviceIDFV               @"kDeviceIDFV"

#define kStepKey                  @"kStepKey"            //当前步数
#define kWeekStepKey              @"kWeekStepKey"        //一周步数
#define kDistanceKey              @"kDistanceKey"        //距离
#define kIsSynchoriseHealth       @"kIsSynchoriseHealth" //是否同步健康

#define KTotalCalorie            @"KTotal_calorie"      ///    推荐摄入总量
#define KSummotionCalorie        @"KSummotionCalorie"  /// 推荐消耗量
#define KuserInfo                @"KuserInfo"          /// 用户字数据(用于判断用户信息是否改变)

#define kLaunchAdClickNotify      @"kLaunchAdClickNotify"
#define kAnnouncementClickNotify  @"kAnnouncementClickNotify"       // 公告栏关闭通知

#define kAppScheme      @"TonzeCloud"

#define kPaySuccessNotification  @"kPaySuccessNotification"    //支付回调


/***************判断******************/
#define  kIsLogined   [[NSUserDefaultInfos getValueforIdKey:kIsLogin] boolValue]

/**************公共类库*************/
#import "Product-Swift.h"
#import "NSUserDefaultInfos.h"
#import "UIViewExt.h"
#import "UIImage+Extend.h"
#import "HttpRequest.h"
#import "Singleton.h"
#import "TonzeHelpTool.h"
#import "UIColor+Extend.h"
#import "NSString+Extension.h"
#import "NSObject+Extend.h"
#import "UIView+Toast.h"
#import "UIInitMethod.h"
#import "TJYHelper.h"
#import "UIImageView+WebCache.h"
#import "UIAlertView+Extension.h"
#import "Transform.h"
#import "Interface.h"
#import "NetworkTool.h"
#import "MJRefresh.h"
#import "BlankView.h"
#import "JSON.h"
#import "UIDevice+Extend.h"
#import "SSKeychain.h"
#import "UIButton+Extension.h"
