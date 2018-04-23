//
//  RiceAnalysisViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RiceAnalysisViewController.h"
#import "DaysRice.h"
#import "RiceStorageChatrsView.h"
#import "StorageDeviceHelper.h"
#import "RiceRecordModel.h"

#define AllTotalValue   150

@interface RiceAnalysisViewController (){
    UIScrollView      *rootScrollView;
    UIView            *headView;
    UIView            *bottomView;
    UILabel           *timeLabel;
    
    
    NSInteger         weekPage;
    NSInteger         selectedIndex;
    NSInteger         startTimeSp;
    NSInteger         endTimeSp;
    
    NSInteger         month;
    NSInteger         year;
    NSInteger         currentMonth;
    NSMutableArray    *dateArray;
    NSMutableArray    *riceRecordsArray;
    
    NSInteger        dailyRice;     //日均用米
    
    
}

@property (nonatomic ,strong) UISegmentedControl    *riceSegmentControl;
@property (nonatomic ,strong) UIView                *seletedTimeView;
@property (nonatomic ,strong) RiceStorageChatrsView *riceStorageChartsView;
@property (nonatomic,strong ) DaysRice              *daysRice;             //日均用米
@property (nonatomic,strong ) DaysRice              *cumulativeRice;       //累计用米
@property (nonatomic,strong ) UILabel               *titlelabel;

@end

@implementation RiceAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"用米分析";
    
    weekPage=0;
    selectedIndex=0;
    dateArray=[[NSMutableArray alloc] init];
    riceRecordsArray=[[NSMutableArray alloc] init];
    dailyRice=0;
    
    month = [[[TJYHelper sharedTJYHelper] getCurrentMonth] integerValue];
    currentMonth=month;
    year = [[[TJYHelper sharedTJYHelper] getCurrentYear] integerValue];
    
    [self initRiceAnalysisView];
    [self requestRiceAnalysisData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(riceAnalysisOnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(riceAnalysisOnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(riceAnalysisOnPipeData:) name:kOnRecvPipeSyncData object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeSyncData object:nil];
}

#pragma mark -- NSNotification
-(void)riceAnalysisOnPipeData:(NSNotification *)notifi{
    NSDictionary *dict = notifi.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    if ([[device getMacAddressSimple] isEqualToString:self.storageDeviceModel.mac]) {
        MyLog(@"riceAbalysisOnPipeData = %s: %@", __func__, [recvData hexString]); //00 00 00 00 00 12 00 00 01 14 0D 02 19 06 46 02
        ///如果是控制命令的返回就隐藏
        uint32_t cmd_len = (uint32_t)[recvData length];
        uint8_t cmd_data[cmd_len];
        memset(cmd_data, 0, cmd_len);
        [recvData getBytes:(void *)cmd_data length:cmd_len];
        
        if (cmd_data[5]==0x12) {    //获取设备状态
            NSString *lastRiceStr=[NSString stringWithFormat:@"%i",cmd_data[14]];       //46  剩余米量
            NSInteger lastRiceValue=[lastRiceStr integerValue];
            MyLog(@"储米区剩余米量:%ldg",(long)lastRiceValue);
            
            if (dailyRice>0&&lastRiceValue>0) {
                NSInteger days=(NSInteger)(lastRiceValue/dailyRice+0.5);
                NSString *titleText=nil;
                if (lastRiceValue>20) {
                    titleText=[NSString stringWithFormat:@"当前米量不足%ld%%，根据您最近一周的用米情况，米将在%ld天后用完。",lastRiceValue,days];
                }else{
                    titleText=[NSString stringWithFormat:@"当前米量不足%ld%%，根据您最近一周的用米情况，米将在%ld天后用完。请及时补米。",lastRiceValue,days];
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSMutableParagraphStyle *paraStyle=[[NSMutableParagraphStyle alloc] init];
                        paraStyle.alignment=NSTextAlignmentLeft;
                        paraStyle.headIndent=0.0f;
                        CGFloat emptylen=_titlelabel.font.pointSize*2;
                        paraStyle.firstLineHeadIndent=emptylen; //首行缩进
                        paraStyle.lineSpacing=2.0f;//行间距
                        NSAttributedString *attrText=[[NSAttributedString alloc] initWithString:titleText attributes:@{NSParagraphStyleAttributeName:paraStyle}];
                        _titlelabel.attributedText=attrText;
                        
                        CGFloat contentHeight=[_titlelabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:_titlelabel.font,NSFontAttributeName,nil] context:nil].size.height;
                        _titlelabel.frame = CGRectMake(10, 5, kScreenWidth-20, contentHeight+10);
                        bottomView.frame=CGRectMake(0, headView.bottom+10, kScreenWidth, contentHeight+30);
                        rootScrollView.contentSize=CGSizeMake(kScreenWidth, bottomView.bottom);
                    });
                }); 
            }
        }
    }

}


