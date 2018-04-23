//
//  ShopNavView.h
//  Product
//
//  Created by 肖栋 on 17/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^NavBtnClickBlock)(NSInteger tag);

@interface ShopNavView : UIView

@property (nonatomic ,strong)UIButton *rightBtn;

@property (nonatomic, copy) NavBtnClickBlock navBtnClickBlock;
@end
