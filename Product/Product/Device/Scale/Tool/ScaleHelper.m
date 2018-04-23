//
//  ScaleHelper.m
//  Product
//
//  Created by vision on 17/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ScaleHelper.h"
#import "TonzeHelpTool.h"


@implementation ScaleHelper

singleton_implementation(ScaleHelper)


-(void)setScaleUser:(TJYUserModel *)scaleUser{
    _scaleUser=scaleUser;
}


#pragma mark 获取体指标结果列表
-(NSArray *)getBodyIndexResultArrayWithKey:(NSString *)key{
    NSArray *tempArr=[[NSArray alloc] init];
    if ([key isEqualToString:@"weight"]){
        tempArr=@[@"偏瘦",@"标准",@"超重"];
    }else if ([key isEqualToString:@"BMI"]){
        tempArr=@[@"偏瘦",@"正常",@"偏胖",@"肥胖"];
    }else if ([key isEqualToString:@"bodyfat"]) {
        tempArr=@[@"偏低",@"标准",@"偏高",@"严重偏高"];
    }else if ([key isEqualToString:@"water"]){
        tempArr=@[@"偏低",@"标准",@"充足"];
    }else if ([key isEqualToString:@"bone"]){
        tempArr=@[@"偏低",@"达标",@"充足"];
    }else if ([key isEqualToString:@"muscle"]){
        tempArr=@[@"偏低",@"达标",@"充足"];
    }else if ([key isEqualToString:@"protein"]){
        tempArr=@[@"偏低",@"标准",@"充足"];
    }else if ([key isEqualToString:@"visfat"]){
        tempArr=@[@"良好",@"达标",@"偏高",@"严重超标"];
    }else if ([key isEqualToString:@"bmr"]){
        tempArr=@[@"偏低",@"达标",@"良好"];
    }else if ([key isEqualToString:@"subfat"]){
        tempArr=@[@"良好",@"达标",@"偏高",@"严重偏高"];
    }
    return tempArr;
}

