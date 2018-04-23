//
//  SceneOptionButton.m
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SceneOptionButton.h"

@implementation SceneOptionButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _iconImg = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth/2 - 186/2)/2,50 , 186/2, 186/2)];
        [self addSubview:_iconImg];
        
        _titileLab = [[UILabel alloc] initWithFrame:CGRectMake(0, _iconImg.bottom + 10, self.width, 20)];
        _titileLab.font = [UIFont systemFontOfSize:15];
        _titileLab.textAlignment = NSTextAlignmentCenter;
        _titileLab.textColor = UIColorHex(0x6a6a6a);
        [self addSubview:_titileLab];
    }
    return self;
}

@end
