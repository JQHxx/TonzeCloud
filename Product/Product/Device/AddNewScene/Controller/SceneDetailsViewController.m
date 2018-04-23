//
//  SceneDetailsViewController.m
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SceneDetailsViewController.h"
#import "SceneDetailsCell.h"
#import "SceneDetailDeviceTaskModel.h"
#import "AddAndEditSceneViewController.h"
#import "RecordStatusModel.h"
#import "SceneDetailsTimeIntervalsCell.h"

@interface SceneDetailsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    BOOL        _isCarriedOut; // 已执行
    NSString    *_record_flag;  //执行场景标识
    NSTimer     *timer;
}
///
@property (nonatomic, strong) UITableView *sceneDetailTableView;
///
@property (nonatomic ,strong) NSMutableArray *sceneDetailArray;
/// 执行场景按钮
@property (nonatomic ,strong) UIButton *carriedOutBtn;
/// 场景状态数据
@property (nonatomic ,strong) NSMutableArray *sceneStepTypeArray;


@end

@implementation SceneDetailsViewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (timer) {
        [timer invalidate];
        timer=nil;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = self.sceneNameStr;
    self.rigthTitleName = @"编辑";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    _isCarriedOut = NO;
    [self setSceneDetailsView];
    [self loadSceneDetailsData];
}

#pragma mark -- Bulid UI
- (void)setSceneDetailsView{
    [self.view addSubview:self.sceneDetailTableView];
    [self.view addSubview:self.carriedOutBtn];
}

- (UIView *)tableHearView{
    UIView *hearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 100/2)];
    hearView.backgroundColor = [UIColor bgColor_Gray];
    
    UIImageView *startImg = [[UIImageView alloc]initWithFrame:CGRectMake(16, (50- 24)/2, 24, 24)];
    startImg.image = [UIImage imageNamed:@"RecommendedScene_start_ic"];
    [hearView addSubview:startImg];
    
    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(15+ 12, startImg.bottom, 2, hearView.height - startImg.bottom)];
    len.backgroundColor = UIColorHex(0xE3E6E6);
    [hearView addSubview:len];
    
    return hearView;
}

- (UIView *)tableFooterView{
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 71)];
    footerView.backgroundColor = [UIColor bgColor_Gray];
    
    UIImageView *startImg = [[UIImageView alloc]initWithFrame:CGRectMake(16, 0, 24, 24)];
    startImg.image = [UIImage imageNamed:@"RecommendedScene_finsh_ic"];
    [footerView addSubview:startImg];
    
    return footerView;
}

