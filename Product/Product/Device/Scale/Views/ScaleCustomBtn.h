//
//  ScaleCustomBtn.h
//  Product
//
//  Created by vision on 17/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScaleCustomBtn : UIButton


@property (nonatomic,strong)NSDictionary *valueDict;

-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict;



@end
