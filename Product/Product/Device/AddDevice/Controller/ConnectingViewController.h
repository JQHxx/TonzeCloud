//
//  ConnectingViewController.h
//  Product
//
//  Created by Xlink on 15/12/17.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol ConnectingViewControllerDelegate <NSObject>

-(void)connectingViewControllerSubDeviceFailedWithCode:(NSInteger)code;

-(void)connectingViewControllerNetworkFailed;

-(void)connectingViewControllerScanDeviceFailed;

@end


@interface ConnectingViewController : BaseViewController

@property (nonatomic,weak)id<ConnectingViewControllerDelegate>delegate;

@property(nonatomic,strong)NSString *wifiName;
@property(nonatomic,strong)NSString *pwd;
@end
