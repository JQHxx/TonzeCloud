//
//  RecommendedSceneAfterView.m
//  Product
//
//  Created by zhuqinlu on 2017/6/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecommendedSceneAfterView.h"

@implementation RecommendedSceneAfterView

- (instancetype)initWithFrame:(CGRect)frame{
    if ( self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        
        _cookingMethodLab  = [[UILabel alloc]initWithFrame:CGRectMake(20, 11, 200, 15)];
        _cookingMethodLab.textColor = UIColorHex(0x959595);
        _cookingMethodLab.font = kFontSize(13);
        [self addSubview:_cookingMethodLab];
        
        UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, kScreenWidth - 80, 0.5)];
        len.backgroundColor = UIColorHex(0xeeeeee);
        [self addSubview:len];
        
        _deviceImg = [[UIImageView alloc]initWithFrame:CGRectMake(15/2, len.bottom + 8 , 130/2, 130/2)];
        [self addSubview:_deviceImg];
        
        _deviceNameLab = [[UILabel alloc]initWithFrame:CGRectMake(_deviceImg.right + 15/2, len.bottom + (162/2 - 20)/2, 150, 20)];
        _deviceNameLab.textColor = UIColorHex(0x313131);
        _deviceNameLab.font = kFontSize(15);
        [self addSubview:_deviceNameLab];
    }
    return self;
}

@end
