//
//  GuidanceViewController.m
//  Tianjiyun
//
//  Created by vision on 16/9/20.
//  Copyright © 2016年 vision. All rights reserved.
//

#import "GuidanceViewController.h"
#import "AppDelegate.h"
#import "BaseNavigationController.h"
#import "TCFastLoginViewController.h"

@interface GuidanceViewController ()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
}

@end

@implementation GuidanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self initGuidanceView];
}

#pragma mark --Private methods
#pragma mark 初始化引导页
-(void)initGuidanceView{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor=[UIColor whiteColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((kScreenWidth- 80)/2, kScreenHeight - 40, 80, 20)];
    _pageControl.numberOfPages = 5;
    _pageControl.pageIndicatorTintColor = [UIColor colorWithHex:0x000000 alpha:0.2];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHex:0x94d4d3 alpha:0.9];
    [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageControl];
    
    _scrollView.contentSize = CGSizeMake(kScreenWidth * 5,kScreenHeight);
    
    for (int i = 0; i < 5; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"iosguide0%d", i+1]];
        UIImageView *contentView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth*i, 0,kScreenWidth, kScreenHeight)];
        [contentView setImage:image];
        [_scrollView addSubview:contentView];
        
        if (i == 4) {
            UIImage *image = [UIImage imageNamed:@"enter"];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth*4+(kScreenWidth-180)/2, kScreenHeight-100,180,40)];
            [button setImage:image forState:UIControlStateNormal];
            [button addTarget:self action:@selector(startUse:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:button];
        }
    }
}


#pragma mark --Response Methods
#pragma mark 进入app
- (void)startUse:(id)sender{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"hasShowGuidance"];
    [userDefaults synchronize];
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication  sharedApplication] delegate];
    [TJYHelper sharedTJYHelper].isRootWindowIn = YES;
    TCFastLoginViewController  *fastLoginVC=[[TCFastLoginViewController alloc] init];
    BaseNavigationController *nav=[[BaseNavigationController alloc] initWithRootViewController:fastLoginVC];
    appDelegate.window.rootViewController=nav;
    
}

#pragma mark 切换图片
- (void)pageChanged:(UIPageControl *)pageControl{
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * pageControl.currentPage, 0, _scrollView.width, _scrollView.height) animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender{
    int page = _scrollView.contentOffset.x/_scrollView.width;
    _pageControl.currentPage = page;
}


@end
