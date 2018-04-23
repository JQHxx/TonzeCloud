//
//  RecordDetailiViewController.m
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//  执行详情

#import "RecordDetailViewController.h"
#import "RecordDetailCell.h"
#import "RecordStatusModel.h"

@interface RecordDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *recordDetailTableView;
/// 执行场景详情数据
@property (nonatomic ,strong) NSMutableArray *recordArray;
/// 循环查询场景执行状态
@property (nonatomic ,strong) NSTimer *timer;

@end

@implementation RecordDetailViewController

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.timer) {
        [self.timer invalidate];
    }
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = self.sceneNameStr;
    
    [self setRecordDetailUI];
    [self requestRecordDetailData];
}
#pragma mark ====== Bulid UI =======
- (void)setRecordDetailUI{
    [self.view addSubview:self.recordDetailTableView];
}
#pragma mark ====== Request Data =======
// 请求场景执行设备和时间间隔列表
- (void)requestRecordDetailData{
    NSString *urlStr = [NSString stringWithFormat:@"%@?scene_id=%ld&record_flag=%@",kRecordDetail,(long)_sceneId,_record_flag];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] getMethodWithURL:urlStr isLoading:YES success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        if (kIsArray(resultArray)) {
            for (NSDictionary *dict in resultArray) {
                RecordStatusModel *devictStatusModel = [[RecordStatusModel alloc] init];
                [devictStatusModel setValues:dict];
                [weakSelf.recordArray addObject:devictStatusModel];
            }
        }
        [weakSelf.recordDetailTableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


#pragma mark ====== UITableViewDataSource =======
#pragma mark ====== UITableViewDelegate =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.recordArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier  = @"recordDetailCell";
    RecordDetailCell *recordDetailCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!recordDetailCell) {
        recordDetailCell = [[RecordDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    recordDetailCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [recordDetailCell setStatusWithRecordStatusModel:self.recordArray[indexPath.row]];
    
    return  recordDetailCell;
}

#pragma mark ====== Getter && Setter =======
- (UITableView *)recordDetailTableView{
    if (!_recordDetailTableView) {
        _recordDetailTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight) style:UITableViewStylePlain];
        _recordDetailTableView.delegate = self;
        _recordDetailTableView.dataSource = self;
        _recordDetailTableView.backgroundColor = [UIColor bgColor_Gray];
        _recordDetailTableView.tableFooterView = [UIView new];
    }
    return _recordDetailTableView;
}


- (NSMutableArray *)recordArray{
    if (!_recordArray) {
        _recordArray = [NSMutableArray array];
    }
    return _recordArray;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
