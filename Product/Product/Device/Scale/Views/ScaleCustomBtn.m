//
//  ScaleCustomBtn.m
//  Product
//
//  Created by vision on 17/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ScaleCustomBtn.h"
#import "ScaleHelper.h"

@interface ScaleCustomBtn (){
    UILabel             *valueLabel;
    UILabel             *titleLabel;
    UILabel             *standardLabel;
}

@end

@implementation ScaleCustomBtn

-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        CGFloat btnW=frame.size.width;
        valueLabel=[[UILabel alloc] initWithFrame:CGRectMake((btnW-100)/2, 5, 110, 40)];
        valueLabel.textAlignment=NSTextAlignmentCenter;
        valueLabel.font=[UIFont boldSystemFontOfSize:30];
        valueLabel.textColor=[UIColor colorWithHexString:@"#ff9d38"];
        [self addSubview:valueLabel];
        
        NSString  *title=[dict valueForKey:@"title"];
        if ([title isEqualToString:@"BMI"]) {
             valueLabel.text=dict[@"value"];
        }else{
            NSMutableAttributedString *valueAttributeAtr=[[NSMutableAttributedString alloc] initWithString:dict[@"value"]];
            [valueAttributeAtr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(valueAttributeAtr.length-2, 2)];
            valueLabel.attributedText=valueAttributeAtr;
        }
        
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake((btnW-40)/2,valueLabel.bottom+5, 40, 20)];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.font=[UIFont systemFontOfSize:15];
        titleLabel.textColor=[UIColor colorWithHexString:@"#626262"];
        titleLabel.text=dict[@"title"];
        [self addSubview:titleLabel];
        
        standardLabel=[[UILabel alloc] initWithFrame:CGRectMake(titleLabel.right+5,titleLabel.top, 40, 24)];
        standardLabel.textAlignment=NSTextAlignmentCenter;
        standardLabel.font=[UIFont systemFontOfSize:12];
        standardLabel.textColor=[UIColor whiteColor];
        standardLabel.layer.cornerRadius=10;
        standardLabel.clipsToBounds=YES;
        [self addSubview:standardLabel];
        standardLabel.hidden=YES;
    }
    return self;
}


-(void)setValueDict:(NSDictionary *)valueDict{
    _valueDict=valueDict;
    if (kIsDictionary(valueDict)&&valueDict.count>0) {
        standardLabel.hidden=NO;
        
        NSInteger type=[[valueDict valueForKey:@"type"] integerValue];
        
        if (type==1) {
            double  value=[[valueDict valueForKey:@"value"] doubleValue];
            standardLabel.hidden=value<0.1;
            NSString *resultStr=[[ScaleHelper sharedScaleHelper] getBMIStandardWithBmi:value];
            if ([resultStr isEqualToString:@"偏廋"]) {
                standardLabel.backgroundColor=kScaleBlue;
            }else if ([resultStr isEqualToString:@"正常"]){
                standardLabel.backgroundColor=kScaleGreen;
            }else if ([resultStr isEqualToString:@"偏胖"]){
                standardLabel.backgroundColor=kScaleOrange;
            }else{
                standardLabel.backgroundColor=kScaleRed;
            }
            MyLog(@"bmi:%.1f",value);
            
            valueLabel.text=[NSString stringWithFormat:@"%.1f",value];
            standardLabel.text=resultStr;
        }else{
            double  value=[[valueDict valueForKey:@"value"] doubleValue];
            standardLabel.hidden=value<0.1;
            NSString *resultStr=[[ScaleHelper sharedScaleHelper] getWeightStandardWithWeight:value];
            if ([resultStr isEqualToString:@"偏廋"]) {
                standardLabel.backgroundColor=kScaleBlue;
            }else if ([resultStr isEqualToString:@"标准"]){
                standardLabel.backgroundColor=kScaleGreen;
            }else{
                standardLabel.backgroundColor=kScaleRed;
            }
            MyLog(@"weight:%.1f",value);
            
            NSMutableAttributedString *valueAttributeAtr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2fkg",value]];
            [valueAttributeAtr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(valueAttributeAtr.length-2, 2)];
            
            valueLabel.attributedText=valueAttributeAtr;
            standardLabel.text=resultStr;
        }
    }
}


@end
