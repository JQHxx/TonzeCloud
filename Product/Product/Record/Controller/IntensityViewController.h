//
//  IntensityViewController.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
@protocol IntensityDelegate

- (void)intensityViewControllerDidSelectLaborIntensity:(NSString *)selectLabor;

@end
@interface IntensityViewController : BaseViewController
@property(nonatomic, copy )NSString * laborIntensity;  //工作级别
@property (nonatomic, weak) id <IntensityDelegate> controllerDelegate;

@end
