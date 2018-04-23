//
//  ScaleView.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ScaleView.h"
#import "TXHRrettyRuler.h"

@interface ScaleView ()<TXHRrettyRulerDelegate>{
    
    UILabel       *weightLabel;
    UIButton      *weightIntellectualLabel;

    UIView        *rootView;
}

@end
@implementation ScaleView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 5, kScreenWidth-40, 30)];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.font=[UIFont systemFontOfSize:16.0];
        titleLabel.text=@"体重";
        [self addSubview:titleLabel];
        
        UIButton *closeButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, 5, 30, 30)];
        [closeButton setImage:[UIImage imageNamed:@"ic_n_meal_del"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom+5, kScreenWidth, 1)];
        line.backgroundColor=kLineColor;
        [self addSubview:line];
        
        weightLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, line.bottom+10, kScreenWidth-40, 25)];
        weightLabel.textAlignment=NSTextAlignmentCenter;
        weightLabel.font=[UIFont systemFontOfSize:14.0f];
        weightLabel.textColor=[UIColor blackColor];
        
        [self addSubview:weightLabel];
        
        TXHRrettyRuler *ruler=[[TXHRrettyRuler alloc] initWithFrame:CGRectMake(0, weightLabel.bottom+10, kScreenWidth, 120)];
        ruler.rulerDeletate=self;
        [ruler showRulerScrollViewWithCount:250 average:[NSNumber numberWithInteger:1] currentValue:50.0 smallMode:YES mineCount:10];
        [self addSubview:ruler];
        
        NSMutableAttributedString *colaryAttributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"60kg"]];
        [colaryAttributeStr addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, colaryAttributeStr.length-2)];
        weightLabel.attributedText=colaryAttributeStr;
        
        weightIntellectualLabel=[[UIButton alloc] initWithFrame:CGRectMake((frame.size.width-80)/2, ruler.bottom, 80, 35)];
        [weightIntellectualLabel addTarget:self action:@selector(addWeight) forControlEvents:UIControlEventTouchUpInside];
        [weightIntellectualLabel setTitle:@"智能称重" forState:UIControlStateNormal];
        [weightIntellectualLabel setTitleColor:kSystemColor forState:UIControlStateNormal];
        [self addSubview:weightIntellectualLabel];
        
        UIButton *addButton=[[UIButton alloc] initWithFrame:CGRectMake(0, weightIntellectualLabel.bottom+10, kScreenWidth, 50)];
        addButton.backgroundColor=kSystemColor;
        [addButton setTitle:@"记录" forState:UIControlStateNormal];
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
    
    self.frame=CGRectMake(0,kScreenHeight-self.height, kScreenWidth, self.height);
    [view addSubview:rootView];
    [view addSubview:self];
}

#pragma mark 添加重量
-(void)addFoodWeightAction:(UIButton *)sender{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-05-03"];
#endif
    if ([_scaleDelegate respondsToSelector:@selector(scaleView:weight:)]) {
        [_scaleDelegate scaleView:self weight: weightLabel.text];
    }
    [self dismissScaleView];
}
#pragma mark -- 跳转体脂秤
- (void)addWeight{
    if ([_scaleDelegate respondsToSelector:@selector(scaleView:)]) {
        [_scaleDelegate scaleView:self];
    }
    [self dismissScaleView];
}
#pragma mark 关闭视图
-(void)closeViewAction:(UIButton *)sender{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-05-02"];
#endif
    [self dismissScaleView];
}

-(void)dismissScaleView{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame=CGRectMake(0, kScreenHeight, kScreenWidth, self.height);
    } completion:^(BOOL finished) {
        [rootView removeFromSuperview];
        [self removeFromSuperview];
    }];
}


#pragma mark -- TXHRrettyRulerDelegate
-(void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView isBool:(BOOL)isbool{
    NSInteger  weightValue=rulerScrollView.rulerValue;
    NSMutableAttributedString *attributeStr2=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ldkg",weightValue]];
    [attributeStr2 addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, attributeStr2.length-2)];
    weightLabel.attributedText=attributeStr2;
}
@end
