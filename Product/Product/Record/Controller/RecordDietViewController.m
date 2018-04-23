//
//  RecordDietViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecordDietViewController.h"
#import "FDCalendar.h"
#import "TCDietIntakeView.h"
#import "SetDailyDietViewController.h"
#import "RecommendIntakeViewController.h"
#import "ConsumeCaloriesViewController.h"
#import "TCDietRecordsTableView.h"
#import "DietRecordViewController.h"
#import "HistoryRecordViewController.h"
#import "HWPopTool.h"

@interface RecordDietViewController ()<FDCalendarDelegate,TCDietIntakeViewDelegate>{

    UIScrollView   *rootScrollView;
    FDCalendar     *calendar;           //日历控件
    UIView         *cover;
    NSString       *nowDateStr;
    NSString       *seletedDateStr;

    BlankView    *blankView;

    UILabel        *compareIntakeLabel;      //与摄入比较
    UIButton       *getIntakeButton ;        //推荐摄入和推荐消耗
    
    BOOL           isSetTarget;              //是否设置饮食目标
    NSInteger      intakeEnergy;             //摄入量
    
    
}
@property (nonatomic,strong)UIButton                *dietsTitleButton;       // 标题
@property (nonatomic,strong)TCDietIntakeView        *dietIntakeView;         // 饮食摄入
@property (nonatomic,strong)UIView                  *intakeOrConsumeView;    // 推荐摄入或消耗热量
@property (nonatomic,strong)UIButton                *dietRecordTitleBtn;     // 饮食记录标题
@property (nonatomic,strong)TCDietRecordsTableView  *dietRecordsTableView;   // 饮食记录
@property (nonatomic,strong)UIView                  *addDietRecordView;      // 记录饮食

@end
@implementation RecordDietViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rightImageName = @"ic_n_time";
    nowDateStr=[[TJYHelper sharedTJYHelper] getCurrentDate];   //今天
    seletedDateStr = nowDateStr;
    [self initDietView];
    [self loadDietDataWithDateStr:nowDateStr];


}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if ([TJYHelper sharedTJYHelper].isDietReload==YES) {
        [TJYHelper sharedTJYHelper].isDietReload=NO;
        [self loadDietDataWithDateStr:seletedDateStr];
    }
    if ([TJYHelper sharedTJYHelper].isSetDietTarget==YES) {
        [TJYHelper sharedTJYHelper].isSetDietTarget=NO;
        self.targetEnergy = [[NSUserDefaultInfos getValueforKey:kDailyEnergy] integerValue];
        [self loadDietDataWithDateStr:seletedDateStr];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-01" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-01" type:2];
#endif
}

#pragma mark 设置每日饮食目标
-(void)dietIntakeViewDidSetDailyTargetIntake{
    
    SetDailyDietViewController *setDailyDietVC=[[SetDailyDietViewController alloc] init];
    [self.navigationController pushViewController:setDailyDietVC animated:YES];
}

