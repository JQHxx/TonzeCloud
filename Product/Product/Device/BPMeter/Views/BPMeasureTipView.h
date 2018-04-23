//
//  BPMeasureTipView.h
//  Product
//
//  Created by mk-imac2 on 2017/7/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MeasureTipBlock)(BOOL isNoLonger);


@interface BPMeasureTipView : UIView

-(void)showInView:(UIView *)view withMeasureTipBlock:(MeasureTipBlock)block;

@end
