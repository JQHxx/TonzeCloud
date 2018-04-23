//
//  SceneNameAlertView.m
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SceneNameAlertView.h"

@interface SceneNameAlertView ()


@end

@implementation SceneNameAlertView

- (id) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
       
        self.backgroundColor=[UIColor whiteColor];
        self.layer.cornerRadius=5;
        self.clipsToBounds=YES;
        
        //标题
        UILabel *lable_title = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.width-40, 20)];
        lable_title.text = @"场景名称";
        lable_title.textColor = UIColorHex(0x313131);
        lable_title.font = [UIFont systemFontOfSize:15];
        lable_title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lable_title];
        
        //输入内容的框
        self.textField_input = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, self.width-20, 35)];
        self.textField_input.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        self.textField_input.layer.cornerRadius = 3;
        self.textField_input.clipsToBounds = YES;
        [self.textField_input addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self.textField_input becomeFirstResponder];
        
        //设置距离输入框左侧间距
        self.textField_input.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
        self.textField_input.leftViewMode = UITextFieldViewModeAlways;
        self.textField_input.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.textField_input];
        
        //button
        UIButton *button_sure = [[UIButton alloc] initWithFrame:CGRectMake(0, self.height-40, self.width, 40)];
        button_sure.backgroundColor = kSystemColor;
        button_sure.clipsToBounds = YES;
        [button_sure setTitle:@"确 定" forState:0];
        [button_sure.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button_sure addTarget:self action:@selector(dismissViewAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button_sure];
        
    }
    return self;
}

-(void)setInputText:(NSString *)inputText{
    _inputText=inputText;
    
    if (kIsEmptyString(inputText)) {
        self.textField_input.placeholder=@"请输入场景名称";
    }else{
        self.textField_input.text=inputText;
    }
}

//移除视图
- (void)dismissViewAction{
    if (kIsEmptyString(self.textField_input.text) ) {
        [self makeToast:@"请输入20字符以内的名称" duration:1.0 position:CSToastPositionCenter];
        return;
    }else{
        if (self.removeView) {
            self.removeView(self.textField_input.text);
        }
    }
}

#pragma mark ====== UITextFieldChange =======

- (void)textFieldDidChange:(UITextField *)textField{
    if (textField.text.length > 20) {
        textField.text = [textField.text substringToIndex:20];
    }
    
}
@end
