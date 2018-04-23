//
//  TCShopHotWordView.h
//  Product
//
//  Created by 肖栋 on 18/1/16.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCShopHotWordView : UIScrollView

@property (nonatomic ,strong)NSMutableArray *shopHotWordArr;

@property (nonatomic, strong) void (^shopHotSearchClick)   (NSString *title); //点击关键词

@end
