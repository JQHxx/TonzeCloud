//
//  KettleTemCell.h
//  Product
//
//  Created by 肖栋 on 16/12/14.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KettleTemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *teaImgView;

@property (weak, nonatomic) IBOutlet UILabel *temName;

@property (weak, nonatomic) IBOutlet UILabel *tempLB;
@end
