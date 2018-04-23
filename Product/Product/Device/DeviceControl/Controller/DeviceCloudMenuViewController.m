//
//  DeviceCloudMenuViewController.m
//  Product
//
//  Created by Feng on 16/3/3.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DeviceCloudMenuViewController.h"
#import "AppDelegate.h"
#import "DeviceHelper.h"
#import "DeviceProgressViewController.h"
#import "DeviceHelper.h"
#import "DeviceCloudMenuTableViewCell.h"
#import "deviceCloudMenuModel.h"
#import "CloudMenuDetailViewController.h"

@interface DeviceCloudMenuViewController ()<UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>{

    NSMutableArray  *menuArray;
    NSInteger page;
}
@property(nonatomic,strong)UITableView *deviceCloudMenuTab;
@property(nonatomic,strong)BlankView * blankView;
@end

@implementation DeviceCloudMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.model.deviceType == 3) {
        if (self.model.isTea) {
            self.baseTitle=[TonzeHelpTool sharedTonzeHelpTool].teaType;
        }else{
           self.baseTitle = @"云功能";
        }
    } else if(self.model.deviceType == 4){
       self.baseTitle=[TonzeHelpTool sharedTonzeHelpTool].prefrenceType;
    }else{
       self.baseTitle=@"云菜谱";
    }
    page=1;
    menuArray = [[NSMutableArray alloc] init];

    [self.view addSubview:self.deviceCloudMenuTab];
    [self.deviceCloudMenuTab addSubview:self.blankView];
    self.blankView.hidden=YES;
    self.deviceCloudMenuTab.tableFooterView = [[UIView alloc] init];
    [self requestCloudMenu];
}

// 暂无数据页面
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView=[[BlankView alloc] initWithFrame:self.deviceCloudMenuTab.bounds img:@"img_pub_none" text:@"暂无云菜谱"];
    }
    return _blankView;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeSyncData object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
   
    
}
#pragma mark --UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return menuArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"DeviceCloudMenuTableViewCell";
    
    DeviceCloudMenuTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"DeviceCloudMenuTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    deviceCloudMenuModel *model = menuArray[indexPath.row];
    [cell cellDisplayWithModel:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    deviceCloudMenuModel *deviceCloudModel = menuArray[indexPath.row];

    CloudMenuDetailViewController *cloudMenuDetailVC = [[CloudMenuDetailViewController alloc] init];
    cloudMenuDetailVC.model = self.model;
    cloudMenuDetailVC.menuid  = deviceCloudModel.cook_id;
    [self.navigationController pushViewController:cloudMenuDetailVC animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 90;
}
#pragma mark -- 获取云菜谱列表
- (void)requestCloudMenu{
    
    NSInteger index = [[TJYHelper sharedTJYHelper] loadDeviceID:self.model.productID];
    NSString *urlStr  = nil;
    if ([[TonzeHelpTool sharedTonzeHelpTool].teaType isEqualToString:@"花草茶"]&&self.model.isTea==YES) {
        urlStr = [NSString stringWithFormat:@"page_num=%ld&page_size=20&type=1&equipment=%ld&tag=1",(long)page,index];
    } else if([[TonzeHelpTool sharedTonzeHelpTool].teaType isEqualToString:@"水果茶"]&&self.model.isTea==YES) {
        urlStr = [NSString stringWithFormat:@"page_num=%ld&page_size=20&type=1&equipment=%ld&tag=2",(long)page,index];
    }else{
    urlStr = [NSString stringWithFormat:@"page_num=%ld&page_size=20&type=1&equipment=%ld",(long)page,index];
    }
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postMethodWithURL:kMenuList body:urlStr success:^(id json) {
        NSMutableArray *resultArr = [json objectForKey:@"result"];
        NSInteger totalNumber = [[json objectForKey:@"total_num"] integerValue];
        self.deviceCloudMenuTab.mj_footer.hidden=(totalNumber-page*20)<=0;
        NSMutableArray *dataArr = [NSMutableArray array];
        if (resultArr.count > 0) {
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *dic  in resultArr) {
                deviceCloudMenuModel *menuListModel = [deviceCloudMenuModel new];
                [menuListModel setValues:dic];
                [dataArr addObject:menuListModel];
            }
            if (page==1) {
                [menuArray removeAllObjects];
                [menuArray addObjectsFromArray:dataArr];
                
            }else{
                
                [menuArray addObjectsFromArray:dataArr];
            }
        }else{
            // 上拉无数据直接隐藏上拉刷新
            if (page == 1) {
                [menuArray removeAllObjects];
            }
            weakSelf.deviceCloudMenuTab.mj_footer.hidden=YES;
            weakSelf.blankView.hidden = NO;
        }
        [weakSelf.deviceCloudMenuTab.mj_header endRefreshing];
        [weakSelf.deviceCloudMenuTab.mj_footer endRefreshing];
        [weakSelf.deviceCloudMenuTab reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.deviceCloudMenuTab.mj_header endRefreshing];
        [weakSelf.deviceCloudMenuTab.mj_footer endRefreshing];
        [weakSelf.deviceCloudMenuTab reloadData];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
    
    
}
#pragma mark -- 设备接收信息
-(void)OnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    if ([[device getMacAddressSimple]isEqualToString:self.model.mac]) {
        DeviceModel *model=[[DeviceModel alloc]init];
        
        model.deviceName=[DeviceHelper getDeviceName:device];
        model.isOnline=YES;
        model.deviceType=[DeviceHelper getDeviceTypeWithMac:[device getMacAddressSimple]];
        model.deviceID=[device getDeviceID];
        model.mac=[device getMacAddressSimple];
        model.State=[DeviceHelper getStateDicWithDevice:device Data:recvData];
        model.productID=device.productID;
        
        if ([[model.State objectForKey:@"state"]isEqualToString:@"云菜谱"] || [[model.State objectForKey:@"state"]isEqualToString:@"云功能"]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [NSUserDefaultInfos putKey:@"name" andValue:[model.State objectForKey:@"name"]];
                    [self performSegueWithIdentifier:@"ToProgressView" sender:model];
                });
            });
            
        }
        
    }
    
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToProgressView"]) {
        DeviceProgressViewController *progressView=segue.destinationViewController;
        progressView.model=sender;
    }
}

#pragma mark -- loadMoreFoodData  with loadNewFoodData
/// - 加载更多
- (void)loadMoreCloudMenuData{
    page++;
    [self requestCloudMenu];
}
/// 加载最新
- (void)loadNewCloudMenuData{
    page = 1;
    [self requestCloudMenu];
}
#pragma mark -- setters
- (UITableView *)deviceCloudMenuTab{
    if (_deviceCloudMenuTab==nil) {
        
        _deviceCloudMenuTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationHeight+20, kScreenWidth, kAllHeight-64) style:UITableViewStylePlain];
        _deviceCloudMenuTab.backgroundColor = [UIColor bgColor_Gray];
        _deviceCloudMenuTab.delegate = self;
        _deviceCloudMenuTab.dataSource = self;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewCloudMenuData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _deviceCloudMenuTab.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreCloudMenuData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _deviceCloudMenuTab.mj_footer = footer;
        footer.hidden = YES;

    }
    return _deviceCloudMenuTab;
}
@end
