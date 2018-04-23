//
//  BabyModelView.m
//  Product
//
//  Created by 肖栋 on 17/1/13.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BabyModelView.h"
#import "LiuXSlider.h"

@interface BabyModelView ()<UIGestureRecognizerDelegate>{
    UIView *backgroudView;
    LiuXSlider *heatSlider;
    LiuXSlider *preserveHeatSlider;

}

@end

@implementation BabyModelView

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
    [self createbabyModelView];
}
- (void)createbabyModelView{

    startBabyModelBtn.layer.cornerRadius = 8;
    [_choiceModel addTarget:self action:@selector(didClicksegmentedControlAction:)forControlEvents:UIControlEventValueChanged];
    _choiceModel.tintColor = kRGBColor(255, 137, 32);
    self.heatModel = @"冲奶粉";
    self.heatValue = @"40";
    self.preserveHeatValue = @"50";
    heatSlider=[[LiuXSlider alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/320*15, self.remindLabel.bottom+20, SCREEN_WIDTH/320*290, 40) titles:@[@"40℃",@"42℃",@"44℃",@"46℃",@"48℃",@"50℃",@"52℃",@"64℃",@"56℃",@"58℃",@"60℃"] firstAndLastTitles:@[@"40℃",@"60℃"]  defaultIndex:1 sliderImage:[UIImage imageNamed:@"img_sxh_dot"] bgImage:[UIImage imageNamed:@"img_sxh_slider"] coverImage:[UIImage imageNamed:@"img_sxh_slider_on"]];
    heatSlider.rightImage.hidden = YES;
    heatSlider.leftImage.hidden = YES;
    heatSlider.leftLabel.hidden = NO;
    heatSlider.rightLabel.hidden = NO;
    [self.view addSubview:heatSlider];
    __block BabyModelView *blockSelf = self;
    heatSlider.block=^(int index){
        //火力值为index＋1
        NSLog(@"当前index==%d",index);
        
        NSString *stringFire = [[NSString alloc] initWithFormat:@"%d",index];
        
        blockSelf.heatValue = stringFire;
    };
    preserveHeatSlider=[[LiuXSlider alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/320*15, self.remindLabel.bottom+20, SCREEN_WIDTH/320*290, 40) titles:@[@"50℃",@"51℃",@"52℃",@"53℃",@"54℃",@"55℃",@"56℃",@"57℃",@"58℃",@"59℃",@"60℃"] firstAndLastTitles:@[@"50℃",@"60℃"]  defaultIndex:1 sliderImage:[UIImage imageNamed:@"img_sxh_dot"] bgImage:[UIImage imageNamed:@"img_sxh_slider"] coverImage:[UIImage imageNamed:@"img_sxh_slider_on"]];
    preserveHeatSlider.hidden = YES;
    preserveHeatSlider.rightImage.hidden = YES;
    preserveHeatSlider.leftImage.hidden = YES;
    preserveHeatSlider.leftLabel.hidden = NO;
    preserveHeatSlider.rightLabel.hidden = NO;
    [self.view addSubview:preserveHeatSlider];
    preserveHeatSlider.block=^(int index){
        //火力值为index＋1
        NSLog(@"当前index==%d",index);
        
        NSString *stringFire = [[NSString alloc] initWithFormat:@"%d",index];
        
        blockSelf.preserveHeatValue = stringFire;
    };
}
- (void)didClicksegmentedControlAction:(UISegmentedControl *)Seg{
        NSInteger Index = Seg.selectedSegmentIndex;
        NSLog(@"Index %li", (long)Index);
        switch (Index) {
            case 0:
                preserveHeatSlider.hidden=YES;
                heatSlider.hidden = NO;
                self.heatModel = @"冲奶粉";
                self.remindLabel.text = @"将壶内的水烧开(100℃)后，自然降温至下方设定的温度并恒定保温。";
                self.pormptLabel.text = @"温馨提示：请根据奶粉推荐的温度设定";
                break;
            case 1:
                preserveHeatSlider.hidden = NO;
                heatSlider.hidden = YES;
                self.heatModel = @"温母乳";
                self.remindLabel.text = @"将壶内的水加热至下方设定的温度并恒定保温。";
                self.pormptLabel.text = @"温馨提示：将水倒至容器，并将母乳容器隔水温热";
                break;
            default:
                break;
        }
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
/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
