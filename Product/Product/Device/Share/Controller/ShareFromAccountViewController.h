//
//  ShareFromAccountViewController.h
//  Product
//
//  Created by Feng on 16/2/4.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"
#import "ShowProgressBtn.h"
#import "BaseViewController.h"

@interface ShareFromAccountViewController : BaseViewController{


    IBOutlet UILabel *tipsLbl;
    IBOutlet ShowProgressBtn *shareBtn;
    IBOutlet UITextField *accountTF;
}


-(IBAction)shareDevice:(id)sender;

@property(nonatomic,strong)DeviceModel *model;

@end
