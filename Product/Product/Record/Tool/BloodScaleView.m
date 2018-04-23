//
//  BloodScaleView.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BloodScaleView.h"
#import "TXHRrettyRuler.h"

@interface BloodScaleView ()<TXHRrettyRulerDelegate>{
    NSInteger     energy;    //每100g能量值
    
    UILabel       *bloodHeightLabel;
    UILabel       *bloodLowLabel;
    
    UIView        *rootView;
    NSInteger     height;
    NSInteger     low;
}

@end
@implementation BloodScaleView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
                
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 5, kScreenWidth-40, 30)];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.font=[UIFont systemFontOfSize:16.0];
        titleLabel.text=@"血压";
        [self addSubview:titleLabel];
        
        UIButton *closeButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, 5, 30, 30)];
        [closeButton setImage:[UIImage imageNamed:@"ic_n_meal_del"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom+5, kScreenWidth, 1)];
        line.backgroundColor=kLineColor;
        [self addSubview:line];
        
        bloodHeightLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, line.bottom+20, kScreenWidth-40, 25)];
        bloodHeightLabel.textAlignment=NSTextAlignmentCenter;
        bloodHeightLabel.font=[UIFont systemFontOfSize:14.0f];
        bloodHeightLabel.textColor=[UIColor blackColor];
        [self addSubview:bloodHeightLabel];
        
        TXHRrettyRuler *ruler1=[[TXHRrettyRuler alloc] initWithFrame:CGRectMake(0, bloodHeightLabel.bottom+10, kScreenWidth, 120)];
        ruler1.rulerDeletate=self;
        ruler1.isBool = YES;
        [ruler1 showRulerScrollViewWithCount:230 average:[NSNumber numberWithInteger:1] currentValue:130.0 smallMode:YES mineCount:20];
        [self addSubview:ruler1];
        
        bloodHeightLabel.text=@"收缩压（高压）150mmHg";
        
        bloodLowLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, ruler1.bottom, kScreenWidth-40, 25)];
        bloodLowLabel.textAlignment=NSTextAlignmentCenter;
        bloodLowLabel.font=[UIFont systemFontOfSize:14.0f];
        bloodLowLabel.textColor=[UIColor blackColor];
        [self addSubview:bloodLowLabel];
        
        TXHRrettyRuler *ruler2=[[TXHRrettyRuler alloc] initWithFrame:CGRectMake(0, bloodLowLabel.bottom+10, kScreenWidth, 120)];
        ruler2.rulerDeletate=self;
        ruler2.isBool = NO;
        [ruler2 showRulerScrollViewWithCount:230 average:[NSNumber numberWithInteger:1] currentValue:80.0 smallMode:YES mineCount:20];
        [self addSubview:ruler2];
        
        bloodLowLabel.text=@"舒张压（低压）100mmHg";
        
        UIButton *addButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 465-70, kScreenWidth, 50)];
        addButton.backgroundColor=kSystemColor;
        [addButton setTitle:@"记录" forState:UIControlStateNormal];
        [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addFoodWeightAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addButton];
        
        rootView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight+20)];
        rootView.backgroundColor=[UIColor blackColor];
        rootView.alpha=0.3;
        rootView.userInteractionEnabled=YES;
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissScaleView)];
        [rootView addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark -- Private Methods
#pragma mark 弹出界面
-(void)bloodScaleViewShowInView:(UIView *)view{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"TCScaleView"];
    
    self.frame=CGRectMake(0,kScreenHeight+20-self.height, kScreenWidth, self.height);
    [view addSubview:rootView];
    [view addSubview:self];
}

#pragma mark 添加血压
-(void)addFoodWeightAction:(UIButton *)sender{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-06-03"];
#endif
    if ([_bloodScaleDelegate respondsToSelector:@selector(scaleView:height:low:)]) {
        [_bloodScaleDelegate scaleView:self height:height low:low];
    }
    [self dismissScaleView];
}

#pragma mark 关闭视图
-(void)closeViewAction:(UIButton *)sender{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-06-02"];
#endif
    [self dismissScaleView];
}

-(void)dismissScaleView{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame=CGRectMake(0, kScreenHeight+20, kScreenWidth, self.height);
    } completion:^(BOOL finished) {
        [rootView removeFromSuperview];
        [self removeFromSuperview];
    }];
}


#pragma mark -- TXHRrettyRulerDelegate
-(void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView isBool:(BOOL)isbool{
    if (isbool == YES) {
        height=rulerScrollView.rulerValue;
        bloodLowLabel.text=[NSString stringWithFormat:@"收缩压（高压）%ldmmHg",(long)height];
    } else {
        low=rulerScrollView.rulerValue;
        bloodLowLabel.text=[NSString stringWithFormat:@"舒张压（低压）%ldmmHg",(long)low];
    }
}

@end
