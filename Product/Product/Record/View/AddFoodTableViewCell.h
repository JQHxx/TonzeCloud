//
//  AddFoodTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodAddModel.h"

@protocol FoodTableViewCellDelegate <NSObject>

@optional
-(void)foodTableViewCellDeleteFood:(FoodAddModel *)food;

@end
@interface AddFoodTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *foodImageView;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodColaryLabel;
@property (weak, nonatomic) IBOutlet UIButton *choose;

@property (nonatomic,weak)id<FoodTableViewCellDelegate>cellDelegate;

@property (nonatomic,assign)NSInteger cellType;

-(void)cellDisplayWithFood:(FoodAddModel *)model;

@end
