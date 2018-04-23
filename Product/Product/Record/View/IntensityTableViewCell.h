//
//  IntensityTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaborModel.h"
@interface IntensityTableViewCell : UITableViewCell
-(void)cellDisplayWithLabor:(LaborModel *)model;

+(CGFloat)getCellHeightWithLabor:(LaborModel *)model;
@end
