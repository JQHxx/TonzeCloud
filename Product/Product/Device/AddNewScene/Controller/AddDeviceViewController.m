//
//  AddDeviceViewController.m
//  Product
//
//  Created by 肖栋 on 17/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddDeviceViewController.h"
#import "AddDeviceButton.h"
#import "AddDeviceCell.h"
#import "CloudRecipesViewController.h"
#import "DeviceModel.h"

@interface AddDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *addDecviceTabelView;

@property (nonatomic, strong) NSMutableArray *deviceModelArr;
/// 无设备提示语
@property (nonatomic ,strong) UILabel *unDeviceTipLab;
///
@property (nonatomic ,strong) NSArray *optionsArr;

@end

@implementation AddDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"添加设备";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.optionsArr = @[@"云菜谱"];
    
    [self initAddDeviceView];
    
    if ([AutoLoginManager shareManager].hasLogin&&kIsLogined) {
        [[AutoLoginManager shareManager] startAutoLogin];
    }
    [self getDeviceInfo];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-08" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-08" type:2];
#endif
}

#pragma mark -- 初始化界面
- (void)initAddDeviceView{
    [self.view addSubview:self.addDecviceTabelView];
    [self.view addSubview:self.unDeviceTipLab];
}
#pragma mark 获取设备列表信息
-(void)getDeviceInfo{
    //  -- 获取用户绑定的设备列表
    NSMutableArray *deviceArray =[AutoLoginManager shareManager].deviceModelArr;
    //  -- 筛选Wifi设备（只有WiFi设备能用于设备互联）
    for (NSInteger i = 0; i < deviceArray.count; i++) {
        DeviceModel *deviceModel = deviceArray[i];
        MyLog(@"-----%ld",(long)deviceModel.deviceType);
        
        if (![deviceModel.productID isEqualToString:CLINK_BPM_PRODUCT_ID] && ![deviceModel.productID isEqualToString:THERMOMETER_PRODUCT_ID] && ![deviceModel.productID isEqualToString:SCALE_PRODUCT_ID] && ![deviceModel.productID isEqualToString:CABINETS_PRODUCT_ID] ) {
            [self.deviceModelArr addObject:deviceModel];
        }
    }
    if (self.deviceModelArr.count>0) {
        self.unDeviceTipLab.hidden=YES;
    }else{
        self.unDeviceTipLab.hidden=NO;
    }
    [self.addDecviceTabelView reloadData];
}
#pragma mark ====== UITableViewDataSource =======
#pragma mark ====== UITableViewDelegate =======
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.deviceModelArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *addDeviceIdentifier  = @"addDeviceCell";
    AddDeviceCell *addDeviceCell = [tableView dequeueReusableCellWithIdentifier:addDeviceIdentifier];
    if (!addDeviceCell) {
        addDeviceCell = [[AddDeviceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addDeviceIdentifier];
    }
    DeviceModel *model=[self.deviceModelArr objectAtIndex:indexPath.row];
    [addDeviceCell setAddDeviceCellWithModel:model];
    addDeviceCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return addDeviceCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04-09"];
#endif
    
    DeviceModel *deviceModel = self.deviceModelArr[indexPath.row];
    
    kSelfWeak;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *operateAction = [UIAlertAction actionWithTitle:@"云菜谱" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        CloudRecipesViewController *cloudRecipesVC = [[CloudRecipesViewController alloc] init];
        cloudRecipesVC.deviceModel=deviceModel;
        [weakSelf push:cloudRecipesVC];
    }];
    [alertController addAction:operateAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark ====== setters || getters =======

- (UITableView *)addDecviceTabelView{
    if (!_addDecviceTabelView) {
        _addDecviceTabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight) style:UITableViewStylePlain];
        _addDecviceTabelView.delegate = self;
        _addDecviceTabelView.dataSource = self;
        _addDecviceTabelView.backgroundColor = [UIColor bgColor_Gray];
        _addDecviceTabelView.tableFooterView = [UIView new];
    }
    return _addDecviceTabelView;
}
- (UILabel *)unDeviceTipLab{
    if (!_unDeviceTipLab) {
        _unDeviceTipLab = [[UILabel alloc]initWithFrame:CGRectMake(0, kBodyHeight/2 - 40, kScreenWidth, 20)];
        _unDeviceTipLab.text = @"您没有支持智能场景的设备";
        _unDeviceTipLab.textColor = UIColorHex(0x959595);
        _unDeviceTipLab.font = kFontSize(15);
        _unDeviceTipLab.textAlignment = NSTextAlignmentCenter;
        _unDeviceTipLab.hidden = YES;
    }
    return _unDeviceTipLab;
}
- (NSMutableArray *)deviceModelArr{
    if (!_deviceModelArr) {
        _deviceModelArr = [NSMutableArray array];
    }
    return _deviceModelArr;
}


@end
