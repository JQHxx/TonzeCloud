//
//  SportTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportTableModel.h"

@interface SportTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;  //运动
@property (weak, nonatomic) IBOutlet UILabel *sportType;    //运动类型
@property (weak, nonatomic) IBOutlet UILabel *consumeLab;   //运动消耗
@property (weak, nonatomic) IBOutlet UILabel *sportWorkRank;

- (void)cellSportDisplayWith:(SportTableModel *)Model;

@end
