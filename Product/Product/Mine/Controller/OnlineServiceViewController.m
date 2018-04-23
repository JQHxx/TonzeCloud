//
//  OnlineServiceViewController.m
//  Product
//
//  Created by Xlink on 15/12/3.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "OnlineServiceViewController.h"
#import "SVProgressHUD.h"

@interface OnlineServiceViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;


@end

@implementation OnlineServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=self.isDietService?@"营养咨询":@"在线客服";
    
    [self.view addSubview:self.webView];
    
    
    NSString *urlStr=self.isDietService?@"http://www.360tj.com/ext/nutrition.html":@"http://www.360tj.com/ext/feedback.html";
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    [_webView loadRequest:req];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-05-03" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-05-03" type:2];
#endif
}

-(UIWebView *)webView{
    if (!_webView) {
        _webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight)];
        _webView.scrollView.bounces=NO;
        _webView.delegate=self;
    }
    return _webView;
}

#pragma mark --UIWebViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView{
    MyLog(@"webViewDidStartLoad");
    [SVProgressHUD show];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    MyLog(@"webViewDidFinishLoad");
    [SVProgressHUD dismiss];
}

@end
