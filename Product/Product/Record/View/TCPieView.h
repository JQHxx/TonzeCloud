//
//  TCPieView.h
//  TonzeCloud
//
//  Created by vision on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCPieView : UIView

/**
 *  Pie
 *
 *  @param frame      frame
 *  @param dataItems  数据源
 *  @param colorItems 对应数据的pie的颜色，如果colorItems.count < dataItems 或
 *                      colorItems 为nil 会随机填充颜色
 *
 */
-(instancetype)initWithFrame:(CGRect)frame dataItems:(NSArray *)dataItems colorItems:(NSArray *)colorItems;

- (void)stroke;

@end
