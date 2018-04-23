//
//  ScaleListViewController.m
//  Product
//
//  Created by Xlink on 15/12/15.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "ScaleListViewController.h"
#import "ScaleListCell.h"
#import "AppDelegate.h"
#import "ConnectSuccessViewController.h"
#import "BTManager.h"
#import "BLEDeviceModel.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "Product-Swift.h"
#import "DeviceModel.h"
#import "DeviceEntity.h"

#define SCALE_NAME_PREFIX   @"TONZE C-150AIZ_"
#define TMP_NAME_PREFIX     @"蓝牙智能体温贴"
#define BPM_NAME_PREFIX     @"蓝牙智能血压计"

@interface ScaleListViewController (){
    AppDelegate    * appDelegate;
    NSMutableArray * DeviceListArray;
    BTHelper       * btHelper;
}

@end

@implementation ScaleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor bgColor_Gray];
    self.baseTitle=@"添加设备";

    appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.scaleListVC = self;
    
    DeviceListArray =[[NSMutableArray alloc]init];
    
    [self scanBLEDevice];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BTManager stopScan];
}


#pragma mark--UITableViewDelegate and UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return DeviceListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"ScaleCell";
    ScaleListCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *dic=[DeviceListArray objectAtIndex:indexPath.row];
    cell.nameLbl.text=[dic objectForKey:@"name"];
    cell.UUIDLbl.text=[dic objectForKey:@"BLEMacAddress"]==nil?[dic objectForKey:@"UUID"]:[dic objectForKey:@"BLEMacAddress"];
    
    NSArray *bindingArr=[[DBManager shareManager]readAllBindingDevice];
    BOOL isBinding=NO;
    for (NSDictionary *readDic in bindingArr) {
        if ([readDic[@"uuid"]isEqualToString:dic[@"UUID"]]) {
            isBinding=YES;
        }
        if ([readDic[@"BLEMacAddress"]isEqualToString:dic[@"BLEMacAddress"]]) {
            isBinding=YES;
        }
    }
    if (!isBinding) {
        NSMutableArray *deviceModels = [[AutoLoginManager shareManager] getDeviceModelArr];
        for (DeviceModel *curDevModel in deviceModels) {
            if ((curDevModel.deviceType == DeviceTypeThermometer && _deviceType == DeviceTypeThermometer) || (curDevModel.deviceType == DeviceTypeBPMeter && _deviceType == DeviceTypeBPMeter) || (curDevModel.deviceType == DeviceTypeScale && _deviceType == DeviceTypeScale)) {
                BLEDeviceModel *meterDevice = (BLEDeviceModel *)curDevModel;
                if ([meterDevice.BLEMacAddress isEqualToString:[dic objectForKey:@"BLEMacAddress"]]) {
                    isBinding = YES;
                }
            }
        }
    }
    
    if (isBinding) {
        cell.bindingStateLbl.text=@"已绑定";
        cell.bindingStateLbl.backgroundColor=UIColorFromRGB(0x6f6f6f);
    }else{
      cell.bindingStateLbl.text=@"绑定";
         cell.bindingStateLbl.backgroundColor=UIColorFromRGB(0xff8314);
    }
    if (indexPath.row==DeviceListArray.count-1) {
        cell.LineLbl.hidden=NO;
    }else{
        cell.LineLbl.hidden=YES;
    }
    
    if (_deviceType == DeviceTypeBPMeter) {   //血压计
        cell.icon.image = [UIImage imageNamed:@"血压计"];
    }else if (_deviceType == DeviceTypeThermometer) {  //体温计
        cell.icon.image = [UIImage imageNamed:@"体温计"];
    } else {    //脂肪秤
        cell.icon.image = [UIImage imageNamed:@"add体脂秤"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ScaleListCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.bindingStateLbl.text isEqualToString:@"已绑定"]) {
        //选中的是已绑定的设备
        return;
    }
    // 控制连续点击，添加多个重复设备，点击开始，tableview不再触发
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
        listTBV.userInteractionEnabled = NO;
    });
    
    NSDictionary *devDict = [DeviceListArray objectAtIndex:indexPath.row];
    NSString *name = [NSUserDefaultInfos getValueforKey:devDict[@"UUID"]];
    NSInteger type = [devDict[@"type"] integerValue];
    NSString *origName = devDict[@"name"];
    NSString *productId;
 
    if (kIsEmptyString(name)) {
        NSArray *bindingArr=[[DBManager shareManager] readAllBindingDevice];
        NSDictionary *dic=[bindingArr lastObject];
        NSString *lastName = [dic objectForKey:@"name"];
        int idx=[[lastName substringFromIndex:lastName.length-2]intValue];
        idx++;
        switch (type) {
            case DeviceTypeScale:
                name = [NSString stringWithFormat:@"%@%02d", SCALE_NAME_PREFIX, idx];
                productId = SCALE_PRODUCT_ID;
                break;
            case DeviceTypeThermometer:
            {
                name = TMP_NAME_PREFIX;
                productId = THERMOMETER_PRODUCT_ID;
                break;
            }
            case DeviceTypeBPMeter:
            {
                name = BPM_NAME_PREFIX;
                productId = CLINK_BPM_PRODUCT_ID;
                break;
            }
            default:
                break;
        }
        
        [NSUserDefaultInfos putKey:devDict[@"UUID"] andValue:name];
    }
    
    switch (type) {
        case DeviceTypeThermometer:
            productId = THERMOMETER_PRODUCT_ID;
            break;
        case DeviceTypeBPMeter:
            productId = CLINK_BPM_PRODUCT_ID;
            break;
        case DeviceTypeScale:
            productId = SCALE_PRODUCT_ID;
            break;
        default:
            break;
    }
    
    //同步到云端
    if (type == DeviceTypeThermometer || type == DeviceTypeBPMeter ) {
        DeviceObject *newDevice = [[DeviceObject alloc] init];
        newDevice.product_id       = productId;
        newDevice.name             = origName;
        newDevice.mac              = [self getRandomMacAddr];
        newDevice.access_key       = @(8888);
        newDevice.mcu_mod          = @"1";
        newDevice.mcu_version      = @"1";
        newDevice.firmware_mod     = @"1";
        newDevice.firmware_version = @"1";
        
        [self saveBLEDeviceToCloud:newDevice name:origName devType:type devDict:devDict];
    }
}