-(NSDictionary *)getValueDictWithKey:(NSString *)key{
    NSArray *tempArr=[[NSArray alloc] init];
    NSDictionary *dict=[[NSDictionary alloc] init];
    
    double weight=[_scaleUser.weight doubleValue];
    NSString *bornDateStr=_scaleUser.birthday;
    NSInteger sex=_scaleUser.sex;
    NSInteger age=[[TJYHelper sharedTJYHelper] getCurrentAgeWithBornDate:bornDateStr];
    if ([key isEqualToString:@"BMI"]) {
        tempArr=@[@{@"min":@(0.0),@"max":@(18.5)},
                  @{@"min":@(18.5),@"max":@(25.0)},
                  @{@"min":@(25.0),@"max":@(30.0)},
                  @{@"min":@(30.0),@"max":@(60.0)}];
        dict=@{@"per":@(15.0),@"max":@(60.0),@"list":tempArr};
    }else if ([key isEqualToString:@"weight"]) {
        NSInteger height=[_scaleUser.height integerValue];
        double lowWeight=0.8*(height-105);
        double  highWeight=1.2*(height-105);
        tempArr=@[@{@"min":@(30.0),@"max":@(lowWeight)},
                  @{@"min":@(lowWeight),@"max":@(highWeight)},
                  @{@"min":@(highWeight),@"max":@(150)}];
        dict=@{@"per":@(30.0),@"max":@(150.0),@"list":tempArr};
    }else if ([key isEqualToString:@"bodyfat"]) {
        if (sex==1) {
            tempArr=@[@{@"min":@(0.0),@"max":@(11.0)},
                      @{@"min":@(11.0),@"max":@(21.0)},
                      @{@"min":@(21.0),@"max":@(26.0)},
                      @{@"min":@(26.0),@"max":@(100.0)}];
            dict=@{@"per":@(25.0),@"max":@(100.0),@"list":tempArr};
        }else if (sex==2){
            tempArr=@[@{@"min":@(0.0),@"max":@(21.0)},
                      @{@"min":@(21.0),@"max":@(31.0)},
                      @{@"min":@(31.0),@"max":@(36.0)},
                      @{@"min":@(36.0),@"max":@(100.0)}];
            dict=@{@"per":@(25.0),@"max":@(100.0),@"list":tempArr};
        }
    }else if ([key isEqualToString:@"water"]){
        if (sex==1) {
            tempArr=@[@{@"min":@(0.0),@"max":@(55.0)},
                      @{@"min":@(55.0),@"max":@(65.0)},
                      @{@"min":@(65.0),@"max":@(100.0)}];
            double per=100.0/3.0;
            dict=@{@"per":@(per),@"max":@(100.0),@"list":tempArr};
        }else if (sex==2){
            tempArr=@[@{@"min":@(0.0),@"max":@(45.0)},
                      @{@"min":@(45.0),@"max":@(60.0)},
                      @{@"min":@(60.0),@"max":@(100.0)}];
            double per=100.0/3.0;
            dict=@{@"per":@(per),@"max":@(100.0),@"list":tempArr};
        }
    }else if ([key isEqualToString:@"bone"]){
        if (sex==1) {
            if (weight<=60.0) {
                tempArr=@[@(0.0),@(2.25),@(2.75),@(10.0)];
                tempArr=@[@{@"min":@(0.0),@"max":@(2.25)},
                          @{@"min":@(2.25),@"max":@(2.75)},
                          @{@"min":@(2.75),@"max":@(10.0)}];
                double per=10.0/3.0;
                dict=@{@"per":@(per),@"max":@(10.0),@"list":tempArr};
            }else if (weight<=75.0&&weight>60.0){
                tempArr=@[@{@"min":@(0.0),@"max":@(2.61)},
                          @{@"min":@(2.61),@"max":@(3.19)},
                          @{@"min":@(3.19),@"max":@(10.0)}];
                double per=10.0/3.0;
                dict=@{@"per":@(per),@"max":@(10.0),@"list":tempArr};
            }else if (weight>75.0){
                tempArr=@[@{@"min":@(0.0),@"max":@(2.88)},
                          @{@"min":@(2.88),@"max":@(3.52)},
                          @{@"min":@(3.52),@"max":@(10.0)}];
                double per=10.0/3.0;
                dict=@{@"per":@(per),@"max":@(10.0),@"list":tempArr};
            }
        }else if (sex==2){
            if (weight<=45.0) {
                tempArr=@[@{@"min":@(0.0),@"max":@(1.61)},
                          @{@"min":@(1.61),@"max":@(1.98)},
                          @{@"min":@(1.98),@"max":@(10.0)}];
                double per=10.0/3.0;
                dict=@{@"per":@(per),@"max":@(10.0),@"list":tempArr};
            }else if (weight<=60.0&&weight>45.0){
                tempArr=@[@{@"min":@(0.0),@"max":@(1.98)},
                          @{@"min":@(1.98),@"max":@(2.42)},
                          @{@"min":@(2.42),@"max":@(10.0)}];
                double per=10.0/3.0;
                dict=@{@"per":@(per),@"max":@(10.0),@"list":tempArr};
            }else if (weight>60.0){
                tempArr=@[@{@"min":@(0.0),@"max":@(2.25)},
                          @{@"min":@(2.25),@"max":@(2.75)},
                          @{@"min":@(2.75),@"max":@(10.0)}];
                double per=10.0/3.0;
                dict=@{@"per":@(per),@"max":@(10.0),@"list":tempArr};
            }
        }
    }else if ([key isEqualToString:@"muscle"]){
        if (sex==1) {
            tempArr=@[@{@"min":@(0.0),@"max":@(49.0)},
                      @{@"min":@(49.0),@"max":@(59.0)},
                      @{@"min":@(59.0),@"max":@(100.0)}];
            double per=100.0/3.0;
            dict=@{@"per":@(per),@"max":@(100.0),@"list":tempArr};
        }else if (sex==2){
            tempArr=@[@{@"min":@(0.0),@"max":@(40.0)},
                      @{@"min":@(40.0),@"max":@(50.0)},
                      @{@"min":@(50.0),@"max":@(100.0)}];
            double per=100.0/3.0;
            dict=@{@"per":@(per),@"max":@(100.0),@"list":tempArr};
        }
    }else if ([key isEqualToString:@"protein"]){
        if (sex==1) {
            tempArr=@[@{@"min":@(0.0),@"max":@(12.0)},
                      @{@"min":@(12.0),@"max":@(20.0)},
                      @{@"min":@(20.0),@"max":@(50.0)}];
            double per=50.0/3.0;
            dict=@{@"per":@(per),@"max":@(50.0),@"list":tempArr};
        }else if (sex==2){
            tempArr=@[@{@"min":@(0.0),@"max":@(11.0)},
                      @{@"min":@(11.0),@"max":@(18.0)},
                      @{@"min":@(18.0),@"max":@(50.0)}];
            double per=50.0/3.0;
            dict=@{@"per":@(per),@"max":@(50.0),@"list":tempArr};
        }
    }else if ([key isEqualToString:@"visfat"]){
        tempArr=@[@{@"min":@(0),@"max":@(8)},
                  @{@"min":@(8),@"max":@(9)},
                  @{@"min":@(9),@"max":@(14)},
                  @{@"min":@(14),@"max":@(50)}];
        double per=50.0/3.0;
        dict=@{@"per":@(per),@"max":@(50.0),@"list":tempArr};
    }else if ([key isEqualToString:@"bmr"]){
        if (sex==1) {
            if (age>=18&&age<=29) {
                tempArr=@[@{@"min":@(0.0),@"max":@(1240.0)},
                          @{@"min":@(1240.0),@"max":@(1860.0)},
                          @{@"min":@(1860.0),@"max":@(3000.0)}];
                dict=@{@"per":@(1000.0),@"max":@(3000.0),@"list":tempArr};
            }else if (age>29&&age<=49){
                tempArr=@[@{@"min":@(0.0),@"max":@(1200.0)},
                          @{@"min":@(1200.0),@"max":@(1800.0)},
                          @{@"min":@(1800.0),@"max":@(3000.0)}];
                dict=@{@"per":@(1000.0),@"max":@(3000.0),@"list":tempArr};
            }else if (age>49&&age<=69){
                tempArr=@[@{@"min":@(0.0),@"max":@(1080.0)},
                          @{@"min":@(1080.0),@"max":@(1620.0)},
                          @{@"min":@(1620.0),@"max":@(3000.0)}];
                dict=@{@"per":@(1000.0),@"max":@(3000.0),@"list":tempArr};
            }else if (age>69){
                tempArr=@[@{@"min":@(0.0),@"max":@(976.0)},
                          @{@"min":@(976.0),@"max":@(1464.0)},
                          @{@"min":@(1464.0),@"max":@(3000.0)}];
                dict=@{@"per":@(1000.0),@"max":@(3000.0),@"list":tempArr};
            }
        }else if(sex==2){
            if (age>=18&&age<=29) {
                tempArr=@[@{@"min":@(0.0),@"max":@(968.0)},
                          @{@"min":@(968.0),@"max":@(1452.0)},
                          @{@"min":@(1452.0),@"max":@(3000.0)}];
                dict=@{@"per":@(1000.0),@"max":@(3000.0),@"list":tempArr};
            }else if (age>29&&age<=49){
                tempArr=@[@{@"min":@(0.0),@"max":@(936.0)},
                          @{@"min":@(936.0),@"max":@(1404.0)},
                          @{@"min":@(1404.0),@"max":@(3000.0)}];
                dict=@{@"per":@(1000.0),@"max":@(3000.0),@"list":tempArr};
            }else if (age>49&&age<=69){
                tempArr=@[@{@"min":@(0.0),@"max":@(888.0)},
                          @{@"min":@(888.0),@"max":@(1332.0)},
                          @{@"min":@(1332.0),@"max":@(3000.0)}];
                dict=@{@"per":@(1000.0),@"max":@(3000.0),@"list":tempArr};
            }else if (age>69){
                tempArr=@[@{@"min":@(0.0),@"max":@(808.0)},
                          @{@"min":@(808.0),@"max":@(1212.0)},
                          @{@"min":@(1212.0),@"max":@(3000.0)}];
                dict=@{@"per":@(1000.0),@"max":@(3000.0),@"list":tempArr};
            }
        }
    }else if ([key isEqualToString:@"subfat"]){
        if (sex==1) {
            tempArr=@[@{@"min":@(0.0),@"max":@(8.6)},
                      @{@"min":@(8.6),@"max":@(16.7)},
                      @{@"min":@(16.7),@"max":@(20.7)},
                      @{@"min":@(20.7),@"max":@(50.0)}];
            double per=50.0/4.0;
            dict=@{@"per":@(per),@"max":@(50.0),@"list":tempArr};
        }else if (sex==2){
            tempArr=@[@(0.0),@(18.5),@(26.7),@(30.8),@(50.0)];
            tempArr=@[@{@"min":@(0.0),@"max":@(18.5)},
                      @{@"min":@(18.5),@"max":@(26.7)},
                      @{@"min":@(26.7),@"max":@(30.8)},
                      @{@"min":@(30.8),@"max":@(50.0)}];
            double per=50.0/4.0;
            dict=@{@"per":@(per),@"max":@(50.0),@"list":tempArr};
        }
    }
    return dict;
}

