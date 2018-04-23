//
//  RecordBloodViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecordBloodViewController.h"
#import "BloodScaleView.h"
#import "WeightLineChartView.h"
#import "ScaleListViewController.h"

@interface RecordBloodViewController ()<BloodScaleViewDelegate,WeightLineDelegate>{
    
    UIButton *grayButton;
    NSMutableArray *indexArray;
}
@property(nonatomic ,strong)UIScrollView      *rootScrollView;
@property(nonatomic ,strong)WeightLineChartView *lineSystolicPressureCharts;
@property(nonatomic ,strong)WeightLineChartView *lineDiastolicPressureCharts;
@property(nonatomic ,strong)WeightLineChartView *lineHeartRateCharts;

@property (nonatomic, assign) DeviceType chooseDeviceType;

@end

@implementation RecordBloodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"血压";
    self.rightImageName = @"添加";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    indexArray =[[NSMutableArray alloc] init];
    for (int i=0; i<4; i++) {
        [indexArray addObject:@"1"];
    }
    [self initBloodRecordView];
    [self requestBloodData:0];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-06" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-06" type:2];
#endif
}

#pragma mark -- Custom Delegate
#pragma mark  ScaleViewDelegate
-(void)scaleView:(BloodScaleView *)scaleView height:(NSInteger)height low:(NSInteger)low{
    
    NSInteger data =[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:[[TJYHelper sharedTJYHelper] getCurrentDateTime] format:@"yyyy-MM-dd HH:mm"];
    NSString *body = [NSString stringWithFormat:@"diastolic_pressure=%ld&systolic_pressure=%ld&measure_time=%ld&way=1",low,height,data];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kBloodRecordAdd body:body success:^(id json) {
        
        [TJYHelper sharedTJYHelper].isBloodReload=YES;
        [weakSelf requestBloodData:0];
    } failure:^(NSString *errorStr) {
        
    }];
    MyLog(@"%ld",(long)height);
}
#pragma mark --WeightLineChartView
- (void)weightLineChartView:(WeightLineChartView *)ChartView type:(NSInteger)type{
    NSInteger index = [indexArray[type] integerValue];
    index++;
    [indexArray replaceObjectAtIndex:type withObject:[NSString stringWithFormat:@"%ld",index]];
    [self requestBloodData:type];
}

