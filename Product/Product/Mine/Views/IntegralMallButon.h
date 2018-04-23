//
//  IntegralMallButon.h
//  Product
//
//  Created by 肖栋 on 17/5/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntegralMallButon : UIButton

@property(nonatomic ,copy)NSString *title;

///
@property (nonatomic ,strong)  UILabel *label;;

- (instancetype)initWithFrame:(CGRect)frame imagename:(NSString *)image;

@end
