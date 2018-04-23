//
//  PreferenceViewController.h
//  Product
//
//  Created by Xlink on 16/1/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"
#import "PreferenceModel.h"
#import "BaseViewController.h"

@interface PreferenceViewController : BaseViewController{
    IBOutlet UITableView *mainTB;
}

@property(nonatomic,strong)DeviceModel *model;


-(void)updateUI:(PreferenceModel *)pModel;
@end
