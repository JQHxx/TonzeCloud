//
//  IndexResultView.m
//  Product
//
//  Created by vision on 17/5/12.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "IndexResultView.h"
#import "ScaleHelper.h"

@implementation IndexResultView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //直线宽度
    CGContextSetLineWidth(context,self.height*2);
    
    if ([_key isEqualToString:@"bodyfat"]||[_key isEqualToString:@"BMI"]||[_key isEqualToString:@"subfat"]) {
        //设置颜色
        CGContextSetRGBStrokeColor(context, 31.0/255.0, 182.0/255.0, 240.0/255.0, 1.0);
        CGContextMoveToPoint(context,0, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width/4,0);
        //绘制完成
        CGContextStrokePath(context);
        
        //设置颜色
        CGContextSetRGBStrokeColor(context, 192.0/255.0, 229.0/255.0, 104.0/255.0, 1.0);
        CGContextMoveToPoint(context, self.width/4, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width/2,0);
        //绘制完成
        CGContextStrokePath(context);
        
        //设置颜色
        CGContextSetRGBStrokeColor(context, 243.0/255.0, 152.0/255.0, 0.0/255.0, 1.0);
        CGContextMoveToPoint(context, self.width/2, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width*3/4,0);
        //绘制完成
        CGContextStrokePath(context);
        
        //设置颜色
        CGContextSetRGBStrokeColor(context, 250.0/255.0, 84.0/255.0, 83.0/255.0, 1.0);
        CGContextMoveToPoint(context, self.width*3/4, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width,0);
        //绘制完成
        CGContextStrokePath(context);
    }else if ([_key isEqualToString:@"weight"]){
        //设置颜色
        CGContextSetRGBStrokeColor(context, 31.0/255.0, 182.0/255.0, 240.0/255.0, 1.0);
        CGContextMoveToPoint(context,0, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width/3,0);
        //绘制完成
        CGContextStrokePath(context);
        
        //设置颜色
        CGContextSetRGBStrokeColor(context, 192.0/255.0, 229.0/255.0, 104.0/255.0, 1.0);
        CGContextMoveToPoint(context, self.width/3, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width*2/3,0);
        //绘制完成
        CGContextStrokePath(context);
        
        //设置颜色
        CGContextSetRGBStrokeColor(context, 250.0/255.0, 84.0/255.0, 83.0/255.0, 1.0);
        CGContextMoveToPoint(context, self.width*2/3, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width,0);
        //绘制完成
        CGContextStrokePath(context);
    }else if ([_key isEqualToString:@"bone"]||[_key isEqualToString:@"muscle"]||[_key isEqualToString:@"bmr"]||[_key isEqualToString:@"water"]||[_key isEqualToString:@"protein"]){
        //设置颜色
        CGContextSetRGBStrokeColor(context, 31.0/255.0, 182.0/255.0, 240.0/255.0, 1.0);
        CGContextMoveToPoint(context,0, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width/3,0);
        //绘制完成
        CGContextStrokePath(context);
        
        //设置颜色
        CGContextSetRGBStrokeColor(context, 192.0/255.0, 229.0/255.0, 104.0/255.0, 1.0);
        CGContextMoveToPoint(context, self.width/3, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width*2/3,0);
        //绘制完成
        CGContextStrokePath(context);
        
        //设置颜色
        CGContextSetRGBStrokeColor(context, 99.0/255.0, 209.0/255.0, 98.0/255.0, 1.0);
        CGContextMoveToPoint(context, self.width*2/3, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width,0);
        //绘制完成
        CGContextStrokePath(context);
    }else if ([_key isEqualToString:@"visfat"]){
        //设置颜色
        CGContextSetRGBStrokeColor(context, 99.0/255.0, 209.0/255.0, 98.0/255.0, 1.0);  //深绿
        CGContextMoveToPoint(context,0, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width/4,0);
        //绘制完成
        CGContextStrokePath(context);
        
        //设置颜色
        CGContextSetRGBStrokeColor(context, 192.0/255.0, 229.0/255.0, 104.0/255.0, 1.0); //绿
        CGContextMoveToPoint(context, self.width/4, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width/2,0);
        //绘制完成
        CGContextStrokePath(context);
        
        //设置颜色
        CGContextSetRGBStrokeColor(context, 243.0/255.0, 152.0/255.0, 0.0/255.0, 1.0); //橙
        CGContextMoveToPoint(context, self.width/2, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width*3/4,0);
        //绘制完成
        CGContextStrokePath(context);
        
        //设置颜色
        CGContextSetRGBStrokeColor(context, 250.0/255.0, 84.0/255.0, 83.0/255.0, 1.0); //红
        CGContextMoveToPoint(context, self.width*3/4, 0);
        //下一点
        CGContextAddLineToPoint(context,self.width,0);
        //绘制完成
        CGContextStrokePath(context);
    }
    
}


-(void)setKey:(NSString *)key{
    _key=key;
    [self setNeedsDisplay];
}


@end
