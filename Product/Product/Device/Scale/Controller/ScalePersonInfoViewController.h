//
//  ScalePersonInfoViewController.h
//  Product
//
//  Created by Feng on 16/2/27.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ScalePersonInfoViewController : BaseViewController{
    IBOutlet UILabel *sexLbl,*sexValueLbl,*heightLbl,*heightValueLbl,*ageLbl,*ageValueLbl;
    IBOutlet UIButton *SexBtn,*heightBtn,*ageBtn;
    IBOutlet UIButton *completeBtn;
}


-(IBAction)selectSex:(id)sender;

-(IBAction)selectHeight:(id)sender;

-(IBAction)selectAge:(id)sender;


@end
