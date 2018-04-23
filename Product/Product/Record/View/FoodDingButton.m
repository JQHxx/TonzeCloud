//
//  FoodDingButton.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "FoodDingButton.h"
@interface FoodDingButton (){
    UILabel   *valueLabel;
}

@end

@implementation FoodDingButton

-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth/3-10, 30)];
        titleLabel.font=[UIFont systemFontOfSize:14.0f];
        titleLabel.textColor=[UIColor blackColor];
        titleLabel.text =title;
        [self addSubview:titleLabel];
        
        valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/3, 10, 2*kScreenWidth/3-30, 30)];
        valueLabel.font = [UIFont systemFontOfSize:14];
        valueLabel.textColor = [UIColor grayColor];
        valueLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:valueLabel];
        
        UIImageView *birthImage = [[UIImageView alloc] initWithFrame:CGRectMake(valueLabel.right+5, 15, 20, 20)];
        birthImage.image = [UIImage imageNamed:@"箭头_列表"];
        [self addSubview:birthImage];
    }
    return self;
}


-(void)setValueString:(NSString *)valueString{
    _valueString=valueString;
    valueLabel.text=valueString;
}


@end
