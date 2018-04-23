//
//  AddRemindViewController.h
//  Product
//
//  Created by Feng on 16/3/22.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceModel.h"

@interface AddRemindViewController : BaseViewController{

    IBOutlet UIButton *completeBtn,*timeBtn,*valueBtn;
    
    IBOutlet UILabel *timeLbl,*valueLbl,*timeValueLbl,*valueValueLbl;
    
    
}



-(IBAction)selectTime:(id)sender;

-(IBAction)selectValue:(id)sender;

@property(nonatomic,strong)DeviceModel *model;

@property(nonatomic,strong)NSDictionary *remindDic;

@property (strong, nonatomic) NSMutableArray *remindDics;//已经创建的饮水计划，创建传入所有，编辑传入除自己


@property BOOL isUpdateRemind;


@end
