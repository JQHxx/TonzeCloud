//
//  AddSceneViewController.m
//  Product
//
//  Created by 肖栋 on 17/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddAndEditSceneViewController.h"
#import "AddSceneButton.h"
#import "AddDeviceButton.h"
#import "AddDeviceViewController.h"
#import "SceneNameAlertView.h"
#import "SceneOptionView.h"
#import "AddTimeIntervalViewController.h"
#import "AddSceneModel.h"
#import "AddSceneCell.h"
#import "SceneDetailDeviceTaskModel.h"
#import "MineSceneViewController.h"
#import "SceneHelper.h"

@interface AddAndEditSceneViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSString     *_sceneNameStr;      // 场景名称
    NSInteger    _isAllTimeInterval;  // 判断是否全部为时间间隔
    BOOL         _isLastStepTime;     // 最后的步骤为时间
    
    
}
@property (nonatomic ,strong) UIButton           *saveSceneBtn;    // 保存场景
@property (nonatomic ,strong) UILabel            *sceneNameLab;    // 场景名称
@property (nonatomic ,strong) UITableView        *addSceneTab;
@property (nonatomic ,strong) NSMutableArray     *tableArry;
@property (nonatomic, strong) UIView             *coverView;           //遮罩层
@property (nonatomic ,strong) UIView             *optionBgView;        /// 时间设备选择遮罩
@property (nonatomic ,strong) SceneNameAlertView *sceneNameAlertView;  // 场景名称弹窗
@property (nonatomic ,strong) SceneOptionView    *sceneOptionView;     // 设备添加弹窗

@end

@implementation AddAndEditSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self initAddSceneView];
    
    _isLastStepTime = YES;
    
    switch (_sceneType) {
        case AddSceneType:
        {
            self.baseTitle = @"添加场景";
        }break;
         case EditSceneType:
        {
            self.baseTitle = @"编辑场景";
            self.rightImageName = @"deleteScene_icon";
            [self loadSceneDetaliData];
        }break;
        default:
            break;
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(receiveNoti:) name:@"DeviceInfoNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    if (self.sceneType==AddSceneType) {
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-01" type:1];
    }else{
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-14" type:1];
    }
    
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
#if !DEBUG
    if (self.sceneType==AddSceneType) {
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-01" type:2];
    }else{
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-14" type:2];
    }
#endif
}


