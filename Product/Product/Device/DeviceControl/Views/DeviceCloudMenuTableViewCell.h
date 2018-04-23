//
//  DeviceCloudMenuTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/5/10.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "deviceCloudMenuModel.h"

@interface DeviceCloudMenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cloudMenuImg;
@property (weak, nonatomic) IBOutlet UILabel *cloudMenuName;
@property (weak, nonatomic) IBOutlet UILabel *cloudMenuDetail;
@property (weak, nonatomic) IBOutlet UIImageView *eyeCloudMenu;
@property (weak, nonatomic) IBOutlet UIImageView *seletedCloudMenu;
@property (weak, nonatomic) IBOutlet UILabel *eyeNumber;
@property (weak, nonatomic) IBOutlet UILabel *seletedNumber;
@property (weak, nonatomic) IBOutlet UIImageView *isYunImage;
-(void)cellDisplayWithModel:(deviceCloudMenuModel *)model;

@end
