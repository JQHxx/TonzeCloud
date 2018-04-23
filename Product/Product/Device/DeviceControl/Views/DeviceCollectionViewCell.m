//
//  DeviceCollectionViewCell.m
//  Product
//
//  Created by vision on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DeviceCollectionViewCell.h"

@interface DeviceCollectionViewCell ()

@end

@implementation DeviceCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        self.layer.doubleSided = NO;
        
        _deviceImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,40, 80,80)];
        
        [self.contentView addSubview:_deviceImageView];
    }
    return self;
}




@end
