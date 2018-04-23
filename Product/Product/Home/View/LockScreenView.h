//
//  LockScreenView.h
//  Product
//
//  Created by zhuqinlu on 2017/6/1.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LockScreenView : UIView

/// 运动里程
@property (nonatomic ,strong) UILabel *sportsMileageLabel;
/// 运动速度
@property (nonatomic ,strong) UILabel *movementSpeedLabel;
/// 运动时间
@property (nonatomic ,strong) UILabel *sportsTimeLabel;
/// 消耗能量
@property (nonatomic ,strong) UILabel *sportsPhysicalLabel;

@end
