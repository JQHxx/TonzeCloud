//
//  UpgradeSuccessViewController.h
//  socket
//
//  Created by xtmac02 on 15/11/18.
//  Copyright © 2015年 jz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class DeviceEntity;

@interface UpgradeSuccessViewController : BaseViewController

@property NSInteger deviceType;

/**当前设备*/
@property(nonatomic,strong)DeviceEntity *device;

@end
