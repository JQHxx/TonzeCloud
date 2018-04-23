//
//  WeightLineChartView.h
//  Product
//
//  Created by 肖栋 on 17/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WeightLineChartView;
@protocol WeightLineDelegate <NSObject>

-(void)weightLineChartView:(WeightLineChartView *)ChartView type:(NSInteger)type;
-(void)weightrightLineChartView:(WeightLineChartView *)ChartView type:(NSInteger)type;


@end
@interface WeightLineChartView : UIView
@property (nonatomic,assign)id<WeightLineDelegate>weightLineDelegate;

@property (nonatomic,assign)NSInteger page;
@property(nonatomic,assign)NSArray *dataArray;
@property(nonatomic,assign)NSArray *bloodDataArray;
@property(nonatomic,assign)NSInteger type;
- (instancetype)initWithFrame:(CGRect)frame maxY:(NSInteger)maxy title:(NSString *)title;
- (instancetype)initWithFrame:(CGRect)frame maxY:(NSInteger)maxy title:(NSString *)tilte height:(NSInteger)height low:(NSInteger)low;


@end
