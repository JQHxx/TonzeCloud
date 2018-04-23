//
//  DrinkRemindViewController.h
//  Product
//
//  Created by Feng on 16/3/21.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceModel.h"

@interface DrinkRemindViewController : BaseViewController{
    IBOutlet UIButton *drinkBtn,*editRemindBtn,*addRemindBtn;
    
    IBOutlet UISwitch *DistributeSwitch;
    
    IBOutlet UITableView  *remindTB;
    
    IBOutlet UILabel *drinkValueLbl;
    
    
    
}

-(void)updateUIafterAddRemind;


-(IBAction)smartDistribute:(id)sender;

-(IBAction)setTotalValue:(id)sender;

-(IBAction)editRemind:(id)sender;

-(IBAction)addRemind:(id)sender;

@property(nonatomic,strong)DeviceModel *model;

@end
