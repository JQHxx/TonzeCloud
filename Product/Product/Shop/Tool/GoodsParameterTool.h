//
//  GoodsParameterTool.h
//  Product
//
//  Created by 肖栋 on 17/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsModel.h"

@interface GoodsParameterTool : UIView

-(instancetype)initWithHeight:(CGFloat)viewHeight goodsParameter:(GoodsModel *)model;

/**
 *  工具视图弹出显示
 *
 */

-(void)goodsParameterToolShow;
@end