#pragma mark ====== load Data =======
// 加载设备信息数据
- (void)receiveNoti:(NSNotification*)notification{
    NSDictionary *deviceInfoDict =  notification.userInfo;
    NSString *deviceNameStr = [deviceInfoDict objectForKey:@"deviceName"];
    if (!kIsEmptyString(deviceNameStr)) {
        SceneDetailDeviceTaskModel *addSceneModle = [SceneDetailDeviceTaskModel new];
        addSceneModle.function_type = 1;
        addSceneModle.device_id = [deviceInfoDict objectForKey:@"deviceId"];
        addSceneModle.time_interval = 0;
        addSceneModle.device_name = deviceNameStr;
        addSceneModle.product_id = [deviceInfoDict objectForKey:@"productId"];
        addSceneModle.content_id = [[deviceInfoDict objectForKey:@"cookId"] integerValue];
        addSceneModle.name = [deviceInfoDict objectForKey:@"operationName"];
        addSceneModle.code = [deviceInfoDict objectForKey:@"codeStr"];
        
        [self.tableArry addObject:addSceneModle];
        [_addSceneTab reloadData];
    }
}
- (void)loadSceneDetaliData{
    NSString *urlStr = [NSString stringWithFormat:@"%@?scene_id=%ld",KSceneDetail,(long)_sceneId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] getMethodWithURL:urlStr isLoading:YES success:^(id json) {
        NSDictionary *resultDict = [json objectForKey:@"result"];
        NSArray *deviceTaskArry = [resultDict objectForKey:@"device_task"];
        _sceneNameStr =[resultDict objectForKey:@"scene_name"];
        weakSelf.sceneNameLab.text = _sceneNameStr;
        weakSelf.sceneNameLab.textColor = kSystemColor;
        if (kIsArray(deviceTaskArry)) {
            for (NSDictionary *dict in deviceTaskArry) {
                SceneDetailDeviceTaskModel *devictTaskModel = [SceneDetailDeviceTaskModel new];
                [devictTaskModel setValues:dict];
                [weakSelf.tableArry addObject:devictTaskModel];
            }
        }
        [weakSelf.addSceneTab reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 初始化界面
- (void)initAddSceneView{
    [self.view addSubview:self.addSceneTab];
    [self.view addSubview:self.saveSceneBtn];
}

#pragma mark ====== Set UI =======
// 场景名称
- (UIView *)tableViewHearView{
    UIView *hearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 48  + 10)];
    hearView.backgroundColor = [UIColor whiteColor];
    InsertLabel(hearView, CGRectMake(20,(48 - 20)/2, 100, 20), NSTextAlignmentLeft, @"场景名称", kFontSize(15), UIColorHex(0x313131), NO);
    
    _sceneNameLab =InsertLabel(hearView, CGRectMake(120, (48 - 20)/2, kScreenWidth - 160, 20), NSTextAlignmentRight, @"请输入场景名称", kFontSize(14), UIColorHex(0x959595), NO);
    // 箭头
    InsertImageView(hearView, CGRectMake(kScreenWidth - 35, (48 - 15)/2 , 15, 15), [UIImage imageNamed:@"ic_pub_arrow_nor"]);
    InsertButtonWithType(hearView, CGRectMake(0,0 , kScreenWidth, hearView.height - 10), 1000, self, @selector(setSceneNameClick), UIButtonTypeCustom);
    
    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(0, hearView.height - 10, kScreenWidth, 10)];
    len.backgroundColor = [UIColor bgColor_Gray];
    [hearView addSubview:len];
    return hearView;
}
// 添加场景
- (UIView *)tableViewFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 176)];
    footerView.backgroundColor = [UIColor bgColor_Gray]; ;
    InsertImageButton(footerView, CGRectMake((kScreenWidth - 90)/2, 30, 90, 90), 1000, [UIImage imageNamed:@"add_scene"], [UIImage imageNamed:@"add_scene"], self, @selector(addTimeOrDeviceClick));
    return footerView;
}

#pragma mark ====== Event response =======
#pragma mark 删除任务
- (void)deleteTaskClick:(UIButton *)btn{
    UIAlertView *deleteTaskAlertView = [[UIAlertView alloc]initWithTitle:@"确认删除该任务吗？" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [deleteTaskAlertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            UIView *contentView = [btn superview];
            AddSceneCell *cell = (AddSceneCell *)[contentView superview];
            NSIndexPath *indexPath = [self.addSceneTab indexPathForCell:cell];
            [self.tableArry removeObjectAtIndex:indexPath.row];
            [_addSceneTab reloadData];
        }
    }];
}

