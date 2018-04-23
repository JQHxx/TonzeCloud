//
//  AddressManagerViewController.m
//  Product
//
//  Created by vision on 17/12/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddressManagerViewController.h"
#import "AddressManagerCell.h"
#import "AddAndEditAddressViewController.h"
#import "ShippingAddressModel.h"
#import "BlankView.h"
#import "QLAlertView.h"

@interface AddressManagerViewController ()<UITableViewDelegate,UITableViewDataSource,AddressManagerCellDelegate>
{
    NSInteger _page;
}
@property (nonatomic, strong) UITableView *addressManagerTb;
/// 添加地址
@property (nonatomic ,strong) UIButton *addAddressBtn;
/// 地址列表数据
@property (nonatomic ,strong) NSMutableArray *addressListArray;
/// 无数据视图
@property (nonatomic ,strong) UIView *blankView;

@end

@implementation AddressManagerViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TJYHelper sharedTJYHelper].isAddressManagerReload) {
        [self loadNewAddressData];
        [TJYHelper sharedTJYHelper].isAddressManagerReload = NO;
        [TJYHelper sharedTJYHelper].isAddressSelectedReload=YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"收货地址管理";
    
    _page = 1;
    [self initAddressManagerrVC];
    [self requestAddressManagerData];
}
#pragma mark ====== Build UI =======
- (void)initAddressManagerrVC{
    [self.view addSubview:self.addressManagerTb];
    [self.view addSubview:self.addAddressBtn];
}
#pragma mark ====== Request Data =======
- (void)requestAddressManagerData{
    
    NSString *memberIdStr = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *body = [NSString stringWithFormat:@"member_id=%@",memberIdStr];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postShopMethodWithURL:kShippingAddress body:body success:^(id json) {
        NSDictionary *dic = [json objectForKey:@"result"];
        NSArray *data = [dic objectForKey:@"addrList"];
        if (kIsArray(data) && data.count > 0) {
            for (NSDictionary *dic in data) {
                weakSelf.blankView.hidden = YES;
                ShippingAddressModel *addressModel = [ShippingAddressModel new];
                [addressModel setValues:dic];
                [weakSelf.addressListArray addObject:addressModel];
            }
        }else{
            weakSelf.blankView.hidden = NO;
        }
        [weakSelf.addressManagerTb reloadData];
        [weakSelf.addressManagerTb.mj_header endRefreshing];
        [weakSelf.addressManagerTb.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        weakSelf.blankView.hidden = NO;
        [weakSelf.addressManagerTb.mj_header endRefreshing];
        [weakSelf.addressManagerTb.mj_footer endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== MJRefresh Data =======

- (void)loadNewAddressData{
    _page = 1;
    [self.addressListArray removeAllObjects];
    [self requestAddressManagerData];
}
- (void)loadMoreAddressData{
    _page++;
    [self requestAddressManagerData];
}

#pragma mark ====== UITableViewDataSource =======
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.addressListArray.count;
}
#pragma mark ====== UITableViewDelegate =======
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *addressManagerCellIdentifer = @"addressManagerCellIdentifer";
    AddressManagerCell *addressManagerCell = [tableView dequeueReusableCellWithIdentifier:addressManagerCellIdentifer];
    if (!addressManagerCell) {
        addressManagerCell = [[AddressManagerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addressManagerCellIdentifer];
    }
    ShippingAddressModel *addressModel = self.addressListArray[indexPath.row];
    [addressManagerCell cellWithModel:addressModel];
    addressManagerCell.addressDelegate = self;
    return addressManagerCell;
}
#pragma mark ====== AddressManagerCellDelegate =======
// 删除地址
- (void)didSelectDeleteAddressInCell:(UITableViewCell *)cell{
    
    NSIndexPath *indexPath = [self.addressManagerTb indexPathForCell:cell];
    QLAlertView *alertView = [[QLAlertView alloc]initWithTitle:@"" message:@"确定要删除该收货人信息吗？" sureBtn:@"取消" cancleBtn:@"确定"];
    kSelfWeak;
    alertView.resultIndex = ^(NSInteger index){
        if (index == 1) {
            ShippingAddressModel *addressModel = self.addressListArray[indexPath.row];
            NSString *memberIdStr = [NSUserDefaultInfos getValueforKey:USER_ID];
            NSString *body = [NSString stringWithFormat:@"member_id=%@&addr_id=%@",memberIdStr,addressModel.ship_id];
            [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KDeleateAddress body:body success:^(id json) {
                [TJYHelper sharedTJYHelper].isAddressSelectedReload=YES;
                [weakSelf.view makeToast:@"收货人已删除" duration:1.0 position:CSToastPositionCenter];
                [weakSelf.addressListArray removeObjectAtIndex:indexPath.row];
                [weakSelf.addressManagerTb reloadData];
            } failure:^(NSString *errorStr) {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
        }
    };
    [alertView showQLAlertView];
}
// 编辑地址
- (void)didSelectEditAddressInCell:(UITableViewCell *)cell{
    
    NSIndexPath *indexPath = [self.addressManagerTb indexPathForCell:cell];
    AddAndEditAddressViewController *addAddressVC = [AddAndEditAddressViewController new];
    addAddressVC.addressType = EditAddress;
    addAddressVC.addressModel = self.addressListArray[indexPath.row];
    [self.navigationController pushViewController:addAddressVC animated:YES];
}
// 设为默认地址
- (void)didSelectDefaultAddressInCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.addressManagerTb indexPathForCell:cell];
    ShippingAddressModel *addressModel = self.addressListArray[indexPath.row];
    if ([addressModel.is_default isEqualToString:@"false"]) {
        addressModel.is_default = @"1";
        NSString *memberId = [NSUserDefaultInfos getValueforKey:USER_ID];
        NSString *body = [NSString stringWithFormat:@"member_id=%@&ship_name=%@&ship_mobile=%@&ship_zip=%@&ship_area=%@&ship_addr=%@&is_default=%@&ship_id=%@",memberId,addressModel.ship_name,addressModel.ship_mobile,addressModel.ship_zip,addressModel.ship_area,addressModel.ship_addr,addressModel.is_default,addressModel.ship_id];
        kSelfWeak;
        [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KSaveAddress body:body success:^(id json) {
            [weakSelf.view makeToast:@" 设置成功" duration:1.0 position:CSToastPositionCenter];
            [TJYHelper sharedTJYHelper].isAddressSelectedReload=YES;
            [weakSelf loadNewAddressData];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
#pragma mark ====== Event  Reponse =======
// 添加新地址
- (void)addNewAddress{
    if (self.addressListArray.count > 9) {
        [self.view makeToast:@"最多只能添加10个地址" duration:1.0 position:CSToastPositionCenter];
    }else{
        AddAndEditAddressViewController *addAddressVC = [AddAndEditAddressViewController new];
        addAddressVC.addressType = AddAddress;
        addAddressVC.isDefaultAdd = self.addressListArray.count > 0 ? NO  : YES;
        [self.navigationController pushViewController:addAddressVC animated:YES];
    }
}
#pragma mark ====== Setter =======

- (UITableView *)addressManagerTb{
    if (!_addressManagerTb) {
        _addressManagerTb = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kBodyHeight - 40)];
        _addressManagerTb.delegate = self;
        _addressManagerTb.dataSource = self;
        _addressManagerTb.backgroundColor = [UIColor bgColor_Gray];
        _addressManagerTb.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _addressManagerTb.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewAddressData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _addressManagerTb.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreAddressData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _addressManagerTb.mj_footer = footer;
        footer.hidden=YES;
        
        [_addressManagerTb addSubview:self.blankView];
    }
    return _addressManagerTb;
}
#pragma mark 空白视图

-(UIView *)blankView{
    if (!_blankView) {
        _blankView=[[UIView alloc] initWithFrame:CGRectMake(0, 30, kScreenWidth, 300)];
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-118)/2, 90, 118, 62)];
        imgView.image=[UIImage imageNamed:@"pd_ic_address_none"];
        [_blankView addSubview:imgView];
        
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(30, imgView.bottom+10, kScreenWidth-60, 30)];
        titleLab.textAlignment=NSTextAlignmentCenter;
        titleLab.text=@"您的收货地址是空的哦";
        titleLab.textColor=[UIColor colorWithHexString:@"#999999"];
        titleLab.font=[UIFont systemFontOfSize:13];
        [_blankView addSubview:titleLab];
        _blankView.hidden = YES;
    }
    return _blankView;
}

- (UIButton *)addAddressBtn{
    if (!_addAddressBtn) {
        _addAddressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addAddressBtn.frame = CGRectMake(0, kScreenHeight - 40, kScreenWidth, 40);
        [_addAddressBtn setTitle:@"＋添加新地址" forState:UIControlStateNormal];
        [_addAddressBtn setTitleColor:UIColorHex(0xffffff) forState:UIControlStateNormal];
        _addAddressBtn.titleLabel.font = kFontSize(18);
        [_addAddressBtn addTarget:self action:@selector(addNewAddress) forControlEvents:UIControlEventTouchUpInside];
        _addAddressBtn.backgroundColor = kSystemColor;
    }
    return _addAddressBtn;
}
- (NSMutableArray *)addressListArray{
    if (!_addressListArray) {
        _addressListArray = [NSMutableArray array];
    }
    return _addressListArray;
}
@end
