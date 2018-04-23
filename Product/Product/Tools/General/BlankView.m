//
//  BlankView.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BlankView.h"

@implementation BlankView

-(instancetype)initWithFrame:(CGRect)frame img:(NSString *)imgName text:(NSString *)text{
    self=[super initWithFrame:frame];
    if (self) {
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2,40, 120, 120*183/212)];
        imgView.image=[UIImage imageNamed:imgName];
        [self addSubview:imgView];
        
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, imgView.bottom+10, kScreenWidth-40, 20)];
        lab.textAlignment=NSTextAlignmentCenter;
        lab.text=text;
        lab.font=[UIFont systemFontOfSize:14.0f];
        lab.textColor=[UIColor lightGrayColor];
        [self addSubview:lab];
        
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame Searchimg:(NSString *)imgName text:(NSString *)text{
    self=[super initWithFrame:frame];
    if (self) {
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-60)/2,40, 60, 60)];
        imgView.image=[UIImage imageNamed:imgName];
        [self addSubview:imgView];
        
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, imgView.bottom+10, kScreenWidth-40, 20)];
        lab.textAlignment=NSTextAlignmentCenter;
        lab.text=text;
        lab.font=[UIFont systemFontOfSize:14.0f];
        lab.textColor=[UIColor lightGrayColor];
        [self addSubview:lab];
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame unOrderImg:(NSString *)imgName tipText:(NSString *)tipText  chooseText:(NSString *)chooseText{
    self=[super initWithFrame:frame];
    if (self) {
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth- 236/2)/2,40, 236/2, 124/2)];
        imgView.image=[UIImage imageNamed:imgName];
        [self addSubview:imgView];
        
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, imgView.bottom+ 20, kScreenWidth-40, 20)];
        lab.textAlignment=NSTextAlignmentCenter;
        lab.text= tipText;
        lab.font=[UIFont systemFontOfSize:14.0f];
        lab.textColor=[UIColor lightGrayColor];
        [self addSubview:lab];
        
        UILabel *chooseLab=[[UILabel alloc] initWithFrame:CGRectMake(20, lab.bottom+ 10, kScreenWidth-40, 20)];
        chooseLab.textAlignment=NSTextAlignmentCenter;
        chooseLab.text= chooseText;
        chooseLab.font=[UIFont systemFontOfSize:14.0f];
        chooseLab.textColor=[UIColor lightGrayColor];
        [self addSubview:chooseLab];
    }
    return self;
}

-(instancetype)initWithShopFrame:(CGRect)frame Searchimg:(NSString *)imgName title:(NSString *)title text:(NSString *)text{
    self=[super initWithFrame:frame];
    if (self) {
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2,40, 80, 80)];
        imgView.image=[UIImage imageNamed:imgName];
        [self addSubview:imgView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, imgView.bottom+20, kScreenWidth-40, 20)];
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = title;
        titleLabel.textColor = [UIColor grayColor];
        [self addSubview:titleLabel];
        
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, titleLabel.bottom+10, kScreenWidth-40, 20)];
        lab.textAlignment=NSTextAlignmentCenter;
        lab.text=text;
        lab.font=[UIFont systemFontOfSize:14.0f];
        lab.textColor=[UIColor lightGrayColor];
        [self addSubview:lab];
    }
    return self;
}
@end
