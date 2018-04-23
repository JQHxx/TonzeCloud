//
//  ShareFromQRcodeViewController.h
//  Product
//
//  Created by Feng on 16/2/3.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"
#import "QRCodeGenerator.h"
#import "BaseViewController.h"

@interface ShareFromQRcodeViewController : BaseViewController{
    IBOutlet UILabel *tipsLbl;
    IBOutlet UIImageView *QRcodeView;
    
}


@property(nonatomic,strong)DeviceModel *model;

@end
