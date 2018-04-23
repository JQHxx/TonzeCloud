//
//  TCValidationViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 18/2/8.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "TCValidationViewController.h"
#import "TCNewPassWordViewController.h"
#import "XLinkExportObject.h"
#import "AppDelegate.h"
#import "UMMobClick/MobClick.h"
#import "QLVerificationCodeView.h"
#import "TCSexViewController.h"

@interface TCValidationViewController (){
    UIButton        *obtainBtn;
    BOOL            isFirstRegister;  //是否注册
}

@property (nonatomic ,strong) QLVerificationCodeView *verificationCodeView;
@end

@implementation TCValidationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"验证码";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self initVerificationCodeView];
    [self getVerificationCodeAction];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onLogin:) name:kOnLogin object:nil];
}


#pragma mark--NSNotication
#pragma mark 登录通知返回处理
-(void)onLogin:(NSNotification *)noti{
    NSDictionary *result=noti.object;
    int code=[[result objectForKey:@"result"] intValue];
    if (code==0) {
        if (isFirstRegister) {
            kSelfWeak;
            dispatch_async(dispatch_get_main_queue(), ^{
                TCSexViewController *sexVC=[[TCSexViewController alloc] init];
                [weakSelf.navigationController pushViewController:sexVC animated:YES];
            });
        }
    }else{
        [NSUserDefaultInfos putKey:USER_DIC andValue:nil];
        MyLog(@"登录云智易平台失败：%ld",(long)code);
    }
}


#pragma mark ====== Event  Response =======
#pragma mark -- getTextFieldContentDelegate
#pragma mark -- 验证码输入完成回调
-(void)returnTextFieldContent:(NSString *)content{
    if (_codeType==FastLogin) {
        NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
        NSString *uuid=nil;
        if (kIsEmptyObject(retrieveuuid)) {
            uuid=[UIDevice getIDFV];
            [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
        }else{
            uuid=retrieveuuid;
        }
        NSString *body = [NSString stringWithFormat:@"mobile=%@&code=%@&sn=%@&type=2",self.phoneNumber,content,uuid];
        kSelfWeak;
        [[NetworkTool  sharedNetworkTool] postMethodWithURL:kRegisterAPI body:body success:^(id json) {
            NSDictionary *result=[json objectForKey:@"result"];
            NSString     *typeStr=[json objectForKey:@"type"];
            if (kIsDictionary(result)&&result.count>0) {
                TJYUserModel *userModel=[[TJYUserModel alloc] init];
                [userModel setValues:result];
                [TonzeHelpTool sharedTonzeHelpTool].user=userModel;
                
                [NSUserDefaultInfos putKey:kUserID andValue:[NSNumber numberWithInteger:userModel.user_id]];
                [NSUserDefaultInfos putKey:kUserKey andValue:userModel.user_key];
                [NSUserDefaultInfos putKey:kUserSecret andValue:userModel.user_secret];
                [NSUserDefaultInfos putKey:kUserToken andValue:userModel.user_token];
                [NSUserDefaultInfos putKey:kThirdToken andValue:userModel.token];
                [NSUserDefaultInfos putKey:kUserPhone andValue:weakSelf.phoneNumber];
                NSString *openID=[Transform tokenToAccountId:userModel.token];
                [NSUserDefaultInfos putKey:USER_ID andValue:openID];
                [NSUserDefaultInfos putKey:USER_NAME andValue:userModel.nick_name];
                
                MyLog(@"openID:%@,token:%@",openID,userModel.token);
                if (!kIsEmptyString(userModel.token)) {
                    [weakSelf loginInXlinkWithToken:userModel.token nikeName:userModel.nick_name];
                }
                
                [NSUserDefaultInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
                [TJYHelper sharedTJYHelper].isLoginSuccess=YES;
                [TJYHelper sharedTJYHelper].isReloadHome = YES;   // 刷新首页
                
                [MobClick profileSignInWithPUID:[NSString stringWithFormat:@"%ld",(long)userModel.user_id]];
                
                if ([typeStr isEqualToString:@"login"]) {
                    isFirstRegister=NO;
                    if ([TJYHelper sharedTJYHelper].isRootWindowIn) {
                        AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                        appDelegate.window.rootViewController=[storyboard instantiateInitialViewController];
                        [TJYHelper sharedTJYHelper].isRootWindowIn=NO;
                    }else{
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }
                }else{
                    isFirstRegister=YES;
                }
            }
        } failure:^(NSString *errorStr) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    // 清空验证码
                    [_verificationCodeView celanVerificationCode];
                }
            }];
            [alertView show];
        }];
        
    }else{
        kSelfWeak;
        NSString *body=_codeType==ChangePassWord?[NSString stringWithFormat:@"code=%@",content]:[NSString stringWithFormat:@"mobile=%@&code=%@",_phoneNumber,content];
        NSString *urlStr=_codeType==ChangePassWord?kCheckCode:kForgetPassword;
        [[NetworkTool sharedNetworkTool] postMethodWithURL:urlStr body:body success:^(id json) {
            TCNewPassWordViewController *passWordVC = [[TCNewPassWordViewController alloc]init];
            passWordVC.isChangePassWord =_codeType==ChangePassWord?YES:NO;
            passWordVC.messageCode = content;
            if (_codeType==ForgetPassWord) {
                passWordVC.phoneNumber = _phoneNumber;
            }
            [weakSelf.navigationController pushViewController:passWordVC animated:YES];
            
        } failure:^(NSString *errorStr) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [_verificationCodeView celanVerificationCode];  // 清空验证码
                }
            }];
            [alertView show];
        }];
    }
}

