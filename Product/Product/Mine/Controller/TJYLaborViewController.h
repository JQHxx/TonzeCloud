//
//  TJYLaborViewController.h
//  Product
//
//  Created by vision on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

@protocol TJYLaborViewControllerDelegate <NSObject>

-(void)laborVCDidSelectLabor:(NSString *)selLabor;

@end

@interface TJYLaborViewController : BaseViewController

@property(nonatomic,weak)id<TJYLaborViewControllerDelegate>controllerDelegate;
@property(nonatomic, copy )NSString * laborIntensity;  //工作级别

@end
