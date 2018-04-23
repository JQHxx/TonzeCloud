//
//  AddSceneButton.m
//  Product
//
//  Created by 肖栋 on 17/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddSceneButton.h"

@implementation AddSceneButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(width-130, 5, 120, 20)];
        textLabel.text = @"请设置场景名";
        textLabel.textAlignment = NSTextAlignmentRight;
        textLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:textLabel];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(textLabel.right, 5, 20, 20)];
        imgView.image =[UIImage imageNamed:@"箭头_列表"];
        [self addSubview:imgView];
    }
    return self;
}

@end
