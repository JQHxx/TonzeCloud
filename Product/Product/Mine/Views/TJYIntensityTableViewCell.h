//
//  TJYIntensityTableViewCell.h
//  Product
//
//  Created by vision on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYLaborModel.h"

@interface TJYIntensityTableViewCell : UITableViewCell

-(void)cellDisplayWithLabor:(TJYLaborModel *)model;

+(CGFloat)getCellHeightWithLabor:(TJYLaborModel *)model;

@end
