//
//  ScaleViewController.h
//  Product
//
//  Created by Feng on 16/2/27.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ScaleModel.h"

@interface ScaleViewController : BaseViewController

@property (nonatomic,strong)ScaleModel *scaleModel;

@property (nonatomic,assign)NSInteger user_id;

@property (nonatomic,assign)NSInteger record_id;

@property (nonatomic,assign)NSInteger shareScore;

@end
