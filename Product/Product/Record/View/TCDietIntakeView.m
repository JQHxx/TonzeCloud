 //
//  TCDietIntakeView.m
//  TonzeCloud
//
//  Created by fei on 2017/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDietIntakeView.h"
#import "TJYDietCountView.h"

@interface TCDietIntakeView (){
    UILabel                *intakeEnergyLabel;       //摄入量
    UIButton               *setDailyTargetBtn;       //设置每日饮食目标
    TJYDietCountView        *dietCountView;
}

@end

@implementation TCDietIntakeView

-(instancetype)initWithFrame:(CGRect)frame type:(TCDietIntakeViewType)type{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        dietCountView = [[TJYDietCountView alloc] initWithFrame:CGRectMake((kScreenWidth-160)/2, 5, 160, 160)];
        [self addSubview:dietCountView];
        
        UIImageView *circleView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-124)/2, 23, 124, 124)];
        circleView.backgroundColor=[UIColor bgColor_Gray];
        circleView.layer.cornerRadius=62.0;
        circleView.clipsToBounds=YES;
        [self addSubview:circleView];
        
        UIImageView *circleImageView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2, 25, 120, 120)];
        circleImageView.backgroundColor=kSystemColor;
        circleImageView.layer.cornerRadius=60.0;
        circleImageView.clipsToBounds=YES;
        [self addSubview:circleImageView];
        
        intakeEnergyLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, (120-30)/2, 120-20, 30)];
        intakeEnergyLabel.textAlignment=NSTextAlignmentCenter;
        intakeEnergyLabel.textColor=[UIColor whiteColor];
        intakeEnergyLabel.font=[UIFont systemFontOfSize:13.0f];
        [circleImageView addSubview:intakeEnergyLabel];
        
        UILabel *totalIntakeLabel=[[UILabel alloc] initWithFrame:CGRectMake((120-60)/2, intakeEnergyLabel.bottom+10, 60, 20)];
        totalIntakeLabel.textColor=[UIColor whiteColor];
        totalIntakeLabel.textAlignment=NSTextAlignmentCenter;
        totalIntakeLabel.font=[UIFont systemFontOfSize:13.0f];
        [circleImageView addSubview:totalIntakeLabel];
        
        setDailyTargetBtn=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, circleImageView.bottom+25, 200, 30)];
        setDailyTargetBtn.titleLabel.font=[UIFont systemFontOfSize:13.0f];
        [setDailyTargetBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [setDailyTargetBtn setImage:[UIImage imageNamed:@"ic_pub_arrow_nor"] forState:UIControlStateNormal];
        [setDailyTargetBtn addTarget:self action:@selector(setDailyTargetAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:setDailyTargetBtn];
        
        if (type==TCDietIntakeViewDietType) {
            totalIntakeLabel.text=@"总摄入";
            setDailyTargetBtn.hidden=NO;
        }else{
            setDailyTargetBtn.hidden=YES;
            totalIntakeLabel.text=@"总消耗";
        }
    }
    return self;
}

#pragma mark -- Setters and Getters
#pragma mark 摄入量或消耗量
-(void)setEnergyValue:(NSInteger)energyValue{
    _energyValue=energyValue;
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld千卡",(long)energyValue]];
    [attributeStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:25.0f],NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, attributeStr.length-2)];
    intakeEnergyLabel.attributedText=attributeStr;
}

#pragma mark 饮食目标
-(void)setTargetEnergyValue:(NSInteger)targetEnergyValue{
    _targetEnergyValue=targetEnergyValue;
    if (targetEnergyValue>0) {
        [setDailyTargetBtn setTitle:@"" forState:UIControlStateNormal];
        NSString *high = [NSString stringWithFormat:@"%ld",(long)_energyValue];
        NSString *low = [NSString stringWithFormat:@"%ld",(_targetEnergyValue-_energyValue)>0?(_targetEnergyValue-_energyValue):0];
        NSDictionary *dict = @{@"high":high,@"low":low};
        dietCountView.weekRecordsDict = dict;
        NSString *title=[NSString stringWithFormat:@"目标摄入：%ld千卡",targetEnergyValue];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:title];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:kRGBColor(244, 182, 123) range:NSMakeRange(5, attributeStr.length-7)];
        [setDailyTargetBtn setAttributedTitle:attributeStr forState:UIControlStateNormal];
        setDailyTargetBtn.imageEdgeInsets=UIEdgeInsetsMake(0, 170, 0, 0);
    }else{
        NSDictionary *dict = @{@"high":@(0),@"low":@(0)};
        dietCountView.weekRecordsDict = dict;
        [setDailyTargetBtn setTitle:@"设置每日饮食目标" forState:UIControlStateNormal];
        setDailyTargetBtn.imageEdgeInsets=UIEdgeInsetsMake(0, 155, 0, 0);
    }
}

#pragma mark -- Event Response
#pragma mark 设置每日饮食目标
-(void)setDailyTargetAction{
    
    if ([self.delegate respondsToSelector:@selector(dietIntakeViewDidSetDailyTargetIntake)]) {
        [self.delegate dietIntakeViewDidSetDailyTargetIntake];
    }
}


@end