#pragma mark 获取体指标准范围
-(NSArray *)getBodyIndexArrayWithKey:(NSString *)key{
    NSArray *arr=[NSArray new];
    double weight=[_scaleUser.weight doubleValue];
    NSString *bornDateStr=_scaleUser.birthday;
    NSInteger sex=_scaleUser.sex;
    NSInteger age=[[TJYHelper sharedTJYHelper] getCurrentAgeWithBornDate:bornDateStr];
    if ([key isEqualToString:@"bodyfat"]) {
        if (sex==1) {
            arr=@[@(11.0),@(21.0),@(26.0)];
        }else if (sex==2){
            arr=@[@(21.0),@(31.0),@(36.0)];
        }
    }else if ([key isEqualToString:@"water"]){
        if (sex==1) {
            arr=@[@(55.0),@(65.0)];
        }else if (sex==2){
            arr=@[@(45.0),@(60.0)];
        }
    }else if ([key isEqualToString:@"bone"]){
        if (sex==1) {
            if (weight<=60.0) {
                arr=@[@(2.25),@(2.75)];
            }else if (weight<=75.0&&weight>60.0){
                arr=@[@(2.61),@(3.19)];
            }else if (weight>75.0){
                arr=@[@(2.88),@(3.52)];
            }
        }else if (sex==2){
            if (weight<=45.0) {
                arr=@[@(1.61),@(1.98)];
            }else if (weight<=60.0&&weight>45.0){
                arr=@[@(1.98),@(2.42)];
            }else if (weight>60.0){
                arr=@[@(2.25),@(2.75)];
            }
        }
    }else if ([key isEqualToString:@"muscle"]){
        if (sex==1) {
            arr=@[@(49.0),@(59.0)];
        }else if (sex==2){
            arr=@[@(40.0),@(50.0)];
        }
    }else if ([key isEqualToString:@"protein"]){
        if (sex==1) {
            arr=@[@(12.0),@(20.0)];
        }else if (sex==2){
            arr=@[@(11.0),@(18.0)];
        }
    }else if ([key isEqualToString:@"visfat"]){
        arr=@[@(8),@(9),@(14)];
    }else if ([key isEqualToString:@"bmr"]){
        if (sex==1) {
            if (age>=18&&age<=29) {
                arr=@[@(1240.0),@(1860.0)];
            }else if (age>29&&age<=49){
                arr=@[@(1200.0),@(1800.0)];
            }else if (age>49&&age<=69){
                arr=@[@(1080.0),@(1620.0)];
            }else if (age>69){
                arr=@[@(976.0),@(1464.0)];
            }
        }else if(sex==2){
            if (age>=18&&age<=29) {
                arr=@[@(968.0),@(1452.0)];
            }else if (age>29&&age<=49){
                arr=@[@(936.0),@(1404.0)];
            }else if (age>49&&age<=69){
                arr=@[@(888.0),@(1332.0)];
            }else if (age>69){
                arr=@[@(808.0),@(1212.0)];
            }
        }
    }else if ([key isEqualToString:@"subfat"]){
        if (sex==1) {
            arr=@[@(8.6),@(16.7),@(20.7)];
        }else if (sex==2){
            arr=@[@(18.5),@(26.7),@(30.8)];
        }
    }
    return arr;
}

