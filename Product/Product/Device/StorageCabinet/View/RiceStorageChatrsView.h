//
//  RiceStorageChatrsView.h
//  Product
//
//  Created by 肖栋 on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RiceStorageChatrsView : UIView

//数据显示
@property(nonatomic ,strong)NSArray *dataArray;
// 日期显示
@property(nonatomic ,strong) NSArray *dayArray;

@property (nonatomic, assign) NSUInteger  maxy;

@property (nonatomic, copy)NSString *titleText;

@end