#pragma mark  删除场景
- (void)rightButtonAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-11"];
#endif
    UIAlertView *deleteSceneAlertView = [[UIAlertView alloc]initWithTitle:@"确定删除该场景吗？" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    kSelfWeak;
    [deleteSceneAlertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
        if (buttonIndex ==1) {
            NSString *body = [NSString stringWithFormat:@"scene_id=%ld",(long)_sceneId];
            [[NetworkTool sharedNetworkTool]postMethodWithURL:KSceneDelete body:body success:^(id json) {
                NSString *message = [json objectForKey:@"message"];
                [weakSelf.view makeToast:message duration:1.0 position:CSToastPositionCenter];
                for (UIViewController *temp in self.navigationController.viewControllers) {
                    if ([temp isKindOfClass:[MineSceneViewController class]]) {
                        [self.navigationController popToViewController:temp animated:YES];
                    }
                }//返回到我的场景
                [SceneHelper sharedSceneHelper].isRefreshSceneData=YES;
            } failure:^(NSString *errorStr) {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
        }
    }];
}
#pragma mark  保存场景
- (void)saveBtnClick{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-12"];
#endif
    if (_tableArry.count == 0) {
        [self.view makeToast:@"请相关添加设备" duration:1.0 position:CSToastPositionCenter];
        return;
    }else if (kIsEmptyString(_sceneNameStr)){
        [self.view makeToast:@"请输入场景名称" duration:1.0 position:CSToastPositionCenter];
        return;
    }else{
        _isAllTimeInterval = 0; // 初始化值
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        for (NSInteger i = 0 ;i < self.tableArry.count; i++) {
            SceneDetailDeviceTaskModel *addSceneModle = self.tableArry[i];
            NSDictionary *dict = [[NSDictionary alloc]initWithObjects:@[[NSNumber numberWithInteger:i+1],[NSNumber numberWithInteger:addSceneModle.time_interval],addSceneModle.device_id,[NSNumber numberWithInteger:addSceneModle.function_type],addSceneModle.product_id,addSceneModle.device_name,[NSNumber numberWithInteger:addSceneModle.content_id],addSceneModle.code] forKeys:@[@"step",@"time_interval",@"device_id",@"function_type",@"product_id",@"device_name",@"content_id",@"code"]];
            if ([addSceneModle.device_name isEqualToString:@"0"]) {
                _isAllTimeInterval++;
            }
            if (addSceneModle.time_interval == 0 && i == self.tableArry.count - 1){
                _isLastStepTime = NO;// 判断最后一个数据是否为时间间隔
            }
            [tempArr addObject:dict];
        }
        if (_isAllTimeInterval == tempArr.count) {// 判断是否全部为时间间隔类型
            [self.view makeToast:@"请添加设备" duration:1.0 position:CSToastPositionCenter];
            return;
        }else if (_isLastStepTime){
            [self.view makeToast:@"建议您将间隔时间调整到设备之前" duration:1.0 position:CSToastPositionCenter];
            return;
        }else{
            switch (self.sceneType) {
                case AddSceneType:
                {
                    [self addSeneWithArray:tempArr];
                }break;
                case EditSceneType:
                {
                    [self editSeneWithArray:tempArr];
                }break;
                default:
                    break;
            }
        }
    }
}

#pragma mark 添加场景
- (void)addSeneWithArray:(NSMutableArray *)tempArr{
    // 场景数据
    NSString *jsonStr= [[NetworkTool sharedNetworkTool] getValueWithParams:tempArr];
    NSString *body = [NSString stringWithFormat:@"scene_name=%@&device_task=%@",_sceneNameStr,jsonStr];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:KAddScene body:body success:^(id json) {
         MyLog(@"----添加场景成功");
        [SceneHelper sharedSceneHelper].isRefreshSceneData=YES;
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 编辑场景
- (void)editSeneWithArray:(NSMutableArray *)tempArr{
    NSString *jsonStr= [[NetworkTool sharedNetworkTool]getValueWithParams:tempArr];
    NSString *body = [NSString stringWithFormat:@"scene_name=%@&device_task=%@&scene_id=%ld",_sceneNameStr,jsonStr,(long)_sceneId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postMethodWithURL:KSceneEdit body:body success:^(id json) {
        MyLog(@"----编辑场景成功");
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[MineSceneViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
        [SceneHelper sharedSceneHelper].isRefreshSceneData=YES;
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 设定场景名称
- (void)setSceneNameClick{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-03"];
#endif
    [self.view addSubview:self.coverView];
    self.coverView.alpha=0;
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha=0.5;
    }];
    
    [self.view addSubview:self.sceneNameAlertView];
    self.sceneNameAlertView.inputText =kIsEmptyString(_sceneNameStr)?@"": _sceneNameStr;
    
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
        self.sceneNameAlertView.frame=CGRectMake((kScreenWidth-280)/2, 150,280, 160);
    } completion:^(BOOL finished) {
        [self.sceneNameAlertView.textField_input becomeFirstResponder];
    }];
}

#pragma mark ====== 添加间隔时间或设备 =======
- (void)addTimeOrDeviceClick{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-05"];
#endif
    [self.view addSubview:self.optionBgView];
    self.optionBgView.alpha=0.5;
    [self.view addSubview:self.sceneOptionView];
    self.sceneOptionView.frame = CGRectMake(0, kScreenHeight, kScreenWidth,  203);
    kSelfWeak;
   [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
        weakSelf.sceneOptionView.frame = CGRectMake(0, kScreenHeight - 203, kScreenWidth,  203);
    } completion:^(BOOL finished) {

    }];
}

#pragma mark 隐藏遮罩层
-(void)makeHiddenCover{
    kSelfWeak;
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf.sceneNameAlertView.textField_input resignFirstResponder];
        weakSelf.sceneNameAlertView.frame=CGRectMake((kScreenWidth-280)/2,kScreenHeight,280, 160);
    } completion:^(BOOL finished) {
        weakSelf.coverView.alpha=0.0;
        [weakSelf.coverView removeFromSuperview];
        [weakSelf.sceneNameAlertView removeFromSuperview];
    }];
}
- (void)optionBgViewHiddenCover{
    kSelfWeak;
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
        weakSelf.optionBgView.alpha = 0.0;
        [weakSelf.optionBgView removeFromSuperview];
        [weakSelf.sceneOptionView removeFromSuperview];
    } completion:^(BOOL finished) {

    }];
}

