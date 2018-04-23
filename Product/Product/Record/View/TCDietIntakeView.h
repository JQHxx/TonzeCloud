//
//  TCDietIntakeView.h
//  TonzeCloud
//
//  Created by fei on 2017/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TCDietIntakeViewDelegate <NSObject>

-(void)dietIntakeViewDidSetDailyTargetIntake;

@end


typedef enum : NSUInteger {
    TCDietIntakeViewDietType,
    TCDietIntakeViewSportsType,
} TCDietIntakeViewType;

@interface TCDietIntakeView : UIView

@property (nonatomic,weak)id<TCDietIntakeViewDelegate>delegate;

@property (nonatomic,assign)NSInteger energyValue;    //摄入量或消耗量
@property (nonatomic,assign)NSInteger targetEnergyValue;    //饮食目标

-(instancetype)initWithFrame:(CGRect)frame type:(TCDietIntakeViewType)type;


@end
