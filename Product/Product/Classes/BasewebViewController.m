//
//  BasewebViewController.m
//  Product
//
//  Created by zhuqinlu on 2017/4/18.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BasewebViewController.h"
#import "SVProgressHUD.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>
#import "ActionSheetView.h"
#import "TonzeHelpTool.h"
#import <WebKit/WebKit.h>

#define ShareTitle     @"天际云健康-营养百科"

@interface BasewebViewController ()<WKUIDelegate,WKNavigationDelegate>{
    
    UIButton *likeBtn;
    UIButton *collectionBtn;
    
    UIImageView *image;

    NSString  *aDiaryUrl;
    NSString  *timeStr;
}

@property (nonatomic,strong)WKWebView  *rootWebView;
/// 导航栏
@property (nonatomic ,strong) UIView *navigationView;
/// 头部视图
@property (nonatomic ,strong) UIView *headerView;
/// 导航栏菜谱名称
@property (nonatomic ,strong) UILabel *menuNavLabel;

@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation BasewebViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.baseTitle = self.type == BaseWebViewTypeADiary?@"营养日记":@"";
    self.rightImageName =self.type == BaseWebViewTypeADiary?@"ic_top_share":@"";
    image = [[UIImageView alloc] init];
    if (self.type == BaseWebViewTypeADiary) {
        image.image = [UIImage imageNamed:@"ic_share_logo"];
    } else {
        [image sd_setImageWithURL:[NSURL URLWithString:self.imageUrl] placeholderImage:nil];
    }
    
    [self.view addSubview:self.rootWebView];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, [[UIScreen mainScreen] bounds].size.width, 2)];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.progressTintColor = UIColorFromRGB(0xfff100);
    //设置进度条的高度
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.progressView];
    //添加KVO，监听WKWebView加载进度
    [self.rootWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    if (self.type != BaseWebViewTypeADiary) {
        [self setNavigation];
    }
    [self requestWebView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
#if !DEBUG
    if ([TonzeHelpTool sharedTonzeHelpTool].viewType==WebViewTypeUserAgreenment) {
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-05-09" type:1];
    }else if([TonzeHelpTool sharedTonzeHelpTool].viewType==WebViewTypeArticle){
        NSInteger articleID=[TonzeHelpTool sharedTonzeHelpTool].article_id;
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:[NSString stringWithFormat:@"004-04-06-%ld",(long)articleID] type:1];
    }
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    if ([TonzeHelpTool sharedTonzeHelpTool].viewType==WebViewTypeUserAgreenment) {
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-05-09" type:2];
    }else if([TonzeHelpTool sharedTonzeHelpTool].viewType==WebViewTypeArticle){
        NSInteger articleID=[TonzeHelpTool sharedTonzeHelpTool].article_id;
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:[NSString stringWithFormat:@"004-04-06-%ld",(long)articleID] type:2];
    }
#endif
}
#pragma mark -- 分享日记
- (void)rightButtonAction{
    NSArray *titlearr = @[@"微信好友",@"微信朋友圈",@"QQ",@"QQ空间",@"新浪微博",@""];
    NSArray *imageArr = @[@"ic_pub_share_wx",@"ic_pub_share_pyq",@"ic_pub_share_qq",@"ic_pub_share_qzone",@"ic_pub_share_wb",@""];
    
    ActionSheetView *actionsheet = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"测试" and:ShowTypeIsShareStyle];
    [actionsheet setBtnClick:^(NSInteger btnTag) {
        
        if (btnTag==0||btnTag==1||btnTag==2||btnTag==3) {
            //分享代码
            [self shareWeixin:btnTag];
            
        }else if (btnTag==4){
            [self shareSina];
        }else{
            
        }
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];

}

