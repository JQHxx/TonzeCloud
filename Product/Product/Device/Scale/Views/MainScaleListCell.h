//
//  MainScaleListCell.h
//  Product
//
//  Created by Feng on 16/2/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainScaleListCell : UITableViewCell

@property(strong,nonatomic)IBOutlet UIImageView *deviceTypeIV;

@property(strong,nonatomic)IBOutlet UILabel *deviceNameLbl;

@property(strong,nonatomic)IBOutlet UILabel *deviceUUIDLbl;

@property IBOutlet UILabel *lineLbl;

@end
