//
//  RecordStepStaticsViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecordStepStaticsViewController.h"
#import "SynchoriseStepViewController.h"
#import "StepRankingViewController.h"
#import "TCHealthManager.h"
#import "RiceStorageChatrsView.h"
#import "TimePickerView.h"
#import "TJYDietCountView.h"

@interface RecordStepStaticsViewController ()<UITextFieldDelegate,UIActionSheetDelegate>{
    UILabel          *stepCountLabel;
    UILabel          *targetStepCountLabel;
    UILabel          *milesLabel;              //公里数
    UILabel          *caloriesLabel;           //能量
    TimePickerView   *pickerView;
    
    NSInteger         targetStepCount;
    NSMutableArray    *stepsArray;           //步数数组
    
    TJYDietCountView        *dietCountView;
}

@property (nonatomic,strong)UIView                 *stepStaticsView;   //步数
@property (nonatomic,strong)UIButton               *synchoriseBtn;     //同步计步器
@property (nonatomic,strong)UIButton               *rankingBtn;        //排行榜
@property (nonatomic,strong)UIView                 *caloriesView;
@property (nonatomic,strong)RiceStorageChatrsView  *stepRecord;

@end

@implementation RecordStepStaticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"步数";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    NSInteger step = [[NSUserDefaultInfos getValueforKey:@"step"] integerValue];
    targetStepCount=step>0?step:6000;
    stepsArray=[[NSMutableArray alloc] init];
    
    [self initStepView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-04" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-04" type:2];
#endif
}


#pragma mark --UIActionSheetDelegate (TimePickerView)
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (pickerView.pickerStyle==PickerStyle_Step) {
            targetStepCount=([pickerView.locatePicker selectedRowInComponent:0]+1)*1000;
            NSMutableAttributedString *targetAttributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"目标：%ld步",(long)targetStepCount]];
            [targetAttributeStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(3, targetAttributeStr.length-4)];
            targetStepCountLabel.attributedText=targetAttributeStr;
            
            [NSUserDefaultInfos putKey:@"step" andValue:[NSString stringWithFormat:@"%ld",(long)targetStepCount]];
            [self getStepCountData];
        }
    }
}
#pragma mark -- Event Response
#pragma mark 设置目标步数
-(void)resetTargetStep:(UITapGestureRecognizer *)gesture{
    pickerView =[[TimePickerView alloc] initWithTitle:@"步数" delegate:self];
    pickerView.pickerStyle=PickerStyle_Step;
    [pickerView.locatePicker selectRow:targetStepCount/1000-1 inComponent:0 animated:YES];
    [pickerView showInView:self.view];
    
    [pickerView pickerView:pickerView.locatePicker didSelectRow:targetStepCount/1000-1 inComponent:0];

}
#pragma mark 去同步健康
-(void)synchoriseStepMachineAction{
    SynchoriseStepViewController *synchoriseVC=[[SynchoriseStepViewController alloc] init];
    [self.navigationController pushViewController:synchoriseVC animated:YES];
}

#pragma mark 排行榜
-(void)goIntoStepRankingAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-04-01"];
#endif
    StepRankingViewController *stepRankingVC=[[StepRankingViewController alloc] init];
    [self.navigationController pushViewController:stepRankingVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 获取步数
-(void)getStepCountData{
    //今日当前步数
    NSInteger stepCount=[[NSUserDefaultInfos getValueforKey:kStepKey] integerValue];
    NSString *stepStr=stepCount>0?[NSString stringWithFormat:@"%ld 步",(long)stepCount]:@"0 步";
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:stepStr];
    [attributeStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0xf39800"]} range:NSMakeRange(0, attributeStr.length-1)];
    stepCountLabel.attributedText=attributeStr;
    
    //目标步数
    NSMutableAttributedString *targetAttributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"目标：%ld步",(long)targetStepCount]];
    [targetAttributeStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(3, targetAttributeStr.length-4)];
    targetStepCountLabel.attributedText=targetAttributeStr;
    
    NSString *high = [NSString stringWithFormat:@"%ld",(long)stepCount];
    NSString *low = [NSString stringWithFormat:@"%ld",targetStepCount-stepCount>0?targetStepCount-stepCount:0];
    NSDictionary *dict = @{@"high":high,@"low":low};
    dietCountView.weekRecordsDict = dict;
    
    BOOL isSynchoriseHealth=[[NSUserDefaultInfos getValueforKey:kIsSynchoriseHealth] boolValue];
    self.synchoriseBtn.hidden=isSynchoriseHealth;
    
    NSInteger distance=[[NSUserDefaultInfos getValueforKey:kDistanceKey] integerValue];
    NSString *stepStr1=distance>0?[NSString stringWithFormat:@"%ld米",(long)distance]:@"0米";
    NSMutableAttributedString *attributeStr1=[[NSMutableAttributedString alloc] initWithString:stepStr1];
    [attributeStr1 addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0xf39800"]} range:NSMakeRange(0, attributeStr1.length-1)];
    milesLabel.attributedText=attributeStr1;

    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    CGFloat maxStep=0;
    NSArray *stepsArr=(NSArray *)[NSUserDefaultInfos getValueforKey:kWeekStepKey];
    for (NSInteger i=stepsArr.count; i>0; i--) {
        NSDictionary *dict=stepsArr[i-1];
        NSString *dateStr=[[TJYHelper sharedTJYHelper] getLastWeekDateWithDays:i-1];
        NSNumber *countNum=[dict valueForKey:dateStr];
        if ([countNum integerValue]>maxStep) {
            maxStep=[countNum integerValue];
        }
        
        [tempArr addObject:countNum];
    }
    stepsArray=tempArr;
    self.stepRecord.maxy=maxStep+1000;
    self.stepRecord.dayArray=[[TJYHelper sharedTJYHelper] getLastWeekdays];
    self.stepRecord.dataArray = stepsArray;
    
    
    
    
    NSString *stepStr2=stepCount>0?[NSString stringWithFormat:@"%ld千卡",(long)(stepCount*0.027+0.5)]:@"0千卡";
    NSMutableAttributedString *attributeStr2=[[NSMutableAttributedString alloc] initWithString:stepStr2];
    [attributeStr2 addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0xf39800"]} range:NSMakeRange(0, attributeStr2.length-2)];
    caloriesLabel.attributedText=attributeStr2;
}
#pragma mark -- 初始化界面
- (void)initStepView{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 170)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    dietCountView = [[TJYDietCountView alloc] initWithFrame:CGRectMake((kScreenWidth-160)/2, 69, 160, 160)];
    dietCountView.layer.cornerRadius =80;
    [self.view addSubview:dietCountView];
    
    [self.view addSubview:self.stepStaticsView];
    [self.view addSubview:self.rankingBtn];
    [self.view addSubview:self.synchoriseBtn];
    [self.view addSubview:self.caloriesView];
    [self.view addSubview:self.stepRecord];
    [self getStepCountData];
}

