
//
//  TJYRecommendButton.m
//  Product
//
//  Created by zhuqinlu on 2017/5/16.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYRecommendButton.h"

@implementation TJYRecommendButton

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self=[super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit{
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self setTitleColor:UIColorHex(0xd2d2d2) forState:UIControlStateNormal];
    [self setTitleColor:kSystemColor forState:UIControlStateSelected];
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat titleX = 0;
    CGFloat titleY = contentRect.size.height *0.1;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - titleY;
    return CGRectMake(titleX, titleY, titleW, titleH);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageX = CGRectGetWidth(contentRect)*0.3;
    CGFloat imageW = CGRectGetWidth(contentRect)* 0.4;
    CGFloat imageH = contentRect.size.height * 0.4;
    return CGRectMake(imageX, 0, imageW, imageH);
}

@end
