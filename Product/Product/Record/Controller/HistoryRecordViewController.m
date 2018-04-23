//
//  HistoryRecordViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "HistoryRecordViewController.h"
#import "DietHistoryTableViewCell.h"
#import "FoodRecordModel.h"
#import "DietRecordViewController.h"

@interface HistoryRecordViewController ()<UITableViewDelegate,UITableViewDataSource>{

    NSMutableArray         *dietTimeArray;
    NSMutableArray         *dietRecordsArray;
    
    NSInteger              dietPage;     //饮食记录页数
}
@property (nonatomic,strong)UITableView     *dietRecordTableView;
@property (nonatomic,strong)BlankView       *dietBlankView;

@end

@implementation HistoryRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"饮食历史记录";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    dietPage =1;
    dietTimeArray=[[NSMutableArray alloc] init];
    dietRecordsArray=[[NSMutableArray alloc] init];
    [self.view addSubview:self.dietRecordTableView];
    [self.dietRecordTableView addSubview:self.dietBlankView];
    self.dietBlankView.hidden=YES;

    [self loadDietRecordsData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TJYHelper sharedTJYHelper].isHistoryDietReload) {
        dietPage = 1;
        [TJYHelper sharedTJYHelper].isHistoryDietReload=NO;
        [self loadDietRecordsData];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-01-01" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-01-01" type:2];
#endif
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return dietTimeArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *tempList=[[NSMutableArray alloc] init];
    NSString *timeStr=dietTimeArray[section];
    for (FoodRecordModel *model in dietRecordsArray) {
        NSString *timeKey= [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:model.feeding_time format:@"yyyy-MM-dd"];
        if ([timeStr isEqualToString:timeKey]) {
            [tempList addObject:model];
        }
    }
    return tempList.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"DietHistoryTableViewCell";

    DietHistoryTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"DietHistoryTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSMutableArray *tempList=[[NSMutableArray alloc] init];
    NSString *timeStr=dietTimeArray[indexPath.section];
    for (FoodRecordModel *model in dietRecordsArray) {
        NSString *timeKey= [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:model.feeding_time format:@"yyyy-MM-dd"];
        if ([timeStr isEqualToString:timeKey]) {
            [tempList addObject:model];
        }
    }
    FoodRecordModel *diet=tempList[indexPath.row];
    [cell cellDisplayWithModel:diet];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableArray *tempList=[[NSMutableArray alloc] init];
    NSString *timeStr=dietTimeArray[indexPath.section];
    for (FoodRecordModel *model in dietRecordsArray) {
        NSString *timeKey= [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:model.feeding_time format:@"yyyy-MM-dd"];
        if ([timeStr isEqualToString:timeKey]) {
            [tempList addObject:model];
        }
    }
    FoodRecordModel *diet=tempList[indexPath.row];

#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-02"];
#endif
    
    DietRecordViewController *dietVC=[[DietRecordViewController alloc] init];
    [TJYHelper sharedTJYHelper].isHistoryDiet=YES;
    dietVC.foodRecordModel=diet;
    [self.navigationController pushViewController:dietVC animated:YES];

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *timeStr=nil;
    timeStr=dietTimeArray[section];
    return timeStr;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
#pragma mark 加载饮食记录
-(void)loadDietRecordsData{
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&output-way=3",(long)dietPage];
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kDietRecordLists body:body success:^(id json) {
        
        NSDictionary *pager=[json objectForKey:@"pager"];
        if (kIsDictionary(pager)&&pager.count>0) {
            NSInteger totalValues=[[pager valueForKey:@"total"] integerValue];
            self.dietRecordTableView.mj_footer.hidden=(totalValues-dietPage*20)<=0;
        }
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            NSArray *dietRecord=[result valueForKey:@"dietrecord"];
            if (kIsArray(dietRecord)&&dietRecord.count>0) {
                
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                NSMutableArray *tempTimeArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dict in dietRecord) {
                    FoodRecordModel *food=[[FoodRecordModel alloc] init];
                    [food setValues:dict];
                    [tempArr addObject:food];
                    
                    NSString *timeStr= [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:food.feeding_time format:@"yyyy-MM-dd"];
                    [tempTimeArr addObject:timeStr];
                }
                
                if (dietPage==1) {
                    dietRecordsArray=tempArr;
                    dietTimeArray=tempTimeArr;
                }else{
                    [dietRecordsArray addObjectsFromArray:tempArr];
                    [dietTimeArray addObjectsFromArray:tempTimeArr];
                }
                
                NSSet *set = [NSSet setWithArray:dietTimeArray];
                NSArray *timeArr=[set allObjects];
                timeArr=[timeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj2 compare:obj1]; //降序
                }];
                dietTimeArray=[NSMutableArray arrayWithArray:timeArr];
                MyLog(@"times:%@",dietTimeArray);
            }else{
                self.dietBlankView.hidden=NO;
                self.dietRecordTableView.mj_footer.hidden=YES;
            }
            [self.dietRecordTableView reloadData];
            [self.dietRecordTableView.mj_header endRefreshing];
            [self.dietRecordTableView.mj_footer endRefreshing];
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        [self.dietRecordTableView.mj_header endRefreshing];
        [self.dietRecordTableView.mj_footer endRefreshing];
    }];
}

#pragma mark 加载最新记录
-(void)loadNewRecordData{
        dietPage=1;
        [self loadDietRecordsData];
}

#pragma mark 加载更多记录
-(void)loadMoreRecordData{
        dietPage++;
        [self loadDietRecordsData];
}
#pragma mark -- setters
#pragma mark  记录列表
-(UITableView *)dietRecordTableView{
    if (_dietRecordTableView==nil) {
        _dietRecordTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kAllHeight-64) style:UITableViewStyleGrouped];
        _dietRecordTableView.dataSource=self;
        _dietRecordTableView.delegate=self;
        _dietRecordTableView.showsVerticalScrollIndicator=NO;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewRecordData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _dietRecordTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreRecordData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _dietRecordTableView.mj_footer = footer;
        footer.hidden=YES;

    }
    return _dietRecordTableView;
}
#pragma mark 无数据空白页
-(BlankView *)dietBlankView{
    if (_dietBlankView==nil) {
        _dietBlankView=[[BlankView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无历史记录"];
    }
    return _dietBlankView;
}

@end