#pragma mark 判断值显示位置
-(CGFloat)getBodyIndexValueXWithValue:(NSString *)valueStr width:(CGFloat)width key:(NSString *)key{
    CGFloat valueX=0.0;
    NSDictionary *dict=[self getValueDictWithKey:key];
    NSArray *tempArr=[[NSArray alloc] init];
    if ([key isEqualToString:@"visfat"]) {
        NSInteger value=[valueStr doubleValue];
        NSInteger perX=[[dict valueForKey:@"per"] integerValue];
        CGFloat max=[[dict valueForKey:@"max"] floatValue];
        tempArr=[dict valueForKey:@"list"];
        for (NSInteger i=0; i<tempArr.count; i++) {
            NSDictionary *dict=tempArr[i];
            NSInteger maxValue=[dict[@"max"] integerValue];
            NSInteger minValue=[dict[@"min"] integerValue];
            if (value<=maxValue&&value>=minValue) {
                CGFloat progress=i*perX+perX*(value-minValue)/(maxValue-minValue);
                valueX=(progress/max)*width;
            }
        }
    }else{
        double value=[valueStr doubleValue];
        CGFloat perX=[[dict valueForKey:@"per"] floatValue];
        tempArr=[dict valueForKey:@"list"];
        CGFloat max=[[dict valueForKey:@"max"] floatValue];
        for (NSInteger i=0; i<tempArr.count; i++) {
            NSDictionary *dict=tempArr[i];
            double maxValue=[dict[@"max"] doubleValue];
            double minValue=[dict[@"min"] doubleValue];
            if (value<=maxValue&&value>=minValue) {
                CGFloat progress=i*perX+perX*(value-minValue)/(maxValue-minValue);
                valueX=(progress/max)*width;
            }
        }
    }
    return valueX;
}


