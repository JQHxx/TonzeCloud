//
//  LogisticsDetailsCell.h
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrajectoryModel.h"

@interface LogisticsDetailsCell : UITableViewCell

///
@property (nonatomic ,strong)  UIImageView *statusImg;
///
@property (nonatomic ,strong)  UILabel *lens;
///
@property (nonatomic ,strong)  UILabel  *orderInfoLab;
///
@property (nonatomic ,strong)  UILabel  *timeLab;

- (void)cellWithTrajectoryModel:(TrajectoryModel *)model;

+ (CGFloat)cellHeightForRowAtIndexPath:(NSString *)str;


@end
