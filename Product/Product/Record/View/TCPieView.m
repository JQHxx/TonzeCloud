//
//  TCPieView.m
//  TonzeCloud
//
//  Created by vision on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCPieView.h"

#define kPieRandColor [UIColor colorWithRed:arc4random() % 255 / 255.0f green:arc4random() % 255 / 255.0f blue:arc4random() % 255 / 255.0f alpha:1.0f]

@interface TCPieView (){
    CGFloat       total;
    CAShapeLayer  *bgCircleLayer;
}

@end

@implementation TCPieView

-(instancetype)initWithFrame:(CGRect)frame dataItems:(NSArray *)dataItems colorItems:(NSArray *)colorItems{
    self=[super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        
        //1.pieView中心点
        CGFloat centerWidth = self.width * 0.5f;
        CGFloat centerHeight = self.height * 0.5f;
        CGFloat centerX = centerWidth;
        CGFloat centerY = centerHeight;
        CGPoint centerPoint = CGPointMake(centerX, centerY);
        CGFloat radiusBasic = centerWidth > centerHeight ? centerHeight : centerWidth;
        
        //计算红绿蓝部分总和
        total = 0.0f;
        for (int i = 0; i < dataItems.count; i++) {
            total += [dataItems[i] floatValue];
        }
        
        //线的半径为扇形半径的一半，线宽是扇形半径，这样就能画出圆形了
        //2.背景路径
        CGFloat bgRadius = radiusBasic * 0.5;
        UIBezierPath *bgPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                              radius:bgRadius
                                                          startAngle:-M_PI_2
                                                            endAngle:M_PI_2 * 3
                                                           clockwise:YES];
        bgCircleLayer = [CAShapeLayer layer];
        bgCircleLayer.fillColor   = [UIColor clearColor].CGColor;
        bgCircleLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        bgCircleLayer.strokeStart = 0.0f;
        bgCircleLayer.strokeEnd   = 1.0f;
        bgCircleLayer.zPosition   = 1;
        bgCircleLayer.lineWidth   = bgRadius * 2.0f;
        bgCircleLayer.path        = bgPath.CGPath;
        
        //3.子扇区路径
        CGFloat otherRadius = radiusBasic * 0.5 - 3.0;
        UIBezierPath *otherPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                                 radius:otherRadius
                                                             startAngle:-M_PI_2
                                                               endAngle:M_PI_2 * 3
                                                              clockwise:YES];
        
        CGFloat start = 0.0f;
        CGFloat end = 0.0f;
        for (int i = 0; i < dataItems.count; i++) {
            //4.计算当前end位置 = 上一个结束位置 + 当前部分百分比
            end = [dataItems[i] floatValue] / total + start;
            
            //图层
            CAShapeLayer *pie = [CAShapeLayer layer];
            [self.layer addSublayer:pie];
            pie.fillColor   = [UIColor clearColor].CGColor;
            if (i > colorItems.count - 1 || !colorItems  || colorItems.count == 0) {//如果传过来的颜色数组少于item个数则随机填充颜色
                pie.strokeColor = kPieRandColor.CGColor;
            } else {
                pie.strokeColor = ((UIColor *)colorItems[i]).CGColor;
            }
            pie.strokeStart = start;
            pie.strokeEnd   = end;
            pie.lineWidth   = otherRadius * 2.0f;
            pie.zPosition   = 2;
            pie.path        = otherPath.CGPath;
            
            //计算下一个start位置 = 当前end位置
            start = end;
        }
        self.layer.mask = bgCircleLayer;
    }
    return self;
}

- (void)stroke{
    //画图动画
    self.hidden = NO;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration  = 1.0f;
    animation.fromValue = @0.0f;
    animation.toValue   = @1.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    [bgCircleLayer addAnimation:animation forKey:@"circleAnimation"];
}

-(void)dealloc{
    [self.layer removeAllAnimations];
}

@end
