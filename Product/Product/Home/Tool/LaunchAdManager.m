//
//  LaunchAdManager.m
//  TonzeCloud
//
//  Created by vision on 17/11/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "LaunchAdManager.h"
#import "XHLaunchAd.h"
#import "TCBannerModel.h"
#import "BasewebViewController.h"
#import "FoodDetailViewController.h"
#import "LoginViewController.h"
#import "HeziTrigger.h"
#import "TJYFoodDetailsVC.h"
#import "UIViewController+Nav.h"
#import "BaseNavigationController.h"
#import "TCFastLoginViewController.h"


@interface LaunchAdManager()<XHLaunchAdDelegate,HeziTriggerActivePageDelegate>{
    TCBannerModel *banner;
}

@end

@implementation LaunchAdManager

+(void)load{
    [self shareManager];
}

+(LaunchAdManager *)shareManager{
    static LaunchAdManager *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[LaunchAdManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //在UIApplicationDidFinishLaunching时初始化开屏广告,做到对业务层无干扰,当然你也可以直接在AppDelegate didFinishLaunchingWithOptions方法中初始化
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            //初始化开屏广告
            [self setupLauchAd];
        }];
    }
    return self;
}

-(void)setupLauchAd{
    //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    //1.因为数据请求是异步的,请在数据请求前,调用下面方法配置数据等待时间.
    //2.设为3即表示:启动页将停留3s等待服务器返回广告数据,3s内等到广告数据,将正常显示广告,否则将不显示
    //3.数据获取成功,配置广告数据后,自动结束等待,显示广告
    //注意:请求广告数据前,必须设置此属性,否则会先进入window的的根控制器
    [XHLaunchAd setWaitDataDuration:3];
    
    
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kAdIndexUrl body:@"type=2" success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            banner=[[TCBannerModel alloc] init];
            [banner setValues:result];

            //配置广告数据
            XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration new];
            imageAdconfiguration.duration              = [banner.minutes integerValue];                                  //广告停留时间
            imageAdconfiguration.frame                 = CGRectMake(0, 0, kScreenWidth, kScreenHeight);   //广告frame
            imageAdconfiguration.imageNameOrURLString  = banner.image_url;                                   //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
            imageAdconfiguration.imageOption           = XHLaunchAdImageCacheInBackground;                //先缓存,下次显示
            imageAdconfiguration.contentMode           = UIViewContentModeScaleAspectFill;                //图片填充模式
            imageAdconfiguration.showFinishAnimate     = ShowFinishAnimateLite;                            //广告显示完成动画
            imageAdconfiguration.showFinishAnimateTime = 0.8;                                              //广告显示完成动画时间
            imageAdconfiguration.skipButtonType        = SkipTypeTimeText;                                 //跳过按钮类型
            imageAdconfiguration.openURLString         = banner.info;

            //显示开屏广告
            [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
        }
    } failure:^(NSString *errorStr) {

    }];
}

#pragma mark - XHLaunchAd delegate - 倒计时回调
/**
 *  广告点击事件 回调
 */
- (void)xhLaunchAd:(XHLaunchAd *)launchAd clickAndOpenURLString:(NSString *)openURLString{
    MyLog(@"广告点击事件");
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-09-01"];
#endif
    NSString *uuid = [[TJYHelper sharedTJYHelper] deviceUUID];
    NSString *body = [NSString stringWithFormat:@"doSubmit=1&type=3&imsi=%@&type_id=%ld",uuid,(long)banner.id];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kBannarStatistics body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        
    }];
    UIViewController* rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    
    BOOL isNeedLogin=[banner.login_limit boolValue];
    BOOL isLogin= kIsLogined;
    
    BOOL flag=NO;
    if (isNeedLogin) {
        flag=isLogin;
    }else{
        flag=YES;
    }
    
    if (banner.type>1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLaunchAdClickNotify object:nil];
    }
    
    if (flag) {
        switch (banner.type) {
            case 1: //url外部跳转
            {
                NSString *tmall_url=banner.info;
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[tmall_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
                break;
            case 2: //文章
            {
                
                [TonzeHelpTool sharedTonzeHelpTool].viewType=WebViewTypeArticle;
                NSString *url = [NSString stringWithFormat:@"%@",kHostURL];
                url = [url stringByReplacingOccurrencesOfString:@"/%@" withString:@""];
                NSString *urlString = [NSString stringWithFormat:@"%@/article/%@",url,banner.info];
                BasewebViewController *webVC=[[BasewebViewController alloc] init];
                webVC.articleId = [banner.info integerValue];
                webVC.titleText=@"文章详情";
                webVC.isWebUrl = NO;
                webVC.imageUrl = banner.image_url;
                webVC.urlStr=urlString;
                webVC.titleName = banner.name;
                webVC.hidesBottomBarWhenPushed=YES;
                [rootVC.myNavigationController pushViewController:webVC animated:YES];
            }
                break;
            case 3: //食物
            {
                TJYFoodDetailsVC *foodDetailsVC = [TJYFoodDetailsVC new];
                foodDetailsVC.food_id = [banner.info integerValue];
                foodDetailsVC.hidesBottomBarWhenPushed=YES;
                [rootVC.myNavigationController pushViewController:foodDetailsVC animated:YES];
            }
                break;
            case 5: //活动盒子
            {
                NSString *phone=[NSUserDefaultInfos getValueforKey:kUserPhone];
                NSDictionary *userInfo=@{@"username":phone,@"mobile":phone};
                [HeziTrigger trigger:banner.info userInfo:userInfo showIconInView:rootVC.view rootController:rootVC delegate:self];
            }
                break;
            case 6: //url内部链接
            {
                BasewebViewController *webVC=[[BasewebViewController alloc] init];
                webVC.titleText=banner.name;
                webVC.urlStr=banner.info;
                webVC.hidesBottomBarWhenPushed=YES;
                [rootVC.myNavigationController pushViewController:webVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    }else{
        TCFastLoginViewController  *fastLoginVC=[[TCFastLoginViewController alloc] init];
        BaseNavigationController *nav=[[BaseNavigationController alloc] initWithRootViewController:fastLoginVC];
        [rootVC.myNavigationController presentViewController:nav animated:YES completion:nil];
    }
}

/**
 *  图片本地读取/或下载完成回调
 *
 *  @param launchAd  XHLaunchAd
 *  @param image 读取/下载的image
 *  @param imageData 读取/下载的imageData
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd imageDownLoadFinish:(UIImage *)image imageData:(NSData *)imageData{
    MyLog(@"图片下载完成/或本地图片读取完成回调");
}


/**
 *  广告显示完成
 */
-(void)xhLaunchAdShowFinish:(XHLaunchAd *)launchAd{
    MyLog(@"广告显示完成");
}


@end
