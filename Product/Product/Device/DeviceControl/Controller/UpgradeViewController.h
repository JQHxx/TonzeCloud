//
//  UpgradeViewController.h
//  socket
//
//  Created by xtmac02 on 15/11/18.
//  Copyright © 2015年 jz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceEntity.h"
#import "BaseViewController.h"
@interface UpgradeViewController : BaseViewController


/**当前设备*/
@property(nonatomic,strong)DeviceEntity *device;

@property NSInteger deviceType;

@end
