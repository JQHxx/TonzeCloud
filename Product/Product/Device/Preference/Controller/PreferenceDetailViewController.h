//
//  PreferenceDetailViewController.h
//  Product
//
//  Created by Xlink on 16/1/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"
#import "BaseViewController.h"

@interface PreferenceDetailViewController : BaseViewController{
    IBOutlet UIButton *completeBtn;
    
    IBOutlet UILabel *typeTitleLbl,*typeLbl,*timeLbl;
    
    IBOutlet UIPickerView *timePicker;
    
    IBOutlet UIView *timePickerView;
    
}

@property(nonatomic,strong)DeviceModel *model;

@property NSInteger selectedType;


-(IBAction)completeSetting:(id)sender;


@end
