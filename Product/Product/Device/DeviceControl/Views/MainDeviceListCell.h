//
//  MainDeviceListCell.h
//  Product
//
//  Created by Xlink on 16/1/19.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainDeviceListCell : UITableViewCell

@property(strong,nonatomic)IBOutlet UIImageView *deviceTypeIV;

@property(strong,nonatomic)IBOutlet UILabel *deviceNameLbl;

@property(strong,nonatomic)IBOutlet UILabel *deviceStateLbl;

@property(strong,nonatomic)IBOutlet UIImageView *deviceStateIV;

@property IBOutlet UILabel *lineLbl;

@property(strong,nonatomic)IBOutlet UILabel *deviceProgressLbl;


@end
