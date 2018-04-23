//
//  PayWayTool.m
//  Product
//
//  Created by vision on 17/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "PayWayTool.h"

@interface PayWayTool (){
    UIImageView   *iconImageView;
    UILabel       *titleLabel;
    UIImageView   *selImageView;
}

@end

@implementation PayWayTool

-(instancetype)initWithFrame:(CGRect)frame iconName:(NSString *)icon title:(NSString *)titleText{
    self=[super initWithFrame:frame];
    if (self) {
        iconImageView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 30, 30)];
        iconImageView.image=[UIImage imageNamed:icon];
        [self addSubview:iconImageView];
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right+10, 10, 100, 30)];
        titleLabel.font=[UIFont systemFontOfSize:15];
        titleLabel.textColor=[UIColor blackColor];
        titleLabel.text=titleText;
        [self addSubview:titleLabel];
        
        selImageView=[[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-40, 15, 20, 20)];
        [self addSubview:selImageView];
    }
    return self;
}

-(void)setIsWaySelected:(BOOL)isWaySelected{
    selImageView.image=isWaySelected?[UIImage imageNamed:@"pd_ic_pick_on"]:[UIImage imageNamed:@"pd_ic_pick_un"];
}


@end
