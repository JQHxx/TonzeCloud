//
//  PhoneText.m
//  Distribution
//
//  Created by fei on 14-12-18.
//  Copyright (c) 2014年 ___YKSKJ.COM___. All rights reserved.
//

#import "PhoneText.h"

@implementation PhoneText

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {

        self.font = [UIFont systemFontOfSize:12.0];
        self.keyboardType=UIKeyboardTypeNumberPad;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
        view.backgroundColor = [UIColor whiteColor];
        self.inputAccessoryView = view;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth * 0.8, 5, 40, 40)];
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [btn setTitleColor:kSystemColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(confirmEdit) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
    }
    return self;
}

-(void)confirmEdit{
    [self resignFirstResponder];
}

@end