#pragma mark -- Event response
- (void)riceSegment:(UISegmentedControl *)sender{
    MyLog(@"%ld",sender.selectedSegmentIndex);
    selectedIndex=sender.selectedSegmentIndex;
    if (selectedIndex==0) {
        timeLabel.text = [self requestWeekDay];
        [self requestRiceAnalysisData];
    }else{
        timeLabel.text = [NSString stringWithFormat:@"%ld年%ld月",(long)year,(long)month];
        [self getMonthStartTimeAndEndTime];
        [self requestRiceAnalysisData];
    }
}

#pragma mark 
-(void)getWeekDateAction:(UIButton *)sender{
    if (sender.tag==100) {
        if (selectedIndex == 0) {
            // 周记录
            weekPage++;
            timeLabel.text = [self requestWeekDay];
        }else{
            /// 月记录
            if (month > 1 && month <=12) {
                month--;
                timeLabel.text = [NSString stringWithFormat:@"%ld年%ld月",(long)year,(long)month];
            }else{
                year--;
                month = 12;
                timeLabel.text = [NSString stringWithFormat:@"%ld年%ld月",(long)year,(long)month];
            }
            [self getMonthStartTimeAndEndTime];
        }
    }else{
        if (selectedIndex== 0) {
            if (weekPage>0) {
                // 周记录
                weekPage--;
                timeLabel.text = [self requestWeekDay];
            }
        }else{
            if (month<currentMonth) {
                // 月记录
                if (month>0 && month < 12) {
                    month++;
                    timeLabel.text = [NSString stringWithFormat:@"%ld年%ld月",(long)year,(long)month];
                }else{
                    year++;
                    month =1;
                    timeLabel.text = [NSString stringWithFormat:@"%ld年%ld月",(long)year,(long)month];
                }
                [self getMonthStartTimeAndEndTime];
            }
        }
    }
    [self requestRiceAnalysisData];
}

