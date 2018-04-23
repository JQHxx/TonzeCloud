//
//  DeviceViewController.h
//  Product
//
//  Created by Xlink on 15/12/1.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class BLEDeviceModel;

@interface DeviceViewController : BaseViewController{
    IBOutlet UITableView *DeviceTB;
    IBOutlet UIScrollView *rootScrollView;
}

@end
