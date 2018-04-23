//
//  TCMenuView.m
//  TonzeCloud
//
//  Created by vision on 17/2/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TJYMenuView.h"

#define kBtnWidth 80

@interface TJYMenuView(){
    UILabel   *line_lab;
    UIButton  *selectBtn;
    CGFloat   btnWidth;
    CGFloat   viewHeight;
    NSUInteger num;
}

@end

@implementation TJYMenuView

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

-(void)setMenusArray:(NSMutableArray *)menusArray{
    _menusArray=menusArray;
    
    CGFloat  lineHeight=0.0;
    num=menusArray.count;
    if (kBtnWidth*num<kScreenWidth) {
        btnWidth=kScreenWidth/num;
        self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, viewHeight);
        lineHeight=kScreenWidth;
    }else{
        btnWidth=kBtnWidth;
        self.rootScrollView.contentSize=CGSizeMake(btnWidth*num, viewHeight);
        lineHeight=btnWidth*num;
    }
    
    for (int i=0; i<num; i++) {
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(i*btnWidth, 0, btnWidth, viewHeight)];
        [btn setTitle:menusArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"0x626262"] forState:UIControlStateNormal];
        [btn setTitleColor:kSystemColor forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        btn.tag=100+i;
        [btn addTarget:self action:@selector(changeViewWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootScrollView addSubview:btn];
        
        if (i==0) {
            selectBtn=btn;
            selectBtn.selected=YES;
        }
    }
    
    line_lab=[[UILabel alloc] initWithFrame:CGRectMake(0.0,viewHeight-3, btnWidth, 2.0)];
    line_lab.backgroundColor = kSystemColor;
    [self.rootScrollView addSubview:line_lab];
    
    CALayer *line = [[CALayer alloc]init];
    line.frame = CGRectMake(0, viewHeight-1, lineHeight, 1);
    line.backgroundColor = [UIColor colorWithHexString:@"0xdadada"].CGColor;
    [self.layer addSublayer:line];
    
}
- (void)setShopMenusArray:(NSMutableArray *)shopMenusArray{
    
    _shopMenusArray=shopMenusArray;
    
    CGFloat  lineHeight=0.0;
    num=_shopMenusArray.count;
    if (kBtnWidth*num<kScreenWidth) {
        btnWidth=kScreenWidth/num;
        self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, viewHeight);
        lineHeight=kScreenWidth;
    }else{
        btnWidth=kBtnWidth;
        self.rootScrollView.contentSize=CGSizeMake(btnWidth*num, viewHeight);
        lineHeight=btnWidth*num;
    }
    
    for (int i=0; i<num; i++) {
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(i*btnWidth, 0, btnWidth, viewHeight)];
        [btn setTitle:_shopMenusArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"0x626262"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"0xf39800"] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.tag=100+i;
        [btn addTarget:self action:@selector(changeViewWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootScrollView addSubview:btn];
        
        if (i==0) {
            selectBtn=btn;
            selectBtn.selected=YES;
        }
    }
    
    line_lab=[[UILabel alloc] initWithFrame:CGRectMake(0.0,viewHeight-2, btnWidth, 2.0)];
    line_lab.backgroundColor = [UIColor colorWithHexString:@"0xf39800"];
    [self.rootScrollView addSubview:line_lab];
    
    CALayer *line = [[CALayer alloc]init];
    line.frame = CGRectMake(0, viewHeight-0.5, lineHeight, 0.5);
    line.backgroundColor = kLineColor.CGColor;
    [self.layer addSublayer:line];
    
}
-(void)changeViewWithButton:(UIButton *)btn{
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(index*btnWidth, viewHeight-3, btnWidth, 2.0);
        
        if (index>2&&index<num-2) {
            CGPoint position=CGPointMake((index-2)*btnWidth, 0);
            [self.rootScrollView setContentOffset:position animated:YES];
        }else if (index==1||index==2||index==0){
            [self.rootScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }else if (index==num-2||index==num-1){
            CGFloat scrollw = 0.0;
            if (self.menusArray.count>0) {
                scrollw=self.menusArray.count*btnWidth;
            } else {
                scrollw=self.shopMenusArray.count*btnWidth;
            }
            if (scrollw>kScreenWidth) {
                [self.rootScrollView setContentOffset:CGPointMake(scrollw-kScreenWidth, 0) animated:YES];
            }
        }
    }];
    
    if ([_delegate respondsToSelector:@selector(menuView:actionWithIndex:)]) {
        [_delegate menuView:self actionWithIndex:index];
    }
}

@end
