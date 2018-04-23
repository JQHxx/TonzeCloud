//
//  ShareFromAccountViewController.m
//  Product
//
//  Created by Feng on 16/2/4.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "ShareFromAccountViewController.h"
#import "AppDelegate.h"

@interface ShareFromAccountViewController (){
    AppDelegate *appDelegate;
}

@end

@implementation ShareFromAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"ID分享";
    
    appDelegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    shareBtn.layer.masksToBounds=YES;
    shareBtn.layer.cornerRadius=20.0f;
    
    [self hiddenKeyboard];
}

- (void)hiddenKeyboard{
    //回收键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    //设置同时只能有1个按钮被触发点击事件
    for (UIButton *btn in self.view.subviews) {
        if ([btn isMemberOfClass:[UIButton class]]) {
            btn.exclusiveTouch = YES;
        }
    }
}

- (void)tap:(UITapGestureRecognizer *)tap{
    [self textFieldShouldReturn:accountTF];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma  mark 分享设备
-(IBAction)shareDevice:(id)sender{
    if (accountTF.text.length==0) {
        [self showAlertWithTitle:@"提示" Message:@"请输入要分享的用户ID"];
        return;
    }
    
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    if ([accountTF.text isEqualToString:[NSUserDefaultInfos getValueforKey:USER_NAME]]||[[userDic objectForKey:@"user_id"] integerValue]==accountTF.text.integerValue) {
        [self showAlertWithTitle:@"提示" Message:@"不能分享设备给自己"];
        return;
    }

    [shareBtn showIndicator];

    [HttpRequest shareDeviceWithDeviceID:[NSNumber numberWithInt:self.model.deviceID] withAccessToken:[userDic objectForKey:@"access_token"] withShareAccount:accountTF.text withExpire:@(3600*24) didLoadData:^(id result, NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [shareBtn hideIndicator];
            if (err) {
                if (err.code==4041011) {
                    [self showAlertWithTitle:nil Message:@"帐号不存在，请检查是否拼写有误"];
                }else if (err.code==4031003) {
                    [appDelegate updateAccessToken];
                }else{
                    [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
                }
                
            }else{
                NSLog(@"result=%@",result);
                [self showAlertWithTitle:nil Message:@"邀请已发送，等待用户处理"];
                
            }
            
        });

    }];
    
}



//// 下面两个方法是为了防止TextFiled让键盘挡住的方法
//
-(void) textFieldDidBeginEditing:(UITextField *)textField{
    float textY = accountTF.frame.origin.y+accountTF.frame.size.height+70;
    float bottomY = self.view.frame.size.height-textY;
    if(bottomY>=282)  //判断当前的高度是否已经有282，如果超过了就不需要再移动主界面的View高度
    {
        
        return;
    }
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    float moveY = 282-bottomY;
    
    CGRect frame = self.view.frame;
    frame.origin.y -=moveY;//view的Y轴上移
    self.view.frame = frame;
    [UIView commitAnimations];//设置调整界面的动画效果
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
        [accountTF resignFirstResponder];
    if (self.view.frame.origin.y<0) {
        NSTimeInterval animationDuration = 0.30f;
        //self.view移回原位置
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        CGRect frame = self.view.frame;

         frame.origin.y =0;
         self.view.frame = frame;

        [UIView commitAnimations];
    }
    return YES;
}


- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message {
    NSString *otherButtonTitle = NSLocalizedString(@"好的", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([message isEqualToString:@"邀请已发送，等待用户处理"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];

    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}





@end
