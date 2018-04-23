//
//  FoodDingButton.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodDingButton : UIButton
-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

@property (nonatomic, copy )NSString *valueString;
@end
