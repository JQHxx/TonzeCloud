//
//  ShopDetailToolBar.h
//  Product
//
//  Created by 肖栋 on 17/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ShopDetailToolBarDelegate <NSObject>


- (void)shopDetailToolBarSelete:(NSInteger)index;

@end
@interface ShopDetailToolBar : UIView

@property (nonatomic,weak)id<ShopDetailToolBarDelegate>shopToolBaDelegate;

@end
