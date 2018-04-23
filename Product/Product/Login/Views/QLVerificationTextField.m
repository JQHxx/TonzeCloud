//
//  QLVerificationTextField.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/2/28.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "QLVerificationTextField.h"

@implementation QLVerificationTextField

-(void)deleteBackward{
    [super deleteBackward];
    
    if ([self.ql_delegate respondsToSelector:@selector(QLTextFieldDeleteBackward:)]) {
        
        [self.ql_delegate QLTextFieldDeleteBackward:self];
    }
}
@end
