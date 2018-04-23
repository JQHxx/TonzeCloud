//
//  QLVerificationTextField.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/2/28.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QLVerificationTextField;

@protocol QLTextFieldDelegate <NSObject>

- (void)QLTextFieldDeleteBackward:(QLVerificationTextField *)textField;

@end


@interface QLVerificationTextField : UITextField

@property (nonatomic, weak)id<QLTextFieldDelegate> ql_delegate;

@end
