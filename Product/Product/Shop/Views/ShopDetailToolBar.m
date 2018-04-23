//
//  ShopDetailToolBar.m
//  Product
//
//  Created by 肖栋 on 17/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopDetailToolBar.h"

@implementation ShopDetailToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [self addSubview:lineLabel];
        
        UIButton *serviceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0.5, width/10*2, height)];
        [serviceButton setTitle:@"客服" forState:UIControlStateNormal];
        [serviceButton setTitleColor:[UIColor colorWithHexString:@"0x959595"] forState:UIControlStateNormal];
        serviceButton.titleLabel.font = [UIFont systemFontOfSize:12];
        serviceButton.backgroundColor = [UIColor whiteColor];
        serviceButton.tag = 100;
        [serviceButton setImage:[UIImage imageNamed:@"pd_ic_detail_service"] forState:UIControlStateNormal];
        [serviceButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:2];
        [serviceButton addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:serviceButton];
        
        UIButton *shopButton = [[UIButton alloc] initWithFrame:CGRectMake(width/10*2, 0.5, width/10*2, height)];
        [shopButton setTitle:@"购物车" forState:UIControlStateNormal];
        [shopButton setTitleColor:[UIColor colorWithHexString:@"0x959595"] forState:UIControlStateNormal];
        shopButton.titleLabel.font = [UIFont systemFontOfSize:12];
        shopButton.backgroundColor = [UIColor whiteColor];
        shopButton.tag = 101;
        [shopButton setImage:[UIImage imageNamed:@"pd_ic_detail_car"] forState:UIControlStateNormal];
        [shopButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:2];
        [shopButton addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shopButton];
        
        UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(width/10*4, 0, width/10*3, height)];
        [addButton setTitle:@"加入购物车" forState:UIControlStateNormal];
        [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addButton.titleLabel.font = [UIFont systemFontOfSize:15];
        addButton.backgroundColor = [UIColor colorWithHexString:@"0x4da6fe"];
        addButton.tag = 102;
        [addButton addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addButton];
        
        UIButton *payButton = [[UIButton alloc] initWithFrame:CGRectMake(width/10*7, 0, width/10*3, height)];
        [payButton setTitle:@"立即购买" forState:UIControlStateNormal];
        [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        payButton.titleLabel.font = [UIFont systemFontOfSize:15];
        payButton.backgroundColor = [UIColor colorWithHexString:@"0xf39800"];
        payButton.tag = 103;
        [payButton addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:payButton];
        
    }
    return self;
}
- (void)button:(UIButton *)button{

    if ([self.shopToolBaDelegate respondsToSelector:@selector(shopDetailToolBarSelete:)]) {
        [self.shopToolBaDelegate shopDetailToolBarSelete:button.tag-100];
    }

}
@end
