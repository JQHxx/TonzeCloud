//
//  DeviceMenuTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/5/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceMenuTableViewCell : UITableViewCell

@property(strong,nonatomic)IBOutlet UIImageView *deviceTypeIV;

@property(strong,nonatomic)IBOutlet UILabel *deviceNameLbl;

@property(strong,nonatomic)IBOutlet UILabel *deviceStateLbl;

@property(strong,nonatomic)IBOutlet UIImageView *deviceStateIV;

@property(strong,nonatomic)IBOutlet UILabel *deviceProgressLbl;
@end
