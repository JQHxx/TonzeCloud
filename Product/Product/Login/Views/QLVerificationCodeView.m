//
//  QLVerificationCodeView.m
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/2/28.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import "QLVerificationCodeView.h"
#import "QLVerificationTextField.h"

@interface QLVerificationCodeView ()<UITextFieldDelegate,QLTextFieldDelegate>
#pragma mark - 私有属性

@property (nonatomic, strong,readwrite) NSString *vertificationCode;//验证码内容
@end

@implementation QLVerificationCodeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.VerificationCodeNum = 4;//默认4位
        self.Spacing = 0;//默认间距为0
        self.selectedColor = [UIColor cyanColor];
        self.deselectColor = [UIColor redColor];   //默认边框颜色
        
        [self setView]; //绘制界面
        
        MyLog(@"%ld",self.VerificationCodeNum);
    }
    return self;
}

-(void)setSecure{//修改明文密文方法
    
    for (UITextField *tf in _textFieldArray) {
        
        tf.secureTextEntry = _isSecure;
    }
}
-(void)setView{
    
    self.textFieldArray = [NSMutableArray array];
    NSArray *views = [self subviews];
    for (UITextField *tf in views) {
        [tf removeFromSuperview];
    }
    
    for (int i = 0 ; i<self.VerificationCodeNum; i++) {
        
        QLVerificationTextField *tf = [[QLVerificationTextField alloc]initWithFrame:CGRectMake(i*self.frame.size.width/self.VerificationCodeNum+_Spacing/2, 0, self.frame.size.width/self.VerificationCodeNum - _Spacing , self.frame.size.height)];
        tf.backgroundColor = [UIColor whiteColor];
        tf.ql_delegate = self;
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.layer.borderColor = self.deselectColor.CGColor;
        tf.layer.borderWidth = 0.5;
        //圆弧度
        //        tf.layer.cornerRadius = 6;
        tf.delegate = self;
        tf.tag = 100+i;
        tf.textAlignment = NSTextAlignmentCenter;
        tf.secureTextEntry = self.isSecure;
        [self addSubview:tf];
        [self.textFieldArray addObject:tf];
        if (i == 0) {
            [tf becomeFirstResponder];
        }
    }
}

//点击退格键的代理
#pragma mark - PZXTextFieldDelegate
- (void)QLTextFieldDeleteBackward:(QLVerificationTextField *)textField{
    
    if (textField.tag > [[_textFieldArray firstObject] tag]) {
        
        UITextField *newTF =  (UITextField *)[self viewWithTag:textField.tag-1];
        newTF.text = @"";
        [newTF becomeFirstResponder];
    }
}
#pragma mark - UITextFieldDelegate

//代理（里面有自己的密码线）
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    textField.text = string;
    
    if (textField.text.length > 0) {//防止退格第一个的时候往后跳一格
        
        if (textField.tag<  [[_textFieldArray lastObject] tag]) {
            
            UITextField *newTF =  (UITextField *)[self viewWithTag:textField.tag+1];
            
            [newTF becomeFirstResponder];
        }
    }
    
    if (textField.tag == [[_textFieldArray lastObject]tag]) {
        [textField resignFirstResponder];
        if (self.vertificationCodeBlock) {
            self.vertificationCodeBlock(_vertificationCode);
        }
    }
    return NO;
}

//在里面改变选中状态以及获取验证码
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    textField.layer.borderColor = self.selectedColor.CGColor;
    [self getVertificationCode];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    textField.layer.borderColor = self.deselectColor.CGColor;
    [self getVertificationCode];
}

-(void)getVertificationCode{ //获取验证码方法
    
    NSString *str = [NSString string];
    
    for (int i = 0; i<_textFieldArray.count; i++) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%@",(UITextField *)[_textFieldArray[i] text]]];
    }
    _vertificationCode = str;
}
- (void)celanVerificationCode{
    
    for (UITextField *tf in _textFieldArray) {
        
        tf.text = @"";
        if (tf.tag == 100) {
            [tf becomeFirstResponder];
        }
    }
}

#pragma mark - set方法
-(void)setVerificationCodeNum:(NSInteger)VerificationCodeNum{
    
    //这里用self会死循环！
    _VerificationCodeNum = VerificationCodeNum;
    [self setView];
}
-(void)setSpacing:(CGFloat)Spacing{
    
    _Spacing = Spacing;
    [self setView];
}

-(void)setIsSecure:(BOOL)isSecure{
    
    _isSecure = isSecure;
    [self setSecure];
}

-(void)setDeselectColor:(UIColor *)deselectColor{
    
    _deselectColor = deselectColor;
}
-(void)setSelectedColor:(UIColor *)selectedColor{
    
    _selectedColor = selectedColor;
}

//点击回收键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    for (UITextField *tf in self.textFieldArray) {
        
        [tf resignFirstResponder];
    }
}
@end

