//
//  RecordViewController.m
//  Product
//
//  Created by vision on 17/4/13.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecordViewController.h"
#import "RecordButton.h"
#import "RecordDietViewController.h"
#import "RecordSportViewController.h"
#import "RecordStepStaticsViewController.h"
#import "RecordWeightViewController.h"
#import "RecordBloodViewController.h"
#import "LoginViewController.h"
#import "BaseNavigationController.h"

@interface RecordViewController (){

    NSInteger sum_calorie;
}

@property(nonatomic ,strong)UIScrollView      *rootScrollView;
@property(nonatomic ,strong)RecordButton      *dietButton;
@property(nonatomic ,strong)RecordButton      *sportButton;
@property(nonatomic ,strong)RecordButton      *walkButton;
@property(nonatomic ,strong)RecordButton      *weightButton;
@property(nonatomic ,strong)RecordButton      *bloodButton;
@property(nonatomic ,strong)NSArray           *recommendArray;
@property(nonatomic ,strong)NSArray           *everyArray;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"记录";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.isHiddenBackBtn=YES;
    [self initRecordView];
    
    [self loadAllNewRecordData];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (kIsLogined) {
        if ([TJYHelper sharedTJYHelper].isSportsRecordReload) {
            [self requsetSportHeaithData];
            [TJYHelper sharedTJYHelper].isSportsRecordReload= NO;
        }
        if ([TJYHelper sharedTJYHelper].isRecordDietReload) {
            [self requestFoodHealthData];
            [TJYHelper sharedTJYHelper].isRecordDietReload=NO;
        }
        if ([TJYHelper sharedTJYHelper].isWeightReload) {
            [self requsetWeightHealthData];
            [TJYHelper sharedTJYHelper].isWeightReload=NO;
        }
        if ([TJYHelper sharedTJYHelper].isBloodReload) {
            [self requsetBloodHealthData];
            [TJYHelper sharedTJYHelper].isBloodReload=NO;
        }
        //刷新记录页面
        if ([TJYHelper sharedTJYHelper].isRecordReload) {
            [self loadAllNewRecordData];
            [TJYHelper sharedTJYHelper].isRecordReload=NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005" type:2];
#endif
}
 
#pragma mark -- Event Methods
#pragma mark 获取数据
-(void)loadAllNewRecordData{
    [self requestStepCount];
    
    if (kIsLogined) {
        [self requestFoodHealthData];
        [self requsetSportHeaithData];
        [self requsetWeightHealthData];
        [self requsetBloodHealthData];
    }else{
        [self.rootScrollView.mj_header endRefreshing];
    }
}


#pragma mark -- 获取饮食数据
- (void)requestFoodHealthData{

    kSelfWeak;
    NSInteger startTimeSp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:[[TJYHelper sharedTJYHelper] getCurrentDate] format:@"yyyy-MM-dd"];
    NSString *body=[NSString stringWithFormat:@"feeding_time_begin=%ld&feeding_time_end=%ld&output-way=1",(long)startTimeSp,(long)startTimeSp];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kDietRecordLists body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        //饮食摄入能量值
        NSString *allCalories =[NSString stringWithFormat:@"%@千卡",[result valueForKey:@"all_calories"]];
        weakSelf.dietButton.recordDict = @{@"image":@"ic_hea_food",@"content":allCalories,@"title":@"饮食",@"date":@"今日",@"color":@"0x05d380"};
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark -- 获取运动数据
- (void)requsetSportHeaithData{
    kSelfWeak;
    NSInteger startTimeSp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:[[TJYHelper sharedTJYHelper] getCurrentDate] format:@"yyyy-MM-dd"];
    NSString *body=[NSString stringWithFormat:@"motion_bigin_time_begin=%ld&motion_bigin_time_end=%ld&output-way=1",(long)startTimeSp,(long)startTimeSp];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kSportRecordLists body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            NSString *allCalories=[NSString stringWithFormat:@"%@千卡",[result valueForKey:@"all_calories"]];
            weakSelf.sportButton.recordDict = @{@"image":@"ic_hea_sport",@"content":allCalories,@"title":@"运动",@"date":@"今日",@"color":@"0x00a0e9"};
        }
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark -- 获取步数
-(void)requestStepCount{
    NSInteger stepCount=[[NSUserDefaultInfos getValueforKey:kStepKey] integerValue];
    NSString *stepStr=stepCount>0?[NSString stringWithFormat:@"%ld 步",(long)stepCount]:@"0 步";
    self.walkButton.recordDict=@{@"image":@"ic_hea_step",@"content":stepStr,@"title":@"步数",@"date":@"今日",@"color":@"0xfece26"};
}

