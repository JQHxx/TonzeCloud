//
//  TJYMenuFilterView.h
//  Product
//
//  Created by mk-imac2 on 2017/9/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

/**
 *  筛选页面
 */
#import <UIKit/UIKit.h>

typedef void (^MenuFilterBlock)(NSInteger menuIndex,NSInteger deviceIndex,NSMutableArray * arrayEffectIndex);

/**
 *  菜谱筛选页面
 */
@interface TJYMenuFilterView : UIView

@property (nonatomic,copy) MenuFilterBlock fillerBlock;
/**
 *  筛选类型
 */
@property (nonatomic,assign) NSInteger menuIndex;
@property (nonatomic,assign) NSInteger deviceIndex;
@property (nonatomic,strong) NSMutableArray * arrayEffectIndex;


/**
 *  显示页面
 */
-(void)showMenuFilterView:(UIView *)view withDeviceArray:(NSMutableArray *)arrayDevice withEffectArray:(NSMutableArray *)arrayEffect;

@end