- (void)rightButtonAction:(UIButton *)button{
    
    if (button.tag==1000) {
#if !DEBUG
        NSString *targetId=[NSString stringWithFormat:@"004-04-07-%ld",(long)self.articleId];
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:targetId];
#endif
        NSArray *titlearr = @[@"微信好友",@"微信朋友圈",@"QQ",@"QQ空间",@"新浪微博",@""];
        NSArray *imageArr = @[@"ic_pub_share_wx",@"ic_pub_share_pyq",@"ic_pub_share_qq",@"ic_pub_share_qzone",@"ic_pub_share_wb",@""];
        
        ActionSheetView *actionsheet = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"测试" and:ShowTypeIsShareStyle];
        [actionsheet setBtnClick:^(NSInteger btnTag) {
            
            if (btnTag==0||btnTag==1||btnTag==2||btnTag==3) {
                //分享代码
                [self shareWeixin:btnTag];
                
            }else if (btnTag==4){
                [self shareSina];
            }else{
                
            }
        }];
        [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];
    } else {
        NSString *body = [NSString stringWithFormat:@"target_type=article&doSubmit=1&target_id=%ld",(long)self.articleId];
        kSelfWeak;
        [[NetworkTool sharedNetworkTool]postMethodWithURL:KCollection body:body success:^(id json) {
            NSInteger status  = [[json objectForKey:@"status"] integerValue];
            NSString *messageStr = [json objectForKey:@"message"];
            if (status== 1) {
                [TJYHelper sharedTJYHelper].isReloadHome = YES;
                [weakSelf.view makeToast:messageStr duration:1.0 position:CSToastPositionCenter];
                if (!_isWebUrl) {
                    if (!weakSelf.isCollect) {
                        [collectionBtn setImage:[UIImage imageNamed:@"ic_top_collect_on"] forState:UIControlStateNormal];
                    }else{
                        [collectionBtn setImage:[UIImage imageNamed:@"ic_top_collect_un"] forState:UIControlStateNormal];
                    }
                }
            }
            weakSelf.isCollect =!weakSelf.isCollect;
            [TJYHelper sharedTJYHelper].isReloadArticle = YES;
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];

    }

}
#pragma mark -- 分享微信／qq
- (void)shareWeixin:(NSInteger)index{
    
    NSString *shareUrl=self.type==BaseWebViewTypeADiary?aDiaryUrl:self.urlStr;
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if (image) {
        [shareParams SSDKSetupShareParamsByText:self.type == BaseWebViewTypeADiary?timeStr:ShareTitle
                                         images:image.image
                                            url:[NSURL URLWithString:shareUrl]
                                          title:self.type == BaseWebViewTypeADiary?@"天际云健康-营养日记":self.titleName
                                           type:SSDKContentTypeAuto];
    }
    [shareParams SSDKEnableUseClientShare];
    if (index==0) {
        [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            [self shareSuccessorError:state];
        }];
        
    }else if (index==1){
        [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            [self shareSuccessorError:state];
        }];
        
    }else if (index==2){
        [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            [self shareSuccessorError:state];
        }];
        
    }else{
        [ShareSDK share:SSDKPlatformSubTypeQZone parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            [self shareSuccessorError:state];
        }];
        
    }
}
#pragma mark -- 分享新浪
- (void)shareSina{
    NSString *shareUrl=self.type==BaseWebViewTypeADiary?aDiaryUrl:self.urlStr;
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if (image) {
        [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@%@",self.type == BaseWebViewTypeADiary?@"天际云健康-营养日记":self.titleName,
                                                 [NSURL URLWithString:shareUrl]]
                                         images:image.image
                                            url:[NSURL URLWithString:shareUrl]
                                          title:self.type == BaseWebViewTypeADiary?timeStr:ShareTitle
                                           type:SSDKContentTypeAuto];
    }
    [shareParams SSDKEnableUseClientShare];
    [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        [self shareSuccessorError:state];
    }];
}
#pragma mark -- 分享成功／失败／取消
- (void)shareSuccessorError:(NSInteger)index{
    if (index==1) {
        [self.view makeToast:@"分享成功" duration:1.0 position:CSToastPositionCenter];
        
    }else if (index==2){
        [self.view makeToast:@"分享失败" duration:1.0 position:CSToastPositionCenter];
        
    }else{
        [self.view makeToast:@"分享取消" duration:1.0 position:CSToastPositionCenter];
        
    }
    
}

#pragma mark - 监听web加载进度
// 在监听方法中获取网页加载的进度，并将进度赋给progressView.progress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.rootWebView.estimatedProgress;
        if (self.progressView.progress == 1) {
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - WKWKNavigationDelegate Methods
//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}
//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
    //加载完成后隐藏progressView

}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *URL = navigationAction.request.URL;
    //用代理获取点击焦点的href
    if (self.type == BaseWebViewTypeADiary) {
        aDiaryUrl =  [URL absoluteString];
        
        NSArray     *urlArray = [aDiaryUrl componentsSeparatedByString:@"?"];
        NSString    *urlTag = urlArray[1];
        NSArray     *shareArr = [urlTag componentsSeparatedByString:@"="];
        NSString    *shareTag = shareArr[1];
        timeStr = [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:shareTag format:@"yyyy-MM-dd"];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark -- Private Methods
-(void)requestWebView{
    NSString *urlString=[NSString stringWithFormat:@"%@",self.urlStr];
    MyLog(@"url:%@",urlString);
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [self.rootWebView loadRequest:req];
}
#pragma mark -- Navigation
/** 导航栏 **/
- (void)setNavigation{
    _navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    _navigationView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.01];
    [self.view addSubview:_navigationView];
    
    UIButton *backBtn=[[UIButton alloc] initWithFrame:CGRectMake(5, 22, 40, 40)];
    [backBtn setImage:[UIImage drawImageWithName:@"back.png" size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
    [backBtn addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_navigationView addSubview:backBtn];
    
    _menuNavLabel = InsertLabel(_navigationView, CGRectMake((SCREEN_WIDTH-150)/2, 20, 150, 44), NSTextAlignmentCenter, self.titleText, kFontSize(18), [UIColor whiteColor], NO);
    
    if (![self.titleText isEqualToString:@"用户协议"]) {
        /// 分享
        likeBtn =  InsertButtonWithType(_navigationView, CGRectMake(kScreenWidth - 85, 22 , 40, 40), 1000, self, @selector(rightButtonAction:), UIButtonTypeCustom);
        if (!_isWebUrl) {
            [likeBtn setImage:[UIImage imageNamed:@"ic_top_share"] forState:UIControlStateNormal];
        }
        /// 收藏
        collectionBtn = InsertButtonWithType(_navigationView, CGRectMake(kScreenWidth - 45, 22 , 40, 40), 1001, self, @selector(rightButtonAction:), UIButtonTypeCustom);
        if (!_isWebUrl) {
            if (_isCollect && kIsLogin) {
                [collectionBtn setImage:[UIImage imageNamed:@"ic_top_collect_on"] forState:UIControlStateNormal];
            }else{
                [collectionBtn setImage:[UIImage imageNamed:@"ic_top_collect_un"] forState:UIControlStateNormal];
            }
        }
        
    }
}
#pragma mark -- setters and getters
-(WKWebView *)rootWebView{
    if (_rootWebView==nil) {
        _rootWebView=[[WKWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-kNavigationHeight)];
        _rootWebView.UIDelegate=self;
        _rootWebView.navigationDelegate = self;
        _rootWebView.backgroundColor=[UIColor whiteColor];
    }
    return _rootWebView;
}
#pragma mark ====== dealloc =======
- (void)dealloc {
    [self.rootWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
