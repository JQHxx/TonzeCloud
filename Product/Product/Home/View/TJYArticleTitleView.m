//
//  TJYArticleTitleView.m
//  Product
//
//  Created by zhuqinlu on 2018/3/26.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import "TJYArticleTitleView.h"

#define kBtnWidth 80

@interface TJYArticleTitleView(){
    UILabel   *line_lab;
    UIButton  *selectBtn;
    CGFloat   btnWidth;
    CGFloat   viewHeight;
    NSUInteger num;
}
@end

@implementation TJYArticleTitleView

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
- (void)setArticleMenusArray:(NSMutableArray *)articleMenusArray{
    
    while (self.rootScrollView.subviews.count) {
        [self.rootScrollView.subviews.lastObject removeFromSuperview];
    }
    
    _articleMenusArray = articleMenusArray;
    
    CGFloat  lineHeight=0.0;
    
    num= articleMenusArray.count;
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
        [btn setTitle:articleMenusArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        [btn setTitleColor:kSystemColor forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        btn.tag=100+i;
        [btn addTarget:self action:@selector(changeFoodViewWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootScrollView addSubview:btn];
        
        if (i==0) {
            selectBtn=btn;
            selectBtn.selected=YES;
        }
    }
    line_lab=[[UILabel alloc] initWithFrame:CGRectMake(0.0,viewHeight-3, btnWidth, 3.0)];
    line_lab.backgroundColor = kSystemColor;
    [self.rootScrollView addSubview:line_lab];
    
    CALayer *line = [[CALayer alloc]init];
    line.frame = CGRectMake(0, viewHeight-0.5, kScreenWidth, 0.5);
    line.backgroundColor = UIColorHex(0xe5e5e5).CGColor;
    [self.layer addSublayer:line];
}

-(void)changeFoodViewWithButton:(UIButton *)btn{
    
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(index*btnWidth, viewHeight-3, btnWidth, 2.0);
        
        if (index>2&&index<num-2) {
            CGPoint position=CGPointMake((index-2)*btnWidth, 0);
            [self.rootScrollView setContentOffset:position animated:YES];
        }else if (index==1||index==2){
            [self.rootScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }else if (index==num-2){
            CGFloat scrollw=self.articleMenusArray.count*btnWidth;
            if (scrollw>kScreenWidth) {
                [self.rootScrollView setContentOffset:CGPointMake(scrollw-kScreenWidth, 0) animated:YES];
            }
        }
    }];
    if ([_delegate respondsToSelector:@selector(articleTitleMenuView:actionWithIndex:)]) {
        [_delegate articleTitleMenuView:self actionWithIndex:index];
    }
}

-(void)changeBtnLineWithButton:(UIButton *)btn{
    
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(index*btnWidth, viewHeight-3, btnWidth, 2.0);
        
        if (index>2&&index<num-2) {
            CGPoint position=CGPointMake((index-2)*btnWidth, 0);
            [self.rootScrollView setContentOffset:position animated:YES];
        }else if (index==1||index==2){
            [self.rootScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }else if (index==num-2){
            CGFloat scrollw=self.articleMenusArray.count*btnWidth;
            if (scrollw>kScreenWidth) {
                [self.rootScrollView setContentOffset:CGPointMake(scrollw-kScreenWidth, 0) animated:YES];
            }
        }
    }];
    
}

@end
