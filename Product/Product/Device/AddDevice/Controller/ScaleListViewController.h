//
//  ScaleListViewController.h
//  Product
//
//  Created by Xlink on 15/12/15.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DeviceModel.h"

@interface ScaleListViewController : BaseViewController{
    IBOutlet UITableView *listTBV;
    
}

@property (nonatomic, assign) DeviceType deviceType;

-(void)didDiscoverDeivce:(NSDictionary *)deviceDic;

@end
