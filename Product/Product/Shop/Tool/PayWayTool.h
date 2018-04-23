//
//  PayWayTool.h
//  Product
//
//  Created by vision on 17/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayWayTool : UIButton

@property (nonatomic,assign)BOOL isWaySelected;

-(instancetype)initWithFrame:(CGRect)frame iconName:(NSString *)icon title:(NSString *)titleText;

@end
