//
//  FoodSelectView.h
//  Product
//
//  Created by 肖栋 on 17/4/24.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodAddModel.h"

@protocol FoodSelectViewDelegate <NSObject>

//已选食物视图关闭
-(void)foodSelectViewDismissAction;
//删除食物
-(void)foodSelectViewDeleteFood:(FoodAddModel *)food;
//选择食物
-(void)foodSelectViewDidSelectFood:(FoodAddModel *)food;

@end

@interface FoodSelectView : UIView

@property (nonatomic,weak)id<FoodSelectViewDelegate>delegate;

@property (nonatomic,strong)UITableView     *tableView;
@property (nonatomic,strong)NSMutableArray  *foodSelectArray;

@end
