//
//  ClickViewGroup.m
//  TonzeCloud
//
//  Created by vision on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "ClickViewGroup.h"

#define kBtnWidth 70

@interface ClickViewGroup ()<UIScrollViewDelegate>{
    UIButton       *selectBtn;
    UILabel        *line_lab;
    
    CGFloat        viewHeight;
    CGFloat        btnWidth;
    CGFloat        lineHeight;
    
    NSUInteger     num;
}

@end

@implementation ClickViewGroup

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles color:(UIColor *)color{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        self.showsHorizontalScrollIndicator=NO;
        self.delegate=self;
        
        viewHeight=frame.size.height;
        
        num=titles.count;
        if (kBtnWidth*num<kScreenWidth) {
            btnWidth=kScreenWidth/num;
            self.contentSize=CGSizeMake(kScreenWidth, viewHeight);
            lineHeight=kScreenWidth;
        }else{
            btnWidth=kBtnWidth;
            self.contentSize=CGSizeMake(btnWidth*num, viewHeight);
            lineHeight=btnWidth*num;
        }
        
        for (int i=0; i<num; i++) {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(i*btnWidth, 0, btnWidth, viewHeight)];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btn setTitleColor:color forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            btn.tag=100+i;
            [btn addTarget:self action:@selector(changeViewWithButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
            if (i==0) {
                selectBtn=btn;
                selectBtn.selected=YES;
            }
        }
        
        line_lab=[[UILabel alloc] initWithFrame:CGRectMake(5.0,viewHeight-3, btnWidth-10.0, 2.0)];
        line_lab.backgroundColor = color;
        [self addSubview:line_lab];
        
        UILabel *lineLab=[[UILabel alloc] initWithFrame:CGRectMake(-10, viewHeight-1, self.contentSize.width+20, 1)];
        lineLab.backgroundColor=kLineColor;
        [self addSubview:lineLab];
    }
    return self;
}

-(void)changeViewWithButton:(UIButton *)btn{
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(index*btnWidth+5.0, 38, btnWidth-10.0, 2.0);
        if (index>=2&&index<num-2) {
            CGPoint position=CGPointMake((index-2)*btnWidth-10, 0);
            [self setContentOffset:position animated:YES];
        }
        
    }];

    if ([_viewDelegate respondsToSelector:@selector(ClickViewGroupActionWithIndex:)]) {
        [_viewDelegate ClickViewGroupActionWithIndex:index];
    }
    
}

@end
