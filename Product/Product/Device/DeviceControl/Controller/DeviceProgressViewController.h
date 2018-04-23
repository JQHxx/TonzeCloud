//
//  DeviceProgressViewController.h
//  Product
//
//  Created by Xlink on 16/1/21.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"
#import "YSProgressView.h"
#import "BaseViewController.h"

@interface DeviceProgressViewController : BaseViewController{
    IBOutlet UILabel *stateLbl,*workTypeLbl,*progressLbl;
    IBOutlet UITableView *detailTB;
    IBOutlet UIImageView *typeIV,*stateIV,*onlineIV;
    IBOutlet UIButton *cancelBtn;
    
    YSProgressView *progressView;
    IBOutlet UIView *proBgView;
    __weak IBOutlet UIView *bgCookView;

}
@property(nonatomic,assign)NSInteger index;

-(IBAction)cancelFunction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *workName;

@property(nonatomic,strong)DeviceModel *model;



@end