#pragma mark -- Private Methods
#pragma mark  获取出米记录数据
- (void)requestRiceAnalysisData{
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    int deviceId=[StorageDeviceHelper sharedStorageDeviceHelper].device_id;
    NSDictionary *contentDict=@{@"offset":@(0),@"limit":@(1000),@"date":@{@"begin":@(startTimeSp*1000),@"end":@(endTimeSp*1000)},@"rule_id":kStorageRuleId};
    __weak typeof(self) weakSelf=self;
    [HttpRequest getDeviceSnapshotWithContent:contentDict ProductID:CABINETS_PRODUCT_ID withAccessToken:[userDic valueForKey:@"access_token"] deviceID:deviceId didLoadData:^(id result, NSError *err) {
        if (err) {
            MyLog(@"获取设备快照失败 error:%@",err.localizedDescription);
        }else{
            NSArray *list=[result objectForKey:@"list"];
            if (kIsArray(list)) {
                NSMutableArray   *tempArr=[[NSMutableArray alloc] init];
                NSMutableArray   *tempDateArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dict in list) {
                    RiceRecordModel *model=[[RiceRecordModel alloc] init];
                    model.outRiceVlue=[dict[@"4"] integerValue];
                    model.date=[dict[@"snapshot_date"] substringWithRange:NSMakeRange(0, 10)];
                    model.time=[dict[@"snapshot_date"] substringWithRange:NSMakeRange(11, 5)];
                    if (model.outRiceVlue>0) {
                        [tempArr addObject:model];
                        [tempDateArr addObject:model.date];
                    }
                }
                
                NSString *body2=[NSString stringWithFormat:@"device_id=%d&record_time_begin=%ld&record_time_end=%ld",deviceId,(long)startTimeSp,(long)endTimeSp];
                [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kGetOfflineRiceRecord body:body2 success:^(id json) {
                    NSArray *offlineResult=[json objectForKey:@"result"];
                    for (NSDictionary *tempDict in offlineResult) {
                        RiceRecordModel *recordModel=[[RiceRecordModel alloc] init];
                        recordModel.date=[[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",tempDict[@"record_time"]] format:@"yyyy-MM-dd"];
                        recordModel.time=[[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",tempDict[@"record_time"]] format:@"HH:mm"];
                        recordModel.outRiceVlue=[tempDict[@"cup"] integerValue];
                        [tempArr addObject:recordModel];
                        [tempDateArr addObject:recordModel.date];
                    }
                    
                    
                    //时间剔重排序
                    NSSet *set = [NSSet setWithArray:tempDateArr];
                    NSArray *timeArr=[set allObjects];
                    timeArr=[timeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        return [obj2 compare:obj1]; //降序
                    }];
                    [tempDateArr removeAllObjects];
                    [tempDateArr addObjectsFromArray:timeArr];
                    MyLog(@"times:%@",tempDateArr);
                    
                    
                    //获得同一天的出米记录总和
                    NSMutableArray  *tempRecordArr=[[NSMutableArray alloc] init];
                    for (NSString *dateStr in tempDateArr) {
                        NSInteger totalValue=0.0;
                        for (RiceRecordModel *recordModel in tempArr) {
                            if ([recordModel.date isEqualToString:dateStr]) {
                                totalValue+=recordModel.outRiceVlue;
                            }
                        }
                        NSDictionary *dict=@{@"date":dateStr,@"value":[NSNumber numberWithInteger:totalValue]};
                        [tempRecordArr addObject:dict];
                    }
                    
                    // 获取对应日期的出米记录
                    NSInteger maxy = 0; // Y轴最大值
                    NSInteger totalValue=0;   //累积用米
                    NSMutableArray *tempRecordResultArr=[[NSMutableArray alloc] init];
                    for (NSInteger i=0; i<dateArray.count; i++) {
                        NSString *start = [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",(long)startTimeSp] format:@"YYYY-MM-dd"];
                        NSString *tempDateStr = [[TJYHelper sharedTJYHelper] getAfterDayWithTime:start days:i];
                        NSInteger recordValue=0;
                        for (NSDictionary *tempDict in tempRecordArr) {
                            NSString *recordDateStr=tempDict[@"date"];
                            if ([recordDateStr isEqualToString:tempDateStr]) {
                                recordValue=[tempDict[@"value"] integerValue];
                                if (maxy<recordValue) {
                                    maxy=recordValue;
                                }
                                totalValue+=recordValue;
                                break;
                            }else{
                                recordValue=0;
                            }
                        }
                        [tempRecordResultArr addObject:[NSNumber numberWithInteger:recordValue]];
                    }
                    MyLog(@"result:%@",tempRecordResultArr);
                    
                    // 日均用米
                    dailyRice=(NSInteger)(totalValue/dateArray.count+0.5);
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            //出米记录曲线
                            weakSelf.riceStorageChartsView.maxy=maxy+2;
                            weakSelf.riceStorageChartsView.dataArray=tempRecordResultArr;
                            
                            //出米记录统计（日均用米和累积用米）
                            weakSelf.daysRice.riceValue=dailyRice;
                            weakSelf.cumulativeRice.riceValue=totalValue;
                        });
                    });
                    
                } failure:^(NSString *errorStr) {
                    MyLog(@"获取离线出米记录失败");
                }];
            }
        }
    }];
}