#pragma mark -- Request Data
- (void)loadSceneDetailsData{
    NSString *urlStr = [NSString stringWithFormat:@"%@?scene_id=%ld",KSceneDetail,(long)_sceneId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] getMethodWithURL:urlStr isLoading:YES success:^(id json) {
        NSDictionary *resultDict = [json objectForKey:@"result"];
        NSArray *deviceTaskArry = [resultDict objectForKey:@"device_task"];
        //场景执行状态  1 执行中 0未执行
        NSInteger status = [[resultDict objectForKey:@"complete"] integerValue];
        if (status == 1) {
            [weakSelf.carriedOutBtn setTitle:@"停止执行" forState:UIControlStateNormal];
            _isCarriedOut = YES;
            weakSelf.isHiddenRightBtn = NO;
        }
        if (kIsArray(deviceTaskArry)) {
            for (NSDictionary *dict in deviceTaskArry) {
                SceneDetailDeviceTaskModel *deviceTaskModel = [SceneDetailDeviceTaskModel new];
                [deviceTaskModel setValues:dict];
                [weakSelf.sceneDetailArray addObject:deviceTaskModel];
            }
        }
        weakSelf.sceneDetailTableView.tableHeaderView = [weakSelf tableHearView];
        weakSelf.sceneDetailTableView.tableFooterView = [weakSelf tableFooterView];
        [weakSelf.sceneDetailTableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

/// --- 发起设备状态查询
- (void)queryStatus{
    NSString *urlStr = [NSString stringWithFormat:@"%@?scene_id=%ld&record_flag=%@",KRecordStatus,(long)_sceneId,_record_flag];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] getMethodWithURL:urlStr isLoading:NO success:^(id json) {
        NSDictionary *dict = [json objectForKey:@"result"];
        NSInteger complete=[[dict valueForKey:@"complete"] integerValue];
        if (complete==0) {
            if (timer) {
                [timer invalidate];
                timer=nil;
            }
            weakSelf.isHiddenRightBtn = NO;
            _isCarriedOut = NO;
            [weakSelf.carriedOutBtn setTitle:@"重新执行" forState:UIControlStateNormal];
            [weakSelf.view makeToast:@"执行完成!" duration:1.0 position:CSToastPositionCenter];
        }
        NSArray *deviceArray = [dict objectForKey:@"device"];
        if (kIsArray(deviceArray)) {
            for (NSDictionary *deviceDict in deviceArray) {
                RecordStatusModel *recordStatusModel = [RecordStatusModel new];
                [recordStatusModel setValues:deviceDict];
                [weakSelf.sceneStepTypeArray addObject:recordStatusModel];
            }
            [weakSelf.sceneDetailTableView reloadData];
        }
    } failure:^(NSString *errorStr) {
//                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

// 开始执行和停止执行
- (void)startAndEndRecorScene{
    if (_isCarriedOut) {// -- 停止执行
        NSString *body = [NSString stringWithFormat:@"scene_id=%ld",(long)_sceneId];
        kSelfWeak;
        [[NetworkTool sharedNetworkTool]postMethodWithURL:KStopRecorScene body:body success:^(id json) {
            NSInteger status = [[json objectForKey:@"status"] integerValue];
            if (status == 1) {
                if (timer) {
                    [timer invalidate];
                    timer=nil;
                }
                weakSelf.isHiddenRightBtn = NO;
                _isCarriedOut = NO;
                [weakSelf.carriedOutBtn setTitle:@"执行场景" forState:UIControlStateNormal];
            }
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }else{ // -- 开始执行
        NSString *dataStr =[[TJYHelper sharedTJYHelper] getCurrentDateTime];
        NSInteger time =[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:dataStr format:@"yyyy-MM-dd HH:mm"];
        NSString *body = [NSString stringWithFormat:@"scene_id=%ld&start_time=%ld",(long)_sceneId,(long)time];
        kSelfWeak;
        [[NetworkTool sharedNetworkTool]postMethodWithURL:KStartRecorScene body:body success:^(id json) {
            NSDictionary *result=[json objectForKey:@"result"];
            if (kIsDictionary(result)) {
                _record_flag=[result valueForKey:@"record_flag"];
                [weakSelf.view makeToast:@"开始执行场景" duration:1.0 position:CSToastPositionCenter];
                // 启动定时查询执行状态
                if (timer==nil) {
                    timer = [NSTimer scheduledTimerWithTimeInterval:(2.0)
                                                              target:self
                                                            selector:@selector(queryStatus)
                                                            userInfo:nil
                                                             repeats:YES];
                }
                _isCarriedOut = YES;
                [weakSelf.carriedOutBtn setTitle:@"停止执行" forState:UIControlStateNormal];
                weakSelf.isHiddenRightBtn = YES;
            }
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}

#pragma mark ====== Event response =======
- (void)carriedOutClick{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-13"];
#endif
    if (_isCarriedOut) {
        UIAlertView *arertView = [[UIAlertView alloc]initWithTitle:@"确定停止执行该场景吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [arertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self startAndEndRecorScene];
            }
        }];
    }else{
        [self startAndEndRecorScene];
    }
}

#pragma mark ====== Event response =======
- (void)rightButtonAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-14"];
#endif
    AddAndEditSceneViewController *editSceneVC = [AddAndEditSceneViewController new];
    editSceneVC.sceneType = EditSceneType;
    editSceneVC.sceneId = _sceneId;
    [self push:editSceneVC];
}

#pragma mark ====== UITableViewDataSource =======
#pragma mark ====== UITableViewDelegate =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sceneDetailArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SceneDetailDeviceTaskModel *deviceTaskModel = self.sceneDetailArray[indexPath.row];
    if ([deviceTaskModel.device_name isEqualToString:@"0"]) {
        return 30;
    }else{
        return 232/2 + 20;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *sceneDetailIdentifier  = @"sceneDetailsCell";
    static NSString *sceneDetailTimeIdentifier  = @"sceneDetailTimeCell";
    
    SceneDetailDeviceTaskModel *deviceTaskModel= self.sceneDetailArray[indexPath.row];
    if ([deviceTaskModel.device_name isEqualToString:@"0"]) {
        SceneDetailsTimeIntervalsCell *timeIntervalsCell = [tableView dequeueReusableCellWithIdentifier:sceneDetailTimeIdentifier];
        if (!timeIntervalsCell) {
            timeIntervalsCell =[[SceneDetailsTimeIntervalsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sceneDetailTimeIdentifier];
        }
        [timeIntervalsCell setSecordTimeIntervalsCellWithModel:self.sceneDetailArray[indexPath.row]];
        timeIntervalsCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return timeIntervalsCell;
    }else{
        SceneDetailsCell *sceneCell = [tableView dequeueReusableCellWithIdentifier:sceneDetailIdentifier];
        if (!sceneCell) {
            sceneCell = [[SceneDetailsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sceneDetailIdentifier];
        }
        sceneCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [sceneCell setSecordDetailCellWithModel:deviceTaskModel];
        
        RecordStatusModel *recordStatusModel=[[RecordStatusModel alloc] init];
        for (RecordStatusModel *model in self.sceneStepTypeArray) {
            if ([model.device_id isEqualToString:deviceTaskModel.device_id]&&model.step==deviceTaskModel.step) {
                recordStatusModel=model;
            }
        }
        if (recordStatusModel) {
            [sceneCell setStatusWithRecordStatusModel:recordStatusModel];
        }
        return sceneCell;
    }
}

#pragma mark ====== Getter =======
-(NSMutableArray *)sceneDetailArray{
    if (!_sceneDetailArray) {
        _sceneDetailArray = [NSMutableArray array];
    }
    return _sceneDetailArray;
}

- (NSMutableArray *)sceneStepTypeArray{
    if (!_sceneStepTypeArray) {
        _sceneStepTypeArray  = [NSMutableArray array];
    }
    return _sceneStepTypeArray;
}

- (UITableView *)sceneDetailTableView{
    if (!_sceneDetailTableView) {
        _sceneDetailTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight - 44) style:UITableViewStylePlain];
        _sceneDetailTableView.delegate = self;
        _sceneDetailTableView.dataSource = self;
        _sceneDetailTableView.backgroundColor = [UIColor bgColor_Gray];
        _sceneDetailTableView.tableFooterView = [UIView new];
        _sceneDetailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _sceneDetailTableView;
}

- (UIButton *)carriedOutBtn{
    if (!_carriedOutBtn) {
        _carriedOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _carriedOutBtn.frame = CGRectMake(0, kScreenHeight - 44,kScreenWidth , 44);
        [_carriedOutBtn setTitle:@"执行场景" forState:UIControlStateNormal];
        [_carriedOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _carriedOutBtn.backgroundColor = KSysOrangeColor;
        [_carriedOutBtn addTarget:self action:@selector(carriedOutClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _carriedOutBtn;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


@end