#pragma mark 判断结果说明
-(NSString *)getStandardContentWithResult:(NSString *)resultStr key:(NSString *)key{
    NSString *contentStr=nil;
    if ([key isEqualToString:@"weight"]) {  //体重
        if ([resultStr isEqualToString:@"偏瘦"]) {
            contentStr=@"您的体重目前偏瘦，可能会导致营养不良、免疫力低等；请适当增加饮食热量并坚持每日运动。";
        }else if ([resultStr isEqualToString:@"标准"]){
            contentStr=@"您的体重目前标准，请继续保持健康的生活方式。";
        }else if ([resultStr isEqualToString:@"超重"]){
            contentStr=@"您的体重目前超重，可能容易引发各种慢性疾病，请调整饮食结构控制饮食热量并坚持每日30分钟以上的运动。";
        }
    }else if ([key isEqualToString:@"BMI"]) {  //BMI
        if ([resultStr isEqualToString:@"偏瘦"]) {
            contentStr=@"您的BMI指数偏瘦，容易引起免疫力低下等健康问题；请合理的调整膳食结构并加强运动来增强免疫力。";
        }else if ([resultStr isEqualToString:@"正常"]){
            contentStr=@"您的BMI指数正常，请继续保持健康的生活方式。";
        }else if ([resultStr isEqualToString:@"偏胖"]){
            contentStr=@"您的BMI指数偏胖，非常值得引起注意；若体脂肪率同时处于偏高的状态，则容易引起代谢类疾病等各种健康问题的风险，请及时调整膳食结构控制饮食总热量并坚持每天运动。";
        }else{
            contentStr=@"您的BMI指数肥胖，一定要引起注意；请一定严格控制饮食总热量的摄入，合理搭配膳食结构，每天坚持运动最少30分钟。";
        }
    }else if ([key isEqualToString:@"bodyfat"]) {  //体脂肪率
        if ([resultStr isEqualToString:@"偏低"]) {
            contentStr=@"您的体脂肪率偏低，可能会导致内分泌失调等健康问题；请合理调整饮食结构并坚持每天运动。";
        }else if ([resultStr isEqualToString:@"标准"]){
            contentStr=@"您的体脂肪率标准，请继续保持健康的生活方式。";
        }else if ([resultStr isEqualToString:@"偏高"]){
            contentStr=@"您的体脂肪率偏高，请控制食物的总热量并坚持每天运动。";
        }else{
            contentStr=@"您的体脂肪率严重偏高，可能会增加许多慢病患病的风险。请一定控制食物的总热量并坚持每天至少30分钟的运动。";
        }
    }else if ([key isEqualToString:@"water"]){  //体水分率
        if ([resultStr isEqualToString:@"偏低"]) {
            contentStr=@"您的体水分率偏低，可能会导致人体代谢循环不畅，毒素和废物不容易排出体外。";
        }else if ([resultStr isEqualToString:@"标准"]){
            contentStr=@"您的体水分率标准，请继续保持健康的生活方式。";
        }else{
            contentStr=@"您的体水分率充足，请继续保持健康的生活方式。";
        }
    }else if ([key isEqualToString:@"bone"]){   //骨量
        if ([resultStr isEqualToString:@"偏低"]) {
            contentStr=@"您的骨量情况偏低，请适量的补钙，以及胶原蛋白。";
        }else if ([resultStr isEqualToString:@"达标"]){
            contentStr=@"您的骨量情况达标，请继续保持健康的生活方式。";
        }else{
            contentStr=@"您的骨量情况充足，请继续保持良好的饮食和运动习惯。";
        }
    }else if ([key isEqualToString:@"muscle"]){  //骨骼肌率
        if ([resultStr isEqualToString:@"偏低"]) {
            contentStr=@"您的骨骼肌率偏低，骨骼肌率过少可能意味着钙磷缺乏、可能会导致骨质疏松。";
        }else if ([resultStr isEqualToString:@"达标"]){
            contentStr=@"您的骨骼肌率达标，请继续保持健康的生活方式。";
        }else{
            contentStr=@"您的骨骼肌率充足，请继续保持良好的饮食和运动习惯。";
        }
    }else if ([key isEqualToString:@"protein"]){ //蛋白质
        if ([resultStr isEqualToString:@"偏低"]) {
            contentStr=@"您的蛋白质偏低，缺乏蛋白质会引起肌肉无力、营养不良、贫血、也会引起免疫力下降等。";
        }else if ([resultStr isEqualToString:@"标准"]){
            contentStr=@"您的蛋白质标准，请继续保持健康的生活方式。";
        }else{
            contentStr=@"您的蛋白质充足，请继续保持健康的生活方式。";
        }
    }else if ([key isEqualToString:@"visfat"]){   //内脏脂肪等级
        if ([resultStr isEqualToString:@"良好"]) {
            contentStr=@"您的内脏脂肪等级良好，请继续保持良好的饮食和运动习惯。";
        }else if ([resultStr isEqualToString:@"达标"]){
            contentStr=@"您的内脏脂肪等级达标，请继续保持健康的生活方式。";
        }else if ([resultStr isEqualToString:@"偏高"]){
            contentStr=@"您的内脏脂肪等级偏高，值得引起注意；请一定要控制饮食总热量并且坚持每天运动。";
        }else{
            contentStr=@"您的内脏脂肪等级严重超标，一定要引起注意；请一定要控制饮食总热量并且坚持每天至少30分钟以上的运动。";
        }
    }else if ([key isEqualToString:@"bmr"]){     //基础代谢量
        if ([resultStr isEqualToString:@"偏低"]) {
            contentStr=@"您的基础代谢量偏低，请适量的的调整饮食结构并且坚持运动。";
        }else if ([resultStr isEqualToString:@"达标"]){
            contentStr=@"您的基础代谢量达标，请继续保持健康的生活方式。";
        }else{
            contentStr=@"您的基础代谢量良好，请继续保持良好的饮食和运动习惯。";
        }
    }else if ([key isEqualToString:@"subfat"]){   //皮下脂肪率
        if ([resultStr isEqualToString:@"偏低"]) {
            contentStr=@"您的皮下脂肪率良好，请继续保持良好的饮食和运动习惯。";
        }else if ([resultStr isEqualToString:@"达标"]){
            contentStr=@"您的皮下脂肪率达标，请继续保持健康的生活方式。";
        }else if([resultStr isEqualToString:@"偏高"]){
            contentStr=@"您的皮下脂肪率偏高，值得引起注意；请适量的的调整饮食结构并且坚持运动。";
        }else{
            contentStr=@"您的皮下脂肪率严重偏高，一定要引起注意；请一定要控制饮食总热量并且坚持每天至少30分钟以上的运动。";
        }
    }
    return contentStr;
}

