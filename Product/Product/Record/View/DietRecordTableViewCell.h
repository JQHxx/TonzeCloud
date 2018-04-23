//
//  DietRecordTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/4/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DietRecordTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *foodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodsWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodEnergyLabel;


-(void)cellDisplayWithFoodDict:(NSDictionary *)foodDict;
@end
