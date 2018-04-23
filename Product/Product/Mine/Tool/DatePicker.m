//
//  DatePicker.m
//  Product
//
//  Created by Feng on 16/4/22.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DatePicker.h"

@interface DatePicker (){

     UIView *backgroudView;
}

@end

@implementation DatePicker

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showInView:(UIView*)view{
    
    if (!backgroudView) {
        backgroudView=[[UIView alloc]initWithFrame:view.frame];
    }
    
    backgroudView.alpha=0.5f;
    
    [backgroudView setBackgroundColor:[UIColor blackColor]];
    
    [view addSubview:backgroudView];

    
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.view setAlpha:1.0f];
    [self.view.layer addAnimation:animation forKey:@"DDLocateView"];
    
    
    self.view.frame = CGRectMake(0,view.frame.size.height - self.view.frame.size.height,[UIScreen mainScreen ].bounds.size.width, self.view.frame.size.height);
    
    
    [view addSubview:self.view];
    
    //设置最大日期
    [datePicker setMaximumDate:[NSDate date]];
}




-(IBAction)okBtnClick:(id)sender{
    
    
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.view setAlpha:0.0f];
    [self.view.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3];
    
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(datePickerViewDidClickOK:)]) {
        
        NSDateFormatter *df= [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr= [df stringFromDate:datePicker.date];
        
        [self.delegate datePickerViewDidClickOK:dateStr];
        
    }
}


-(void)viewRemoveFromSuperview{
    [backgroudView removeFromSuperview];
    [self.view removeFromSuperview];
}


-(IBAction)cancleBtnClick:(id)sender{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.view setAlpha:0.0f];
    [self.view.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3];
    
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
