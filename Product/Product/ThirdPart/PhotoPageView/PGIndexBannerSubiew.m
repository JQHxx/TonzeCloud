//
//  PGIndexBannerSubiew.m
//  NewPagedFlowViewDemo
//
//  Created by Mars on 16/6/18.
//  Copyright © 2016年 Mars. All rights reserved.
//  Designed By PageGuo,
//  QQ:799573715
//  github:https://github.com/PageGuo/NewPagedFlowView

#import "PGIndexBannerSubiew.h"

@implementation PGIndexBannerSubiew

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        [self addSubview:self.mainImageView];
        [self addSubview:self.coverView];
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.contentLab];
    }
    return self;
}
- (UIImageView *)mainImageView {
    
    if (_mainImageView == nil) {
        _mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth/3, kScreenWidth/3)];
        _mainImageView.userInteractionEnabled = YES;
        _mainImageView.layer.masksToBounds = YES;
        _mainImageView.layer.cornerRadius = 5;
    }

    return _mainImageView;
}

- (UIView *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIView alloc] initWithFrame:self.bounds];
        _coverView.backgroundColor = [UIColor clearColor];
    }
    return _coverView;
}
- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(12 * kScreenWidth/375, (234/2 - 28 - 13) * kScreenWidth/375 , (368/2 - 24)* kScreenWidth/375, 54/2)];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 14;
    }
    return _contentView;
}
- (UILabel *)contentLab{
    if (!_contentLab) {
        _contentLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.contentView.width, 54/2)];
        _contentLab.textAlignment = NSTextAlignmentCenter;
        _contentLab.textColor = UIColorFromRGB(0x313131);
        _contentLab.font = [UIFont systemFontOfSize:13];
    }
    return _contentLab;
}

@end
