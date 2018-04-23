//
//  FoodWeightScaleView.m
//  Product
//
//  Created by 肖栋 on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "FoodWeightScaleView.h"
#import "TXHRrettyRuler.h"

@interface FoodWeightScaleView ()<TXHRrettyRulerDelegate>{
    
    UILabel       *weightLabel;
    UILabel       *weightIntellectualLabel;
    
    UIView        *rootView;
    NSInteger     weightValue;

}

@end
@implementation FoodWeightScaleView

-(instancetype)initWithFrame:(CGRect)frame weight:(NSInteger)weight{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];

        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 5, kScreenWidth-40, 30)];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.font=[UIFont systemFontOfSize:16.0];
        titleLabel.text=@"重量";
        [self addSubview:titleLabel];
        
        UIButton *closeButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, 5, 30, 30)];
        [closeButton setImage:[UIImage imageNamed:@"ic_n_meal_del"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom+5, kScreenWidth, 1)];
        line.backgroundColor=kLineColor;
        [self addSubview:line];
        
        NSInteger defaultWeight=weight>0?weight:100;
        
        weightLabel=[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2, line.bottom+30, 80, 25)];
        weightLabel.textAlignment=NSTextAlignmentCenter;
        weightLabel.font=[UIFont systemFontOfSize:14.0f];
        weightLabel.textColor=[UIColor blackColor];
        NSMutableAttributedString *colaryAttributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ldg",(long)defaultWeight]];
        [colaryAttributeStr addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, colaryAttributeStr.length-1)];
        weightLabel.attributedText=colaryAttributeStr;
        [self addSubview:weightLabel];
        
        TXHRrettyRuler *ruler=[[TXHRrettyRuler alloc] initWithFrame:CGRectMake(0, weightLabel.bottom+25, kScreenWidth, 120)];
        ruler.rulerDeletate=self;
        [ruler showRulerScrollViewWithCount:9999 average:[NSNumber numberWithInteger:1] currentValue:defaultWeight smallMode:YES mineCount:0];
        [self addSubview:ruler];
        
        UIButton *addButton=[[UIButton alloc] initWithFrame:CGRectMake(0, ruler.bottom+10, kScreenWidth, 50)];
        addButton.backgroundColor=[UIColor colorWithHexString:@"#00b7ee"];
        [addButton setTitle:@"确认" forState:UIControlStateNormal];
        [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(FoodWeightAction) forControlEvents:UIControlEventTouchUpInside];
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
-(void)foodWeightScaleViewShowInView:(UIView *)view{
    [view addSubview:rootView];
    [view addSubview:self];
    
    [UIView animateWithDuration:0.05 animations:^{
        self.frame=CGRectMake(0,kScreenHeight-self.height, kScreenWidth, self.height);
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark -- 确认
- (void)FoodWeightAction{
    if (weightValue==0) {
        [self makeToast:@"食材重量不能为0" duration:1.0 position:CSToastPositionCenter];
    }else{
        if ([_foodWeightScaleDelegate respondsToSelector:@selector(foodWeightScaleView:weight:)]) {
            [_foodWeightScaleDelegate foodWeightScaleView:self weight:[weightLabel.text integerValue]];
        }
        [self dismissScaleView];
    }
}

#pragma mark 关闭视图
-(void)closeViewAction:(UIButton *)sender{
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
    weightValue=rulerScrollView.rulerValue;
    NSMutableAttributedString *attributeStr2=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ldg",weightValue]];
    [attributeStr2 addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, attributeStr2.length-1)];
    weightLabel.attributedText=attributeStr2;
}

@end