#pragma mark 判断结果文字颜色
-(UIColor *)getResultColorWithResult:(NSString *)resultStr key:(NSString *)key{
    UIColor *textColor;
    if ([key isEqualToString:@"bodyfat"]) {  //体脂肪率
        if ([resultStr isEqualToString:@"偏低"]) {
            textColor=kScaleBlue;
        }else if ([resultStr isEqualToString:@"标准"]){
            textColor=kScaleGreen;
        }else if ([resultStr isEqualToString:@"偏高"]){
            textColor=kScaleOrange;
        }else{
            textColor=kScaleRed;
        }
    }else if ([key isEqualToString:@"water"]){  //体水分率
        if ([resultStr isEqualToString:@"偏低"]) {
            textColor=kScaleBlue;
        }else if ([resultStr isEqualToString:@"标准"]){
            textColor=kScaleGreen;
        }else{
            textColor=kScaleGreenMore;
        }
    }else if ([key isEqualToString:@"bone"]){   //骨量
        if ([resultStr isEqualToString:@"偏低"]) {
            textColor=kScaleBlue;
        }else if ([resultStr isEqualToString:@"达标"]){
            textColor=kScaleGreen;
        }else{
            textColor=kScaleGreenMore;
        }
    }else if ([key isEqualToString:@"muscle"]){  //骨骼肌率
        if ([resultStr isEqualToString:@"偏低"]) {
            textColor=kScaleBlue;
        }else if ([resultStr isEqualToString:@"达标"]){
            textColor=kScaleGreen;
        }else{
            textColor=kScaleGreenMore;
        }
    }else if ([key isEqualToString:@"protein"]){ //蛋白质
        if ([resultStr isEqualToString:@"偏低"]) {
            textColor=kScaleBlue;
        }else if ([resultStr isEqualToString:@"标准"]){
            textColor=kScaleGreen;
        }else{
            textColor=kScaleGreenMore;
        }
    }else if ([key isEqualToString:@"visfat"]){   //内脏脂肪等级
        if ([resultStr isEqualToString:@"良好"]) {
            textColor=kScaleGreenMore;
        }else if ([resultStr isEqualToString:@"达标"]){
            textColor=kScaleGreen;
        }else if ([resultStr isEqualToString:@"偏高"]){
            textColor=kScaleOrange;
        }else{
            textColor=kScaleRed;
        }
    }else if ([key isEqualToString:@"bmr"]){     //基础代谢量
        if ([resultStr isEqualToString:@"偏低"]) {
            textColor=kScaleBlue;
        }else if ([resultStr isEqualToString:@"达标"]){
            textColor=kScaleGreen;
        }else{
            textColor=kScaleGreenMore;
        }
    }else if ([key isEqualToString:@"subfat"]){   //皮下脂肪率
        if ([resultStr isEqualToString:@"偏低"]) {
            textColor=kScaleBlue;
        }else if ([resultStr isEqualToString:@"达标"]){
            textColor=kScaleGreen;
        }else if([resultStr isEqualToString:@"偏高"]){
            textColor=kScaleOrange;
        }else{
            textColor=kScaleRed;
        }
    }else if ([key isEqualToString:@"bmi"]){
        if ([resultStr isEqualToString:@"偏廋"]) {
            textColor=kScaleBlue;
        }else if ([resultStr isEqualToString:@"正常"]){
            textColor=kScaleGreen;
        }else if([resultStr isEqualToString:@"偏胖"]){
            textColor=kScaleOrange;
        }else{
            textColor=kScaleRed;
        }
    }else if ([key isEqualToString:@"weight"]){
        if ([resultStr isEqualToString:@"偏廋"]) {
            textColor=kScaleBlue;
        }else if ([resultStr isEqualToString:@"超重"]){
            textColor=kScaleRed;
        }else{
            textColor=kScaleGreen;
        }
    }
    return textColor;
}


#pragma mark 体重
-(NSString *)getWeightStandardWithWeight:(double)weight{
    NSString *resultString=@"";
    TJYUserModel *user=_scaleUser;
    NSInteger height=[user.height integerValue];
    double lowWeight=0.8*(height-105);
    double  highWeight=1.2*(height-105);
    if (weight>0.0) {
        if (weight<lowWeight) {
            resultString=@"偏瘦";
        }else if (weight>highWeight){
            resultString=@"超重";
        }else{
            resultString=@"标准";
        }
    }
    return resultString;
}

#pragma mark BMI
-(NSString *)getBMIStandardWithBmi:(double)bmi{
    NSString *resultString=@"";
    if (bmi>0.0) {
        if (bmi<18.5) {
            resultString=@"偏瘦";
        }else if (bmi>=18.5&&bmi<=24.9){
            resultString=@"正常";
        }else if (bmi>=25.0&&bmi<=29.9){
            resultString=@"偏胖";
        }else if (bmi>29.9&&bmi<=60.0){
            resultString=@"肥胖";
        }else{
            resultString=@"肥胖";
        }
    }
    return resultString;
}

