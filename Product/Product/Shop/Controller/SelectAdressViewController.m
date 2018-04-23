//
//  SelectAdressViewController.m
//  Product
//
//  Created by vision on 17/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SelectAdressViewController.h"
#import "AddressTableViewCell.h"
#import "AddressManagerViewController.h"
#import "AddAndEditAddressViewController.h"

@interface SelectAdressViewController ()<UITableViewDelegate,UITableViewDataSource,AddressTableViewCellDelegate>{
    NSMutableArray  *allAddressArray;
}

@property (nonatomic,strong)UITableView     *addressTableView;
@property (nonatomic,strong)UIButton        *addNewAddressBtn;
@property (nonatomic,strong)UIView          *blankView;


@end

@implementation SelectAdressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"选择收货地址";
    self.rigthTitleName=@"管理";
    
    allAddressArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.addressTableView];
    [self.addressTableView addSubview:self.blankView];
    self.blankView.hidden=YES;
    [self.view addSubview:self.addNewAddressBtn];
    
    [self requestConsigneeAddressInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TJYHelper sharedTJYHelper].isAddressSelectedReload) {
        [allAddressArray removeAllObjects];
        [self requestConsigneeAddressInfo];
        [TJYHelper sharedTJYHelper].isAddressSelectedReload=NO;
        [TJYHelper sharedTJYHelper].isAddressManagerReload = NO;
    }
}

#pragma mark －－ UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return allAddressArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"AddressTableViewCell";
    AddressTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[AddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.delegate=self;
    ShippingAddressModel *model=allAddressArray[indexPath.row];
    model.isSelected=[self.selectedConsigneeId isEqualToString:model.ship_id];
    [cell addressTableViewCellDisplayWithAddress:model];
    
    cell.editAddressBtn.tag=indexPath.row;
    [cell.editAddressBtn addTarget:self action:@selector(editAddressInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShippingAddressModel *model=allAddressArray[indexPath.row];
    return [AddressTableViewCell getCellHeightWithAddress:model];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ShippingAddressModel *model=allAddressArray[indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
    self.selectAddressBlock(model);
}

#pragma mark -- Custom Delegate
#pragma mark AddressTableViewCellDelegate
-(void)editAddressInfoAction:(UIButton *)sender{
    ShippingAddressModel *model=allAddressArray[sender.tag];
    [self addOrEditAddressWithType:1 address:model];
}

#pragma mark -- Event Response
#pragma mark 地址管理
-(void)rightButtonAction{
    AddressManagerViewController *addressManagerVC=[[AddressManagerViewController alloc] init];
    [self.navigationController pushViewController:addressManagerVC animated:YES];
}

#pragma mark 添加新地址
-(void)addNewAddressAction:(UIButton *)sender{
    [self addOrEditAddressWithType:0 address:nil];
}

#pragma mark -- Private Methods
-(void)requestConsigneeAddressInfo{
    NSInteger memberId=[[NSUserDefaultInfos getValueforKey:USER_ID] integerValue];
    NSString *body = [NSString stringWithFormat:@"member_id=%ld&version=%@",(long)memberId,APP_VERSION];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postShopMethodWithURL:kShippingAddress body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            NSArray *addressList = [result valueForKey:@"addrList"];
            if (kIsArray(addressList) && addressList.count > 0) {
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dic in addressList) {
                    ShippingAddressModel *addressModel = [[ShippingAddressModel alloc] init];
                    [addressModel setValues:dic];
                    [tempArr addObject:addressModel];
                }
                allAddressArray=tempArr;
            }
            weakSelf.blankView.hidden=allAddressArray.count>0;
        }else{
            weakSelf.blankView.hidden=NO;
        }
        [weakSelf.addressTableView reloadData];
        [weakSelf.addressTableView.mj_header endRefreshing];
    } failure:^(NSString *errorStr) {
        [weakSelf.addressTableView.mj_header endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 添加或编辑地址
-(void)addOrEditAddressWithType:(NSInteger)type address:(ShippingAddressModel *)selAddress{
    if (allAddressArray.count > 9) {
        [self.view makeToast:@"最多只能添加10个地址" duration:1.0 position:CSToastPositionCenter];
    }else{
        AddAndEditAddressViewController *controller=[[AddAndEditAddressViewController alloc] init];
        controller.addressType=type==0?AddAddress:EditAddress;
        controller.isDefaultAdd = allAddressArray.count > 0 ? NO : YES;
        controller.addressModel=selAddress;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark -- Setters and Getters
#pragma mark 地址列表
-(UITableView *)addressTableView{
    if (!_addressTableView) {
        _addressTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationHeight+20, kScreenWidth, kBodyHeight-45) style:UITableViewStylePlain];
        _addressTableView.dataSource=self;
        _addressTableView.delegate=self;
        _addressTableView.backgroundColor=[UIColor bgColor_Gray];
        _addressTableView.tableFooterView=[[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestConsigneeAddressInfo)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _addressTableView.mj_header=header;
    }
    return _addressTableView;
}

#pragma mark 空白
-(UIView *)blankView{
    if (!_blankView) {
        _blankView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300)];
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-118)/2, 80, 118, 62)];
        imgView.image=[UIImage imageNamed:@"pd_ic_address_none"];
        [_blankView addSubview:imgView];
        
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(30, imgView.bottom+10, kScreenWidth-60, 30)];
        titleLab.textAlignment=NSTextAlignmentCenter;
        titleLab.text=@"您的收货地址是空的哦";
        titleLab.textColor=[UIColor colorWithHexString:@"#999999"];
        titleLab.font=[UIFont systemFontOfSize:13];
        [_blankView addSubview:titleLab];
    }
    return _blankView;
}

#pragma mark 新增地址
-(UIButton *)addNewAddressBtn{
    if (!_addNewAddressBtn) {
        _addNewAddressBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-45, kScreenWidth, 45)];
        [_addNewAddressBtn setTitle:@"+添加新地址" forState:UIControlStateNormal];
        [_addNewAddressBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addNewAddressBtn.backgroundColor=kSystemColor;
        [_addNewAddressBtn addTarget:self action:@selector(addNewAddressAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addNewAddressBtn;
}

@end
