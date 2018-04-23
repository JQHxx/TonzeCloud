//
//  ScaleView.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScaleView;
@protocol ScaleViewDelegate <NSObject>

-(void)scaleView:(ScaleView *)scaleView weight:(NSString *)weight;
-(void)scaleView:(ScaleView *)scaleView;

@end
@interface ScaleView : UIView
@property (nonatomic,weak)id<ScaleViewDelegate>scaleDelegate;

-(void)scaleViewShowInView:(UIView *)view;

@end
