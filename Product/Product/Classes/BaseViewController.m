//
//  BaseViewController.m
//  Product
//
//  Created by 梁家誌 on 16/7/29.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceConnectStateCheckService.h"
#import "DeviceStateListener.h"
#import "TCFastLoginViewController.h"
#import "BaseNavigationController.h"

@interface BaseViewController ()<UIAlertViewDelegate>{
    UIView        *navView;
    UIButton      *backBtn;
    UILabel       *titleLabel;
    UIButton      *rightBtn;
    
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    //ScrollView莫名其妙不能在viewController划到,加上这句解决
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationController.interactivePopGestureRecognizer.enabled=YES;
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self customNavBar];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetDevice:) name:KDelectDevice object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDelectDevice object:nil];
    [SVProgressHUD dismiss];
    
}

#pragma mark -- NSNotification
- (void)resetDevice:(NSNotification *)notif{
    NSString *name = notif.object;
    NSString *msg = [NSString stringWithFormat:@"您对 %@ 的控制权限已被取消！",name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alert.tag = 123;
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];

}


#pragma mark -- Private methods
-(void)customNavBar{
    navView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    navView.backgroundColor=kSystemColor;
    [self.view addSubview:navView];

    
    backBtn=[[UIButton alloc] initWithFrame:CGRectMake(5, 22, 40, 40)];
    [backBtn setImage:[UIImage drawImageWithName:@"back.png" size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
    [backBtn addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    titleLabel =[[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-180)/2, 20, 180, 44)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.font=[UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    
    rightBtn=[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH- 52, 22, 45, 40)];
    [rightBtn addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:rightBtn];
}

#pragma mark --Response
#pragma mark --返回方法
-(void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --导航栏右侧按钮事件
-(void)rightButtonAction{
    
}

#pragma mark --setters and getters
#pragma mark --隐藏导航栏
-(void)setIsHiddenNavBar:(BOOL)isHiddenNavBar{
    _isHiddenNavBar=isHiddenNavBar;
    navView.hidden=isHiddenNavBar;
}
#pragma mark --隐藏右边按钮
- (void)setIsHiddenRightBtn:(BOOL)isHiddenRightBtn{
    _isHiddenRightBtn = isHiddenRightBtn;
    rightBtn.hidden = isHiddenRightBtn;
}

#pragma mark --隐藏返回按钮
-(void)setIsHiddenBackBtn:(BOOL)isHiddenBackBtn{
    _isHiddenBackBtn=isHiddenBackBtn;
    backBtn.hidden=isHiddenBackBtn;
}

-(void)setLeftImageName:(NSString *)leftImageName{
    _leftImageName=leftImageName;
    if (_leftImageName) {
        backBtn.hidden=NO;
        [backBtn setImage:[UIImage drawImageWithName:_leftImageName size:CGSizeMake(22, 24)] forState:UIControlStateNormal];
        [backBtn setImageEdgeInsets:UIEdgeInsetsZero];
    }
}

#pragma mark --给标题赋值
-(void)setBaseTitle:(NSString *)baseTitle{
    _baseTitle=baseTitle;
    titleLabel.text=baseTitle;
}

#pragma mark --导航栏右侧按钮图片
-(void)setRightImageName:(NSString *)rightImageName{
    _rightImageName=rightImageName;
    [rightBtn setImage:[UIImage drawImageWithName:rightImageName size:CGSizeMake(24, 24)] forState:UIControlStateNormal];
}

-(void)setRigthTitleName:(NSString *)rigthTitleName{
    _rigthTitleName=rigthTitleName;
    [rightBtn setTitle:rigthTitleName forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (rigthTitleName.length > 2) {
        rightBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        rightBtn.frame = CGRectMake(SCREEN_WIDTH- 80, 22, 70, 40);
    }else{
        rightBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    }
    rightBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark --自定义弹出框
- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message {
    NSString *otherButtonTitle = NSLocalizedString(@"确定", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

+ (instancetype)instantiateOfStoryboard {
    NSString *className = NSStringFromClass([self class]);
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:className];
}

#pragma mark
- (void)push:(UIViewController *)viewController{
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark 跳转到快速登录
- (void)pushToFastLogin{
    
    
    TCFastLoginViewController  *fastLoginVC=[[TCFastLoginViewController alloc] init];
    BaseNavigationController *nav=[[BaseNavigationController alloc] initWithRootViewController:fastLoginVC];
    [self presentViewController:nav animated:YES completion:nil];
}


@end
