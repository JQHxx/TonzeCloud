//
//  DaysRice.m
//  Product
//
//  Created by 肖栋 on 17/4/18.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DaysRice.h"
@interface DaysRice(){
    UILabel *numLabel;
}
@end
@implementation DaysRice

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor=[UIColor whiteColor];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, kScreenWidth/2-16, 20)];
        textLabel.font = [UIFont systemFontOfSize:15];
        textLabel.text=title;
        [self addSubview:textLabel];
        
        numLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, textLabel.bottom+10, kScreenWidth/2-16, 20)];
        numLabel.font = [UIFont systemFontOfSize:14];
        numLabel.textColor = [UIColor grayColor];
        [self addSubview:numLabel];
    }
    return self;
}

-(void)setRiceValue:(NSInteger)riceValue{
    _riceValue=riceValue;
    numLabel.text =[NSString stringWithFormat:@"%ld杯（≈%ld克)",riceValue,riceValue*150];
}


@end