#pragma mark -- 登录云智易
-(void)loginInXlinkWithToken:(NSString *)token nikeName:(NSString *)nickName{
    NSString *accountID=[Transform tokenToAccountId:token];
    [NSUserDefaultInfos putKey:USER_ID andValue:accountID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [HttpRequest thirdAuthWithOpenID:accountID withToken:token didLoadData:^(id result, NSError *err) {
            if (!err) {
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
            }else{
                MyLog(@"云智易第三方用户认证失败,error--code:%ld,error:%@",err.code,err.localizedDescription);
            }
        }];
    });
}

    
    
#pragma mark  获取验证码
- (void)getVerificationCodeAction{
    NSString *typeStr;
    if (_codeType == ChangePassWord) {
        typeStr = @"modifyPwd";
    }else if (_codeType == ForgetPassWord){
        typeStr = @"forget";
    }else if(_codeType == FastLogin){
        typeStr = @"login";
    }
    
    NSString *body = [NSString stringWithFormat:@"mobile=%@&type=%@",self.phoneNumber,typeStr];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kSendSign body:body success:^(id json) {
        __block int timeout=60; //倒计时时间
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            if(timeout<=0){ //倒计时结束，关闭
                dispatch_source_cancel(_timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [obtainBtn setTitle:@"重新发送验证码" forState:UIControlStateNormal];
                    [obtainBtn setTitleColor:[UIColor colorWithHexString:@"#f39800"] forState:UIControlStateNormal];
                    obtainBtn.enabled = YES;
                });
            }else{
                int seconds = timeout % 61;
                NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [obtainBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
                    [obtainBtn setTitle:[NSString stringWithFormat:@"%@s",strTime] forState:UIControlStateNormal];
                    obtainBtn.enabled = NO;
                });
                timeout--;
            }
        });
        dispatch_resume(_timer);
        [weakSelf.view makeToast:@"验证码已发送" duration:1.0 position:CSToastPositionCenter];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        [obtainBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [obtainBtn setTitleColor:[UIColor colorWithHexString:@"#f39800"] forState:UIControlStateNormal];
        obtainBtn.enabled = YES;
    }];
}
 
#pragma mark -- Private Methods
#pragma mark -- 初始化界面
- (void)initVerificationCodeView{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kNewNavHeight+30, kScreenWidth, 20)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    titleLabel.text = @"已发送验证码至";
    [self.view addSubview:titleLabel];
    
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, kScreenWidth, 20)];
    phoneLabel.textAlignment = NSTextAlignmentCenter;
    phoneLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    phoneLabel.font = [UIFont systemFontOfSize:15];
    phoneLabel.text = self.phoneNumber;
    [self.view addSubview:phoneLabel];

    _verificationCodeView = [[QLVerificationCodeView alloc]initWithFrame:CGRectMake(15, phoneLabel.bottom + 30, kScreenWidth - 30, (kScreenWidth - 30 - 50)/6)];
    _verificationCodeView.selectedColor = kSystemColor;
    _verificationCodeView.deselectColor = [UIColor colorWithHexString:@"0xd2d2d2"];
    _verificationCodeView.VerificationCodeNum = 6;
    _verificationCodeView.Spacing = 10;//每个格子间距属性
    kSelfWeak;
    _verificationCodeView.vertificationCodeBlock = ^(NSString *codeStr) {
        [weakSelf returnTextFieldContent:codeStr];
    };
    [self.view addSubview:self.verificationCodeView];
    
    
    obtainBtn = [[UIButton alloc] initWithFrame:CGRectMake(50,self.verificationCodeView.bottom+10,kScreenWidth-100, 30)];
    obtainBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [obtainBtn setTitleColor:[UIColor colorWithHexString:@"#f39800"] forState:UIControlStateNormal];
    [obtainBtn addTarget:self action:@selector(getVerificationCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:obtainBtn];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnLogin object:nil];
}


@end
