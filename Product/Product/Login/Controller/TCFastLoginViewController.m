//
//  TCFastLoginViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/2/9.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCFastLoginViewController.h"
#import "BasewebViewController.h"
#import "TCValidationViewController.h"
#import "LoginViewController.h"
#import "PhoneText.h"
#import "MYCoreTextLabel.h"
#import "AppDelegate.h"
#import "BackScrollView.h"

@interface TCFastLoginViewController ()<UITextFieldDelegate,MYCoreTextLabelDelegate>{

    PhoneText      *loginField;
    UIButton       *nextButton;
    UIButton       *selectButton;
}
@property (nonatomic,strong)BackScrollView    *backScrollView;
@end

@implementation TCFastLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.isHiddenNavBar = YES; 
    
    [self initFastLoginView];
}
#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [loginField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (loginField.text.length+string.length>0) {
        if (loginField.text.length+string.length==11&&selectButton.selected) {
            nextButton.enabled = selectButton.selected;
            nextButton.backgroundColor = [UIColor colorWithHexString:@"#f39800"];
        }
    }
    if (1 == range.length) {//按下回格键
        nextButton.enabled = NO;
        nextButton.backgroundColor =[UIColor colorWithHexString:@"#fbd79b"];
        return YES;
    }
    if (loginField==textField) {
        if ([textField.text length]<11) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- 点击空白收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


#pragma mark -- MYCoreTextLabelDelegate
#pragma mark -- 点击标记区域
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag
{
    MyLog(@"------------点击内容是 : %@--------------链接类型是 : %li",clickString,linkType);
    if ([clickString isEqualToString:@"密码登录"]) {
        LoginViewController *loginVC=[[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    } else {
        BasewebViewController *webVC=[[BasewebViewController alloc] init];
        webVC.titleText= @"用户协议";
        webVC.isWebUrl = YES;
        webVC.urlStr=@"http://api-h.360tj.com/shared/reg/tjyHealthUserProtocol.html";
        webVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

#pragma mark -- 退出
- (void)closeFastLoginVCAction{
    if ([TJYHelper sharedTJYHelper].isRootWindowIn) {
        AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        appDelegate.window.rootViewController=[storyboard instantiateInitialViewController];
        [TJYHelper sharedTJYHelper].isRootWindowIn=NO;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
 
#pragma mark -- 下一步
- (void)nextStepAction:(UIButton *)button{
    [loginField resignFirstResponder];
    NSString *str = nil;
    if (!kIsEmptyString(loginField.text)) {
        str = [loginField.text substringToIndex:1];
    }
    if (kIsEmptyString(loginField.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (loginField.text.length != 11||![str isEqualToString:@"1"]){
        [self.view makeToast:@"请输入正确的手机号" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    TCValidationViewController *validationVC = [[TCValidationViewController alloc] init];
    validationVC.codeType = FastLogin;
    validationVC.phoneNumber = loginField.text;
    [self.navigationController pushViewController:validationVC animated:YES];
}
#pragma mark -- 选择用户协议
- (void)seleteAgreement:(UIButton *)button{
    button.selected=!button.selected;
    selectButton.selected=button.selected;
    if (loginField.text.length==11&&selectButton.selected) {
        nextButton.enabled = YES;
        nextButton.backgroundColor = [UIColor colorWithHexString:@"#f39800"];
    }else{
        nextButton.enabled = NO;
        nextButton.backgroundColor =[UIColor colorWithHexString:@"#fbd79b"];
    }
}
#pragma mark -- Private Methods
#pragma mark  初始化登陆界面
- (void)initFastLoginView{
    _backScrollView = [[BackScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _backScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backScrollView];
    [self.view sendSubviewToBack:_backScrollView];
    
    UIButton *cloceBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    cloceBtn.frame = CGRectMake(kScreenWidth - 50, 20, 40 , 40);
    [cloceBtn setImage:[UIImage imageNamed:@"ic_top_close"] forState:UIControlStateNormal];
    [cloceBtn addTarget:self action:@selector(closeFastLoginVCAction) forControlEvents:UIControlEventTouchUpInside];
    [cloceBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
    [self.backScrollView addSubview:cloceBtn];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-90)/2, 84, 90, 90)];
    imgView.image=[UIImage imageNamed:@"ic_tjy_logo"];
    [self.backScrollView addSubview:imgView];
    
    loginField = [[PhoneText alloc] initWithFrame:CGRectMake(24, imgView.bottom+40, kScreenWidth-48, 38)];
    loginField.returnKeyType=UIReturnKeyDone;
    loginField.keyboardType = UIKeyboardTypeNumberPad;
    loginField.clearButtonMode = UITextFieldViewModeWhileEditing;
    loginField.delegate = self;
    loginField.tag = 100;
    loginField.font = [UIFont systemFontOfSize:18];
    loginField.placeholder = @"手机号码";
    loginField.textColor=[UIColor colorWithHexString:@"#999999"];
    [self.backScrollView addSubview:loginField];

    UILabel *loginlbl = [[UILabel alloc] initWithFrame:CGRectMake(18, loginField.bottom, kScreenWidth-36, 1)];
    loginlbl.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.backScrollView addSubview:loginlbl];
    
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(18, loginField.bottom + 24, kScreenWidth-36, 45)];
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:18];
    nextButton.backgroundColor =[UIColor colorWithHexString:@"#fbd79b"];
    nextButton.layer.cornerRadius=22.5;
    nextButton.clipsToBounds=YES;
    [nextButton addTarget:self action:@selector(nextStepAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:nextButton];
    
    MYCoreTextLabel *LoginLabel = [[MYCoreTextLabel alloc] initWithFrame:CGRectZero];
    LoginLabel.lineSpacing = 1.5;
    LoginLabel.wordSpacing = 0.5;
    //设置普通文本的属性
    LoginLabel.textFont = [UIFont systemFontOfSize:15.f];   //设置普通内容文字大小
    LoginLabel.textColor = [UIColor colorWithHexString:@"0x959595"];   // 设置普通内容文字颜色
    LoginLabel.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
    //设置关键字的属性
    LoginLabel.customLinkFont = [UIFont systemFontOfSize:15];
    LoginLabel.customLinkColor = kSystemColor;  //设置关键字颜色
    LoginLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    [LoginLabel setText:@"已有帐号，密码登录" customLinks:@[@"密码登录"] keywords:@[@""]];
    CGSize loginSize = [LoginLabel sizeThatFits:CGSizeMake(kScreenWidth, [UIScreen mainScreen].bounds.size.height)];
    LoginLabel.frame = CGRectMake((kScreenWidth-loginSize.width)/2,nextButton.bottom+20, loginSize.width, loginSize.height);
    [self.backScrollView addSubview:LoginLabel];
    self.backScrollView.contentSize = CGSizeMake(kScreenWidth, LoginLabel.bottom+20);
    
    
    selectButton = [[UIButton alloc] initWithFrame:CGRectMake(nextButton.left+10, kScreenHeight-100, 20, 20)];
    [selectButton setImage:[UIImage imageNamed:@"pub_ic_unpick"] forState:UIControlStateNormal];
    [selectButton setImage:[UIImage imageNamed:@"pub_ic_pick"] forState:UIControlStateSelected];
    [selectButton addTarget:self action:@selector(seleteAgreement:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:selectButton];
    selectButton.selected= YES;
    
    MYCoreTextLabel *agreementLabel = [[MYCoreTextLabel alloc] initWithFrame:CGRectZero];
    agreementLabel.lineSpacing = 1.5;
    agreementLabel.wordSpacing = 0.5;
    //设置普通文本的属性
    agreementLabel.textFont = [UIFont systemFontOfSize:12.f];   //设置普通内容文字大小
    agreementLabel.textColor = [UIColor colorWithHexString:@"0x939393"];   // 设置普通内容文字颜色
    agreementLabel.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
    //设置关键字的属性
    agreementLabel.customLinkFont = [UIFont systemFontOfSize:12];
    agreementLabel.customLinkColor = kSystemColor;  //设置关键字颜色
    agreementLabel.customLinkBackColor = [UIColor whiteColor];  //设置关键字高亮背景色
    [agreementLabel setText:@"未注册天际云健康的手机号，登录时将自动注册，且代表您已阅读并同意《天际云健康用户协议》。" customLinks:@[@"《天际云健康用户协议》"] keywords:@[@""]];
    CGSize size = [agreementLabel sizeThatFits:CGSizeMake(nextButton.width-40, kScreenHeight)];
    agreementLabel.frame = CGRectMake(nextButton.left+30, kScreenHeight-100, size.width, size.height);
    [self.backScrollView addSubview:agreementLabel];
    
   
}
@end
