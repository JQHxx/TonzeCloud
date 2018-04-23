//
//  BloodScaleView.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BloodScaleView;
@protocol BloodScaleViewDelegate <NSObject>

-(void)scaleView:(BloodScaleView *)scaleView height:(NSInteger)height low:(NSInteger)low;

@end
@interface BloodScaleView : UIView
@property (nonatomic,assign)id<BloodScaleViewDelegate>bloodScaleDelegate;


-(void)bloodScaleViewShowInView:(UIView *)view;

-(void)dismissScaleView;
@end
