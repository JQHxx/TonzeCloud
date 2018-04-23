//
//  PerformRecordViewController.m
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "PerformRecordViewController.h"
#import "PerformRecordCell.h"
#import "RecordDetailViewController.h"
#import "PerformRecordModel.h"

@interface PerformRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _pageNumber; // 页数
}
@property (nonatomic, strong) UITableView *reconrdTableView;
/// 执行数据
@property (nonatomic ,strong) NSMutableArray *reconrdDataArray;
/// 无数据页面
@property (nonatomic ,strong) BlankView *blankView;

@end

@implementation PerformRecordViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"执行记录";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    _pageNumber = 1;
    [self setPerformRecord];
    [self requestPerformRecordData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-02" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-02" type:2];
#endif
}

#pragma mark ====== Bulid UI =======
- (void)setPerformRecord{
    [self.view addSubview:self.reconrdTableView];
}
#pragma mark ====== Request Data =======
- (void)requestPerformRecordData{
    NSString *urlStr = [NSString stringWithFormat:@"%@?page_size=20&page_num=%ld",kRecordList,(long)_pageNumber];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] getMethodWithURL:urlStr isLoading:YES success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        
        NSInteger totalNum=[[json objectForKey:@"total"] integerValue];
        weakSelf.reconrdTableView.mj_footer.hidden=(totalNum-_pageNumber*20)<=0;
        
        if (kIsArray(resultArray) && resultArray.count > 0) {
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *dict in resultArray) {
                PerformRecordModel *performRecordModel = [PerformRecordModel new];
                [performRecordModel setValues:dict];
                [weakSelf.reconrdDataArray addObject:performRecordModel];
            }
        }else{
            weakSelf.blankView.hidden = NO;
        }
        [weakSelf.reconrdTableView reloadData];
        [weakSelf.reconrdTableView.mj_header endRefreshing];
        [weakSelf.reconrdTableView.mj_header endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.reconrdTableView.mj_header endRefreshing];
        [weakSelf.reconrdTableView.mj_header endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
- (void)loadNewReconrdData{
    _pageNumber = 1;
    [self.reconrdDataArray removeAllObjects];
    [self requestPerformRecordData];
}
- (void)loadMoreReconrdData{
    _pageNumber++;
    [self requestPerformRecordData];
}

#pragma mark ====== UITableViewDataSource =======
#pragma mark ====== UITableViewDelegate =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.reconrdDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *recordIdentifier  = @"recordCell";
    PerformRecordCell *performRecordCell = [tableView dequeueReusableCellWithIdentifier:recordIdentifier];
    if (!performRecordCell) {
        performRecordCell = [[PerformRecordCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:recordIdentifier];
        ;
    }
    performRecordCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [performRecordCell setCellWithModel:_reconrdDataArray[indexPath.row]];

    return performRecordCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordDetailViewController *recordDetailVC = [RecordDetailViewController new];
    PerformRecordModel *performRecordModel = _reconrdDataArray[indexPath.row];
    recordDetailVC.sceneId = [performRecordModel.scene_id integerValue];
    recordDetailVC.record_flag = performRecordModel.record_flag;
    recordDetailVC.sceneNameStr=performRecordModel.scene_name;
    [self push:recordDetailVC];
}

#pragma mark ====== Getter && Setter =======
- (UITableView *)reconrdTableView{
    if (!_reconrdTableView) {
        _reconrdTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight) style:UITableViewStylePlain];
        _reconrdTableView.delegate = self;
        _reconrdTableView.dataSource = self;
        _reconrdTableView.backgroundColor = [UIColor bgColor_Gray];
        _reconrdTableView.tableFooterView = [UIView new];
        _reconrdTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewReconrdData)];
        header.automaticallyChangeAlpha= YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _reconrdTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreReconrdData)];
        footer.automaticallyRefresh = NO;
        _reconrdTableView.mj_footer = footer;
        footer.hidden = YES;
    
        [_reconrdTableView addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return _reconrdTableView;
}
- (BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 +44) img:@"img_tips_no" text:@"暂无执行记录"];
    }
    return _blankView;
}
- (NSMutableArray *)reconrdDataArray{
    if (!_reconrdDataArray) {
        _reconrdDataArray = [NSMutableArray array];
    }
    return _reconrdDataArray;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
