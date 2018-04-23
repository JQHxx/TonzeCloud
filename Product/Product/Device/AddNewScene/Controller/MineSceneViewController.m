//
//  MineSceneViewController.m
//  Product
//
//  Created by 肖栋 on 17/5/31.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "MineSceneViewController.h"
#import "MineSceneModel.h"
#import "PerformRecordViewController.h"
#import "AddAndEditSceneViewController.h"
#import "MineSceneModel.h"
#import "SceneDeviceModel.h"
#import "MineSceneCell.h"
#import "SceneDetailsViewController.h"
#import "RecommendedSceneView.h"
#import "SceneHelper.h"

@interface MineSceneViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _pageNum;
}
///
@property (nonatomic ,strong) NSMutableArray *mySceneMarray;

@property (nonatomic,strong)  UITableView   *mySceneTableView;
/// 添加场景
@property (nonatomic ,strong) UIButton *addSceneBtn;
/// 推荐场景
@property (nonatomic ,strong) RecommendedSceneView *recommendedSceneView;

@end

@implementation MineSceneViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([SceneHelper sharedSceneHelper].isRefreshSceneData) {
        [self loadMineSceneData];
        [SceneHelper sharedSceneHelper].isRefreshSceneData=NO;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04" type:2];
#endif
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的场景";
    self.rigthTitleName = @"执行记录";
    
    _pageNum = 1;
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self setMineSceneView];
    [self loadMineSceneData];
}

#pragma mark ====== set UI =======
- (void)setMineSceneView{
    [self.view addSubview:self.mySceneTableView];
    [self.view addSubview:self.addSceneBtn];
}
#pragma mark ====== request Data =======
- (void)loadMineSceneData{
    NSString *url = [NSString stringWithFormat:@"%@?page_size=20&page_num=%ld",KSceneList,(long)_pageNum];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]getMethodWithURL:url isLoading:YES success:^(id json) {
        NSArray *resultArry = [json objectForKey:@"result"];
        NSInteger totalNumber = [[json objectForKey:@"total"] integerValue];
        weakSelf.mySceneTableView.mj_footer.hidden =(totalNumber-_pageNum*20)<= 0;
        if (kIsArray(resultArry) && resultArry.count > 0) {
            weakSelf.recommendedSceneView.hidden = YES;
            NSMutableArray *tempMySceneArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in resultArry) {
                MineSceneModel *mineScentModle = [MineSceneModel new];
                [mineScentModle setValues:dict];
                [tempMySceneArr  addObject:mineScentModle];
            }
            weakSelf.mySceneTableView.mj_footer.hidden=tempMySceneArr.count<20;
            if (_pageNum==1) {
                weakSelf.mySceneMarray=tempMySceneArr;
            }else{
                [weakSelf.mySceneMarray addObjectsFromArray:tempMySceneArr];
            }
        }else{
            [weakSelf.view addSubview:weakSelf.recommendedSceneView];
            weakSelf.recommendedSceneView.hidden = NO;
        }
        [weakSelf.mySceneTableView reloadData];
        [weakSelf.mySceneTableView.mj_header endRefreshing];
        [weakSelf.mySceneTableView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.mySceneTableView.mj_header endRefreshing];
        [weakSelf.mySceneTableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

- (void)loadNewSceneData{
    _pageNum = 1;
    [self loadMineSceneData];
}


-(void)loadMoreSceneData{
    _pageNum++;
    [self loadMineSceneData];
}

#pragma mark -- UITableViewDelegate and UITableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mySceneMarray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 276/2 + 15;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"MineSceneTableViewCell";
    MineSceneCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[MineSceneCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    MineSceneModel *mySceneModel  = self.mySceneMarray[indexPath.row];
    [cell cellWithMineSceneMode:mySceneModel];
    cell.deviceProductIdArray = mySceneModel.device;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SceneDetailsViewController *sceneDetailVC = [SceneDetailsViewController new];
    MineSceneModel *mySceneModel  = self.mySceneMarray[indexPath.row];
    sceneDetailVC.sceneNameStr = mySceneModel.scene_name;
    sceneDetailVC.sceneId = [mySceneModel.scene_id integerValue];
    [self push:sceneDetailVC];
}

#pragma mark -- Event response

- (void)rightButtonAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-02"];
#endif
    PerformRecordViewController *performRecordVC = [PerformRecordViewController new];
    [self push:performRecordVC];
}

#pragma mark -- 添加场景
- (void)addSceneAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-01"];
#endif
    AddAndEditSceneViewController *addScreneVC = [AddAndEditSceneViewController new];
    [self push:addScreneVC];
}

#pragma mark -- setters && getters
#pragma mark 我的场景列表
- (UITableView *)mySceneTableView{
    if (!_mySceneTableView) {
        _mySceneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight - 44) style:UITableViewStylePlain];
        _mySceneTableView.delegate = self;
        _mySceneTableView.dataSource = self;
        _mySceneTableView.backgroundColor=[UIColor bgColor_Gray];
        _mySceneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewSceneData)];
        header.automaticallyChangeAlpha= YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _mySceneTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreSceneData)];
        footer.automaticallyRefresh = NO;
        _mySceneTableView.mj_footer = footer;
        footer.hidden = YES;
    }
    return _mySceneTableView;
}

- (NSMutableArray *)mySceneMarray{
    if (!_mySceneMarray) {
        _mySceneMarray = [NSMutableArray array];
    }
    return _mySceneMarray;
}

- (UIButton *)addSceneBtn{
    if (!_addSceneBtn) {
        _addSceneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addSceneBtn.frame = CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44);
        [_addSceneBtn setTitle:@"添加场景" forState:UIControlStateNormal];
        [_addSceneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addSceneBtn.backgroundColor = KSysOrangeColor;
        [_addSceneBtn addTarget:self action:@selector(addSceneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addSceneBtn;
}

- (RecommendedSceneView *)recommendedSceneView{
    if (!_recommendedSceneView) {
        _recommendedSceneView = [[RecommendedSceneView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight - 200)];
    }
    return  _recommendedSceneView;
}


@end
