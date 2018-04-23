//
//  GetCodeViewController.m
//  Product
//
//  Created by Xlink on 15/11/30.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "GetCodeViewController.h"
#import "TCValidationViewController.h"
#import "PhoneText.h"

@interface GetCodeViewController ()<UITextFieldDelegate>{
    UILabel      *phoneLabel;
    PhoneText    *phoneTextField;
}

@end

@implementation GetCodeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    
    if (self.isChangePassword) {
        self.baseTitle=@"修改密码";
    }else{
        self.baseTitle=@"忘记密码";
    }
    
    [self initGetCodeView];
}


#pragma mark--Response Methods
#pragma mark 获取验证码
- (void)getCodeAction:(id)sender{
    if (!self.isChangePassword) {
        if (phoneTextField.text.length==0) {
            [self showAlertWithTitle:@"提示" Message:@"请输入手机号"];
            return;
        }
        
        if (phoneTextField.text.length!=11) {
            [self showAlertWithTitle:@"提示" Message:@"请输入正确的手机号"];
            return;
        }
    }

    TCValidationViewController *validationVC = [[TCValidationViewController alloc]init];
    validationVC.codeType = self.isChangePassword ? ChangePassWord  :  ForgetPassWord;
    validationVC.phoneNumber =self.isChangePassword?phoneLabel.text:phoneTextField.text;
    [self.navigationController pushViewController:validationVC animated:YES];
}


#pragma mark UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [phoneTextField resignFirstResponder];
    return YES;
}

#pragma mark -- Private Methods
#pragma mark 初始化获取验证码界面
- (void)initGetCodeView{
    NSString *UserMobile=[NSUserDefaultInfos getValueforKey:kUserPhone];
    if (self.isChangePassword) {
        phoneLabel=[[UILabel alloc] initWithFrame:CGRectMake(24, kNewNavHeight+30, kScreenWidth-48, 38)];
        phoneLabel.textColor=[UIColor colorWithHexString:@"#999999"];
        phoneLabel.font=[UIFont systemFontOfSize:18];
        [self.view addSubview:phoneLabel];
        if (!kIsEmptyString(UserMobile)) {
            phoneLabel.text=UserMobile;
        }
        
    }else{
        phoneTextField = [[PhoneText alloc] initWithFrame:CGRectMake(24, kNewNavHeight+30, kScreenWidth-48, 38)];
        phoneTextField.returnKeyType=UIReturnKeyDone;
        phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        phoneTextField.font = [UIFont systemFontOfSize:18];
        phoneTextField.placeholder = @"手机号码";
        phoneTextField.delegate=self;
        phoneTextField.textColor=[UIColor colorWithHexString:@"#999999"];
        [self.view addSubview:phoneTextField];
        
        if (!kIsEmptyString(UserMobile)) {
            phoneTextField.text=UserMobile;
        }
    }
    
    UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(18, kNewNavHeight+68, kScreenWidth-36, 1)];
    line.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.view addSubview:line];
    
    UIButton *getCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(18, line.bottom + 40, kScreenWidth-36, 45)];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    getCodeButton.titleLabel.font = [UIFont systemFontOfSize:18];
    getCodeButton.backgroundColor = [UIColor colorWithHexString:@"#f39800"];
    getCodeButton.layer.cornerRadius=22.5;
    getCodeButton.clipsToBounds=YES;
    [getCodeButton addTarget:self action:@selector(getCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getCodeButton];
}


@end