#pragma mark -- FDCalendarDelegate
-(void)calendarDidSelectDate:(NSString *)dateStr{

    [[HWPopTool sharedInstance] closeAnimation:NO WithBlcok:^{
        
    }];
    NSInteger data =[[TJYHelper sharedTJYHelper] compareDate:dateStr withDate:nowDateStr];
    if (data==-1||data==0) {
        if ([dateStr isEqualToString:nowDateStr]) {
            self.dietsTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 70, 0, 0);
            self.dietsTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -40, 0, 0);
            [self.dietsTitleButton setTitle:@"今天" forState:UIControlStateNormal];
        }else{
            self.dietsTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 120, 0, 0);
            self.dietsTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -30, 0, 0);
            [self.dietsTitleButton setTitle:dateStr forState:UIControlStateNormal];
        }
        seletedDateStr=dateStr;
        [self loadDietDataWithDateStr:dateStr];
    }else{
        [self.view makeToast:@"不能选择未来时间" duration:1.0 position:CSToastPositionCenter];

    }
}
#pragma mark -- Event response
#pragma mark 选择日期（显示蒙板）
-(void)dietsTitleButtonClickForChooseTime:(UIButton *)sender{

    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.layer.cornerRadius = 5;
    contentView.backgroundColor =[UIColor bgColor_Gray];
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date =[dateFormat dateFromString:seletedDateStr];
    
    calendar=[[FDCalendar alloc] initWithCurrentDate:date];
    calendar.calendarDelegate=self;
    [contentView addSubview:calendar];
    contentView.frame = CGRectMake(20, 84, kScreenWidth-40, calendar.bottom+20);
    [HWPopTool sharedInstance].shadeBackgroundType = ShadeBackgroundTypeSolid;
    [HWPopTool sharedInstance].closeButtonType = ButtonPositionTypeNone;
    [[HWPopTool sharedInstance] showWithPresentView:contentView animated:YES];
}
#pragma mark -- 饮食历史纪录
-(void)rightButtonAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-01"];
#endif
    HistoryRecordViewController *historyRecordVC = [[HistoryRecordViewController alloc] init];
    [self.navigationController pushViewController:historyRecordVC animated:YES];
}
#pragma mark 隐藏蒙板
-(void)makeHiddenCover{
    cover.alpha=0.0;
    [cover removeFromSuperview];
    [calendar removeFromSuperview];
}
#pragma mark 推荐摄入或消耗热量
-(void)getIntakeOrConsumeAction:(UIButton *)sender{
    if ([sender.currentTitle isEqualToString:@"推荐摄入"]) {
        RecommendIntakeViewController *recommendIntakeVC=[[RecommendIntakeViewController alloc] init];
        recommendIntakeVC.restEnergy=_targetEnergy;
        [self.navigationController pushViewController:recommendIntakeVC animated:YES];
    }else{
        ConsumeCaloriesViewController *consumeCaloriesVC=[[ConsumeCaloriesViewController alloc] init];
        consumeCaloriesVC.surplusEnergy=intakeEnergy-_targetEnergy;
        [self.navigationController pushViewController:consumeCaloriesVC animated:YES];
    }
}
#pragma mark 添加饮食记录
-(void)addDietRecordForClickBtn:(UIButton *)sender{
    DietRecordViewController *dietRecordVC = [[DietRecordViewController alloc] init];
    [self.navigationController pushViewController:dietRecordVC animated:YES];
}
#pragma mark -- Pravite Methods
#pragma mark 加载数据
-(void)loadDietDataWithDateStr:(NSString *)dateStr{
    NSInteger startTimeSp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:dateStr format:@"yyyy-MM-dd"];
    NSString *body=[NSString stringWithFormat:@"feeding_time_begin=%ld&feeding_time_end=%ld&output-way=1",(long)startTimeSp,(long)startTimeSp];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kDietRecordLists body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        
        //饮食摄入能量值
        intakeEnergy=[[result valueForKey:@"all_calories"] integerValue];
        weakSelf.dietIntakeView.energyValue=intakeEnergy;
        [weakSelf loadDietTargetIntakeAction];
        
        //饮食记录列表
        NSArray *dietArr=[result valueForKey:@"dietrecord"];
        if (dietArr.count>0) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            NSMutableArray *keysTempArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in dietArr) {
                FoodRecordModel *model=[[FoodRecordModel alloc] init];
                [model setValues:dict];
                [keysTempArr addObject:model.time_slot];
                [tempArr addObject:model];
            }
            
            NSMutableDictionary *dietDict=[[NSMutableDictionary alloc] init];
            for (NSString *timeKey in keysTempArr) {
                NSMutableArray *mealArr=[[NSMutableArray alloc] init];
                for (NSInteger i=0; i<tempArr.count; i++) {
                    FoodRecordModel *model=tempArr[i];
                    if ([model.time_slot isEqualToString:timeKey]) {
                        [mealArr addObjectsFromArray:model.item];
                    }
                }
                [dietDict setObject:mealArr forKey:timeKey];
            }
            weakSelf.dietRecordsTableView.dietRecordsDict=dietDict;
        }else{
            weakSelf.dietRecordsTableView.dietRecordsDict=[[NSDictionary alloc] init];
        }
        blankView.hidden=dietArr.count>0;
        if (![dateStr isEqualToString:nowDateStr]) {
            self.intakeOrConsumeView.hidden = YES;
            self.dietIntakeView.frame = CGRectMake(0, 0, kScreenWidth, 170);
            self.dietRecordTitleBtn.frame = CGRectMake(0, self.dietIntakeView.bottom+8, kScreenWidth, 40);
            self.dietRecordsTableView.frame = CGRectMake(0, self.dietRecordTitleBtn.bottom, kScreenWidth, kScreenHeight-50-self.dietRecordTitleBtn.bottom);
            blankView.frame=CGRectMake(0,self.dietRecordsTableView.top-20,kScreenWidth, 200);
        }else{
            if (!(_targetEnergy>0)) {
                self.intakeOrConsumeView.hidden = YES;
                self.dietIntakeView.frame = CGRectMake(0, 0, kScreenWidth, 200);
                self.dietRecordTitleBtn.frame = CGRectMake(0, self.dietIntakeView.bottom+10, kScreenWidth, 40);
                self.dietRecordsTableView.frame = CGRectMake(0, self.dietRecordTitleBtn.bottom, kScreenWidth, kScreenHeight-50-self.dietRecordTitleBtn.bottom);
                blankView.frame=CGRectMake(0,self.dietRecordsTableView.top-20,kScreenWidth, 200);
            } else {
                self.intakeOrConsumeView.hidden = NO;
                self.dietIntakeView.frame = CGRectMake(0, 0, kScreenWidth, 200);
                self.intakeOrConsumeView.frame = CGRectMake(0, self.dietIntakeView.bottom, kScreenWidth, 40);
                self.dietRecordTitleBtn.frame = CGRectMake(0, self.intakeOrConsumeView.bottom+10, kScreenWidth, 40);
                self.dietRecordsTableView.frame = CGRectMake(0, self.dietRecordTitleBtn.bottom, kScreenWidth, kScreenHeight-50-self.dietRecordTitleBtn.bottom);
                blankView.frame=CGRectMake(0,self.dietRecordsTableView.top-20,kScreenWidth, 200);
            }
        }

        [weakSelf.dietRecordsTableView reloadData];
        weakSelf.dietRecordsTableView.frame=CGRectMake(0, weakSelf.dietRecordTitleBtn.bottom, kScreenWidth,dietArr.count==0?0:weakSelf.dietRecordsTableView.contentSize.height);
        [rootScrollView setContentSize:CGSizeMake(kScreenWidth, weakSelf.dietRecordsTableView.top+weakSelf.dietRecordsTableView.contentSize.height+64)];

        
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        
    }];
}

