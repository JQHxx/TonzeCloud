//
//  SmartSettingViewController.h
//  Product
//
//  Created by Feng on 16/3/19.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceModel.h"

@interface SmartSettingViewController : BaseViewController{
    IBOutlet UIButton *temBtn;
    IBOutlet UILabel *tipsLbl,*temLbl,*temValueLbl,*chlorineLbl;
    IBOutlet UISwitch *chlorineSwith;

}


-(IBAction)selectTem:(id)sender;

-(IBAction)selectChlorine:(id)sender;

@property(nonatomic,strong)DeviceModel *model;

@end