#pragma mark 体脂肪率
-(NSString *)getBodyFatStandardWithBodyfat:(double)bodyfat{
    NSString *resultString=@"";
    NSInteger sex=self.scaleUser.sex;
    if (bodyfat>0.0) {
        if (sex==1) {
            if (bodyfat<11.0) {
                resultString=@"偏低";
            }else if (bodyfat>=11.0&&bodyfat<=21.0){
                resultString=@"标准";
            }else if (bodyfat>21&&bodyfat<=26.0){
                resultString=@"偏高";
            }else{
                resultString=@"严重偏高";
            }
        }else if(sex==2){
            if (bodyfat<21.0) {
                resultString=@"偏低";
            }else if (bodyfat>=21.0&&bodyfat<=31.0){
                resultString=@"标准";
            }else if (bodyfat>31&&bodyfat<=36){
                resultString=@"偏高";
            }else{
                resultString=@"严重偏高";
            }
        }
    }
    return resultString;
}

#pragma mark 体水分率
-(NSString *)getWaterStandardWithWater:(double)water{
    NSString *resultString=@"";
    NSInteger sex=_scaleUser.sex;
    if (water>0.0) {
        if (sex==1) {
            if (water<55.0) {
                resultString=@"偏低";
            }else if (water>=55.0&&water<=65.0){
                resultString=@"标准";
            }else if (water>65.0&&water<=100){
                resultString=@"充足";
            }
        }else if(sex==2){
            if (water<45.0) {
                resultString=@"偏低";
            }else if (water>=45.0&&water<=60.0){
                resultString=@"标准";
            }else if (water>60.0&&water<=100){
                resultString=@"充足";
            }
        }
    }
    return resultString;
}

#pragma mark 骨量
-(NSString *)getBoneStandardWithBone:(double)bone{
    NSString *resultString=@"";
    NSInteger sex=_scaleUser.sex;
    double weight=[_scaleUser.weight doubleValue] ;
    if (bone>0.0) {
        if (sex==1) {
            if (weight<=60.0) {
                if (bone<2.25) {
                    resultString=@"偏低";
                }else if (bone>=2.25&&bone<=2.75){
                    resultString=@"达标";
                }else if (bone>2.75&&bone<=10){
                    resultString=@"充足";
                }
            }else if (weight>60.0&&weight<=75.0){
                if (bone<2.61) {
                    resultString=@"偏低";
                }else if (bone>=2.61&&bone<=3.19){
                    resultString=@"达标";
                }else if (bone>3.19&&bone<=10){
                    resultString=@"充足";
                }
            }else if (weight>75.0){
                if (bone<2.88) {
                    resultString=@"偏低";
                }else if (bone>=2.88&&bone<=3.52){
                    resultString=@"达标";
                }else if (bone>3.52&&bone<=10){
                    resultString=@"充足";
                }
            }
        }else if(sex==2){
            if (weight<=45.0) {
                if (bone<1.62) {
                    resultString=@"偏低";
                }else if (bone>=1.62&&bone<=1.98){
                    resultString=@"达标";
                }else if (bone>1.98&&bone<=10){
                    resultString=@"充足";
                }
            }else if (weight>45.0&&weight<=60.0){
                if (bone<1.98) {
                    resultString=@"偏低";
                }else if (bone>=1.98&&bone<=2.42){
                    resultString=@"达标";
                }else if (bone>2.42&&bone<=10){
                    resultString=@"充足";
                }
            }else if (weight>60.0){
                if (bone<2.25) {
                    resultString=@"偏低";
                }else if (bone>=2.25&&bone<=2.75){
                    resultString=@"达标";
                }else if (bone>2.75&&bone<=10){
                    resultString=@"充足";
                }
            }
        }
    }
    
    return resultString;
}

#pragma mark 骨骼肌率
-(NSString *)getMuscleStandardWithMuscle:(double)muscle{
    NSString *resultString=@"";
    NSInteger sex=_scaleUser.sex;
    if (muscle>0) {
        if (sex==1) {
            if (muscle<49.0) {
                resultString=@"偏低";
            }else if (muscle>=49.0&&muscle<=59.0){
                resultString=@"达标";
            }else if (muscle>59.0&&muscle<=100){
                resultString=@"充足";
            }
        }else if(sex==2){
            if (muscle<40.0) {
                resultString=@"偏低";
            }else if (muscle>=40.0&&muscle<=50.0){
                resultString=@"达标";
            }else if (muscle>50.0&&muscle<=100){
                resultString=@"充足";
            }
        }
    }
    return resultString;
}

