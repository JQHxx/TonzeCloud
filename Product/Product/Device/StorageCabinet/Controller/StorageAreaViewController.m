//
//  StorageAreaViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StorageAreaViewController.h"
#import "StorageModel.h"
#import "StorageAreaTableViewCell.h"
#import "FoodScaleView.h"
#import "StorageAddFoodViewController.h"
#import "BlankView.h"
#import "TJYSearchFoodVC.h"
#import "StorageDeviceHelper.h"


@interface StorageAreaViewController ()<UITableViewDelegate,UITableViewDataSource,FoodScaleViewDelegate>{
    NSMutableArray      *storageArray;
}

@property (nonatomic ,strong)UITableView *storageTab;
@property (nonatomic ,strong)BlankView   *blankView;


@end

@implementation StorageAreaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"储物区";
    self.rightImageName = @"添加";
    storageArray = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.storageTab];
    [self.storageTab addSubview:self.blankView];
    self.blankView.hidden=storageArray.count>0;
    
    [self requestStorageData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    if ([StorageDeviceHelper sharedStorageDeviceHelper].isStorageFoodRefresh) {
        [self requestStorageData];
        [StorageDeviceHelper sharedStorageDeviceHelper].isStorageFoodRefresh=NO;
    }
}

#pragma mark --UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return storageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"StorageAreaTableViewCell";
    StorageAreaTableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[StorageAreaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    StorageModel *storageModel =storageArray[indexPath.row];
    [cell storageCellDisplayWithModel:storageModel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    StorageModel *storageModel =storageArray[indexPath.row];
    
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *takeoutFoodButtonTitle = NSLocalizedString(@"取出食材", nil);
    NSString *editFoodButtonTitle = NSLocalizedString(@"编辑食材", nil);
    NSString *searchFoodButtonTitle = NSLocalizedString(@"搜索食材", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __block __typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *takeoutFoodAction = [UIAlertAction actionWithTitle:takeoutFoodButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        FoodScaleView *scaleView=[[FoodScaleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300) WithModel:storageModel];
        scaleView.foodScaleDelegate=self;
        [scaleView foodScaleViewShowInView:weakSelf.view];
    }];
    UIAlertAction *editFoodAction = [UIAlertAction actionWithTitle:editFoodButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        StorageAddFoodViewController *storageAddFoodVC = [[StorageAddFoodViewController alloc] init];
        storageAddFoodVC.foodModel=storageModel;
        storageAddFoodVC.storageType=1;
        [weakSelf.navigationController pushViewController:storageAddFoodVC animated:YES];
    }];
    UIAlertAction *searchFoodAction = [UIAlertAction actionWithTitle:searchFoodButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        TJYSearchFoodVC *searchVC = [[TJYSearchFoodVC alloc] init];
        searchVC.searchType = FoodSearchType;
        searchVC.keyword=storageModel.item_name;
        [self push:searchVC];
    }];
    //管理员才能显示
    [alertController addAction:takeoutFoodAction];
    [alertController addAction:editFoodAction];
    [alertController addAction:searchFoodAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    headView.backgroundColor=kSystemColor;
    
    NSArray *titlesArr=@[@"食材名称",@"重量",@"过期日期"];
    for (NSInteger i=0; i<titlesArr.count; i++) {
        UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(i*kScreenWidth/3, 10, kScreenWidth/3, 30)];
        lbl.textAlignment=NSTextAlignmentCenter;
        lbl.font=[UIFont boldSystemFontOfSize:16];
        lbl.text=titlesArr[i];
        lbl.textColor=[UIColor whiteColor];
        [headView addSubview:lbl];
    }
    
    UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    line.backgroundColor=[UIColor whiteColor];
    [headView addSubview:line];
    
    return headView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

#pragma mark -- Event response
#pragma mark -- 添加
- (void)rightButtonAction{
    StorageAddFoodViewController *storageAddFoodVC = [[StorageAddFoodViewController alloc] init];
    storageAddFoodVC.storageType=0;
    [self.navigationController pushViewController:storageAddFoodVC animated:YES];
}

#pragma mark -- Custom Delegate
#pragma mark  ScaleViewDelegate
#pragma mark -- 取出食物
- (void)foodScaleViewTakeoutForFood:(StorageModel *)model{
    int deviceId=[StorageDeviceHelper sharedStorageDeviceHelper].device_id;
    NSString *body=[NSString stringWithFormat:@"device_id=%d&overdue_time=%ld&weight=%ld&item_name=%@&locker_ingredient_id=%ld&doSubmit=1",deviceId,(long)model.overdue_time,(long)model.weight,model.item_name,(long)model.locker_ingredient_id];
    __weak typeof(self) weakSelf=self;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kUpdateStorageFood body:body success:^(id json) {
        [StorageDeviceHelper sharedStorageDeviceHelper].isStorageHomereFresh=YES;
        [weakSelf requestStorageData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


#pragma mark -- Private Methods
#pragma mark  获取储物区数据
- (void)requestStorageData{
    __weak typeof(self) weakSelf=self;
    int deviceId=[StorageDeviceHelper sharedStorageDeviceHelper].device_id;
    NSString *body=[NSString stringWithFormat:@"page_num=1&page_size=1000&device_id=%d",deviceId];
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kGetStorageFoodList body:body success:^(id json) {
        [weakSelf.storageTab.mj_footer endRefreshing];
        [weakSelf.storageTab.mj_header endRefreshing];
        NSArray *list=[json objectForKey:@"result"];
        if (kIsArray(list)) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in list) {
                StorageModel *storageModel = [[StorageModel alloc] init];
                [storageModel setValues:dict];
                [tempArr addObject:storageModel];
            }
            storageArray=tempArr;
            weakSelf.blankView.hidden=storageArray.count>0;
            
            NSArray *reslutArr=[storageArray sortedArrayUsingComparator:^NSComparisonResult(StorageModel* obj1, StorageModel* obj2) {
                NSNumber *time1=[NSNumber numberWithInteger:obj1.overdue_time];
                NSNumber *time2=[NSNumber numberWithInteger:obj2.overdue_time];
                return [time1 compare:time2];
            }];
            storageArray=[NSMutableArray arrayWithArray:reslutArr];
            [weakSelf.storageTab reloadData];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.storageTab.mj_header endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


#pragma mark -- setters
#pragma mark 食材列表
- (UITableView *)storageTab{
    if (_storageTab==nil) {
        _storageTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationHeight+20, kScreenWidth, kBodyHeight) style:UITableViewStylePlain];
        _storageTab.backgroundColor = [UIColor bgColor_Gray];
        _storageTab.delegate = self;
        _storageTab.dataSource = self;
        [_storageTab setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestStorageData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _storageTab.mj_header=header;
    }
    return _storageTab;
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView=[[BlankView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 200) img:@"pub_ic_kong" text:@"暂无食材"];
    }
    return _blankView;
}

@end
