//
//  HerderClassifyButton.m
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "HerderClassifyButton.h"

@implementation HerderClassifyButton


-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self commonInit];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)commonInit{
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    [self setTitleColor:UIColorHex(0x666666) forState:UIControlStateNormal];
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat titleX = 0;
    CGFloat titleY = contentRect.size.height * 0.5;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - titleY;
    return CGRectMake(titleX, titleY, titleW, titleH);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageX = CGRectGetWidth(contentRect)/4;
    CGFloat imageY = CGRectGetHeight(contentRect)/6;
    CGFloat imageW = CGRectGetWidth(contentRect)/2;
    CGFloat imageH = contentRect.size.height * 0.4;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

@end