#pragma mark -- 初始化界面
- (void)initRiceAnalysisView{
    rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0,64, kScreenWidth, kScreenHeight-44)];
    rootScrollView.showsVerticalScrollIndicator=NO;
    rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    [self.view addSubview:rootScrollView];
    
    
    headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 420)];
    headView.backgroundColor=[UIColor whiteColor];
    [rootScrollView addSubview:headView];

    [headView addSubview:self.riceSegmentControl];
    [headView addSubview:self.seletedTimeView];
    [headView addSubview:self.riceStorageChartsView];
    [headView addSubview:self.daysRice];
    [headView addSubview:self.cumulativeRice];
    
    bottomView=[[UIView alloc] initWithFrame:CGRectZero];
    bottomView.backgroundColor=[UIColor whiteColor];
    [rootScrollView addSubview:bottomView];
    [bottomView addSubview:self.titlelabel];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, self.riceStorageChartsView.bottom+10, kScreenWidth, 1)];
    line.backgroundColor = [UIColor colorWithWhite:0.832 alpha:1.000];
    [headView addSubview:line];
    
    UILabel *bgline = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-1, self.riceStorageChartsView.bottom+40, 1, 40)];
    bgline.backgroundColor = [UIColor colorWithWhite:0.832 alpha:1.000];
    [bottomView addSubview:bgline];
}


#pragma mark -- 获取周一和周末日期
- (NSString *)requestWeekDay{
    NSDictionary *dict= [[TJYHelper sharedTJYHelper] getWeekTime:weekPage];
    NSString *firstStr = [dict objectForKey:@"firstday"];
    NSString *lastStr = [dict objectForKey:@"lastday"];
    startTimeSp = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:firstStr format:@"yyyy年MM月dd日"];  // 开始时间
    endTimeSp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:lastStr format:@"yyyy年MM月dd日"];   // 结束时间

    // 获得日期数据
    dateArray = [[TJYHelper sharedTJYHelper] getDataFromTodayWithTime:[self getTimestampWithTimeStr:lastStr] days:7];
    self.riceStorageChartsView.dayArray =@[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
    return [NSString stringWithFormat:@"%@-%@",[firstStr substringFromIndex:5],[lastStr substringFromIndex:5]];
}