#pragma mark -- 获取体重数据
- (void)requsetWeightHealthData{
    
    NSString *nowData = [[TJYHelper sharedTJYHelper] getLastWeekDateWithDays:-1];
    NSString *sexData = [[TJYHelper sharedTJYHelper] getLastWeekDateWithDays:365];
    NSInteger nowdata = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:nowData format:@"yyyy-MM-dd"];
    NSInteger sexdata = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:sexData format:@"yyyy-MM-dd"];
    
    NSString *body = [NSString stringWithFormat:@"page_num=1&page_size=20&start_time=%ld&end_time=%ld&type=2",(long)sexdata,(long)nowdata];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kWeightRecordList body:body success:^(id json) {
        NSDictionary *weightDict= [json objectForKey:@"result"];
        if (kIsDictionary(weightDict)) {
            NSArray *titleArray = [weightDict allKeys];
            NSMutableArray *timedataArray =[[TJYHelper sharedTJYHelper] loadMaxTime:titleArray];
            NSArray *dataArray = [weightDict objectForKey:timedataArray[0]];
            NSDictionary *dataDic = dataArray[0];
            NSString *timeString = [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:[dataDic objectForKey:@"add_time"] format:@"yyyy-MM-dd HH:mm"];
            double weight=[[dataDic objectForKey:@"weight"] doubleValue];
            NSString *weightStr = [NSString stringWithFormat:@"%.1fkg",weight>0?weight:0];
            weakSelf.weightButton.recordDict = @{@"image":@"ic_hea_weight",@"content":weightStr,@"title":@"体重",@"date":timeString,@"color":@"0xffaa52"};

        }
    } failure:^(NSString *errorStr) {
        
        
    }];
}
#pragma mark -- 获取血压数据
- (void)requsetBloodHealthData{
    NSString *nowData = [[TJYHelper sharedTJYHelper] getLastWeekDateWithDays:-1];
    NSString *sexData = [[TJYHelper sharedTJYHelper] getLastWeekDateWithDays:365];
    NSInteger nowdata = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:nowData format:@"yyyy-MM-dd"];
    NSInteger sexdata = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:sexData format:@"yyyy-MM-dd"];
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"start_time=%ld&end_time=%ld",(long)sexdata,(long)nowdata];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kBloodRecordList body:body success:^(id json) {
        
        NSArray *bloodArray = [json objectForKey:@"result"];
        if (kIsArray(bloodArray)&&bloodArray.count>0) {
            NSDictionary *dataArray = bloodArray[bloodArray.count-1];
            NSString *timeStr = [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:[dataArray objectForKey:@"measure_time"] format:@"yyyy-MM-dd HH:mm"];
            NSInteger systolic_pressure = [[dataArray objectForKey:@"systolic_pressure"] integerValue];
            NSInteger diastolic_pressure = [[dataArray objectForKey:@"diastolic_pressure"] integerValue];
            NSString *bloodStr = [NSString stringWithFormat:@"%ld/%ldmmHg",(long)(systolic_pressure>0?systolic_pressure:0),(long)(diastolic_pressure>0?diastolic_pressure:0)];
            weakSelf.bloodButton.recordDict = @{@"image":@"ic_hea_blood",@"content":bloodStr,@"title":@"血压",@"date":timeStr,@"color":@"0xfb7b7a"};
        }
        
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark -- Event pesponse
#pragma mark -- 饮食记录
- (void)dietRecord{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01"];
#endif
    if (kIsLogined) {
        RecordDietViewController *dietVC = [[RecordDietViewController alloc] init];
        dietVC.targetEnergy = [[NSUserDefaultInfos getValueforKey:kDailyEnergy] integerValue];
        dietVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:dietVC animated:YES];
    }else{
        [self pushToFastLogin];
    }
    
}
#pragma mark -- 运动记录
- (void)sportRecord{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-03"];
#endif
    if (kIsLogined) {
        RecordSportViewController *sportVC = [[RecordSportViewController alloc] init];
        sportVC.targetEnergy = [_recommendArray[_recommendArray.count-1] integerValue];
        sportVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:sportVC animated:YES];
    }else{
        [self pushToFastLogin];
    }
    
}
#pragma mark -- 步数
- (void)walkRecord{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-04"];
#endif
    RecordStepStaticsViewController *stepStartVC = [[RecordStepStaticsViewController alloc] init];
    stepStartVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:stepStartVC animated:YES];
}
#pragma mark -- 体重
- (void)weightRecord{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-05"];
#endif
    if (kIsLogined) {
        RecordWeightViewController *weightVC = [[RecordWeightViewController alloc] init];
        weightVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:weightVC animated:YES];
    }else{
        [self pushToFastLogin];
    }
    
}
#pragma mark -- 血压
- (void)bloodRecord{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-06"];
#endif
    if (kIsLogined) {
        RecordBloodViewController *bloodVC =[[RecordBloodViewController alloc] init];
        bloodVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:bloodVC animated:YES];
    }else{
        [self pushToFastLogin];
    }
    
}

