//
//  TCValidationViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 18/2/8.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "BaseViewController.h"
typedef void(^LoginSuccessBlock)();

typedef NS_ENUM(NSInteger,VerificationCodeType){
    FastLogin,           // 快速登录
    ChangePassWord,      // 修改密码
    ForgetPassWord      // 忘记密码
};
@interface TCValidationViewController : BaseViewController

@property (nonatomic ,strong)NSString *phoneNumber;
///
@property (nonatomic, assign) VerificationCodeType  codeType;

@property (nonatomic,assign)BOOL isGuidanceIn;
/// 登录成功回调
@property (nonatomic, copy) LoginSuccessBlock loginSuccess;

@end
