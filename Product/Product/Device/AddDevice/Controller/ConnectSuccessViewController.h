//
//  ConnectSuccessViewController.h
//  Product
//
//  Created by Xlink on 15/12/17.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DeviceEntity.h"

@interface ConnectSuccessViewController : BaseViewController

@property (strong,nonatomic ) DeviceEntity *device;
@property (nonatomic,assign ) BOOL         isScanQR;
@property (nonatomic,  copy ) NSString    *productID;


@end
