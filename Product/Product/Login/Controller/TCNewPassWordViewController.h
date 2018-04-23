//
//  TCNewPassWorldViewController.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/2/8.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "BaseViewController.h"

@interface TCNewPassWordViewController : BaseViewController
///
@property (nonatomic, assign) BOOL   isChangePassWord;
/// 验证码
@property (nonatomic, copy) NSString *messageCode;
/// 手机号码
@property (nonatomic, copy) NSString *phoneNumber ;

@end
