//
//  DeviceMenuScaleView.h
//  Product
//
//  Created by 肖栋 on 17/5/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYCookDetailsEquipmentModel.h"

@class DeviceMenuScaleView;
@protocol DeviceMenuScaleViewDelegate <NSObject>

-(void)DeviceMenuScaleViewView:(DeviceMenuScaleView *)DeviceMenuScaleViewView model:(DeviceModel *)model menu:(TJYCookDetailsEquipmentModel *)menu index:(NSInteger)index;

@end
@interface DeviceMenuScaleView : UIView
@property (nonatomic,weak)id<DeviceMenuScaleViewDelegate>DeviceMenuScaleViewDelegate;
@property (nonatomic,assign)NSMutableArray  *dataArray;
@property (nonatomic,assign)NSMutableArray  *menuArray;
@property (nonatomic,assign)NSInteger index;
-(void)DeviceMenuScaleViewShowInView:(UIView *)view;
@end
