//
//  LoginViewController.m
//  Product
//
//  Created by Xlink on 15/11/30.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "LoginViewController.h"
#import "GetCodeViewController.h"
#import "UMMobClick/MobClick.h"
#import "TJYUserModel.h"
#import "AutoLoginManager.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "BackScrollView.h"
#import "PhoneText.h"

@interface LoginViewController ()<UITextFieldDelegate>{
    BackScrollView  *backScrollView;
    PhoneText       *phoneTextField;
    UITextField     *passwordTextField;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar=YES;
    
    [NSUserDefaultInfos putKey:@"kIsFirstIn" andValue:[NSNumber numberWithBool:YES]];

    [self initLoginView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onLogin:) name:kOnLogin object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"002" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"002" type:2];
#endif
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnLogin object:nil];
    [SVProgressHUD dismiss];
}

#pragma mark--UITextField Delegate
#pragma mark 键盘返回按钮处理
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [phoneTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    return YES;
}


#pragma mark 键盘高度处理
-(void) textFieldDidBeginEditing:(UITextField *)textField{
    CGRect textFrame =  passwordTextField.frame;
    float textY = textFrame.origin.y+textFrame.size.height;
    float bottomY = self.view.frame.size.height-textY;
    if(bottomY>=216)  //判断当前的高度是否已经有216，如果超过了就不需要再移动主界面的View高度
    {
        return;
    }
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    float moveY = 216-bottomY;
    CGRect frame = self.view.frame;
    frame.origin.y -=moveY;//view的Y轴上移
    self.view.frame = frame;
    [UIView commitAnimations];//设置调整界面的动画效果
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (self.view.frame.origin.y<64) {
        NSTimeInterval animationDuration = 0.30f;
        //self.view移回原位置
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        CGRect frame = self.view.frame;
        if(textField == phoneTextField||textField== passwordTextField){   //还原界面
            frame.origin.y =0;
            self.view.frame = frame;
        }
        [UIView commitAnimations];
    }
    [passwordTextField resignFirstResponder];
    return YES;
}

#pragma mark -- 点击空白收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


#pragma mark --NSNotification
#pragma mark 登录成功处理
-(void)onLogin:(NSNotification *)noti{
    NSDictionary *result=noti.object;
    MyLog(@"xlinkLoginNotification -- resutl:%@",result);
    int code=[[result objectForKey:@"result"] intValue];
    if (code==0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnLogin object:nil];
    }else{
        [NSUserDefaultInfos putKey:USER_DIC andValue:nil];
        MyLog(@"登录云智易平台失败：%ld",(long)code);
    }
}

