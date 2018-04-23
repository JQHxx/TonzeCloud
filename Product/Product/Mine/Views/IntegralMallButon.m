//
//  IntegralMallButon.m
//  Product
//
//  Created by 肖栋 on 17/5/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "IntegralMallButon.h"
@interface IntegralMallButon ()

@end
@implementation IntegralMallButon

- (instancetype)initWithFrame:(CGRect)frame imagename:(NSString *)image{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake((width-40)/2, 10, 40, 40)];
        imageview.backgroundColor = [UIColor bgColor_Gray];
        imageview.image = [UIImage imageNamed:image];
        [self addSubview:imageview];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(15, imageview.bottom+5, width-30, 20)];
        _label.textColor = [UIColor grayColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:15];
        [self addSubview:_label];
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    _label.text = _title;
}
@end
