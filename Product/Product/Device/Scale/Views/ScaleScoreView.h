//
//  ScaleScoreView.h
//  Product
//
//  Created by vision on 17/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ScaleScoreView;
@protocol ScaleScoreDelegate <NSObject>

-(void)ScaleScoreView:(ScaleScoreView *)scaleScoreView;

@end
@interface ScaleScoreView : UIView

@property (nonatomic,assign)NSInteger bodyScore;

@property (nonatomic,weak)id<ScaleScoreDelegate>ScaleScoreDelegate;

@end