#pragma mark 获取目标摄入能量
-(void)loadDietTargetIntakeAction{

    self.dietIntakeView.targetEnergyValue=_targetEnergy;
    
    
    if(!(_targetEnergy>0)){
        self.intakeOrConsumeView.hidden=YES;
        self.dietRecordTitleBtn.frame=CGRectMake(0, self.dietIntakeView.bottom+10, kScreenWidth, 40);
    }else{
        self.intakeOrConsumeView.hidden=NO;
        self.dietRecordTitleBtn.frame=CGRectMake(0, self.intakeOrConsumeView.bottom+10, kScreenWidth, 40);
        if (intakeEnergy==_targetEnergy) {
            getIntakeButton.hidden=YES;
            compareIntakeLabel.text=@"恭喜您！今日摄入已达目标";
        }else{
            getIntakeButton.hidden=NO;
            NSString *tempStr=nil;
            NSInteger loc=0;
            if (intakeEnergy<_targetEnergy) {
                tempStr=[NSString stringWithFormat:@"今日摄入距离目标还差%ld千卡",(long)(_targetEnergy-intakeEnergy)];
                [getIntakeButton setTitle:@"推荐摄入" forState:UIControlStateNormal];
                loc=10;
            }else{
                tempStr=[NSString stringWithFormat:@"今日摄入已超目标%ld千卡",(long)(intakeEnergy-_targetEnergy)];
                [getIntakeButton setTitle:@"消耗热量" forState:UIControlStateNormal];
                loc=8;
            }
            NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:tempStr];
            [attributeStr addAttribute:NSForegroundColorAttributeName value:kRGBColor(244, 182, 123) range:NSMakeRange(loc, attributeStr.length-loc-2)];
            compareIntakeLabel.attributedText=attributeStr;
        }
    }
}

