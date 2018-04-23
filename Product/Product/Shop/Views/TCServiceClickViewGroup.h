//
//  TCServiceClickViewGroup.h
//  TonzeCloud
//
//  Created by 肖栋 on 17/10/18.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ServiceViewGroupDelegate <NSObject>

-(void)ServiceViewGroupActionWithIndex:(NSUInteger)index;

@end

@interface TCServiceClickViewGroup : UIScrollView
@property (nonatomic ,weak) id<ServiceViewGroupDelegate>serviceDelegate;
@property(nonatomic,assign)BOOL  isNeedReloadData;

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles color:(UIColor*)color;

-(void)serviceChangeViewWithButton:(UIButton *)btn;

-(void)serviceBgChangeViewWithButton:(UIButton *)btn;

@end