#pragma mark -- 初始化界面
- (void)initRecordView{
    
    self.rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0,kNewNavHeight, kScreenWidth, kScreenHeight-kNewNavHeight-kTabbarHeight)];
    self.rootScrollView.showsVerticalScrollIndicator=NO;
    self.rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    [self.view addSubview:self.rootScrollView];
    
    //  下拉加载最新
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadAllNewRecordData)];
    header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
    self.rootScrollView.mj_header=header;

    [self.rootScrollView addSubview:self.dietButton];
    [self.rootScrollView addSubview:self.sportButton];
    [self.rootScrollView addSubview:self.walkButton];
    [self.rootScrollView addSubview:self.weightButton];
    [self.rootScrollView addSubview:self.bloodButton];
    self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.bloodButton.bottom);
}

#pragma  mark -- setters
#pragma mark -- 饮食
- (RecordButton *)dietButton{
    if (_dietButton==nil) {
        _dietButton = [[RecordButton alloc] initWithFrame:CGRectMake(5, 10, (kScreenWidth-20)/2, 180)];
        _dietButton.backgroundColor = [UIColor whiteColor];
        _dietButton.recordDict = @{@"image":@"ic_hea_food",@"content":@"0",@"title":@"饮食",@"date":@"今日",@"color":@"0x05d380"};
        [_dietButton addTarget:self action:@selector(dietRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dietButton;
}

#pragma mark -- 运动
- (RecordButton *)sportButton{
    if (_sportButton==nil) {
        _sportButton = [[RecordButton alloc] initWithFrame:CGRectMake(5+kScreenWidth/2, 10, (kScreenWidth-20)/2, 180)];
        _sportButton.backgroundColor = [UIColor whiteColor];
        _sportButton.recordDict = @{@"image":@"ic_hea_sport",@"content":@"0",@"title":@"运动",@"date":@"今日",@"color":@"0x00a0e9"};
        [_sportButton addTarget:self action:@selector(sportRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sportButton;
}

#pragma mark -- 步数
- (RecordButton *)walkButton{
    if (_walkButton==nil) {
        _walkButton = [[RecordButton alloc] initWithFrame:CGRectMake(5, _dietButton.bottom+10, (kScreenWidth-20)/2, 180)];
        _walkButton.backgroundColor = [UIColor whiteColor];
        _walkButton.recordDict = @{@"image":@"ic_hea_step",@"content":@"0",@"title":@"步数",@"date":@"今日",@"color":@"0xfece26"};
        [_walkButton addTarget:self action:@selector(walkRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _walkButton;
}

#pragma mark -- 体重
- (RecordButton *)weightButton{
    if (_weightButton==nil) {
        _weightButton = [[RecordButton alloc] initWithFrame:CGRectMake(5+kScreenWidth/2, _dietButton.bottom+10, (kScreenWidth-20)/2, 180)];
        _weightButton.backgroundColor = [UIColor whiteColor];
        _weightButton.recordDict = @{@"image":@"ic_hea_weight",@"content":@"--kg",@"title":@"体重",@"date":@"",@"color":@"0xffaa52"};
        [_weightButton addTarget:self action:@selector(weightRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _weightButton;
}

#pragma mark -- 血压
- (RecordButton *)bloodButton{
    if (_bloodButton==nil) {
        _bloodButton = [[RecordButton alloc] initWithFrame:CGRectMake(5, _walkButton.bottom+10, (kScreenWidth-20)/2, 180)];
        _bloodButton.backgroundColor = [UIColor whiteColor];
        _bloodButton.recordDict = @{@"image":@"ic_hea_blood",@"content":@"--/--mmHg",@"title":@"血压",@"date":@"",@"color":@"0xfb7b7a"};
        [_bloodButton addTarget:self action:@selector(bloodRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bloodButton;
}



@end
