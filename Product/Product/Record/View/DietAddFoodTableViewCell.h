//
//  DietAddFoodTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/4/21.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodAddModel.h"

@interface DietAddFoodTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *foodImageView;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodColaryLabel;

- (void)cellFoodDisplayWith:(FoodAddModel *)foodModel;

@end
