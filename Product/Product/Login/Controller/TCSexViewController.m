//
//  TCSexViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSexViewController.h"
#import "TCSexButton.h"
#import "TCBirthdayViewController.h"
#import "AppDelegate.h"
#import "TCUserTool.h"

@interface TCSexViewController ()

@end

@implementation TCSexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"性别";
    self.rigthTitleName=@"跳过";
    
    [self initSexView];
}

#pragma mark 返回
-(void)leftButtonAction{
    if ([TJYHelper sharedTJYHelper].isRootWindowIn) {
        AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        appDelegate.window.rootViewController=[storyboard instantiateInitialViewController];
        [TJYHelper sharedTJYHelper].isRootWindowIn=NO;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -- Event Response
#pragma mark  选择性别
- (void)sexButtonChoose:(UIButton *)button{
    NSInteger sex=button.tag;
    
    MyLog(@"sex:%ld",sex);
    [[TCUserTool sharedTCUserTool] insertValue:[NSNumber numberWithInteger:sex] forKey:@"sex"];
    TCBirthdayViewController *birthdayVC = [[TCBirthdayViewController alloc] init];
    [self.navigationController pushViewController:birthdayVC animated:YES];
}
#pragma mark  跳过
-(void)rightButtonAction{
    if ([TJYHelper sharedTJYHelper].isRootWindowIn) {
        AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        appDelegate.window.rootViewController=[storyboard instantiateInitialViewController];
        [TJYHelper sharedTJYHelper].isRootWindowIn=NO;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark --Private methods
#pragma mark -- 初始化界面
- (void)initSexView{
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kNavigationHeight+40, kScreenWidth, 20)];
    promptLabel.text = @"完善资料后我们将为您推荐精准的营养调理方案。";
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont systemFontOfSize:14];
    promptLabel.textColor = [UIColor grayColor];
    [self.view addSubview:promptLabel];
    
    UILabel *sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, promptLabel.bottom+20, kScreenWidth, 30)];
    sexLabel.text = @"您的性别？";
    sexLabel.font = [UIFont systemFontOfSize:20];
    sexLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:sexLabel];
    
    NSDictionary *dict = @{@"image":@"ic_login_male",@"title":@"男"};
    TCSexButton *manBtn = [[TCSexButton alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, sexLabel.bottom+20, 100, 100) dict:dict];
    manBtn.tag = 1;
    [manBtn addTarget:self action:@selector(sexButtonChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:manBtn];
    
    dict = @{@"image":@"ic_login_female",@"title":@"女"};
    TCSexButton *womanBtn = [[TCSexButton alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, manBtn.bottom+80, 100, 100) dict:dict];
    [womanBtn addTarget:self action:@selector(sexButtonChoose:) forControlEvents:UIControlEventTouchUpInside];
    womanBtn.tag = 2;
    [self.view addSubview:womanBtn];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
