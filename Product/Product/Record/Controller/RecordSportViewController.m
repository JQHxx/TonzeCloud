//
//  RecordSportViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecordSportViewController.h"
#import "FDCalendar.h"
#import "TCDietIntakeView.h"
#import "AddSportViewController.h"
#import "SportHistoryViewController.h"
#import "SportRecordTableView.h"
#import "HWPopTool.h"
#import "TonzeHelpTool.h"
#import "SetDailyDietViewController.h"

@interface RecordSportViewController ()<FDCalendarDelegate,SportsRecordsTableViewDelegate>{
    UIScrollView    *rootScrollView;
    NSInteger       targetStepCount;
    FDCalendar     *calendar;           //日历控件

    NSString       *nowDateStr;
    NSString       *seletedDataStr;

    UIView         *sportCover;
    FDCalendar     *sportCalendar;           //日历控件
    BlankView    *blankView;

}

@property (nonatomic,strong)UIButton                   *sportsTitleButton;        // 标题
@property (nonatomic,strong)TCDietIntakeView           *cosumeCaloriesView;       //消耗热量
@property (nonatomic,strong)UIButton                   *sportRecordsTitleBtn;     //运动记录标题
@property (nonatomic,strong)SportRecordTableView       *sportsRecordsTableView;   //运动记录
@property (nonatomic,strong)UIView                     *addSportsRecordView;      //记录运动
@end

@implementation RecordSportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rightImageName = @"ic_n_time";
    nowDateStr=[[TJYHelper sharedTJYHelper] getCurrentDate];   //今天
    seletedDataStr = nowDateStr;

    [self initSportView];
    
    [self getSportRecordsListWithDate:nowDateStr];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TJYHelper sharedTJYHelper].isSportsReload==YES) {

        [self getSportRecordsListWithDate:seletedDataStr];
        [TJYHelper sharedTJYHelper].isSportsReload=NO;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-03" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-03" type:2];
#endif
}


#pragma mark -- CustomDelegate
-(void)sportsRecordTableView:(SportRecordTableView *)tableView didSelectStepSportModel:(SportRecordModel *)stepModel{

}
#pragma mark FDCalendarDelegate
-(void)calendarDidSelectDate:(NSString *)dateStr{

    [[HWPopTool sharedInstance] closeAnimation:NO WithBlcok:^{
        
    }];
    NSInteger data =[[TJYHelper sharedTJYHelper] compareDate:dateStr withDate:nowDateStr];
    if (data==-1||data==0) {
        if ([dateStr isEqualToString:nowDateStr]) {
            self.sportsTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 70, 0, 0);
            self.sportsTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -40, 0, 0);
            [self.sportsTitleButton setTitle:@"今天" forState:UIControlStateNormal];
        }else{
            self.sportsTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 120, 0, 0);
            self.sportsTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -30, 0, 0);
            [self.sportsTitleButton setTitle:dateStr forState:UIControlStateNormal];
        }
        seletedDataStr=dateStr;
        [self getSportRecordsListWithDate:nowDateStr];
    }else{
        [self.view makeToast:@"不能选择未来时间" duration:1.0 position:CSToastPositionCenter];
        
    }
}
#pragma mark -- Event Reponse
#pragma mark 选择日期（显示蒙板）
-(void)sportsTitleButtonClickForChooseTime:(UIButton *)sender{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.layer.cornerRadius = 5;
    contentView.backgroundColor =[UIColor bgColor_Gray];
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date =[dateFormat dateFromString:seletedDataStr];
    
    calendar=[[FDCalendar alloc] initWithCurrentDate:date];
    calendar.calendarDelegate=self;
    [contentView addSubview:calendar];
    contentView.frame = CGRectMake(20, 84, kScreenWidth-40, calendar.bottom+20);
    [HWPopTool sharedInstance].shadeBackgroundType = ShadeBackgroundTypeSolid;
    [HWPopTool sharedInstance].closeButtonType = ButtonPositionTypeNone;
    [[HWPopTool sharedInstance] showWithPresentView:contentView animated:YES];
}
#pragma mark 添加运动记录
-(void)addSportsRecordForClickBtn:(UIButton *)sender{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-03-06"];
#endif
    [TonzeHelpTool sharedTonzeHelpTool].isAddSport=YES;
    AddSportViewController *addSportVC = [[AddSportViewController alloc] init];
    [self.navigationController pushViewController:addSportVC animated:YES];
}
#pragma mark -- 运动历史纪录
-(void)rightButtonAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-03-01"];
#endif
    SportHistoryViewController *historySportVC = [[SportHistoryViewController alloc] init];
    [self.navigationController pushViewController:historySportVC animated:YES];
}
#pragma mark 隐藏蒙板
-(void)makeHiddenCover{
    sportCover.alpha=0.0;
    [sportCover removeFromSuperview];
    [sportCalendar removeFromSuperview];
}
#pragma mark 获取运动记录
-(void)getSportRecordsListWithDate:(NSString *)dateStr{
    NSInteger startTimeSp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:dateStr format:@"yyyy-MM-dd"];
    NSString *body=[NSString stringWithFormat:@"motion_bigin_time_begin=%ld&motion_bigin_time_end=%ld&output-way=1",(long)startTimeSp,(long)startTimeSp];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kSportRecordLists body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            NSInteger allCalories=[[result valueForKey:@"all_calories"] integerValue];
            weakSelf.cosumeCaloriesView.energyValue=allCalories;
            weakSelf.cosumeCaloriesView.targetEnergyValue=_targetEnergy;

            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            NSArray *recordsArr=[result valueForKey:@"motionrecord"];
            for (NSDictionary *dict in recordsArr) {
                SportRecordModel *sport=[[SportRecordModel alloc] init];
                [sport setValues:dict];
                [tempArr addObject:sport];
            }
            blankView.hidden=tempArr.count>0;
            weakSelf.sportsRecordsTableView.sportsRecordsArray=tempArr;
            
        }else{
            weakSelf.sportsRecordsTableView.sportsRecordsArray=[[NSMutableArray alloc] init];
        }
        [weakSelf.sportsRecordsTableView reloadData];
        weakSelf.sportsRecordsTableView.frame=CGRectMake(0, weakSelf.sportsRecordsTableView.top, kScreenWidth, weakSelf.sportsRecordsTableView.contentSize.height);
        [rootScrollView setContentSize:CGSizeMake(kScreenWidth, weakSelf.sportsRecordsTableView.top+weakSelf.sportsRecordsTableView.contentSize.height+64)];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 初始化界面