#pragma mark --Private Methods
#pragma mark 连接蓝牙设备
-(void)scanBLEDevice{
    if (_deviceType == DeviceTypeBPMeter||_deviceType == DeviceTypeThermometer) {   //血压计、体温计
        [BTManager scanDevice:nil success:^(BLEDeviceModel *device) {
            if (device.deviceType != self.deviceType) {
                return;
            }
            NSLog(@"扫描到蓝牙设备：%@", device.deviceName);
            if (device.BLEMacAddress) {
                NSDictionary *dic = @{
                                      @"UUID": device.uuid,
                                      @"BLEMacAddress": device.BLEMacAddress,
                                      @"name": device.deviceName,
                                      @"type": @(device.deviceType),
                                      };
                [self didDiscoverDeivce:dic];
                
            }else{
                //没有mac，连接当前设备并且获取mac,赋值给uuid
                [[BTManager sharedManager] getMacAddress:device.peripheral successBlcak:^(CBPeripheral * _Nullable peripheral, NSString * _Nullable macAddress) {
                    device.BLEMacAddress = macAddress;
                    NSDictionary *dic = @{
                                          @"UUID": device.uuid,
                                          @"BLEMacAddress": device.BLEMacAddress,
                                          @"name": device.deviceName,
                                          @"type": @(device.deviceType),
                                          };
                    [self didDiscoverDeivce:dic];
                    [BTManager disconnect:peripheral];
                }];
            }
        } fail:^(NSError *error) {
            [self.view makeToast:error.localizedDescription duration:1.0 position:CSToastPositionCenter];
            NSLog(@"扫描蓝牙设备失败：%@", error.localizedDescription);
        }];
    }
}

#pragma mark 添加设备
-(void)didDiscoverDeivce:(NSDictionary *)deviceDic{
    //比较设备是否已经发现
    for (NSDictionary *dic in DeviceListArray) {
        if ([[deviceDic objectForKey:@"UUID"] isEqualToString:[dic objectForKey:@"UUID"]]) {
            return;
        }
        if ([deviceDic[@"type"] integerValue] != self.deviceType) {
            return;
        }
    }
    [DeviceListArray addObject:deviceDic];
    [listTBV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark 获取设备mac地址
- (NSString *)getRandomMacAddr {
    NSMutableString *mac = @"".mutableCopy;
    for (int i = 0; i<6; i++) {
        int value = arc4random_uniform(0xFF);
        [mac appendFormat:@"%02X", value];
    }
    return mac;
}

#pragma mark 保存蓝牙设备到云端
- (void)saveBLEDeviceToCloud:(DeviceObject *)newDevice name:(NSString *)name devType:(DeviceType)type devDict:(NSDictionary *)devDict {
    //注册设备
    [HttpRequest registerDeviceWithUserID:XL_USER_ID withAccessToken:XL_USER_TOKEN withDevice:newDevice didLoadData:^(id result, NSError *err) {
        if (!err) {
            
            //设备注册完成， 保存设备名称和uuid到设备扩展属性
            BLEDeviceModel *device;
            if (type == DeviceTypeThermometer) {
                device = [[ThermometerModel alloc] initWithDictionary:result deviceType:type];
            } else if (type == DeviceTypeBPMeter) {
                device = [[BPMeterModel alloc] initWithDictionary:result deviceType:type];
            } else {
                device = [[BLEDeviceModel alloc] initWithDictionary:result deviceType:type];
            }
            device.uuid = devDict[@"UUID"];
            device.BLEMacAddress = devDict[@"BLEMacAddress"];
            NSDictionary *properties = @{
                                         @"name":name,
                                         @"mac":device.BLEMacAddress,
                                         @"measurements":@[]
                                         };
            [HttpRequest setDevicePropertyDictionary:properties withDeviceID:@(device.deviceID) withProductID:device.productID withAccessToken:XL_USER_TOKEN didLoadData:^(id result, NSError *err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    listTBV.userInteractionEnabled = YES;

                    if (!err) {
                        ConnectSuccessViewController *connectSuccessVC=[[ConnectSuccessViewController alloc] init];
                        connectSuccessVC.productID=device.productID;
                        [self.navigationController pushViewController:connectSuccessVC animated:YES];
                    } else {
                        [self showAlertWithTitle:@"提示" Message:@"绑定失败，请重试"];
                        if (err.code==4031003) {
                            [appDelegate updateAccessToken];
                        }
                    }
                });
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(err) {
                [SVProgressHUD dismiss];
                listTBV.userInteractionEnabled = YES;
                
                [self showAlertWithTitle:@"提示" Message:@"绑定失败，请重试"];
                if (err.code==4031003) {
                    [appDelegate updateAccessToken];
                }
            }
        });
    }];
}



@end
