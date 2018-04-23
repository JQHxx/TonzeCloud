//
//  TCServiceClickViewGroup.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/18.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCServiceClickViewGroup.h"
#define kBtnWidth 50

@interface TCServiceClickViewGroup ()<UIScrollViewDelegate>{
    UIButton       *selectBtn;
    UILabel        *line_lab;
    
    CGFloat        viewHeight;
    CGFloat        btnWidth;
    
    NSUInteger     num;
}

@end
@implementation TCServiceClickViewGroup
-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles color:(UIColor *)color{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=kSystemColor;
        self.showsHorizontalScrollIndicator=NO;
        self.delegate=self;
        
        viewHeight=frame.size.height;
        num=titles.count;

        for (int i=0; i<num; i++) {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectZero];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateNormal];
            [btn setTitleColor:color forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
            btn.tag=100+i;
            btn.frame =CGRectMake(kBtnWidth*i, 10, kBtnWidth, 20);
            [btn addTarget:self action:@selector(serviceChangeViewWithButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            if (i==0) {
                selectBtn=btn;
                selectBtn.selected=YES;
            }
        }
        
        line_lab=[[UILabel alloc] initWithFrame:CGRectMake(5,38, kBtnWidth-10, 2.0)];
        line_lab.backgroundColor = color;
        [self addSubview:line_lab];

    }
    return self;
}

-(void)serviceChangeViewWithButton:(UIButton *)btn{
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(kBtnWidth*index+5, 38, kBtnWidth-10, 2.0);
    }];
    
    if ([_serviceDelegate respondsToSelector:@selector(ServiceViewGroupActionWithIndex:)]) {
        [_serviceDelegate ServiceViewGroupActionWithIndex:index];
    }
    
}
-(void)serviceBgChangeViewWithButton:(UIButton *)btn{
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(kBtnWidth*index+5, 38, kBtnWidth-10, 2.0);
    }];
}
@end
