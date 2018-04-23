//
//  CharacterTeaView.m
//  Product
//
//  Created by 肖栋 on 17/1/13.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "CharacterTeaView.h"
#import "NSUserDefaultInfos.h"

@interface CharacterTeaView ()<UIGestureRecognizerDelegate>{
    UIView *backgroudView;
}
@end
@implementation CharacterTeaView

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

-(IBAction)fruitTeaFunction:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(fruitTeaFunction:)]) {
        [self.delegate fruitTeaFunction:sender];
    }
}

-(IBAction)scentedTeaStartFunction:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scentedTeaStartFunction:)]) {
        [self.delegate scentedTeaStartFunction:sender];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
