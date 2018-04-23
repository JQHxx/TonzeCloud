//
//  FeedbackViewController.m
//  Product
//
//  Created by vision on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()<UITextViewDelegate>{
    
    UILabel    *promptLabel;
    UILabel    *countLabel;
    UITextView *idTextView;
}

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"意见反馈";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    [self initIdeaBackView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-05-04" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-05-04" type:2];
#endif
}


#pragma mark--UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView{
    NSString *tString = [NSString stringWithFormat:@"%lu/200",(unsigned long)textView.text.length];
    countLabel.text = tString;
}
- (void)textViewDidChange:(UITextView *)textView{
    if ([textView.text length]!= 0) {
        promptLabel.hidden = YES;
    }else{
        promptLabel.hidden = NO;
        NSString *tString = [NSString stringWithFormat:@"%lu/200",(unsigned long)textView.text.length];
        countLabel.text = tString;
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (textView==idTextView) {

        if ([textView.text length]+text.length>200) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}
#pragma mark -- 点击空白收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}
#pragma mark -- Event response
#pragma mark -- 提交反馈
- (void)retainButton{
    if (idTextView.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请填写问题或建议！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    } else {
        kSelfWeak;
        NSString *time = [[TJYHelper sharedTJYHelper] getCurrentDateTime];
        NSInteger ideaBackTime =[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:time format:@"yyyy-MM-dd HH:mm"];
        NSString *body = [NSString stringWithFormat:@"feedback_time=%ld&feedback_content=%@&doSubmit=1",(long)ideaBackTime,idTextView.text];
        [[NetworkTool sharedNetworkTool] postMethodWithURL:kFeedbackAdd body:body success:^(id json) {
            [weakSelf.view makeToast:@"提交成功" duration:1.0 position:CSToastPositionCenter];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
#pragma mark-- Custom Methods
#pragma mark -- 初始化界面
- (void)initIdeaBackView{
    
    UIView *bgView =  [[UIView alloc] initWithFrame:CGRectMake(0, 74, kScreenWidth, 250)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    idTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 80, kScreenWidth-30, 240)];
    idTextView.layer.borderColor = [UIColor bgColor_Gray].CGColor;
    idTextView.layer.masksToBounds = YES;
    idTextView.font = [UIFont systemFontOfSize:15];
    idTextView.delegate = self;
    [self.view addSubview:idTextView];
    
    promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 87,kScreenWidth-40, 20)];
    promptLabel.text = @"请简要描述您的问题和意见";
    promptLabel.font = [UIFont systemFontOfSize:16];
    promptLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:promptLabel];
    
    countLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100, idTextView.bottom-30, 80, 20)];
    countLabel.text = @"0/200";
    countLabel.textColor = [UIColor lightGrayColor];
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:countLabel];
    
    UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, idTextView.bottom+50, kScreenWidth, 30)];
    tLabel.text = @"感谢您留下宝贵的建议，我们将及时给予答复。";
    tLabel.textAlignment = NSTextAlignmentCenter;
    tLabel.font = [UIFont systemFontOfSize:13];
    tLabel.textColor = [UIColor grayColor];
    [self.view addSubview:tLabel];
    
    UIButton *retainBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, kScreenHeight-80, kScreenWidth-100, 40)];
    [retainBtn setTitle:@"提交" forState:UIControlStateNormal];
    retainBtn.layer.cornerRadius = 2;
    [retainBtn setBackgroundColor:kSystemColor];
    [retainBtn addTarget:self action:@selector(retainButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:retainBtn];
}


@end
