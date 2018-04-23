//
//  FoodMenuScale.m
//  Product
//
//  Created by 肖栋 on 17/4/24.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "FoodMenuScale.h"
#import "TXHRrettyRuler.h"
#import "EsmateWeightButton.h"

@interface FoodMenuScale ()<TXHRrettyRulerDelegate>{
    NSInteger     energy;    //每100g能量值
    NSInteger     calories_pre100;    //每100g能量值

    UILabel       *caloryLabel;
    UILabel       *weightLabel;
    
    UIView        *rootView;
    
    FoodAddModel   *selFood;
    NSInteger       isMenuFood;
    NSInteger      weightValue;
}

@end
@implementation FoodMenuScale

-(instancetype)initWithFrame:(CGRect)frame model:(FoodAddModel *)model type:(NSInteger)type{
    self=[super initWithFrame:frame];
    if (self) {
        isMenuFood = type;
        self.backgroundColor=[UIColor whiteColor];
        
        selFood=model;
        
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 5, kScreenWidth-40, 30)];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.font=[UIFont systemFontOfSize:16.0];
        titleLabel.text=model.name;
        [self addSubview:titleLabel];
        
        UIButton *closeButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, 5, 30, 30)];
        [closeButton setImage:[UIImage imageNamed:@"箭头_列表"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom+5, kScreenWidth, 1)];
        line.backgroundColor=kLineColor;
        [self addSubview:line];
        
        caloryLabel=[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, line.bottom+10, 100, 25)];
        caloryLabel.textAlignment=NSTextAlignmentCenter;
        caloryLabel.font=[UIFont systemFontOfSize:16.0f];
        caloryLabel.textColor=[UIColor blackColor];
        
        EsmateWeightButton *EstimateBtn = [[EsmateWeightButton alloc] initWithFrame:CGRectMake(kScreenWidth-84, line.bottom+5, 64, 44)];
        [EstimateBtn addTarget:self action:@selector(estimateButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:EstimateBtn];
        
        NSMutableAttributedString *colaryAttributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld千卡",(long)(model.type==YES?model.energykcal:model.calories_pre100)]];
        [colaryAttributeStr addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:20]} range:NSMakeRange(0, colaryAttributeStr.length-2)];
        caloryLabel.attributedText=colaryAttributeStr;
        [self addSubview:caloryLabel];
        
        energy=model.energykcal;
        calories_pre100 = model.calories_pre100;
        NSInteger currentValue=[model.weight integerValue]==0?100:[model.weight integerValue];
        
        TXHRrettyRuler *ruler=[[TXHRrettyRuler alloc] initWithFrame:CGRectMake(0, caloryLabel.bottom+20, kScreenWidth, 120)];
        ruler.rulerDeletate=self;
        [ruler showRulerScrollViewWithCount:1000 average:[NSNumber numberWithInteger:1] currentValue:currentValue smallMode:YES mineCount:0];
        [self addSubview:ruler];
        
        weightLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, ruler.bottom, kScreenWidth-40, 25)];
        weightLabel.textAlignment=NSTextAlignmentCenter;
        weightLabel.font=[UIFont systemFontOfSize:14.0f];
        weightLabel.textColor=[UIColor lightGrayColor];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld克",(long)currentValue]];
        [attributeStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, attributeStr.length-1)];
        weightLabel.attributedText=attributeStr;
        [self addSubview:weightLabel];
        
        UIButton *addButton=[[UIButton alloc] initWithFrame:CGRectMake(0, weightLabel.bottom+10, kScreenWidth, 50)];
        addButton.backgroundColor=kSystemColor;
        [addButton setTitle:@"添加" forState:UIControlStateNormal];
        [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addFoodWeightAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addButton];
        
        rootView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
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
-(void)scaleViewShowInView:(UIView *)view{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"TCScaleView"];
    
    self.frame=CGRectMake(0,kAllHeight-self.height, kScreenWidth, self.height);
    [view addSubview:rootView];
    [view addSubview:self];
}

#pragma mark 添加食物重量
-(void)addFoodWeightAction:(UIButton *)sender{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-11"];
#endif
    if (weightValue<1) {
        [self makeToast:@"重量不得小于1克" duration:1.0 position:CSToastPositionCenter];
    }else{
        if ([_foodMenuScaleDelegate respondsToSelector:@selector(foodMenuScaleView:didSelectFood:)]) {
            [_foodMenuScaleDelegate foodMenuScaleView:self didSelectFood:selFood];
        }
        [self dismissScaleView];
    }
}

#pragma mark 关闭视图
-(void)closeViewAction:(UIButton *)sender{
    if ([_foodMenuScaleDelegate respondsToSelector:@selector(foodMenuNextScaleView:didSelectFood:)]) {
        [_foodMenuScaleDelegate foodMenuNextScaleView:self didSelectFood:selFood];
    }
    if (!self.isShow) {
        [self dismissScaleView];
    }
}

-(void)dismissScaleView{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame=CGRectMake(0, kScreenHeight, kScreenWidth, self.height);
    } completion:^(BOOL finished) {
        [rootView removeFromSuperview];
        [self removeFromSuperview];
    }];
}
#pragma mark -- 估算重量
- (void)estimateButton{

    if ([_foodMenuScaleDelegate respondsToSelector:@selector(foodMenuScaleView:)]) {
        [_foodMenuScaleDelegate foodMenuScaleView:self];
    }
    if (!self.isShow) {
        [self dismissScaleView];
    }
}
#pragma mark -- TXHRrettyRulerDelegate
-(void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView isBool:(BOOL)isbool{
    weightValue=rulerScrollView.rulerValue;
    
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld克",(long)weightValue]];
    [attributeStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, attributeStr.length-1)];
    weightLabel.attributedText=attributeStr;
    NSInteger energyValue = 0;
    if (isMenuFood==YES) {
        energyValue=weightValue*energy/100;
    } else {
        energyValue=weightValue*calories_pre100/100;

    }
    NSMutableAttributedString *attributeStr2=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld千卡",(long)energyValue]];
    [attributeStr2 addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, attributeStr2.length-2)];
    caloryLabel.attributedText=attributeStr2;
    selFood.weight=[NSNumber numberWithInteger:weightValue];

}
@end