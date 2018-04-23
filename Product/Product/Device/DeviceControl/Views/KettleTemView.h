//
//  KettleTemView.h
//  Product
//
//  Created by 肖栋 on 16/12/14.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"

@protocol KettleTemDelegate <NSObject>

@required

-(void)startFunction:(id)sender;

-(void)orderStartFunction:(id)sender;


@end

@interface KettleTemView : UIViewController


@property (weak, nonatomic) IBOutlet UITableView *KettleTabView;


@property (nonatomic,weak) id <KettleTemDelegate> delegate;



-(void)showInView:(UIView*)view;

-(void)dismissView;

-(IBAction)removeView:(id)sender;

@property(nonatomic,strong)DeviceModel *model;

@end