#pragma mark 获得日期时间戳
- (NSString *)getTimestampWithTimeStr:(NSString *)timeStr{
    NSString *timestamp;
    NSString *yearStr = [timeStr stringByReplacingOccurrencesOfString:@"年" withString:@"-"];
    NSString *monthStr = [yearStr stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
    NSString *dayTime = [monthStr stringByReplacingOccurrencesOfString:@"日" withString:@""];
    return timestamp = dayTime;
}

#pragma mark 获得月份查询的开始和结束时间
- (void)getMonthStartTimeAndEndTime{
    dateArray = [[TJYHelper sharedTJYHelper] getMonthDaysWithYears:year month:month];
    self.riceStorageChartsView.dayArray = dateArray;
    NSString *firstDay = [NSString stringWithFormat:@"%ld-%ld-0%@",year,month,[dateArray objectAtIndex:0]];
    NSString *endDay = [NSString stringWithFormat:@"%ld-%ld-%@",year,month,[dateArray lastObject]];
    
    startTimeSp = [[TJYHelper sharedTJYHelper]timeSwitchTimestamp:firstDay format:@"yyyy-MM-dd"];
    endTimeSp = [[TJYHelper sharedTJYHelper]timeSwitchTimestamp:endDay format:@"yyyy-MM-dd"];
}


#pragma mark -- setters
- (UISegmentedControl *)riceSegmentControl{
    if (_riceSegmentControl==nil) {
        NSArray *array = [NSArray arrayWithObjects:@"周",@"月", nil];
        _riceSegmentControl = [[UISegmentedControl alloc] initWithItems:array];
        _riceSegmentControl.frame =CGRectMake(40,10 , kScreenWidth-80, 30);
        _riceSegmentControl.tintColor=kSystemColor;
        [_riceSegmentControl setSelectedSegmentIndex:0];
        [_riceSegmentControl addTarget:self action:@selector(riceSegment:) forControlEvents:UIControlEventValueChanged];
    }
    return _riceSegmentControl;
}

#pragma mark 选择日期
- (UIView *)seletedTimeView{
    if (_seletedTimeView==nil) {
        _seletedTimeView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-220)/2, _riceSegmentControl.bottom+10, 220, 40)];
        
        UIButton *lastBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [lastBtn setImage:[UIImage imageNamed:@"ic_walk_arrow_l"] forState:UIControlStateNormal];
        [lastBtn addTarget:self action:@selector(getWeekDateAction:) forControlEvents:UIControlEventTouchUpInside];
        lastBtn.tag=100;
        [_seletedTimeView addSubview:lastBtn];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont systemFontOfSize:14];
        timeLabel.textColor = [UIColor darkGrayColor];
        timeLabel.text=[self requestWeekDay];
        
        NSString *tempStr=@"06月12日－06月18日";
        CGFloat labW=[tempStr boundingRectWithSize:CGSizeMake(kScreenWidth, 40) withTextFont:timeLabel.font].width;
        timeLabel.frame=CGRectMake(lastBtn.right, 0, labW, 40);
        
        [_seletedTimeView addSubview:timeLabel];
        
        UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(timeLabel.right, 0, 40, 40)];
        [nextBtn setImage:[UIImage imageNamed:@"ic_walk_arrow_r"] forState:UIControlStateNormal];
        [nextBtn addTarget:self action:@selector(getWeekDateAction:) forControlEvents:UIControlEventTouchUpInside];
        nextBtn.tag=101;
        [_seletedTimeView addSubview:nextBtn];
    }
    return _seletedTimeView;
}

#pragma mark 用米分析图表
- (RiceStorageChatrsView *)riceStorageChartsView{
    if (_riceStorageChartsView==nil) {
        _riceStorageChartsView = [[RiceStorageChatrsView alloc] initWithFrame:CGRectMake(0, _seletedTimeView.bottom, kScreenWidth, 240)];
        _riceStorageChartsView.titleText=@"杯";
    }
    return _riceStorageChartsView;
}

#pragma mark -- 日均用米
- (DaysRice *)daysRice{
    if (_daysRice==nil) {
        _daysRice = [[DaysRice alloc] initWithFrame:CGRectMake(0, self.riceStorageChartsView.bottom+11, kScreenWidth/2-1, 80) title:@"日均用米"];
        _daysRice.riceValue =0;
    }
    return _daysRice;
}

#pragma mark -- 累计用米
- (DaysRice *)cumulativeRice{
    if (_cumulativeRice==nil) {
        _cumulativeRice = [[DaysRice alloc] initWithFrame:CGRectMake(kScreenWidth/2, self.riceStorageChartsView.bottom+11, kScreenWidth/2, 80) title:@"累计用米"];
        _cumulativeRice.riceValue =0;
    }
    return _cumulativeRice;
}

#pragma mark -- 米量提示
- (UILabel *)titlelabel{
    if (_titlelabel==nil) {
        _titlelabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titlelabel.textColor = [UIColor grayColor];
        _titlelabel.numberOfLines =0;
        _titlelabel.font = [UIFont systemFontOfSize:14];
    }
    return _titlelabel;
}


@end
