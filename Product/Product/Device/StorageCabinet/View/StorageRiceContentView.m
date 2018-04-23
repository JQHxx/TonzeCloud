//
//  StorageRiceContentView.m
//  Product
//
//  Created by vision on 17/6/12.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StorageRiceContentView.h"
#import "StorageAttrView.h"

@interface StorageRiceContentView (){
    StorageAttrView     *humidityAttrView;       //湿度
    StorageAttrView     *outRiceAttrView;        //出米量
    StorageAttrView     *lastRiceAttrView;       //剩余米量
    UILabel             *riceStateLabel;         //米量不足提醒
}

@end

@implementation StorageRiceContentView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        UILabel *line1=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth-20, 1)];
        line1.backgroundColor=kLineColor;
        [self addSubview:line1];
        
        humidityAttrView=[[StorageAttrView alloc] initWithFrame:CGRectMake(0, 1, kScreenWidth/2, 80)];
        [self addSubview:humidityAttrView];
        
        UILabel *line2=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, 20, 1, 40)];
        line2.backgroundColor=kLineColor;
        [self addSubview:line2];
        
        outRiceAttrView=[[StorageAttrView alloc] initWithFrame:CGRectMake(kScreenWidth/2+1, 1, kScreenWidth/2-1, 80)];
        [self addSubview:outRiceAttrView];
        
        UILabel *line3=[[UILabel alloc] initWithFrame:CGRectMake(10, outRiceAttrView.bottom, kScreenWidth-20, 1)];
        line3.backgroundColor=kLineColor;
        [self addSubview:line3];
        
        lastRiceAttrView=[[StorageAttrView alloc] initWithFrame:CGRectMake(0, line3.bottom, kScreenWidth/2-1, 80)];
        [self addSubview:lastRiceAttrView];
        
        riceStateLabel=[[UILabel alloc] initWithFrame:CGRectMake(40, lastRiceAttrView.bottom+5, kScreenWidth-80, 20)];
        riceStateLabel.font=[UIFont systemFontOfSize:15];
        riceStateLabel.textColor=[UIColor colorWithHexString:@"#ff4c60"];
        riceStateLabel.textAlignment=NSTextAlignmentCenter;
        riceStateLabel.text=@"米量不足";
        [self addSubview:riceStateLabel];
        riceStateLabel.hidden=YES;
        
    }
    return self;
}


#pragma mark -- setters and getters
#pragma mark 湿度
-(void)setRiceHumidityValue:(NSInteger)riceHumidityValue{
    _riceHumidityValue=riceHumidityValue;
    NSDictionary *dict=riceHumidityValue==0?@{@"value":@"--",@"name":@"湿度",@"image":@"cwg_ic_shidu"}: @{@"value":[NSString stringWithFormat:@"%ld%%",riceHumidityValue],@"name":@"湿度",@"image":@"cwg_ic_shidu"};
    humidityAttrView.attrDict=dict;
}

#pragma mark 出米量
-(void)setOutRiceValue:(NSInteger)outRiceValue{
    _outRiceValue=outRiceValue;
    NSDictionary *dict=outRiceValue==0? @{@"value":@"--",@"name":@"出米量",@"image":@"cwg_ic_rongliang"}:@{@"value":[NSString stringWithFormat:@"%ld杯",outRiceValue],@"name":@"出米量",@"image":@"cwg_ic_rongliang"};
    outRiceAttrView.attrDict=dict;
}

#pragma mark 剩余米量
-(void)setLastRiceValue:(NSInteger)lastRiceValue{
    _lastRiceValue=lastRiceValue;
    NSDictionary *dict=lastRiceValue==0? @{@"value":@"--",@"name":@"剩余米量",@"image":@"cwg_ic_miliang"}:@{@"value":[NSString stringWithFormat:@"%ld%%",lastRiceValue],@"name":@"剩余米量",@"image":@"cwg_ic_miliang"};
    lastRiceAttrView.attrDict=dict;
    riceStateLabel.hidden=lastRiceValue>10;
    if (lastRiceValue==0) {
        riceStateLabel.hidden=YES;
    }
}


@end
