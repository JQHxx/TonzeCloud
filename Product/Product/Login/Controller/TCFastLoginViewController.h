//
//  TCFastLoginViewController.h
//  TonzeCloud
//
//  Created by 肖栋 on 18/2/9.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "BaseViewController.h"
typedef void(^LoginSuccessBlock)();

@interface TCFastLoginViewController : BaseViewController

/// 登录成功回调
@property (nonatomic, copy) LoginSuccessBlock loginSuccess;

@end