#pragma mark -- UITableViewDelegate and UITableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableArry.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"EditSceneTableViewCell";
     AddSceneCell *addAndEditSceneCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!addAndEditSceneCell) {
        addAndEditSceneCell = [[AddSceneCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [addAndEditSceneCell setAddSceneCellWithModel:_tableArry[indexPath.row]];
    addAndEditSceneCell.selectionStyle= UITableViewCellSelectionStyleNone;
    [addAndEditSceneCell.deleteBtn addTarget:self action:@selector(deleteTaskClick:) forControlEvents:UIControlEventTouchUpInside];
    // -- 添加移动手势
    UILongPressGestureRecognizer *pan=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(panReg:)];
    [addAndEditSceneCell addGestureRecognizer:pan];
    
    return addAndEditSceneCell;
}

#pragma mark ====== 移动cell 进行设备或时间间隔调整 =======
- (void)panReg:(UILongPressGestureRecognizer*)recognise{
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)recognise;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.addSceneTab];
    NSIndexPath *indexPath = [self.addSceneTab indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.addSceneTab cellForRowAtIndexPath:indexPath];
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.addSceneTab addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    cell.hidden = YES;
                }];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [self.tableArry exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [self.addSceneTab moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            // Clean up.
            UITableViewCell *cell = [self.addSceneTab cellForRowAtIndexPath:sourceIndexPath];
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                cell.hidden = NO;
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
            }];
            break;
        }
    }
}
#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}
#pragma mark -- setters or getters
- (UITableView *)addSceneTab{
    if (_addSceneTab==nil) {
        _addSceneTab = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight- 64 - 44 ) style:UITableViewStylePlain];
        _addSceneTab.delegate = self;
        _addSceneTab.dataSource = self;
        _addSceneTab.backgroundColor = [UIColor bgColor_Gray];
        _addSceneTab.tableHeaderView = [self tableViewHearView];
        _addSceneTab.tableFooterView = [self tableViewFooterView];
    }
    return _addSceneTab;
}

