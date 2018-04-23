//
//  DrinkPlanViewController.h
//  Product
//
//  Created by Feng on 16/3/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceModel.h"

@interface DrinkPlanViewController : BaseViewController{

    IBOutlet UILabel *totalLbl,*drankLbl,*recordLbl,*graphLbl;
    
    IBOutlet UIButton *drinkBtn,*graphBtn,*settingBtn;
    
    IBOutlet UITableView *recordTB;
    
    IBOutlet UIImageView *drinkIV;
    
    
}


-(IBAction)addRecord:(id)sender;



-(void)updateDrankView;

@property(nonatomic,strong)DeviceModel *model;


@end
