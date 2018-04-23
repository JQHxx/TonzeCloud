//
//  DeviceFunctionViewController.h
//  Product
//
//  Created by Xlink on 16/1/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"
#import "BaseViewController.h"

@interface DeviceFunctionViewController : BaseViewController{
    IBOutlet UIButton *cloudMenuBtn,*preferenceBtn;
    IBOutlet UILabel *stateLbl,*workTypeLbl;
    IBOutlet UIImageView *deviceIV,*stateIV;
    IBOutlet UIScrollView *functionScrollView;
    
    __weak IBOutlet UIImageView *topbgImage;

}


-(IBAction)cloudMenuSelected:(id)sender;

-(IBAction)preferenceSelected:(id)sender;

@property(nonatomic,strong)DeviceModel *model;


@end