#pragma mark --Response Methods
#pragma mark 跳出
- (void)closeLoginVCAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"002-05"];
#endif
    if ([TJYHelper sharedTJYHelper].isRootWindowIn) {
        AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        appDelegate.window.rootViewController=[storyboard instantiateInitialViewController];
        [TJYHelper sharedTJYHelper].isRootWindowIn=NO;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark 设置密码可见
- (void)setLoginPwdVisibility:(UIButton *)sender{
    passwordTextField.secureTextEntry=!passwordTextField.secureTextEntry;
    sender.selected=!sender.selected;
    
    NSString *tempString = passwordTextField.text;
    passwordTextField.text=@"";
    passwordTextField.text = tempString;
}

#pragma mark 忘记密码
- (void)forgetPwdAction{
    GetCodeViewController *getCodeVC=[[GetCodeViewController alloc] init];
    [self.navigationController pushViewController:getCodeVC animated:YES];
}

#pragma mark 登录
- (void)loginAction:(id)sender{
    [phoneTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    if (phoneTextField.text.length==0) {
        [self showAlertWithTitle:@"提示" Message:@"请输入手机号"];
        return;
    }
    if (passwordTextField.text.length==0) {
        [self showAlertWithTitle:@"提示" Message:@"请输入密码"];
        return;
    }
    
    __weak typeof(self) weakSelf=self;
    NSString *body = [NSString stringWithFormat:@"mobile=%@&password=%@",phoneTextField.text,passwordTextField.text];
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kLoginAPI body:body success:^(id json) {
        NSDictionary *dict=[json objectForKey:@"result"];
        if (kIsDictionary(dict)&&dict.count>0) {
            TJYUserModel *userModel=[[TJYUserModel alloc] init];
            [userModel setValues:dict];
            [TonzeHelpTool sharedTonzeHelpTool].user=userModel;
            
            [NSUserDefaultInfos putKey:kUserID andValue:[NSNumber numberWithInteger:userModel.user_id]];
            [NSUserDefaultInfos putKey:kUserKey andValue:userModel.user_key];
            [NSUserDefaultInfos putKey:kUserSecret andValue:userModel.user_secret];
            [NSUserDefaultInfos putKey:kUserToken andValue:userModel.user_token];
            [NSUserDefaultInfos putKey:kThirdToken andValue:userModel.token];
            [NSUserDefaultInfos putKey:kUserPhone andValue:userModel.mobile];
            [NSUserDefaultInfos putKey:USER_NAME andValue:userModel.nick_name];
            [NSUserDefaultInfos putKey:kUserPwd anddict:passwordTextField.text];
            
            if (!kIsEmptyString(userModel.token)) {
                [self loginInXlinkWithToken:userModel.token nikeName:userModel.nick_name];
            }
            
            [MobClick profileSignInWithPUID:[NSString stringWithFormat:@"%ld",(long)userModel.user_id]];
            
            [NSUserDefaultInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
            [TJYHelper sharedTJYHelper].isLoginSuccess=YES;
            
            if ([TJYHelper sharedTJYHelper].isRootWindowIn) {
                AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                appDelegate.window.rootViewController=[storyboard instantiateInitialViewController];
                [TJYHelper sharedTJYHelper].isRootWindowIn=NO;
            }else{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
            // 刷新首页
            [TJYHelper sharedTJYHelper].isReloadHome = YES;
            
        }
    } failure:^(NSString *errorStr) {
        [SVProgressHUD dismiss];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


#pragma mark 快速登录（注册）
-  (void)quickLoginAction{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -- Private Methods
#pragma mark 登录云智易
-(void)loginInXlinkWithToken:(NSString *)token nikeName:(NSString *)nickName{
    NSString *openID=[Transform tokenToAccountId:token];
    [NSUserDefaultInfos putKey:USER_ID andValue:openID];
    
    MyLog(@"openID:%@,token:%@",openID,token);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [HttpRequest thirdAuthWithOpenID:openID withToken:token didLoadData:^(id result, NSError *err) {
            if (err) {
                MyLog(@"登陆到Xink失败： %@(%ld)", err.localizedDescription, (long)err.code);
            }else{
                [NSUserDefaultInfos putKey:USER_DIC andValue:result];
                NSNumber *user_id=[result objectForKey:@"user_id"];
                NSString *access_token=[result objectForKey:@"access_token"];
                NSString *authorize=[result objectForKey:@"authorize"];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[XLinkExportObject sharedObject] start];
                    [[XLinkExportObject sharedObject] setSDKProperty:SDK_DOMAIN withKey:PROPERTY_CM_SERVER_ADDR];
                    [[XLinkExportObject sharedObject] loginWithAppID:user_id.intValue andAuthStr:authorize];
                });
                
                //同步昵称到云智易后台
                [HttpRequest modifyAccountNickname:nickName withUserID:user_id withAccessToken:access_token didLoadData:^(id result, NSError *err) {
                    if (err) {
                        MyLog(@"error:%ld,%@",(long)err.code,err.localizedDescription);
                    }
                }];
            }
        }];
    });

}

#pragma mark --Private Methods
#pragma mark 初始化界面
- (void)initLoginView{
    backScrollView = [[BackScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    backScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backScrollView];
    [self.view sendSubviewToBack:backScrollView];
    
    UIButton *cloceBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    cloceBtn.frame = CGRectMake(kScreenWidth - 50, 20, 40 , 40);
    [cloceBtn setImage:[UIImage imageNamed:@"ic_top_close"] forState:UIControlStateNormal];
    [cloceBtn addTarget:self action:@selector(closeLoginVCAction) forControlEvents:UIControlEventTouchUpInside];
    [cloceBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
    [backScrollView addSubview:cloceBtn];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-90)/2, 84, 90, 90)];
    imgView.image=[UIImage imageNamed:@"ic_tjy_logo"];
    [backScrollView addSubview:imgView];
    
    phoneTextField = [[PhoneText alloc] initWithFrame:CGRectMake(24, imgView.bottom+40, kScreenWidth-48, 38)];
    phoneTextField.returnKeyType=UIReturnKeyDone;
    phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneTextField.delegate = self;
    phoneTextField.font = [UIFont systemFontOfSize:18];
    phoneTextField.placeholder = @"手机号码";
    phoneTextField.textColor=[UIColor colorWithHexString:@"#999999"];
    [backScrollView addSubview:phoneTextField];
    
    
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(24, phoneTextField.bottom+10, kScreenWidth-70, 38)];
    passwordTextField.returnKeyType=UIReturnKeyDone;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField.delegate = self;
    passwordTextField.font = [UIFont systemFontOfSize:18];
    passwordTextField.placeholder = @"登录密码";
    passwordTextField.textColor=[UIColor colorWithHexString:@"#999999"];
    passwordTextField.secureTextEntry=YES;
    [backScrollView addSubview:passwordTextField];
    
    
    NSString *UserMobile=[NSUserDefaultInfos getValueforKey:kUserPhone];
    NSString *UserPwd=[NSUserDefaultInfos getValueforKey:kUserPwd];
    if (!kIsEmptyString(UserMobile)) {
        phoneTextField.text=UserMobile;
        if (!kIsEmptyString(UserPwd)) {
            passwordTextField.text=UserPwd;
        }
    }
    
    UIButton *setVisibilityBtn=[[UIButton alloc] initWithFrame:CGRectMake(passwordTextField.right+10, passwordTextField.top+10, 20, 20)];
    [setVisibilityBtn setImage:[UIImage imageNamed:@"ic_login_noeye"] forState:UIControlStateNormal];
    [setVisibilityBtn setImage:[UIImage imageNamed:@"ic_login_eye"] forState:UIControlStateSelected];
    [setVisibilityBtn addTarget:self action:@selector(setLoginPwdVisibility:) forControlEvents:UIControlEventTouchUpInside];
    [backScrollView addSubview:setVisibilityBtn];
    
    for (NSInteger i=0; i<2; i++) {
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(18, imgView.bottom+40+38*(i+1)+10*i, kScreenWidth-36, 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
        [backScrollView addSubview:line];
    }
    
    UIButton *forgetPwdBtn=[[UIButton alloc] initWithFrame:CGRectMake(passwordTextField.right-80, passwordTextField.bottom+15, 80, 20)];
    [forgetPwdBtn setTitleColor:[UIColor colorWithHexString:@"#959595"] forState:UIControlStateNormal];
    [forgetPwdBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    forgetPwdBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    [forgetPwdBtn addTarget:self action:@selector(forgetPwdAction) forControlEvents:UIControlEventTouchUpInside];
    [backScrollView addSubview:forgetPwdBtn];
    
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(18, forgetPwdBtn.bottom + 15, kScreenWidth-36, 45)];
    loginButton.selected = NO;
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:18];
    loginButton.backgroundColor = [UIColor colorWithHexString:@"#f39800"];
    loginButton.layer.cornerRadius=22.5;
    loginButton.clipsToBounds=YES;
    [loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [backScrollView addSubview:loginButton];
    
    UIButton *fastLoginBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, loginButton.bottom+15, kScreenWidth-80, 20)];
    [fastLoginBtn setTitleColor:[UIColor colorWithHexString:@"#f39800"] forState:UIControlStateNormal];
    fastLoginBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    [fastLoginBtn setTitle:@"快速登录(注册)" forState:UIControlStateNormal];
    [fastLoginBtn addTarget:self action:@selector(quickLoginAction) forControlEvents:UIControlEventTouchUpInside];
    [backScrollView addSubview:fastLoginBtn];
    
}



@end