#pragma mark -- 初始化界面
- (void)initDietView{
    //标题
    [self.view addSubview:self.dietsTitleButton];

    rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-50)];
    rootScrollView.showsVerticalScrollIndicator=NO;
    rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    [self.view addSubview:rootScrollView];
    
    [rootScrollView addSubview:self.dietIntakeView];
    [rootScrollView addSubview:self.intakeOrConsumeView];
    [rootScrollView addSubview:self.dietRecordTitleBtn];
    [rootScrollView addSubview:self.dietRecordsTableView];
    //记录饮食
    [self.view addSubview:self.addDietRecordView];
    
    blankView=[[BlankView alloc] initWithFrame:CGRectMake(0,self.dietRecordTitleBtn.bottom-20,kScreenWidth, 200) img:@"img_tips_no" text:@"暂无饮食记录"];
    [rootScrollView addSubview:blankView];
    blankView.hidden=YES;

}
#pragma mark -- Getters and Setters
#pragma mark 标题
-(UIButton *)dietsTitleButton{
    if (_dietsTitleButton==nil) {
        _dietsTitleButton=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, 20, 150, kNavigationHeight)];
        [_dietsTitleButton setTitle:@"今天" forState:UIControlStateNormal];
        [_dietsTitleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _dietsTitleButton.imageEdgeInsets=UIEdgeInsetsMake(0, 70, 0, 0);
        _dietsTitleButton.titleEdgeInsets=UIEdgeInsetsMake(0, -40, 0, 0);
        [_dietsTitleButton setImage:[UIImage imageNamed:@"ic_n_down"] forState:UIControlStateNormal];
        [_dietsTitleButton addTarget:self action:@selector(dietsTitleButtonClickForChooseTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dietsTitleButton;
}
#pragma mark 饮食摄入
-(TCDietIntakeView *)dietIntakeView{
    if (_dietIntakeView==nil) {
        _dietIntakeView=[[TCDietIntakeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) type:TCDietIntakeViewDietType];
        _dietIntakeView.delegate = self;
    }
    return _dietIntakeView;
}
#pragma mark 推荐摄入或消耗热量
-(UIView *)intakeOrConsumeView{
    if (_intakeOrConsumeView==nil) {
        _intakeOrConsumeView=[[UIView alloc] initWithFrame:CGRectMake(0, self.dietIntakeView.bottom, kScreenWidth, 40)];
        _intakeOrConsumeView.backgroundColor=[UIColor whiteColor];
        
        compareIntakeLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, kScreenWidth-100, 30)];
        compareIntakeLabel.textColor=[UIColor blackColor];
        compareIntakeLabel.font=[UIFont systemFontOfSize:13.0f];
        [_intakeOrConsumeView addSubview:compareIntakeLabel];
        
        //推荐摄入或消耗热量
        getIntakeButton=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 5, 100, 30)];
        [getIntakeButton setTitle:@"饮食指导" forState:UIControlStateNormal];
        [getIntakeButton setTitleColor:kSystemColor forState:UIControlStateNormal];
        [getIntakeButton setImage:[UIImage imageNamed:@"ic_pub_arrow_nor"] forState:UIControlStateNormal];
        getIntakeButton.imageEdgeInsets=UIEdgeInsetsMake(0, 80, 0, 0);
        getIntakeButton.titleEdgeInsets=UIEdgeInsetsMake(0, -20, 0, 0);
        getIntakeButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [getIntakeButton addTarget:self action:@selector(getIntakeOrConsumeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_intakeOrConsumeView addSubview:getIntakeButton];
        
    }
    return _intakeOrConsumeView;
}

#pragma mark 饮食记录标题
-(UIButton *)dietRecordTitleBtn{
    if(_dietRecordTitleBtn==nil){
        _dietRecordTitleBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, self.intakeOrConsumeView.bottom+10, kScreenWidth, 40)];
        _dietRecordTitleBtn.backgroundColor=[UIColor whiteColor];
        [_dietRecordTitleBtn setTitle:@"饮食记录" forState:UIControlStateNormal];
        [_dietRecordTitleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _dietRecordTitleBtn.titleLabel.font=[UIFont systemFontOfSize:13.0f];
        [_dietRecordTitleBtn setImage:[UIImage imageNamed:@"ic_pub_lite_record"] forState:UIControlStateNormal];
        _dietRecordTitleBtn.imageEdgeInsets=UIEdgeInsetsMake(0, -20, 0, 0);
    }
    return _dietRecordTitleBtn;
}
#pragma mark 饮食记录
-(TCDietRecordsTableView *)dietRecordsTableView{
    if (_dietRecordsTableView==nil) {
        _dietRecordsTableView=[[TCDietRecordsTableView alloc] initWithFrame:CGRectMake(0, self.dietRecordTitleBtn.bottom, kScreenWidth, kScreenHeight-50-self.dietIntakeView.bottom) style:UITableViewStyleGrouped];
    }
    return _dietRecordsTableView;
}

#pragma mark 记录饮食
-(UIView *)addDietRecordView{
    if (_addDietRecordView==nil) {
        _addDietRecordView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _addDietRecordView.backgroundColor=kSystemColor;
        UIButton *addDietBtn=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, 10, 200, 30)];
        [addDietBtn setImage:[UIImage imageNamed:@"ic_n_write"] forState:UIControlStateNormal];
        [addDietBtn setTitle:@"记录饮食" forState:UIControlStateNormal];
        [addDietBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addDietBtn.titleLabel.font=[UIFont systemFontOfSize:15.0f];
        [addDietBtn addTarget:self action:@selector(addDietRecordForClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_addDietRecordView addSubview:addDietBtn];
    }
    return _addDietRecordView;
}

@end
