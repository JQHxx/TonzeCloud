//
//  TJYFoodRecommendMenuView.m
//  Product
//
//  Created by zhuqinlu on 2017/5/16.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYFoodRecommendMenuView.h"

#define kBtnWidth 80

@interface TJYFoodRecommendMenuView(){
    UILabel   *line_lab;
    UIImageView *titleImg;
    UIButton  *selectBtn;
    CGFloat   btnWidth;
    CGFloat   viewHeight;
    NSUInteger num;
    CGSize btnTextSize;
    CGFloat titleImgLeft;
}

@end
@implementation TJYFoodRecommendMenuView

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
        [btn setTitleColor:UIColorHex(0x666666) forState:UIControlStateNormal];
        [btn setTitleColor:kSystemColor forState:UIControlStateSelected];
        btn.titleLabel.font = kFontSize(13);
        btn.tag=100+i;
        [btn addTarget:self action:@selector(changeViewWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootScrollView addSubview:btn];
        
        if (i==0) {
            selectBtn=btn;
            selectBtn.selected=YES;
        }
    }
    NSString *textWidth = @"晚餐";
    btnTextSize = [textWidth boundingRectWithSize:CGSizeMake(100, 100) withTextFont:kFontSize(13)];
    titleImgLeft =(btnWidth - btnTextSize.width)/2;
    
    //    titleImg = [[UIImageView alloc]initWithFrame:CGRectMake(titleImgLeft, (viewHeight -15)/2, 15, 15)];
    //    titleImg.image = [UIImage imageNamed:@"ic_h_food_mark"];
    //    [self.rootScrollView addSubview:titleImg];
    
    line_lab=[[UILabel alloc] initWithFrame:CGRectMake(titleImgLeft,viewHeight-2, btnTextSize.width,2)];
    line_lab.backgroundColor = kSystemColor;
    [self.rootScrollView addSubview:line_lab];
    
    //    CALayer *line=[[CALayer alloc] init];
    //    line.frame = CGRectMake(0, viewHeight-0.5, lineHeight, 0.5);
    //    line.backgroundColor=kLineColor.CGColor;
    //    [self.layer addSublayer:line];
}

-(void)changeViewWithButton:(UIButton *)btn{
    titleImg.hidden = YES;
    NSUInteger index=btn.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        btn.selected=YES;
        selectBtn=btn;
        line_lab.frame=CGRectMake(index * btnWidth +  titleImgLeft,viewHeight-2, btnTextSize.width, 2);
        if (index>2&&index<num-2) {
            CGPoint position=CGPointMake((index-2)*btnWidth, 0);
            [self.rootScrollView setContentOffset:position animated:YES];
        }else if (index==1||index==2){
            [self.rootScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }else if (index==num-2){
            CGFloat scrollw=self.menusArray.count*btnWidth;
            if (scrollw>kScreenWidth) {
                [self.rootScrollView setContentOffset:CGPointMake(scrollw-kScreenWidth, 0) animated:YES];
            }
        }
    }];
    
    titleImg.frame =CGRectMake(index * btnWidth + titleImgLeft, (viewHeight -15)/2, 15, 15);
    titleImg.hidden = NO;
    
    if ([_delegate respondsToSelector:@selector(foodMenuView:Index:)]) {
        [_delegate foodMenuView:self Index:index];
    }
}
@end
