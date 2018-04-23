//
//  RiceRecordViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RiceRecordViewController.h"
#import "RiceRecordTableViewCell.h"
#import "RiceRecordModel.h"
#import "XLinkExportObject.h"
#import "StorageDeviceHelper.h"
#import "BlankView.h"


@interface RiceRecordViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray     *riceRecordArray;
    NSMutableArray     *dateArray;
    NSInteger          offset;
}

@property(nonatomic ,strong)UITableView *riceRecordTableView;
@property(nonatomic ,strong)BlankView   *blankView;

@end

@implementation RiceRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"用米记录";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    offset=0;
    
    riceRecordArray = [[NSMutableArray alloc] init];
    dateArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.riceRecordTableView];
    [self.riceRecordTableView addSubview:self.blankView];
    self.blankView.hidden=YES;
    
    [self requestRiceRecordData];
}


#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return dateArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *tempDateStr=dateArray[section];
    NSMutableArray *tempRowsArr=[[NSMutableArray alloc] init];
    for (RiceRecordModel *model in riceRecordArray) {
        if ([model.date isEqualToString:tempDateStr]) {
            [tempRowsArr addObject:model];
        }
    }
    return tempRowsArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"RiceRecordTableViewCell";
    RiceRecordTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[RiceRecordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    NSString *tempDateStr=dateArray[indexPath.section];
    NSMutableArray *tempRowsArr=[[NSMutableArray alloc] init];
    for (RiceRecordModel *model in riceRecordArray) {
        if ([model.date isEqualToString:tempDateStr]) {
            [tempRowsArr addObject:model];
        }
    }
    NSArray *valuesArr=[tempRowsArr sortedArrayUsingComparator:^NSComparisonResult(RiceRecordModel *obj1, RiceRecordModel *obj2) {
        return [obj2.time compare:obj1.time]; //降序
    }];
    
    RiceRecordModel *riceRecordModel =valuesArr[indexPath.row];
    [cell riceRecordCellDisplayWithModel:riceRecordModel];
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 66;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return dateArray[section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

#pragma mark -- Private methods
#pragma mark 获取最新出米记录
-(void)loadNewRiceRecordData{
    offset=0;
    [self requestRiceRecordData];
}

#pragma mark 获取更多出米记录
-(void)loadMoreRiceRecordData{
    offset++;
    [self requestRiceRecordData];
}

#pragma mark -- 获取用米数据
- (void)requestRiceRecordData{
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    int deviceId=[StorageDeviceHelper sharedStorageDeviceHelper].device_id;
    NSDictionary *contentDict=@{@"offset":@(offset*20),@"limit":@(20),@"rule_id":kStorageRuleId,@"sort_by_date":@"desc"};
    __weak typeof(self) weakSelf=self;
    [HttpRequest getDeviceSnapshotWithContent:contentDict ProductID:CABINETS_PRODUCT_ID withAccessToken:[userDic valueForKey:@"access_token"] deviceID:deviceId didLoadData:^(id result, NSError *err) {
        [weakSelf.riceRecordTableView.mj_header endRefreshing];
        [weakSelf.riceRecordTableView.mj_footer endRefreshing];
        if (err) {
            MyLog(@"获取设备快照失败 error:%@",err.localizedDescription);
        }else{
            MyLog(@"获取设备快照成功 result：%@",result);
            NSArray *list=[result objectForKey:@"list"];
            if (kIsArray(list)) {
                NSMutableArray  *tempArr=[[NSMutableArray alloc] init];
                NSMutableArray *tempTimeArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dict in list) {
                    RiceRecordModel *model=[[RiceRecordModel alloc] init];
                    model.outRiceVlue=[dict[@"4"] integerValue];
                    NSString *dateStr=dict[@"snapshot_date"];
                    model.date=[dateStr substringWithRange:NSMakeRange(0, 10)];
                    model.time=[dateStr substringWithRange:NSMakeRange(11, 5)];
                    if (model.outRiceVlue>0) {
                        [tempArr addObject:model];
                    }
                    
                    [tempTimeArr addObject:model.date];
                }
                weakSelf.riceRecordTableView.mj_footer.hidden=list.count<20;
                
                NSString *body2=[NSString stringWithFormat:@"device_id=%d&page_num=1&page_size=1000",deviceId];
                [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kGetOfflineRiceRecord body:body2 success:^(id json) {
                    NSArray *offlineResult=[json objectForKey:@"result"];
                    for (NSDictionary *tempDict in offlineResult) {
                        RiceRecordModel *recordModel=[[RiceRecordModel alloc] init];
                        recordModel.date=[[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",tempDict[@"record_time"]] format:@"YYYY-MM-dd"];
                        recordModel.time=[[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",tempDict[@"record_time"]] format:@"HH:mm"];
                        recordModel.outRiceVlue=[tempDict[@"cup"] integerValue];
                        [tempArr addObject:recordModel];
                        [tempTimeArr addObject:recordModel.date];
                    }
                    
                    if (offset==0) {
                        riceRecordArray=tempArr;
                        dateArray=tempTimeArr;
                    }else{
                        [riceRecordArray addObjectsFromArray:tempArr];
                        [dateArray addObjectsFromArray:tempTimeArr];
                    }
                    
                    //时间剔重排序
                    NSSet *set = [NSSet setWithArray:dateArray];
                    NSArray *timeArr=[set allObjects];
                    timeArr=[timeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        return [obj2 compare:obj1]; //降序
                    }];
                    dateArray=[NSMutableArray arrayWithArray:timeArr];
                    MyLog(@"times:%@",dateArray);
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            if (offset==0) {
                                weakSelf.blankView.hidden=riceRecordArray.count>0;
                            }
                            [weakSelf.riceRecordTableView reloadData];
                        });
                    });
                    
                } failure:^(NSString *errorStr) {
                    MyLog(@"获取离线出米记录失败");
                }];
            }
        }
    }];
}

#pragma mark -- setters
-(UITableView *)riceRecordTableView{
    if (_riceRecordTableView==nil) {
        _riceRecordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _riceRecordTableView.backgroundColor = [UIColor bgColor_Gray];
        _riceRecordTableView.delegate = self;
        _riceRecordTableView.dataSource = self;
        [_riceRecordTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewRiceRecordData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _riceRecordTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreRiceRecordData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _riceRecordTableView.mj_footer = footer;
        footer.hidden = YES;
    }
    return _riceRecordTableView;
}

#pragma mark 暂无记录
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView=[[BlankView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) img:@"pub_ic_kong" text:@"暂无出米记录"];
    }
    return _blankView;
}


@end
