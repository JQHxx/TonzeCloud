//
//  StoragePropertyViewController.h
//  Product
//
//  Created by vision on 17/10/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceModel.h"

@interface StoragePropertyViewController : BaseViewController

@property (nonatomic,strong)DeviceModel *model;
@property (nonatomic,assign)NSInteger getHumidity;
@property (nonatomic,assign)NSInteger getTemprature;

@end