#pragma mark 蛋白质
-(NSString *)getProteinStandardWithProtein:(double)protein{
    NSString *resultString=@"";
    NSInteger sex=_scaleUser.sex;
    if (protein>0) {
        if (sex==1) {
            if (protein<12.0) {
                resultString=@"偏低";
            }else if (protein>=12.0&&protein<=20.0){
                resultString=@"标准";
            }else if (protein>20.0&&protein<=50){
                resultString=@"充足";
            }
        }else if(sex==2){
            if (protein<11.0) {
                resultString=@"偏低";
            }else if (protein>=11.0&&protein<=18.0){
                resultString=@"标准";
            }else if (protein>18.0&&protein<=50){
                resultString=@"充足";
            }
        }
    }
    return resultString;
}

#pragma mark 内脏脂肪等级
-(NSString *)getVisfatStandardWithVisfat:(NSInteger)visfat{
    NSString *resultString=@"";
    if (visfat>0) {
        if (visfat<8) {
            resultString=@"良好";
        }else if (visfat>=8&&visfat<=9){
            resultString=@"达标";
        }else if (visfat>9&&visfat<=14){
            resultString=@"偏高";
        }else{
            resultString=@"严重超标";
        }
    }
    return resultString;
}

#pragma mark 基础代谢率
-(NSString *)getBmrStandardWithBmr:(double)bmr{
    NSString *resultString=@"";
    NSString *bornDateStr=_scaleUser.birthday;
    NSInteger sex=_scaleUser.sex;
    NSInteger age=[[TJYHelper sharedTJYHelper] getCurrentAgeWithBornDate:bornDateStr];
    
    MyLog(@"birthday:%@,age:%ld,sex:%ld",bornDateStr,(long)age,(long)sex);
    
    if (bmr>0) {
        if (sex==1) {
            if (age>=18&&age<=29) {
                if (bmr<1240.0) {
                    resultString=@"偏低";
                }else if (bmr>=1240.0&&bmr<=1860.0){
                    resultString=@"达标";
                }else if (bmr>1860.0&&bmr<3000.0){
                    resultString=@"良好";
                }
            }else if (age>29&&age<=49){
                if (bmr<1200.0) {
                    resultString=@"偏低";
                }else if (bmr>=1200.0&&bmr<=1800.0){
                    resultString=@"达标";
                }else if (bmr>1800.0&&bmr<3000.0){
                    resultString=@"良好";
                }

            }else if (age>49&&age<=69){
                if (bmr<1080.0) {
                    resultString=@"偏低";
                }else if (bmr>=1080.0&&bmr<=1620.0){
                    resultString=@"达标";
                }else if (bmr>1620.0&&bmr<3000.0){
                    resultString=@"良好";
                }

            }else if (age>69){
                if (bmr<976.0) {
                    resultString=@"偏低";
                }else if (bmr>=976.0&&bmr<=1464.0){
                    resultString=@"达标";
                }else if (bmr>1464.0&&bmr<3000.0){
                    resultString=@"良好";
                }

            }
        }else if(sex==2){
            if (age>=18&&age<=29) {
                if (bmr<968.0) {
                    resultString=@"偏低";
                }else if (bmr>=968.0&&bmr<=1404.0){
                    resultString=@"达标";
                }else if (bmr>1404.0&&bmr<3000.0){
                    resultString=@"良好";
                }
            }else if (age>29&&age<=49){
                if (bmr<888.0) {
                    resultString=@"偏低";
                }else if (bmr>=888.0&&bmr<=1332.0){
                    resultString=@"达标";
                }else if (bmr>1332.0&&bmr<3000.0){
                    resultString=@"良好";
                }
            }else if (age>49&&age<=69){
                if (bmr<808.0) {
                    resultString=@"偏低";
                }else if (bmr>=808.0&&bmr<=1212.0){
                    resultString=@"达标";
                }else if (bmr>1212.0&&bmr<3000.0){
                    resultString=@"良好";
                }
            }else if (age>69){
                if (bmr<1240.0) {
                    resultString=@"偏低";
                }else if (bmr>=1240.0&&bmr<=1860.0){
                    resultString=@"达标";
                }else if (bmr>1860.0&&bmr<3000.0){
                    resultString=@"良好";
                }
            }
        }
    }
    
    return resultString;
}

#pragma mark 皮下脂肪率
-(NSString *)getSubfatStandardWithSubfat:(double)subfat{
    NSString *resultString=@"";
    NSInteger sex=_scaleUser.sex;
    if (subfat>0) {
        if (sex==1) {
            if (subfat<8.6) {
                resultString=@"良好";
            }else if (subfat>=8.6&&subfat<=16.7){
                resultString=@"达标";
            }else if (subfat>16.7&&subfat<=20.7){
                resultString=@"偏高";
            }else if (subfat>20.7&&subfat<=50){
                resultString=@"严重偏高";
            }
        }else if(sex==2){
            if (subfat<18.5) {
                resultString=@"良好";
            }else if (subfat>=18.5&&subfat<=26.7){
                resultString=@"达标";
            }else if (subfat>26.7&&subfat<=30.8){
                resultString=@"偏高";
            }else{
                resultString=@"严重偏高";
            }
        }
    }
    return resultString;
}

@end
