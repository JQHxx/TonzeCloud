//
//  OrderButton.m
//  Weekens
//
//  Created by fei on 15/4/16.
//  Copyright (c) 2015年 ___YKSKJ.COM___. All rights reserved.
//

#import "OrderButton.h"

#define kOrderBtnScale  0.5

@implementation OrderButton

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self){
        [self setTitleColor:kRGBColor(54, 54, 54) forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:13]];
        self.titleLabel.textAlignment=NSTextAlignmentCenter;
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    frame.size=CGSizeMake(kOrderButtonWidth, kOrderButtonW+20);
    [super setFrame:frame];
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake((kOrderButtonWidth-kOrderButtonW)/2, 0, kOrderButtonW, kOrderButtonW);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake((kOrderButtonWidth-40)/2, kOrderButtonW*185/223, 40, 25);
}

@end
