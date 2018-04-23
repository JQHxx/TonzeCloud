//
//  SportHistoryViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SportHistoryViewController.h"
#import "SportRecordModel.h"
#import "SportRecordTableViewCell.h"
#import "AddSportViewController.h"

@interface SportHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSMutableArray         *sportTimeArray;
    NSMutableArray         *sportRecordsArray;
    
    NSInteger              sportPage;    //运动记录页数

}
@property (nonatomic,strong)UITableView     *sportRecordTableView;
@property (nonatomic,strong)BlankView       *recordBlankView;
@end

@implementation SportHistoryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"运动历史记录";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    sportPage = 1;
    
    [self.view addSubview:self.sportRecordTableView];
    
    [self.sportRecordTableView addSubview:self.recordBlankView];
    self.recordBlankView.hidden=YES;
    
    [self loadSportRecordsData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TJYHelper sharedTJYHelper].isSportsHistoryReload == YES) {
        [self loadSportRecordsData];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-03-01" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-03-01" type:2];
#endif
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return sportTimeArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *tempList=[[NSMutableArray alloc] init];
    NSString *timeStr=sportTimeArray[section];
    for (SportRecordModel *model in sportRecordsArray) {
        NSString *timeKey= [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:model.motion_bigin_time format:@"yyyy-MM-dd"];
        if ([timeStr isEqualToString:timeKey]) {
            [tempList addObject:model];
        }
    }
    return tempList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"SportRecordTableViewCell";
    
    SportRecordTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"SportRecordTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSMutableArray *tempList=[[NSMutableArray alloc] init];
    NSString *timeStr=sportTimeArray[indexPath.section];
    for (SportRecordModel *model in sportRecordsArray) {
        NSString *timeKey= [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:model.motion_bigin_time format:@"yyyy-MM-dd"];
        if ([timeStr isEqualToString:timeKey]) {
            [tempList addObject:model];
        }
    }
    SportRecordModel *sport=tempList[indexPath.row];
    [cell cellDisplayWithModel:sport];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-03-02"];
#endif
    NSMutableArray *tempList=[[NSMutableArray alloc] init];
    NSString *timeStr=sportTimeArray[indexPath.section];
    for (SportRecordModel *model in sportRecordsArray) {
        NSString *timeKey= [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:model.motion_bigin_time format:@"yyyy-MM-dd"];
        if ([timeStr isEqualToString:timeKey]) {
            [tempList addObject:model];
        }
    }
    SportRecordModel *sport=tempList[indexPath.row];
    
    AddSportViewController *addSportVC = [[AddSportViewController alloc] init];
    addSportVC.sportModel = sport;
    [self.navigationController pushViewController:addSportVC animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *timeStr=nil;
    timeStr=sportTimeArray[section];
    return timeStr;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

#pragma mark 加载运动记录
-(void)loadSportRecordsData{
    sportTimeArray=[[NSMutableArray alloc] init];
    sportRecordsArray=[[NSMutableArray alloc] init];
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&output-way=3",(long)sportPage];
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kSportRecordLists body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            NSArray *sportRecord=[result valueForKey:@"motionrecord"];
            if (kIsArray(sportRecord)&&sportRecord.count>0) {
                
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                NSMutableArray *tempTimeArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dict in sportRecord) {
                    SportRecordModel *sport=[[SportRecordModel alloc] init];
                    [sport setValues:dict];
                    [tempArr addObject:sport];
                    
                    NSString *timeStr= [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:sport.motion_bigin_time format:@"YYYY-MM-dd"];
                    [tempTimeArr addObject:timeStr];
                }
                
                if (sportPage==1) {
                    sportRecordsArray=tempArr;
                    sportTimeArray=tempTimeArr;
                    
                    self.sportRecordTableView.mj_footer.hidden=sportRecordsArray.count<20;
                }else{
                    [sportRecordsArray addObjectsFromArray:tempArr];
                    [sportTimeArray addObjectsFromArray:tempTimeArr];
                }
                
                NSSet *set = [NSSet setWithArray:sportTimeArray];
                NSArray *timeArr=[set allObjects];
                timeArr=[timeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj2 compare:obj1]; //降序
                }];
                sportTimeArray=[NSMutableArray arrayWithArray:timeArr];
                MyLog(@"times:%@",sportTimeArray);
            }else{
                self.recordBlankView.hidden=NO;
                self.sportRecordTableView.mj_footer.hidden=YES;
            }
            
            [self.sportRecordTableView reloadData];
            [self.sportRecordTableView.mj_header endRefreshing];
            [self.sportRecordTableView.mj_footer endRefreshing];
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        [self.sportRecordTableView.mj_header endRefreshing];
        [self.sportRecordTableView.mj_footer endRefreshing];
    }];
}

#pragma mark 加载最新记录
-(void)loadNewRecordData{
        sportPage=1;
        [self loadSportRecordsData];
}

#pragma mark 加载更多记录
-(void)loadMoreRecordData{
        sportPage++;
        [self loadSportRecordsData];
}

#pragma mark -- setters
#pragma mark  记录列表
-(UITableView *)sportRecordTableView{
    if (_sportRecordTableView==nil) {
        _sportRecordTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kAllHeight-64) style:UITableViewStyleGrouped];
        _sportRecordTableView.dataSource=self;
        _sportRecordTableView.delegate=self;
        _sportRecordTableView.showsVerticalScrollIndicator=NO;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewRecordData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _sportRecordTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreRecordData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _sportRecordTableView.mj_footer = footer;
        footer.hidden=YES;

    }
    return _sportRecordTableView;
}
#pragma mark 无数据空白页
-(BlankView *)recordBlankView{
    if (_recordBlankView==nil) {
        _recordBlankView=[[BlankView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无历史记录"];
    }
    return _recordBlankView;
}



@end
