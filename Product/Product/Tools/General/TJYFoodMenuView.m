//
//  TCFoodMenuView.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/29.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TJYFoodMenuView.h"
#define kBtnWidth 80

@interface TJYFoodMenuView(){
    UILabel   *line_lab;
    UIButton  *selectBtn;
    CGFloat   btnWidth;
    CGFloat   viewHeight;
    NSUInteger num;
}
@end
@implementation TJYFoodMenuView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        viewHeight=frame.size.height;
        
        self.rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, viewHeight)];
        self.rootScrollView.showsHorizontalScrollIndicator=NO;
        [self addSubview:self.rootScrollView];
        num=0;
    }
    return self;
}

-(void)setFoodMenusArray:(NSMutableArray *)foodMenusArray{
    _foodMenusArray=foodMenusArray;
    
    CGFloat width = 0.0;
    for (int i=0; i<foodMenusArray.count; i++) {
        NSString *title =foodMenusArray[i];
        CGSize detailSize = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, viewHeight) withTextFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
        CGFloat tempW=detailSize.width+20;
        
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(width, 0, tempW, viewHeight)];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btn setTitleColor:kSystemColor forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        btn.tag=100+i;
        [btn addTarget:self action:@selector(changeFoodViewWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootScrollView addSubview:btn];
        
        width+=tempW;
        if (i==0) {
            selectBtn=btn;
            selectBtn.selected=YES;
        }
    }
    
    [self.rootScrollView setContentSize:CGSizeMake(width, viewHeight)];
    
    //线条宽度
    NSString *temptitle=foodMenusArray[0];
    CGSize detailSize = [temptitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, viewHeight) withTextFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    CGFloat tempW=detailSize.width+20;
    
    line_lab=[[UILabel alloc] initWithFrame:CGRectMake(0.0,viewHeight-3, tempW, 2.0)];
    line_lab.backgroundColor = kSystemColor;
    [self.rootScrollView addSubview:line_lab];
    
    CALayer *line = [[CALayer alloc]init];
    line.frame = CGRectMake(0, viewHeight-0.5, width, 0.5);
    line.backgroundColor = kLineColor.CGColor;
    [self.layer addSublayer:line];
}

-(void)changeFoodViewWithButton:(UIButton *)btn{
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        
        //线条坐标
        btnWidth = 0.0;
        for (NSInteger i=0; i<index; i++) {
            NSString *title =self.foodMenusArray[i];
            CGSize detailSize = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, viewHeight) withTextFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
            CGFloat tempW=detailSize.width+20;
            btnWidth+=tempW;
        }
        
        // 线条宽度
        NSString *temptitle=self.foodMenusArray[index];
        CGSize detailSize = [temptitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, viewHeight) withTextFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
        CGFloat tempLineW=detailSize.width+20;
        
        line_lab.frame=CGRectMake(btnWidth, viewHeight-3, tempLineW, 2.0);
        if (index>2&&index<_foodMenusArray.count-2) {
            NSString *textStr =self.foodMenusArray[index];
            CGSize detailSize = [textStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, viewHeight) withTextFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
            CGFloat tempScrollW=detailSize.width;
            
            CGPoint position=CGPointMake(btnWidth-(kScreenWidth-tempScrollW)/2, 0);
            [self.rootScrollView setContentOffset:position animated:YES];
        }else if (index==1||index==2||index==0){
            [self.rootScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }else if (index==self.foodMenusArray.count-1||index==self.foodMenusArray.count-2){
            CGFloat scrollWidth = 0.0;
            for (NSInteger i=0; i<self.foodMenusArray.count; i++) {
                NSString *title =self.foodMenusArray[i];
                CGSize detailSize = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, viewHeight) withTextFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
                CGFloat tempW=detailSize.width+20;
                scrollWidth+=tempW;
            }
            if (scrollWidth>kScreenWidth) {
                [self.rootScrollView setContentOffset:CGPointMake(scrollWidth-kScreenWidth, 0) animated:YES];
            }
        }
    }];
    if ([_delegate respondsToSelector:@selector(foodMenuView:actionWithIndex:)]) {
        [_delegate foodMenuView:self actionWithIndex:index];
    }
}

@end