- (void)weightrightLineChartView:(WeightLineChartView *)ChartView type:(NSInteger)type{
    NSInteger index = [indexArray[type] integerValue];
    index--;
    [indexArray replaceObjectAtIndex:type withObject:[NSString stringWithFormat:@"%ld",index]];
    [self requestBloodData:type];
}
#pragma mark -- 滑动获取数据
- (void)requestBloodData:(NSInteger)type{

    NSString *nowData = [[TJYHelper sharedTJYHelper] getLastWeekDateWithDays:([indexArray[type] integerValue]-1)*20-1];
    NSString *sexData = [[TJYHelper sharedTJYHelper] getLastDayDate:[indexArray[type] integerValue]*20-1];
    NSInteger nowdata = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:nowData format:@"yyyy-MM-dd"];
    NSInteger sexdata = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:sexData format:@"yyyy-MM-dd"];
    
    NSString *body = [NSString stringWithFormat:@"start_time=%ld&end_time=%ld",sexdata,nowdata];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kBloodRecordList body:body success:^(id json) {
        NSArray *bloodArray = [json objectForKey:@"result"];
        NSArray *dataArray = [[TJYHelper sharedTJYHelper] getStringDateFromTodayWithDays:20*[indexArray[type] integerValue]];
        
        NSMutableArray *pageArray = [[NSMutableArray alloc] init];
        for (int i=0; i<20; i++) {
            [pageArray addObject:@"0"];
        }
        NSArray *array =pageArray;
        NSMutableArray *diastolic_pressureArray = [NSMutableArray arrayWithArray:array];
        NSMutableArray *systolic_pressureArray =  [NSMutableArray arrayWithArray:array];
        NSMutableArray *heart_rateArray =   [NSMutableArray arrayWithArray:array];

        for (int i=0; i<bloodArray.count; i++) {
            for (int j=0; j<20; j++) {
                
                if ([[bloodArray[i] objectForKey:@"day"] isEqualToString:dataArray[j]]) {
                    [diastolic_pressureArray replaceObjectAtIndex:j withObject:[bloodArray[i] objectForKey:@"diastolic_pressure"]];
                    [systolic_pressureArray replaceObjectAtIndex:j withObject:[bloodArray[i] objectForKey:@"systolic_pressure"]];
                    [heart_rateArray replaceObjectAtIndex:j withObject:[bloodArray[i] objectForKey:@"heart_rate"]];
                }
            }
        }
        if (type==1) {
            weakSelf.lineSystolicPressureCharts.page = [indexArray[type] integerValue];
            weakSelf.lineSystolicPressureCharts.bloodDataArray = diastolic_pressureArray;
        }else if (type==0){
            weakSelf.lineSystolicPressureCharts.page = [indexArray[type] integerValue];
            weakSelf.lineDiastolicPressureCharts.page = [indexArray[type] integerValue];
            weakSelf.lineHeartRateCharts.page = [indexArray[type] integerValue];
            weakSelf.lineHeartRateCharts.bloodDataArray  = heart_rateArray;
            weakSelf.lineDiastolicPressureCharts.bloodDataArray = systolic_pressureArray;
            weakSelf.lineSystolicPressureCharts.bloodDataArray = diastolic_pressureArray;

        }else if (type==2){
            weakSelf.lineDiastolicPressureCharts.page = [indexArray[type] integerValue];
            weakSelf.lineDiastolicPressureCharts.bloodDataArray = systolic_pressureArray;
        }else {
            weakSelf.lineHeartRateCharts.page = [indexArray[type] integerValue];
            weakSelf.lineHeartRateCharts.bloodDataArray  = heart_rateArray;
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];


}
#pragma mark -- Event response
#pragma mark -- 添加血压
- (void)rightButtonAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-06-01"];
#endif
    BloodScaleView *scaleView=[[BloodScaleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 465)];
    scaleView.bloodScaleDelegate=self;
    [scaleView bloodScaleViewShowInView:self.view];
}
#pragma mark -- 跳转血压计
- (void)nextMeterDevice{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-06-04"];
#endif
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ScaleListViewController *scaleListVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ScaleListViewController"];
    scaleListVC.deviceType = DeviceTypeBPMeter;
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.BTHelper =[[BTHelper alloc]init];
    [appDelegate.BTHelper initParam];
    [self.navigationController pushViewController:scaleListVC animated:YES];

}
#pragma mark --  初始化界面
- (void)initBloodRecordView{
    self.rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0,64, kScreenWidth, kAllHeight-64)];
    self.rootScrollView.showsVerticalScrollIndicator=NO;
    self.rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    self.rootScrollView .userInteractionEnabled = YES;
    [self.view addSubview:self.rootScrollView];
    
    [self.rootScrollView addSubview:self.lineSystolicPressureCharts];
    [self.rootScrollView addSubview:self.lineDiastolicPressureCharts];
    [self.rootScrollView addSubview:self.lineHeartRateCharts];
    [self.rootScrollView addSubview:grayButton];
    self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.lineHeartRateCharts.bottom);
}
#pragma mark -- setters
#pragma mark -- 收缩压
- (WeightLineChartView *)lineSystolicPressureCharts{
    if (_lineSystolicPressureCharts == nil) {
        _lineSystolicPressureCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0,10, kScreenWidth, 220) maxY:180 title:@"收缩压" height:90 low:60];
        _lineSystolicPressureCharts.type=1;
        _lineSystolicPressureCharts.weightLineDelegate = self;
    }
    return _lineSystolicPressureCharts;
}
#pragma mark -- 舒张压
- (WeightLineChartView *)lineDiastolicPressureCharts{
    if (_lineDiastolicPressureCharts == nil) {
        _lineDiastolicPressureCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, _lineSystolicPressureCharts.bottom+10, kScreenWidth, 220) maxY:220 title:@"舒张压" height:140 low:90];
        _lineDiastolicPressureCharts.type=2;
        _lineDiastolicPressureCharts.weightLineDelegate = self;
    }
    return _lineDiastolicPressureCharts;
}
#pragma mark -- 心率
- (WeightLineChartView *)lineHeartRateCharts{
    if (_lineHeartRateCharts == nil) {
        _lineHeartRateCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, _lineDiastolicPressureCharts.bottom+10, kScreenWidth, 220) maxY:120 title:@"心率"];
        _lineHeartRateCharts.type=3;
        _lineHeartRateCharts.weightLineDelegate = self;
        
        grayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _lineDiastolicPressureCharts.bottom+10, _lineHeartRateCharts.width, _lineHeartRateCharts.height)];
        [grayButton addTarget:self action:@selector(nextMeterDevice) forControlEvents:UIControlEventTouchUpInside];
        [grayButton setImage:[UIImage imageNamed:@"pub_ic_lock"] forState:UIControlStateNormal];
        grayButton.backgroundColor = [UIColor grayColor];
        grayButton.alpha = 0.5;
    }
    return _lineHeartRateCharts;
}

@end
