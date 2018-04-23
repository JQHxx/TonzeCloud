//
//  StorageContentView.m
//  Product
//
//  Created by vision on 17/6/12.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StorageContentView.h"
#import "StorageAttrView.h"

@interface StorageContentView (){
    StorageAttrView     *humidityAttrView;
    StorageAttrView     *temperatureAttrView;
    UILabel             *foodDetailLabel;
}

@end

@implementation StorageContentView

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
        
        temperatureAttrView=[[StorageAttrView alloc] initWithFrame:CGRectMake(kScreenWidth/2+1, 1, kScreenWidth/2-1, 80)];
        [self addSubview:temperatureAttrView];
        
        UILabel *line3=[[UILabel alloc] initWithFrame:CGRectMake(10, temperatureAttrView.bottom, kScreenWidth-20, 1)];
        line3.backgroundColor=kLineColor;
        [self addSubview:line3];
        
        foodDetailLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, line3.bottom+10, kScreenWidth-40, 20)];
        foodDetailLabel.font=[UIFont systemFontOfSize:14];
        foodDetailLabel.textColor=[UIColor colorWithHexString:@"#626262"];
        foodDetailLabel.textAlignment=NSTextAlignmentCenter;
        [self addSubview:foodDetailLabel];
        foodDetailLabel.hidden=YES;  
        
        UIButton   *saveFoodBtn=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2, foodDetailLabel.bottom+10, 120, 36)];
        [saveFoodBtn setTitle:@"储存食材" forState:UIControlStateNormal];
        [saveFoodBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        saveFoodBtn.backgroundColor=[UIColor colorWithHexString:@"#ff9d38"];
        saveFoodBtn.layer.cornerRadius=18;
        saveFoodBtn.clipsToBounds=YES;
        [saveFoodBtn addTarget:self action:@selector(saveFoodAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveFoodBtn];
        
    }
    return self;
}

#pragma mark -- Event Response
#pragma mark 储存食材
-(void)saveFoodAction{
    if ([_delegate respondsToSelector:@selector(storageContentViewSaveFoodAction)]) {
        [_delegate storageContentViewSaveFoodAction];
    }
}

#pragma mark -- setters
#pragma mark 食材数量统计
-(void)setFoodCountDict:(NSDictionary *)foodCountDict{
    _foodCountDict=foodCountDict;
    NSInteger foodExpiringCount=[[foodCountDict valueForKey:@"expiring"] integerValue];
    NSInteger foodExpiredCount=[[foodCountDict valueForKey:@"expired"] integerValue];
    
    NSString *expiringCountStr=[NSString stringWithFormat:@"%ld",foodExpiringCount];
    NSString *expiredCountStr=[NSString stringWithFormat:@"%ld",foodExpiredCount];
    
    if (foodExpiredCount>0&&foodExpiringCount>0) {
        foodDetailLabel.hidden=NO;
        NSString *foodTitle=[NSString stringWithFormat:@"%ld个食材即将过期，%ld个食材已过期",foodExpiringCount,foodExpiredCount];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:foodTitle];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#93dd93"] range:NSMakeRange(0,expiringCountStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#ff0000"] range:NSMakeRange(expiringCountStr.length+8,expiredCountStr.length)];
        foodDetailLabel.attributedText=attributeStr;
    }else if(foodExpiringCount>0&&foodExpiredCount==0){
        foodDetailLabel.hidden=NO;
        NSString *foodTitle=[NSString stringWithFormat:@"%ld个食材即将过期",foodExpiringCount];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:foodTitle];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#93dd93"] range:NSMakeRange(0,expiringCountStr.length)];
        foodDetailLabel.attributedText=attributeStr;
    }else if (foodExpiringCount==0&&foodExpiredCount>0){
        foodDetailLabel.hidden=NO;
        NSString *foodTitle=[NSString stringWithFormat:@"%ld个食材已过期",foodExpiredCount];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:foodTitle];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#93dd93"] range:NSMakeRange(0,expiredCountStr.length)];
        foodDetailLabel.attributedText=attributeStr;
    }else{
        foodDetailLabel.hidden=YES;
    }
}

#pragma mark 湿度
-(void)setHumidityValue:(NSInteger)humidityValue{
    _humidityValue=humidityValue;
    NSDictionary *dict;
    if (humidityValue==0) {
       dict=@{@"value":@"--",@"name":@"湿度",@"image":@"cwg_ic_shidu"};
    }else{
       dict=@{@"value":[NSString stringWithFormat:@"%ld%%",humidityValue],@"name":@"湿度",@"image":@"cwg_ic_shidu"};
    }
    
    humidityAttrView.attrDict=dict;
    
}

#pragma mark  温度
-(void)setTemperatureValue:(NSInteger)temperatureValue{
    _temperatureValue=temperatureValue;
    NSDictionary *dict;
    if (temperatureValue==0) {
        dict=@{@"value":@"--",@"name":@"温度",@"image":@"cwg_ic_wendu"};
    }else{
        dict=@{@"value":[NSString stringWithFormat:@"%ld°C",temperatureValue],@"name":@"温度",@"image":@"cwg_ic_wendu"};
    }
    temperatureAttrView.attrDict=dict;
}

@end
