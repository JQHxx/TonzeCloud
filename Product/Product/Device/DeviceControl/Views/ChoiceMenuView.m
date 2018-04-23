//
//  ChoiceMenuView.m
//  Product
//
//  Created by 肖栋 on 16/10/19.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "ChoiceMenuView.h"
#import "TimePickerView.h"
#import "LiuXSlider.h"
#import "ControllerHelper.h"

@interface ChoiceMenuView ()<UIGestureRecognizerDelegate>{
    UIView *backgroudView;
    TimePickerView *pickerView;
    UILabel *textLabel;
    LiuXSlider *slider;
}

@end

@implementation ChoiceMenuView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _fireText = [[UILabel alloc] init];
    _fireText.text = @"1";
    
    backgroudView=[[UIView alloc]initWithFrame:[ UIScreen mainScreen ].bounds];
    [backgroudView setBackgroundColor:[UIColor blackColor]];
    [backgroudView setAlpha:0.3f];
    textLabel = [[UILabel alloc] init];
        
    slider=[[LiuXSlider alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/320*25, 0, SCREEN_WIDTH/320*262, 40) titles:@[@"10％火力",@"20％火力",@"30％火力",@"40％火力",@"50％火力",@"60％火力",@"70％火力",@"80％火力",@"90％火力",@"100％火力"] firstAndLastTitles:@[@"10％",@"100％"]  defaultIndex:1 sliderImage:[UIImage imageNamed:@"ic_on"] bgImage:[UIImage imageNamed:@"bar_nor"] coverImage:[UIImage imageNamed:@"bar_hl"]];
    [_backFireView addSubview:slider];
    slider.rightImage.hidden = NO;
    slider.leftImage.hidden = NO;
    slider.leftLabel.hidden = YES;
    slider.rightLabel.hidden = YES;
    __block ChoiceMenuView *blockSelf = self;
    slider.block=^(int index){
        //火力值为index＋1
        NSLog(@"当前index==%d",index);
        
        NSString *stringFire = [[NSString alloc] initWithFormat:@"%d",index];
        
        blockSelf.fireText.text = stringFire;
    };
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



-(IBAction)startFunction:(id)sender{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(startFunction:)]) {
        [self.delegate startFunction:sender];
    }
}

-(IBAction)removeView:(id)sender{


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

@end
