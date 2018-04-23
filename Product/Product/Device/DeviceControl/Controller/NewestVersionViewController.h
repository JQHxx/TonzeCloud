//
//  NewestVersionViewController.h
//  socket
//
//  Created by xtmac02 on 15/11/18.
//  Copyright © 2015年 jz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceEntity.h"
#import "BaseViewController.h"

@interface NewestVersionViewController : BaseViewController

@property(strong,nonatomic)DeviceEntity *device;
@property (strong, nonatomic) NSDictionary *dict;

@property NSInteger deviceType;

@end
