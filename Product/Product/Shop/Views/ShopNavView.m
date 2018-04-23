//
//  ShopNavView.m
//  Product
//
//  Created by 肖栋 on 17/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopNavView.h"

@implementation ShopNavView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = kSystemColor;
        
        UIImageView *headImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-80,  kStatusBarHeight + (64 - 24 - kStatusBarHeight)/2, 24, 24)];
        headImg.userInteractionEnabled = YES;
        headImg.image = [UIImage imageNamed:@"top_ic_car"];
        [self addSubview:headImg];
        UITapGestureRecognizer *headImgTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(haadTapAction)];
        [headImg addGestureRecognizer:headImgTap];
        
        _rightBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-45, kStatusBarHeight + 2, 40, 40)];
        [_rightBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_rightBtn setImage:[UIImage drawImageWithName:@"更多" size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
        _rightBtn.tag = 1001;
        [self addSubview:_rightBtn];
    }
    return self;
}
- (void)buttonAction:(UIButton *)sender{
    if (self.navBtnClickBlock) {
        self.navBtnClickBlock(sender.tag);
    }
}
- (void)haadTapAction{
    if (self.navBtnClickBlock) {
        self.navBtnClickBlock(1000);
    }
}

@end
