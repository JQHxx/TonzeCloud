//
//  StartFunctionView.m
//  Product
//
//  Created by Xlink on 16/1/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "StartFunctionView.h"
#import "NSUserDefaultInfos.h"

@interface StartFunctionView ()<UIGestureRecognizerDelegate>{
    UIView *backgroudView;
}

@end

@implementation StartFunctionView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    backgroudView=[[UIView alloc]initWithFrame:[ UIScreen mainScreen ].bounds];
    [backgroudView setBackgroundColor:[UIColor blackColor]];
    [backgroudView setAlpha:0.3f];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [backgroudView addGestureRecognizer:gesture];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showInView:(UIView*)view{

    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.view setAlpha:1.0f];
    [self.view.layer addAnimation:animation forKey:@"DDLocateView"];
    self.view.frame = CGRectMake(0, view.frame.size.height - self.view.frame.size.height,SCREEN_WIDTH, self.view.frame.size.height);
    
    [view addSubview:backgroudView];
    [view addSubview:self.view];

    if (!self.canSetWorkTime) {
        self.setTimeView.hidden=YES;
    }else{
        self.setTimeView.hidden=NO;
    }
}



-(void)dismissView{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
      [self.view setAlpha:0.0f];
    [self.view.layer addAnimation:animation forKey:@"TSLocateView"];
        self.view.frame = CGRectMake(0,SCREEN_HEIGHT - self.view.frame.size.height, SCREEN_WIDTH, self.view.frame.size.height);
    
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3f];
    

}

-(void)viewRemoveFromSuperview{
        [backgroudView removeFromSuperview];
        [self.view removeFromSuperview];
}


-(IBAction)selectTime:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectTime:)]) {
        [self.delegate selectTime:sender];
    }
}

-(IBAction)startFunction:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(startFunction:)]) {
        [self.delegate startFunction:sender];
    }
}

-(IBAction)orderStartFunction:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(orderStartFunction:)]) {
        [self.delegate orderStartFunction:sender];
    }

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
