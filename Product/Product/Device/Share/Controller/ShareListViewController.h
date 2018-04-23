//
//  ShareListViewController.h
//  Product
//
//  Created by Feng on 16/2/3.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"
#import "BaseViewController.h"

@interface ShareListViewController : BaseViewController {
    IBOutlet UIView *withoutShareView;
    IBOutlet UITableView *shareListTB;
    IBOutlet UILabel *shareTitleLbl,*shareTipsLbl;
    
}


@property(nonatomic,strong)DeviceModel *model;


@end
