//
//  StorageAddFoodViewController.h
//  Product
//
//  Created by 肖栋 on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "StorageModel.h"



@interface StorageAddFoodViewController : BaseViewController

@property (nonatomic,strong)StorageModel  *foodModel;
@property (nonatomic,assign)NSInteger     storageType;

@end
