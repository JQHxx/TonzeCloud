//
//  FoodScaleView.m
//  Product
//
//  Created by 肖栋 on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "FoodScaleView.h"
#import "TXHRrettyRuler.h"

@interface FoodScaleView ()<TXHRrettyRulerDelegate>{
    
    UILabel       *weightLabel;
    UILabel       *weightIntellectualLabel;
    
    UIView        *rootView;
    
    NSInteger     weightValue;
    StorageModel  *storageModel;
}

@end
@implementation FoodScaleView

-(instancetype)initWithFrame:(CGRect)frame WithModel:(StorageModel *)model{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        storageModel=model;
        weightValue=model.weight;
        
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 5, kScreenWidth-40, 30)];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.font=[UIFont systemFontOfSize:16.0];
        titleLabel.text=@"取出食材";
        [self addSubview:titleLabel];
        
        UIButton *closeButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, 5, 30, 30)];
        [closeButton setImage:[UIImage imageNamed:@"ic_n_meal_del"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom+5, kScreenWidth, 1)];
        line.backgroundColor=kLineColor;
        [self addSubview:line];
        
        weightIntellectualLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, line.bottom+10, kScreenWidth-40, 25)];
        weightIntellectualLabel.textAlignment=NSTextAlignmentCenter;
        weightIntellectualLabel.font=[UIFont systemFontOfSize:14.0f];
        weightIntellectualLabel.textColor=[UIColor grayColor];
        weightIntellectualLabel.text = model.item_name;
        [self addSubview:weightIntellectualLabel];
        
        weightLabel=[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2, weightIntellectualLabel.bottom+10, 80, 25)];
        weightLabel.textAlignment=NSTextAlignmentCenter;
        weightLabel.font=[UIFont systemFontOfSize:14.0f];
        weightLabel.textColor=[UIColor blackColor];
        NSMutableAttributedString *colaryAttributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ldg",model.weight]];
        [colaryAttributeStr addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, colaryAttributeStr.length-1)];
        weightLabel.attributedText=colaryAttributeStr;
        [self addSubview:weightLabel];
        
        TXHRrettyRuler *ruler=[[TXHRrettyRuler alloc] initWithFrame:CGRectMake(0, weightLabel.bottom+10, kScreenWidth, 120)];
        ruler.rulerDeletate=self;
        [ruler showRulerScrollViewWithCount:model.weight average:[NSNumber numberWithInteger:1] currentValue:model.weight smallMode:YES mineCount:0];
        [self addSubview:ruler];
        
        UIButton *addButton=[[UIButton alloc] initWithFrame:CGRectMake(0, ruler.bottom+10, kScreenWidth, 50)];
        addButton.backgroundColor=[UIColor colorWithHexString:@"#00b7ee"];
        [addButton setTitle:@"取出" forState:UIControlStateNormal];
        [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(setTakeFoodWeightAction:) forControlEvents:UIControlEventTouchUpInside];
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
-(void)foodScaleViewShowInView:(UIView *)view{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"FoodScaleView"];
    
    self.frame=CGRectMake(0,kScreenHeight-self.height, kScreenWidth, self.height);
    [view addSubview:rootView];
    [view addSubview:self];
}

#pragma mark 取出食物重量
-(void)setTakeFoodWeightAction:(UIButton *)sender{
    if (weightValue==0) {
        [self makeToast:@"取出食物重量不能为0" duration:1.0 position:CSToastPositionCenter];
    }else{
        storageModel.weight-=weightValue;
        if ([_foodScaleDelegate respondsToSelector:@selector(foodScaleViewTakeoutForFood:)]) {
            [_foodScaleDelegate foodScaleViewTakeoutForFood:storageModel];
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
