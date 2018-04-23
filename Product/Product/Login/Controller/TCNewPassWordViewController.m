//
//  TCNewPassWorldViewController.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/2/8.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCNewPassWordViewController.h"
#import "TJYUserInfoViewController.h"
#import "LoginViewController.h"
#import "BackScrollView.h"
#import "PhoneText.h"

@interface TCNewPassWordViewController ()<UITextFieldDelegate>
{
    PhoneText       *passWordField;
    UIButton        *_getCodeBtn;
}
@property (nonatomic,strong) BackScrollView    *backScrollView;

@end

@implementation TCNewPassWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"输入密码";
    [self buildNewPassWorldVC];
}

#pragma mark -- Event  Response
#pragma mark  返回
- (void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark  设置密码可见
- (void)setPwVisbleAction:(UIButton *)sender{
    sender.selected=!sender.selected;
    passWordField.secureTextEntry=!passWordField.secureTextEntry;
    
    NSString *tempString = passWordField.text;
    passWordField.text=@"";
    passWordField.text = tempString;
}

#pragma mark 完成
- (void)completeAction{
    if (kIsEmptyString(passWordField.text)) {
        [self.view makeToast:@"密码不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (passWordField.text.length > 19){
        [self.view makeToast:@"密码不可超过20位" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    if (_isChangePassWord) {
        kSelfWeak;
        NSString *body=[NSString stringWithFormat:@"type=2&new_password=%@&code=%@",passWordField.text,_messageCode];
        [[NetworkTool sharedNetworkTool] postMethodWithURL:kChangePassWord body:body success:^(id json) {
            [weakSelf.view makeToast:@"修改成功" duration:1.0 position:CSToastPositionCenter];
            // 返回个人信息界面
            for (UIViewController *temp in self.navigationController.viewControllers) {
                if ([temp isKindOfClass:[TJYUserInfoViewController class]]) {
                    [weakSelf.navigationController popToViewController:temp animated:YES];
                }
            }
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }else{
        // 忘记密码
        NSString *body = [NSString stringWithFormat:@"mobile=%@&password=%@&code=%@",_phoneNumber,passWordField.text,_messageCode];
        kSelfWeak;
        [[NetworkTool sharedNetworkTool] postMethodWithURL:kUpdatePassword body:body success:^(id json) {
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[LoginViewController class]]) {
                    LoginViewController *loginVC =(LoginViewController *)controller;
                    [self.navigationController popToViewController:loginVC animated:YES];
                }
            }
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}

#pragma mark — — Private Methods
#pragma mark 初始化界面
- (void)buildNewPassWorldVC{
    _backScrollView = [[BackScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _backScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backScrollView];
    [self.view sendSubviewToBack:_backScrollView];
    
    passWordField = [[PhoneText alloc] initWithFrame:CGRectMake(24 , kNewNavHeight + 28 ,kScreenWidth - 30 - 40, 45)];
    passWordField.delegate = self;
    passWordField.tag = 100;
    passWordField.clearsOnBeginEditing = YES;
    passWordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passWordField.returnKeyType=UIReturnKeyDone;
    passWordField.keyboardType = UIKeyboardTypeASCIICapable;
    passWordField.font = [UIFont systemFontOfSize:15];
    passWordField.placeholder = @"请输入6-20位新密码";
    [self.backScrollView addSubview:passWordField];
    passWordField.secureTextEntry=YES;
    
    UIButton *seeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 48, passWordField.top+ 12, 30, 20)];
    [seeButton setImage:[UIImage imageNamed:@"ic_login_noeye"] forState:UIControlStateNormal];
    [seeButton setImage:[UIImage imageNamed:@"ic_login_eye"] forState:UIControlStateSelected];
    [seeButton addTarget:self action:@selector(setPwVisbleAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:seeButton];
    
    UIImageView *phoneImg = [[UIImageView alloc] initWithFrame:CGRectMake(18,passWordField.top + 8, 30, 30)];
    phoneImg.image = [UIImage imageNamed:@"ic_login_code"];
    [_backScrollView addSubview:phoneImg];
    
    UILabel *loginlbl = [[UILabel alloc] initWithFrame:CGRectMake(18, passWordField.bottom, kScreenWidth-36, 1)];
    loginlbl.backgroundColor = [UIColor colorWithHexString:@"#c9c9c9"];
    [self.backScrollView addSubview:loginlbl];
    
    _getCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(18, passWordField.bottom+ 30, kScreenWidth-36, 48)];
    [_getCodeBtn setTitle:@" 完成" forState:UIControlStateNormal];
    _getCodeBtn.backgroundColor = [UIColor colorWithHexString:@"#f39800"];
    _getCodeBtn.layer.cornerRadius = 24;
    _getCodeBtn.clipsToBounds=YES;
    [_getCodeBtn addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:_getCodeBtn];
}



@end
