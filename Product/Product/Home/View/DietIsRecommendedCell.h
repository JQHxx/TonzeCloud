//
//  DietIsRecommendedCell.h
//  Product
//
//  Created by zhuqinlu on 2018/3/21.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DietIsRecommendedCellDelegate <NSObject>

- (void)swipMealTime:(UISwipeGestureRecognizer *)gesture;

- (void)menuClickIndexRow:(NSInteger)row;

@end

@interface DietIsRecommendedCell : UITableViewCell

/// 推荐菜谱数据
@property (nonatomic ,strong) NSArray *recommendDietData;

@property (nonatomic, weak) id<DietIsRecommendedCellDelegate> delegate;

@end
