//
//  AddDeviceButton.m
//  Product
//
//  Created by 肖栋 on 17/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddDeviceButton.h"

@implementation AddDeviceButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 20, 20)];
        imgView.image = [UIImage imageNamed:@"ic_cha"];
        [self addSubview:imgView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right, 5, 100, 20)];
        textLabel.text = @"添加设备";
        textLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:textLabel];
    }

    return self;
}
@end