#pragma mark 遮罩层
-(UIView *)coverView{
    if (!_coverView) {
        _coverView=[[UIView alloc] initWithFrame:self.view.bounds];
        _coverView.backgroundColor=[UIColor blackColor];
        _coverView.autoresizingMask=self.view.autoresizingMask;
        _coverView.userInteractionEnabled=YES;
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeHiddenCover)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

- (UIView *)optionBgView{
    if (!_optionBgView) {
        _optionBgView=[[UIView alloc] initWithFrame:self.view.bounds];
        _optionBgView.backgroundColor=[UIColor blackColor];
        _optionBgView.autoresizingMask=self.view.autoresizingMask;
        _optionBgView.userInteractionEnabled=YES;
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionBgViewHiddenCover)];
        [_optionBgView addGestureRecognizer:tap];
    }
    return _optionBgView;
}
#pragma mark 添加时间或设备
- (SceneOptionView *)sceneOptionView{
    if (!_sceneOptionView) {
        _sceneOptionView = [[SceneOptionView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth,  203)];
        kSelfWeak;
        _sceneOptionView.btnClickBlock = ^(NSInteger index){
            [weakSelf.optionBgView removeFromSuperview];
            switch (index) {
                case 1002:
                {// 添加时间间隔
#if !DEBUG
                    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-06"];
#endif
                    AddTimeIntervalViewController *addTimeIntervalVC = [AddTimeIntervalViewController new];
                    addTimeIntervalVC.timeIntervalBlock = ^(NSInteger timeSum){
#if !DEBUG
                        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-07"];
#endif
                        SceneDetailDeviceTaskModel *addSceneModle = [SceneDetailDeviceTaskModel new];
                        addSceneModle.function_type = 0;
                        addSceneModle.device_id = @"0";
                        addSceneModle.time_interval = timeSum;
                        addSceneModle.device_name = @"0";
                        addSceneModle.product_id = @"0";
                        addSceneModle.content_id = 0;
                        addSceneModle.code = @"0";
                        [weakSelf.tableArry addObject:addSceneModle];
                        [weakSelf.addSceneTab reloadData];
                    };
                    [weakSelf push:addTimeIntervalVC];
                }break;
                case 1001:
                {// 添加设备
#if !DEBUG
                    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-08"];
#endif
                    AddDeviceViewController *addDeviceVC = [AddDeviceViewController new];
                    [weakSelf push:addDeviceVC];
                }break;
                default:
                    break;
            }
            [weakSelf.sceneOptionView removeFromSuperview];
        };
    }
    return _sceneOptionView;
}

#pragma mark 设置场景名称
- (SceneNameAlertView *)sceneNameAlertView{
    if (!_sceneNameAlertView) {
        _sceneNameAlertView =[[SceneNameAlertView alloc] initWithFrame:CGRectMake((kScreenWidth-280)/2, kScreenHeight, 280, 160)];
        kSelfWeak;
        self.sceneNameAlertView.removeView = ^(NSString *sceneNameStr){
            if (!kIsEmptyString(sceneNameStr)) {
                _sceneNameStr = sceneNameStr;
                weakSelf.sceneNameLab.text = sceneNameStr;
                weakSelf.sceneNameLab.textColor = kSystemColor;
#if !DEBUG
                [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-04"];
#endif
            }
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
                weakSelf.sceneNameAlertView.frame=CGRectMake((kScreenWidth-280)/2, 150,280, 160);
            } completion:^(BOOL finished) {
                weakSelf.coverView.alpha=0.0;
                [weakSelf.coverView removeFromSuperview];
                [weakSelf.sceneNameAlertView removeFromSuperview];
            }];
        };
    }
    return _sceneNameAlertView;
}

- (UIButton *)saveSceneBtn{
    if (!_saveSceneBtn) {
        _saveSceneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveSceneBtn.frame = CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44);
        [_saveSceneBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_saveSceneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveSceneBtn.backgroundColor = KSysOrangeColor;
        [_saveSceneBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveSceneBtn;
}

- (NSMutableArray *)tableArry{
    if (!_tableArry) {
        _tableArry = [NSMutableArray array];
    }
    return _tableArry;
}

#pragma mark ====== deallock =======
- (void)dealloc{
    [[NSNotificationCenter  defaultCenter]removeObserver:self name:@"DeviceInfoNotification" object:nil];
}

@end
