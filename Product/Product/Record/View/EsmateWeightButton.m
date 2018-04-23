//
//  EsmateWeightButton.m
//  Product
//
//  Created by 肖栋 on 17/5/18.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "EsmateWeightButton.h"

@implementation EsmateWeightButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((width-25)/2,0 , 25, 25)];
        img.image = [UIImage imageNamed:@"ic_pub_scale"];
        [self addSubview:img];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, img.bottom, width, 15)];
        titleLabel.text = @"估算重量";
        titleLabel.font = [UIFont systemFontOfSize:10];
        titleLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
    }
    return self;
}

@end
