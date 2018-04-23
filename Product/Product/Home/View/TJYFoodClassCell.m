//
//  FoodClassCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYFoodClassCell.h"

@implementation TJYFoodClassCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.foodImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, CGRectGetWidth(self.frame)-10, CGRectGetWidth(self.frame)-10)];
        self.foodImage.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:self.foodImage];
        
        self.classLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(self.foodImage.frame), CGRectGetWidth(self.frame)-10, 20)];
        self.classLabel.backgroundColor = [UIColor brownColor];
        self.classLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.classLabel];
    }
    return self;
}

@end
