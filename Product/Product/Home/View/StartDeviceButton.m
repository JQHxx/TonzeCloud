//
//  StartDeviceButton.m
//  Product
//
//  Created by 肖栋 on 17/5/12.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StartDeviceButton.h"

@implementation StartDeviceButton

- (instancetype)initWithFrame:(CGRect)frame dict:(NSString *)image{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;

        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((width-40)/2, (height-40)/2, 40, 40)];
        img.image = [UIImage imageNamed:image];
        [self addSubview:img];
    }
    return self;
}

@end
