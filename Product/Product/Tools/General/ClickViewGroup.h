//
//  ClickViewGroup.h
//  TonzeCloud
//
//  Created by vision on 17/2/22.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClickViewGroupDelegate <NSObject>

-(void)ClickViewGroupActionWithIndex:(NSUInteger)index;

@end

@interface ClickViewGroup : UIScrollView

@property (nonatomic ,assign) id<ClickViewGroupDelegate>viewDelegate;
@property(nonatomic,assign)BOOL  isNeedReloadData;

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles color:(UIColor*)color;

-(void)changeViewWithButton:(UIButton *)btn;


@end
