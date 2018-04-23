//
//  DrawLine.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DrawLine.h"

@implementation DrawLine

- (void)drawRect:(CGRect)rect {
    // 获取上下文,进行绘制
    CGContextRef ContextRef = UIGraphicsGetCurrentContext();
    // 线的颜色 横线
    CGContextSetStrokeColorWithColor(ContextRef, [UIColor lightGrayColor].CGColor);
    for (int i =0 ; i<11; i++) {
        CGContextMoveToPoint(ContextRef, 0,i*self.height/10);
        CGContextAddLineToPoint(ContextRef,self.width,(self.height/10)*i);
        CGContextStrokePath(ContextRef);
    }
    // 设置线的宽度 竖线
    for (int i= 0; i< 3; i++) {
        CGContextMoveToPoint(ContextRef, i*self.width/2, self.height);
        CGContextAddLineToPoint(ContextRef, i*self.width/2,0);
        CGContextStrokePath(ContextRef);
    }
}


@end
