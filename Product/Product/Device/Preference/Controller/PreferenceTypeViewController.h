//
//  PreferenceTypeViewController.h
//  Product
//
//  Created by Xlink on 16/1/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"
#import "BaseViewController.h"


@interface PreferenceTypeViewController : BaseViewController{
    
    IBOutlet UITableView *mainTB;
    

}


@property(nonatomic,strong)DeviceModel *model;



@end
