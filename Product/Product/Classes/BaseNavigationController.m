//
//  BaseNavigationController.m
//  Product
//
//  Created by vision on 16/12/27.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BaseNavigationController.h"
#import "UIImage+Extend.h"
#import "UIColor+Extend.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏背景
    UIImage *img=[UIImage imageWithColor:kRGBColor(253, 131, 43) size:CGSizeMake([UIScreen mainScreen].bounds.size.width, 64)];
    [self.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    //
    self.navigationBar.tintColor=[UIColor whiteColor];
    if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0) {
        [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    }
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
    [super pushViewController:viewController animated:animated];
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
