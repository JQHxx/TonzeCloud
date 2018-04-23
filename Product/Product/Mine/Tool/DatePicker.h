//
//  DatePicker.h
//  Product
//
//  Created by Feng on 16/4/22.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerViewDelegate <NSObject>

-(void)datePickerViewDidClickOK:(NSString *)DateStr;

@end

@interface DatePicker : UIViewController{
    
    IBOutlet UIButton *cancelBtn,*okBtn;
    IBOutlet UIDatePicker *datePicker;
    
}

@property(nonatomic, unsafe_unretained) id <DatePickerViewDelegate> delegate;

-(IBAction)okBtnClick:(id)sender;
-(IBAction)cancleBtnClick:(id)sender;


-(void)showInView:(UIView*)view;


@end
