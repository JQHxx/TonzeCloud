//
//  DietHistoryTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/4/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodRecordModel.h"

@interface DietHistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *dietImageView;
@property (weak, nonatomic) IBOutlet UILabel *dietTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloryLabel;

-(void)cellDisplayWithModel:(FoodRecordModel *)diet;

@end
