
//
//  CloudRecipesViewController.m
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "CloudRecipesViewController.h"
#import "CloudRecipesCell.h"
#import "CloudRecipesModel.h"
#import "AddAndEditSceneViewController.h"
#import "SceneHelper.h"

@interface CloudRecipesViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _pageNumber;
}
@property (nonatomic ,strong) UITableView *menuTableView;
/// 菜谱数据
@property (nonatomic ,strong) NSMutableArray *menuListMarray;
/// 无数据视图
@property (nonatomic ,strong) BlankView *blankView;

@end

@implementation CloudRecipesViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"云菜谱";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    _pageNumber = 1;
    [self setCloudRecipesVC];
    [self loadCloudRecipesData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-10" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-10" type:2];
#endif
}

#pragma mark ====== Set UI =======
- (void)setCloudRecipesVC{
    [self.view addSubview:self.menuTableView];
}

#pragma mark ====== Request Data =======
- (void)loadCloudRecipesData{
    NSInteger equipment=[[SceneHelper sharedSceneHelper] getEquipmentWithDeviceProductID:self.deviceModel.productID];
    NSString *urlStr = [NSString stringWithFormat:@"page_num=%ld&page_size=20&equipment=%ld&type=1",(long)_pageNumber,(long)equipment];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kMenuList body:urlStr success:^(id json) {
        NSMutableArray *resultArr = [json objectForKey:@"result"];
        NSInteger totalNumber = [[json objectForKey:@"total_num"] integerValue];
        weakSelf.menuTableView.mj_footer.hidden=(totalNumber-_pageNumber*20)<=0;
        
        NSMutableArray *dataArr = [NSMutableArray array];
        if (kIsArray(resultArr)&&resultArr.count > 0) {
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *dic  in resultArr) {
                CloudRecipesModel *recipeModle = [CloudRecipesModel new];
                [recipeModle setValues:dic];
                [dataArr addObject:recipeModle];
            }
            [weakSelf.menuListMarray addObjectsFromArray:dataArr];
        }else{
            weakSelf.blankView.hidden = NO;
             [_menuTableView addSubview:weakSelf.blankView];
        }
        [weakSelf.menuTableView.mj_header endRefreshing];
        [weakSelf.menuTableView.mj_footer endRefreshing];
        [weakSelf.menuTableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.menuTableView.mj_header endRefreshing];
        [weakSelf.menuTableView.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


- (void)loadNewMenuData
{
    _pageNumber = 1;
    [self.menuListMarray removeAllObjects];
    [self loadCloudRecipesData];
}
- (void)loadMoreMenuData{
    _pageNumber++;
    [self loadCloudRecipesData];
}
#pragma mark ====== UITableViewDataSource =======
#pragma mark ====== UITableViewDelegate =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _menuListMarray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90 *kScreenWidth/320;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cloudRecipesIdentifier  = @"cloudRecipesCell";
    CloudRecipesCell *cloudRecipesCell = [tableView dequeueReusableCellWithIdentifier:cloudRecipesIdentifier];
    if (!cloudRecipesCell) {
        cloudRecipesCell = [[CloudRecipesCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cloudRecipesIdentifier];
    }
    cloudRecipesCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cloudRecipesCell setMenuListWithModel:_menuListMarray[indexPath.row]];
    return cloudRecipesCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 获取菜谱详情数据
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-10"];
#endif
    CloudRecipesModel *recipeModle = _menuListMarray[indexPath.row];
    NSInteger cookId = recipeModle.cook_id;
    NSString *operationNameStr = [NSString stringWithFormat:@"云菜谱: %@",recipeModle.name];
    NSString *menuCodeStr = [NSString stringWithFormat:@"%@%@",[self loadTitleAscWithMenuName:recipeModle.name],recipeModle.code];
    
    NSString *codeStr = nil;
    if ([self.deviceModel.productID isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]) {
        NSString *preferenceCode;
        switch (recipeModle.tag_id) {
            case 3:
            {
                preferenceCode = [SceneHelper ql_getDeviceCodeWithCloudMenu:menuCodeStr productID:_deviceModel.productID cookerTag:1 isPreference:YES];
            }
                break;
            case 4:
            {
               preferenceCode = [SceneHelper ql_getDeviceCodeWithCloudMenu:menuCodeStr productID:_deviceModel.productID cookerTag:2 isPreference:YES];
            }
                break;
            default:
                break;
        }
        NSString *code = [SceneHelper ql_getDeviceCodeWithCloudMenu:menuCodeStr productID:_deviceModel.productID cookerTag:0 isPreference:NO];
        codeStr = [NSString stringWithFormat:@"%@|%@",preferenceCode,code];
    }else{
        codeStr = [SceneHelper ql_getDeviceCodeWithCloudMenu:menuCodeStr productID:_deviceModel.productID cookerTag:0 isPreference:NO];
    }
    // 数据
    NSDictionary *deviceDict = [[NSDictionary alloc]initWithObjects:@[_deviceModel.productID,[NSNumber numberWithInt:_deviceModel.deviceID],_deviceModel.deviceName,[NSNumber numberWithInteger:cookId],operationNameStr,codeStr] forKeys:@[@"productId",@"deviceId",@"deviceName",@"cookId",@"operationName",@"codeStr"]];
    
    MyLog(@"device--dict:%@",deviceDict);
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"DeviceInfoNotification" object:self userInfo:deviceDict];
    //返回到添加场景
    for (UIViewController *temp in self.navigationController.viewControllers) {
        if ([temp isKindOfClass:[AddAndEditSceneViewController class]]) {
            [self.navigationController popToViewController:temp animated:YES];
        }
    }
}
#pragma mark -- 获取菜谱的asc编码
- (NSString *)loadTitleAscWithMenuName:(NSString *)nameStr{
    NSString *str = @"";
    for (int i=0; i<nameStr.length; i++) {
        int asciiCode = [nameStr characterAtIndex:i]; //65
        NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",asciiCode]];
        str = [NSString stringWithFormat:@"%@%@",str,hexString];
    }
    NSInteger length = str.length;
    for (int i=0; i<40-length; i++) {
        str = [NSString stringWithFormat:@"%@0",str];
    }
    return str;
}

#pragma mark ====== Getter =======
- (UITableView *)menuTableView{
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,64, kScreenWidth, kBodyHeight) style:UITableViewStylePlain];
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        _menuTableView.tableFooterView = [UIView new];
        _menuTableView.backgroundColor = [UIColor bgColor_Gray];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewMenuData)];
        header.automaticallyChangeAlpha= YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _menuTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMenuData)];
        footer.automaticallyRefresh = NO;
        _menuTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _menuTableView;
}
- (BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 +44) img:@"img_tips_no" text:@"暂无相关菜谱"];
    }
    return _blankView;
}
- (NSMutableArray *)menuListMarray{
    if (!_menuListMarray) {
        _menuListMarray = [NSMutableArray array];
    }
    return _menuListMarray;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