#pragma mark -- Getters and Setters
#pragma mark 显示步数
-(UIView *)stepStaticsView{
    if (_stepStaticsView==nil) {
        
        _stepStaticsView=[[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-130)/2, 84, 130, 130)];
        _stepStaticsView.layer.cornerRadius=65;
        _stepStaticsView.backgroundColor=[UIColor whiteColor];
        
        UILabel *dayLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 140/3-20, 140-20, 20)];
        dayLabel.text=@"今天";
        dayLabel.textColor=[UIColor blackColor];
        dayLabel.font=[UIFont systemFontOfSize:14.0f];
        dayLabel.textAlignment=NSTextAlignmentCenter;
        [_stepStaticsView addSubview:dayLabel];
        
        stepCountLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, dayLabel.bottom+5, 140-20, 25)];
        stepCountLabel.textAlignment=NSTextAlignmentCenter;
        stepCountLabel.textColor=[UIColor lightGrayColor];
        stepCountLabel.font=[UIFont systemFontOfSize:12.0f];
        [_stepStaticsView addSubview:stepCountLabel];
        
        targetStepCountLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, stepCountLabel.bottom+5, 140-20, 25)];
        targetStepCountLabel.textAlignment=NSTextAlignmentCenter;
        targetStepCountLabel.textColor=[UIColor lightGrayColor];
        targetStepCountLabel.font=[UIFont systemFontOfSize:14.0f];
        [_stepStaticsView addSubview:targetStepCountLabel];
        
        targetStepCountLabel.userInteractionEnabled=YES;
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetTargetStep:)];
        [targetStepCountLabel addGestureRecognizer:tapGesture];
    }
    return _stepStaticsView;
}

#pragma mark 排行榜
-(UIButton *)rankingBtn{
    if (!_rankingBtn) {
        _rankingBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-55, 80, 40, 40)];
        _rankingBtn.layer.cornerRadius = _rankingBtn.width/2;
        [_rankingBtn setImage:[UIImage imageNamed:@"ic_walk_ranklist"] forState:UIControlStateNormal];
        [_rankingBtn addTarget:self action:@selector(goIntoStepRankingAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rankingBtn;
}

#pragma mark 同步计步器
-(UIButton *)synchoriseBtn{
    if (_synchoriseBtn==nil) {
        _synchoriseBtn=[[UIButton alloc] initWithFrame:CGRectMake(20, self.stepStaticsView.bottom+5, kScreenWidth-40, 20)];
        [_synchoriseBtn setTitle:@"未同步计步器>>" forState:UIControlStateNormal];
        _synchoriseBtn.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [_synchoriseBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_synchoriseBtn addTarget:self action:@selector(synchoriseStepMachineAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _synchoriseBtn;
}

#pragma mark 距离和能量
-(UIView *)caloriesView{
    if (_caloriesView==nil) {
        _caloriesView=[[UIView alloc] initWithFrame:CGRectMake(0, self.synchoriseBtn.bottom+5, kScreenWidth, 50)];
        _caloriesView.backgroundColor=[UIColor whiteColor];
        
        milesLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth/2-1, 30)];
        milesLabel.textColor=[UIColor grayColor];
        milesLabel.textAlignment=NSTextAlignmentCenter;
        milesLabel.font=[UIFont systemFontOfSize:16.0f];
        [_caloriesView addSubview:milesLabel];
        
        UILabel *horline=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-1, 10, 1, 30)];
        horline.backgroundColor=[UIColor bgColor_Gray];
        [_caloriesView addSubview:horline];
        
        caloriesLabel=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2, 10, kScreenWidth/2, 30)];
        caloriesLabel.textColor=[UIColor grayColor];
        caloriesLabel.textAlignment=NSTextAlignmentCenter;
        caloriesLabel.font=[UIFont systemFontOfSize:16.0f];
        caloriesLabel.text=@"0千卡";
        [_caloriesView addSubview:caloriesLabel];
        
    }
    return _caloriesView;
}
#pragma mark 步数图表
-(RiceStorageChatrsView *)stepRecord{
    if (_stepRecord==nil) {
        _stepRecord=[[RiceStorageChatrsView alloc] initWithFrame:CGRectMake(10, _caloriesView.bottom+20, kScreenWidth-20, 200)];
    }
    return _stepRecord;
}

@end
