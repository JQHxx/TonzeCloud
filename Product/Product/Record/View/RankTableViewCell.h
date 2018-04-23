//
//  RankTableViewCell.h
//  Product
//
//  Created by vision on 17/5/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StepRankModel.h"


@interface RankTableViewCell : UITableViewCell

@property (nonatomic,strong)UIImageView *imgView;

-(void)rankCellDisplayWithModel:(StepRankModel *)model;

@end
