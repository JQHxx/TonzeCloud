//
//  SportViewController.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "SportTableModel.h"
@protocol SportsViewControllerDelegate <NSObject>

-(void)sportsViewControllerDidSelectDict:(NSDictionary *)dict;

@end
@interface SportViewController : BaseViewController
@property (nonatomic,weak)id<SportsViewControllerDelegate>controllerDelegate;
@property (nonatomic,assign) NSInteger motion_record_id;
@end