- (void)initSportView{
    //标题
    [self.view addSubview:self.sportsTitleButton];
    
    //根视图
    rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-50)];
    rootScrollView.showsVerticalScrollIndicator=NO;
    rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    [self.view addSubview:rootScrollView];
    
    //饮食记录
    [rootScrollView addSubview:self.cosumeCaloriesView];
    [rootScrollView addSubview:self.sportRecordsTitleBtn];
    [rootScrollView addSubview:self.sportsRecordsTableView];
    [self.view addSubview:self.addSportsRecordView];
    
    blankView=[[BlankView alloc] initWithFrame:CGRectMake(0,self.sportRecordsTitleBtn.bottom+50,kScreenWidth, 200) img:@"img_tips_no" text:@"暂无运动纪录"];
    [self.view addSubview:blankView];
    blankView.hidden=YES;

}
#pragma mark -- Getters and Setters
#pragma mark 标题
-(UIButton *)sportsTitleButton{
    if (_sportsTitleButton==nil) {
        _sportsTitleButton=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, 20, 150, kNavigationHeight)];
        [_sportsTitleButton setTitle:@"今天" forState:UIControlStateNormal];
        [_sportsTitleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sportsTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 70, 0, 0);
        _sportsTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -40, 0, 0);
        [_sportsTitleButton setImage:[UIImage imageNamed:@"ic_n_down"] forState:UIControlStateNormal];
        [_sportsTitleButton addTarget:self action:@selector(sportsTitleButtonClickForChooseTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sportsTitleButton;
}
#pragma mark 消耗量
-(TCDietIntakeView *)cosumeCaloriesView{
    if (_cosumeCaloriesView==nil) {
        _cosumeCaloriesView=[[TCDietIntakeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 170) type:TCDietIntakeViewSportsType];
        }
    return _cosumeCaloriesView;
}
#pragma mark 运动记录标题
-(UIButton *)sportRecordsTitleBtn{
    if (_sportRecordsTitleBtn==nil) {
        _sportRecordsTitleBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, self.cosumeCaloriesView.bottom+10, kScreenWidth, 40)];
        _sportRecordsTitleBtn.backgroundColor=[UIColor whiteColor];
        [_sportRecordsTitleBtn setTitle:@"运动记录" forState:UIControlStateNormal];
        [_sportRecordsTitleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _sportRecordsTitleBtn.titleLabel.font=[UIFont systemFontOfSize:13.0f];
        [_sportRecordsTitleBtn setImage:[UIImage imageNamed:@"ic_pub_lite_record"] forState:UIControlStateNormal];
        _sportRecordsTitleBtn.imageEdgeInsets=UIEdgeInsetsMake(0, -20, 0, 0);
    }
    return _sportRecordsTitleBtn;
}
#pragma mark 运动记录
-(SportRecordTableView *)sportsRecordsTableView{
    if (_sportsRecordsTableView==nil) {
        _sportsRecordsTableView=[[SportRecordTableView alloc] initWithFrame:CGRectMake(0,self.sportRecordsTitleBtn.bottom+10 , kScreenWidth, kScreenHeight-50-self.cosumeCaloriesView.bottom) style:UITableViewStylePlain];
        _sportsRecordsTableView.viewDelegate=self;
        
    }
    return _sportsRecordsTableView;
}
#pragma mark 记录运动
-(UIView *)addSportsRecordView{
    if (_addSportsRecordView==nil) {
        _addSportsRecordView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _addSportsRecordView.backgroundColor=kSystemColor;
        
        UIButton *addSportsBtn=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, 10, 200, 30)];
        [addSportsBtn setImage:[UIImage imageNamed:@"ic_n_write"] forState:UIControlStateNormal];
        [addSportsBtn setTitle:@"记录运动" forState:UIControlStateNormal];
        [addSportsBtn addTarget:self action:@selector(addSportsRecordForClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_addSportsRecordView addSubview:addSportsBtn];
    }
    return _addSportsRecordView;
}
@end
