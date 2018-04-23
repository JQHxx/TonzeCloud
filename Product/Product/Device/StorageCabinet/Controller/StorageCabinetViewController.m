//
//  StorageCabinetViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StorageCabinetViewController.h"
#import "StoragePropertyViewController.h"
#import "StorageTitleView.h"
#import "StorageContentView.h"
#import "StorageRiceContentView.h"
#import "RiceRecordViewController.h"
#import "RiceAnalysisViewController.h"
#import "StorageAreaViewController.h"
#import "TimePickerView.h"
#import "DeviceModel.h"
#import "AppDelegate.h"
#import "XLinkExportObject.h"
#import "DeviceHelper.h"
#import "ShareListViewController.h"
#import "UpgradeViewController.h"
#import "AppDelegate.h"
#import "StorageDeviceHelper.h"
#import "NotiModel.h"

@interface StorageCabinetViewController ()<StorageTitleViewDelegate,StorageContentViewDelegate,UITextFieldDelegate>{
    NSInteger               getHumidity;
    NSInteger               getTemperature;
    
    NSInteger               riceCapacity;
    TimePickerView          *Picker;
    UIAlertAction           * OkBtnEnabledAction;
}

@property (nonatomic,strong)UIScrollView            *rootScrollView;          //根滚动视图
@property (nonatomic,strong)UILabel                 *stateLabel;              //设备状态
@property (nonatomic,strong)StorageTitleView        *storageTitleView;        //储物区标题
@property (nonatomic,strong)StorageTitleView        *storageRiceTitleView;    //储米区标题
@property (nonatomic,strong)StorageContentView      *storageContentView;      //储物区工作台
@property (nonatomic,strong)StorageRiceContentView  *storageRiceContentView;  //储米区工作台


@end

@implementation StorageCabinetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.storageDevice.deviceName;
    self.rightImageName = @"更多";
    
    [StorageDeviceHelper sharedStorageDeviceHelper].device_id=self.storageDevice.deviceID;
    
    [self initStorageView];
    
    [self getStorageCabinetDeviceInfo];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[StorageDeviceHelper sharedStorageDeviceHelper] storageDeviceMac:self.storageDevice.mac SendDataForType:StorageDeviceSendTypeGetHumidity withValue:0]; //获取储物区湿度
    [[StorageDeviceHelper sharedStorageDeviceHelper] storageDeviceMac:self.storageDevice.mac SendDataForType:StorageDeviceSendTypeGetTemperature withValue:0]; //获取储物区温度
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnConnectDevice:) name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnDeviceStateChanged:) name:kOnDeviceStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeSyncData object:nil];
    
    if ([StorageDeviceHelper sharedStorageDeviceHelper].isStorageHomereFresh) {
        [self requestStorageCaninetFoodsData];
        [StorageDeviceHelper sharedStorageDeviceHelper].isStorageHomereFresh=NO;
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnDeviceStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeSyncData object:nil];
}


#pragma mark -- NSNotification
#pragma mark 设备连接通知回调处理
-(void)OnConnectDevice:(NSNotification *)notifi{
    NSDictionary *dict = notifi.object;
    MyLog(@"storageOnConnectDevice,result:%@",dict);
    DeviceEntity *device=[dict objectForKey:@"device"];
    
    if ([[device getMacAddressSimple] isEqualToString:self.storageDevice.mac]) {
        NSData *Data=[Transform nsstringToHex:@"0000000000120000"];
        MyLog(@"发送查询智能厨物柜(%@)状态>>：%@", self.storageDevice.mac, [Data hexString]);
        //获取最新状态
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject] sendPipeData:device andPayload:Data];
        }else{
            [[XLinkExportObject sharedObject] sendLocalPipeData:device andPayload:Data];
        }
    }
}


#pragma mark 设备接收信息通知回调处理
-(void)OnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    if ([[device getMacAddressSimple] isEqualToString:self.storageDevice.mac]) {
        MyLog(@"storageOnPipeData = %s: %@", __func__, [recvData hexString]); //00 00 00 00 00 12 00 00 01 14 0D 02 19 06 46 02
        ///如果是控制命令的返回就隐藏
        uint32_t cmd_len = (uint32_t)[recvData length];
        uint8_t cmd_data[cmd_len];
        memset(cmd_data, 0, cmd_len);
        [recvData getBytes:(void *)cmd_data length:cmd_len];
        
        if (cmd_data[0]==0x16&&self.storageDevice.role ==0) {
            //重置设备返回命令
            [[ControllerHelper shareHelper] dismissProgressView];
            [self disbindingDevice];
            return;
        }
        
        if (cmd_data[5]==0x11){
            MyLog(@"-----------智能厨物柜获取设备属性成功------------");
            if (cmd_data[8]==0x02) {
                getHumidity=cmd_data[9];
            }else if (cmd_data[8]==0x03){
                getTemperature=cmd_data[9];
            }else if (cmd_data[8]==0x04){
                riceCapacity=cmd_data[9];
            }
        }else if (cmd_data[5]==0x12) {    //获取设备状态
            NSString *humidityStr=[NSString stringWithFormat:@"%i",cmd_data[9]];   //14  湿度
            NSString *tempStr=[NSString stringWithFormat:@"%i",cmd_data[10]];      //0D  温度
            NSString *typeStr=[NSString stringWithFormat:@"%i",cmd_data[11]];      //02  工作状态
            MyLog(@"储物区--湿度：%@,温度:%@,工作状态：%ld",humidityStr,tempStr,(long)[typeStr integerValue]);
            
            NSString *riceHumidityStr=[NSString stringWithFormat:@"%i",cmd_data[12]];   //19  湿度
            NSString *outRiceStr=[NSString stringWithFormat:@"%i",cmd_data[13]];        //06  出米量
            NSString *lastRiceStr=[NSString stringWithFormat:@"%i",cmd_data[14]];       //46  剩余米量
            NSString *riceWorkTypeStr=[NSString stringWithFormat:@"%i",cmd_data[15]];   //02 工作状态
            NSString *riceWorkAbnormalTypeStr=[NSString stringWithFormat:@"%i",cmd_data[16]];   //02 异常状态
            MyLog(@"储米区--湿度：%ld,出米量:%ld, 剩余米量:%@,工作状态：%ld",(long)[riceHumidityStr integerValue],(long)[outRiceStr integerValue],lastRiceStr,[riceWorkTypeStr integerValue]);
            
            __weak typeof(self) weakSelf=self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSInteger storageType=[typeStr integerValue];
                    weakSelf.storageTitleView.workType=storageType;
                    weakSelf.storageContentView.humidityValue=storageType==3?0:[humidityStr integerValue];
                    weakSelf.storageContentView.temperatureValue=storageType==3?0:[tempStr integerValue];
                    
                    NSInteger riceWorkType=[riceWorkTypeStr integerValue];
                    weakSelf.storageRiceTitleView.workType=riceWorkType;
                    
                    NSInteger abnormalType=[riceWorkAbnormalTypeStr integerValue];
                    weakSelf.storageRiceContentView.riceHumidityValue=abnormalType==1?0:[riceHumidityStr integerValue];
                    weakSelf.storageRiceContentView.outRiceValue=abnormalType==3?0:[outRiceStr integerValue];
                    weakSelf.storageRiceContentView.lastRiceValue=abnormalType==2?0:[lastRiceStr integerValue];
                    
                    if ([lastRiceStr integerValue]>0) {
                        weakSelf.storageRiceContentView.frame=[lastRiceStr integerValue]>20?CGRectMake(0, self.storageRiceTitleView.bottom, kScreenWidth, 170):CGRectMake(0, self.storageRiceTitleView.bottom, kScreenWidth, 200);
                    }else{
                        weakSelf.storageRiceContentView.frame=CGRectMake(0, self.storageRiceTitleView.bottom, kScreenWidth, 170);
                    }
                });
            });
        }else if (cmd_data[5]==0x13){    //设置设备属性
            MyLog(@"-----------智能厨物柜设置设备属性成功------------");
            if (cmd_data[8]==0x04){
                riceCapacity=cmd_data[9];
                NSString *messageStr=[NSString stringWithFormat:@"成功设置出米量为%i杯",cmd_data[9]];
                __weak typeof(self) weakSelf=self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [weakSelf.view makeToast:messageStr duration:1.0 position:CSToastPositionCenter];
                    });
                });
            }
        }else if (cmd_data[5]==0x16){
            if (cmd_data[8]==0x01) {
                MyLog(@"-----------智能厨物柜获取离线出米量------------");
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                for (NSInteger i=0; i<10; i++) {
                    NSInteger index=9+7*i;
                    NSString *yearStr=[NSString stringWithFormat:@"%i",cmd_data[index+1]];
                    NSString *monthStr=[NSString stringWithFormat:@"%i",cmd_data[index+2]];
                    NSString *dayStr=[NSString stringWithFormat:@"%i",cmd_data[index+3]];
                    NSString *hourStr=[NSString stringWithFormat:@"%i",cmd_data[index+4]];
                    NSString *minuteStr=[NSString stringWithFormat:@"%i",cmd_data[index+5]];
                    NSString *riceOutStr=[NSString stringWithFormat:@"%i",cmd_data[index+6]];
                    if ([riceOutStr integerValue]>0) {
                        NSString *dateStr=[NSString stringWithFormat:@"20%@-%@-%@ %@:%@",yearStr,monthStr,dayStr,hourStr,minuteStr];
                        
                        NSInteger timesp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:dateStr format:@"yyyy-MM-dd HH:mm"];
                        NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)timesp],@"record_time",riceOutStr,@"cup",nil];
                        [tempArr addObject:dict];
                    }
                }
                 MyLog(@"result:%@",tempArr);
                //保存离线出米记录
                [self saveOfflineOutRiceRecordToServerWithData:tempArr];
            }
        }
    }
}

#pragma mark 设备状态变化
- (void)OnDeviceStateChanged:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    if ([[device getMacAddressSimple ]isEqualToString:self.storageDevice.mac]) {
        //当设备状态改变才更新界面
        MyLog(@"storageOnDeviceStateChanged");
        if (device.isConnected) {
            self.storageDevice.isOnline=YES;
            [self.storageDevice.State setObject:@"在线" forKey:@"state"];
            self.stateLabel.text = self.storageDevice.State[@"state"];
        }else{
            self.storageDevice.isOnline=NO;
            [self.storageDevice.State setObject:@"离线" forKey:@"state"];
            self.stateLabel.text = self.storageDevice.State[@"state"];
        }
    }
}

#pragma mark 输入框处理通知
- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    OkBtnEnabledAction.enabled = textField.text.length >= 1;
}


#pragma mark -- Custom Delegate
#pragma mark StorageContentViewDelegate
-(void)storageContentViewSaveFoodAction{
    StorageAreaViewController *consultationVC = [[StorageAreaViewController alloc] init];
    [self.navigationController pushViewController:consultationVC animated:YES];
}

#pragma mark StorageTitleViewDelegate
-(void)storageTitleViewdidSetAction:(StorageTitleView *)storageTitleView{
    if (!self.storageDevice.isOnline) {
        [self showOfflineAlertView];
        return;
    }

    if (storageTitleView==self.storageTitleView) {
        StoragePropertyViewController *storagePropertyVC=[[StoragePropertyViewController alloc] init];
        storagePropertyVC.model=self.storageDevice;
        storagePropertyVC.getHumidity=getHumidity;
        storagePropertyVC.getTemprature=getTemperature;
        [self.navigationController pushViewController:storagePropertyVC animated:YES];
    }else if (storageTitleView==self.storageRiceTitleView){
        riceCapacity = riceCapacity<1?4:riceCapacity;
        
        Picker =[[TimePickerView alloc] initWithTitle:@"储米区设置" delegate:self];
        Picker.pickerStyle=PickerStyle_HumidityRice;
        [Picker.locatePicker selectRow:riceCapacity-1 inComponent:1 animated:YES];
        [Picker showInView:self.view];
        [Picker pickerView:Picker.locatePicker didSelectRow:riceCapacity-1 inComponent:1];
    }
}


#pragma mark TimePickerViewDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if(Picker.pickerStyle==PickerStyle_HumidityRice){
            riceCapacity = [Picker.locatePicker selectedRowInComponent:1]+1;//米量
            [[StorageDeviceHelper sharedStorageDeviceHelper] storageDeviceMac:self.storageDevice.mac SendDataForType:StorageDeviceSendTypeOutRice withValue:riceCapacity];
        }
    }
}

#pragma mark --Event response
#pragma mark --更多按钮事件
-(void)rightButtonAction{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *analysisButtonTitle = NSLocalizedString(@"用米分析", nil);
    NSString *recordButtonTitle = NSLocalizedString(@"用米记录", nil);
    NSString *shareButtonTitle = NSLocalizedString(@"分享", nil);
    NSString *renameButtonTitle = NSLocalizedString(@"重命名", nil);
    NSString *upgradeButtonTitle = NSLocalizedString(@"固件升级", nil);
    NSString *deleteButtonTitle = NSLocalizedString(@"删除", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *analysisAction = [UIAlertAction actionWithTitle:analysisButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        RiceAnalysisViewController *riceAnalsisVC = [[RiceAnalysisViewController alloc] init];
        riceAnalsisVC.storageDeviceModel=weakSelf.storageDevice;
        [weakSelf.navigationController pushViewController:riceAnalsisVC animated:YES];
    }];
    UIAlertAction *recordAction = [UIAlertAction actionWithTitle:recordButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        RiceRecordViewController *riceRecordVC = [[RiceRecordViewController alloc] init];
        riceRecordVC.myDevice=self.storageDevice;
        [weakSelf.navigationController pushViewController:riceRecordVC animated:YES];
         }];
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:shareButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShareListViewController *shareListVC = [storyboard instantiateViewControllerWithIdentifier:@"ShareListViewController"];
        shareListVC.model=self.storageDevice;
        [weakSelf.navigationController pushViewController:shareListVC animated:YES];
    }];
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:renameButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf showNameAlertController];
    }];
    UIAlertAction *upgradeAction= [UIAlertAction actionWithTitle:upgradeButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (weakSelf) {
            if (!weakSelf.storageDevice.isOnline) {
                [weakSelf showOfflineAlertView];
                return;
            }
            
            UpgradeViewController *upgradeVC=[[UpgradeViewController alloc] initWithNibName:@"UpgradeViewController" bundle:nil];
            upgradeVC.deviceType=weakSelf.storageDevice.deviceType;
            upgradeVC.device=[[ControllerHelper shareHelper] getNeedControllDevice:self.storageDevice.mac];
            [weakSelf.navigationController pushViewController:upgradeVC animated:YES];
        }
    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [weakSelf showDeleteAlertController];
    }];

    //管理员才能显示
    [alertController addAction:analysisAction];
    [alertController addAction:recordAction];
    if (self.storageDevice.role==0) {
        //管理员才能显示
        [alertController addAction:shareAction];
        [alertController addAction:upgradeAction];
    }
    [alertController addAction:renameAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- Private Methods
#pragma mark  初始化界面
- (void)initStorageView{
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    [self.view addSubview:self.stateLabel];
    [self.view addSubview:self.rootScrollView];
    
    UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-45, 70, 30, 30)];
    [btn setImage:[UIImage imageNamed:@"cwg_ic_refresh"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(getStorageCabinetDeviceInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self.rootScrollView addSubview:self.storageTitleView];
    [self.rootScrollView addSubview:self.storageContentView];
    [self.rootScrollView addSubview:self.storageRiceTitleView];
    [self.rootScrollView addSubview:self.storageRiceContentView];
    self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.storageRiceContentView.bottom);
    
}

#pragma mark  获取储物柜属性
- (void)getStorageCabinetDeviceInfo{
    self.stateLabel.text = self.storageDevice.State[@"state"];
    
    [self requestStorageCaninetFoodsData]; //储物区食材统计
    
    
    [[StorageDeviceHelper sharedStorageDeviceHelper] storageDeviceMac:self.storageDevice.mac SendDataForType:StorageDeviceSendTypeGetOutRice withValue:0]; //获取出米量
    [[StorageDeviceHelper sharedStorageDeviceHelper] storageDeviceMac:self.storageDevice.mac SendDataForType:StorageDeviceSendTypeGetOfflineOutRice withValue:0]; //获取离线出米记录
}

#pragma mark 保存厨物柜离线出米记录
-(void)saveOfflineOutRiceRecordToServerWithData:(NSMutableArray *)outRiceArr{
    __weak typeof(self) weakSelf=self;
    NSString *params=[[NetworkTool sharedNetworkTool] getValueWithParams:outRiceArr];
    NSString *body=[NSString stringWithFormat:@"device_id=%d&item=%@&doSubmit=1",self.storageDevice.deviceID,params];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kSaveOfflineRiceRecord body:body success:^(id json) {
        [[StorageDeviceHelper sharedStorageDeviceHelper] storageDeviceMac:weakSelf.storageDevice.mac SendDataForType:StorageDeviceSendTypeDeleteOfflineOutRice withValue:0]; //删除离线出米记录
    } failure:^(NSString *errorStr) {
        //保存失败 继续获取记录
        [[StorageDeviceHelper sharedStorageDeviceHelper] storageDeviceMac:weakSelf.storageDevice.mac SendDataForType:StorageDeviceSendTypeGetOutRice withValue:0]; //获取出米量
    }];
    
}

#pragma mark 获取储物区食材统计
-(void)requestStorageCaninetFoodsData{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"device_id=%d",self.storageDevice.deviceID];
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kFoodstatistics body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        NSInteger expiredCount=[[result valueForKey:@"overdue_count"] integerValue];
        NSInteger expiringCount=[[result valueForKey:@"will_expire_count"] integerValue];
        NSDictionary *foodDict=@{@"expiring":[NSNumber numberWithInteger:expiringCount],@"expired":[NSNumber numberWithInteger:expiredCount]};
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                weakSelf.storageContentView.foodCountDict=foodDict;
            });
        });
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 设备离线提示
-(void)showOfflineAlertView{
    NSString *ButtonTitle = NSLocalizedString(@"确定", nil);
    NSString *title=@"设备已离线";
    NSString *message=@"请检查设备是否连接电源、WIFI是否正常后再重新连接";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:ButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (weakSelf) {
            [[ControllerHelper shareHelper] conncetDevice:weakSelf.storageDevice];//连接设备
        }
    }];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 重命名
-(void)showNameAlertController{
    NSString *title = NSLocalizedString(@"重命名", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"请输入新的设备名称"];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField becomeFirstResponder];
        textField.clearButtonMode = UITextFieldViewModeUnlessEditing;

        textField.delegate=self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController.textFields.firstObject resignFirstResponder];
        alertController.textFields.firstObject.text = [alertController.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (alertController.textFields.firstObject.text.length>16||alertController.textFields.firstObject.text.length<1) {
            [weakSelf showAlertWithTitle:@"提示" Message:@"设备名称仅支持1-16个字"];
            
        }else{
            weakSelf.baseTitle=alertController.textFields.firstObject.text;
            weakSelf.storageDevice.deviceName=alertController.textFields.firstObject.text;
            NSString *key=[self.storageDevice.mac stringByAppendingString:@"name"];
            [NSUserDefaultInfos putKey:key andValue:alertController.textFields.firstObject.text];
            NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:weakSelf.storageDevice.deviceName,key, nil];
            NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
            [HttpRequest setDevicePropertyDictionary:dic withDeviceID:[NSNumber numberWithInteger:weakSelf.storageDevice.deviceID] withProductID:weakSelf.storageDevice.productID withAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                if (err) {
                    if (err.code==4031003) {
                        AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate updateAccessToken];
                    }
                    MyLog(@"重命名 err:%@",err.localizedDescription);
                }else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [weakSelf.view makeToast:@"设备重命名成功" duration:1.0 position:CSToastPositionCenter];
                        });
                    });
                }
            }];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceViewUpdateUI object:weakSelf.storageDevice];
            [[NSNotificationCenter defaultCenter] removeObserver:weakSelf name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
        }
    }];
    
    otherAction.enabled = NO;
    OkBtnEnabledAction = otherAction;//定义一个全局变量来存储
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    alertController.view.layer.cornerRadius = 20;
    alertController.view.layer.masksToBounds = YES;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 删除设备
-(void)showDeleteAlertController{
    NSString *otherButtonTitle = NSLocalizedString(@"确定", nil);
    NSString *title = NSLocalizedString(@"提示", nil);
    NSString *message =(!self.storageDevice.isOnline&&self.storageDevice.role==0)?@"离线状态下成功删除设备，再次绑定设备时，需要重置硬件设备": NSLocalizedString(@"确定要删除当前设备？", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.storageDevice.role==0&&weakSelf.storageDevice.isOnline) {
            [[ControllerHelper shareHelper] resteDevice:weakSelf.storageDevice]; //设置在线时，管理员需要重置设备
        }else{
            [weakSelf disbindingDevice];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 取消设备绑定
-(void)disbindingDevice{
    [SVProgressHUD show];
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    __weak typeof(self) weakSelf = self;
    [HttpRequest unsubscribeDeviceWithUserID:[userDic objectForKey:@"user_id"] withAccessToken:[userDic objectForKey:@"access_token"] withDeviceID:[NSNumber numberWithInt:self.storageDevice.deviceID] didLoadData:^(id result, NSError *err) {
        if (err) {
            if (err.code==4001034) {
                //返回这个证明已经取消订阅了该设备
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //更新UI，返回
                        [[AutoLoginManager shareManager] updateUIAfterDeleteDevice:weakSelf.storageDevice];
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                        
                        [[ControllerHelper shareHelper] disconnectDevice:weakSelf.storageDevice];
                        //删除设备
                        [DeviceHelper deleteDeviceFromLocal:self.storageDevice.mac];
                        [[AutoLoginManager shareManager] getDeviceList];
                    });
                });
            }else if (err.code==4031003) {
                AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate updateAccessToken];
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [weakSelf showAlertWithTitle:@"提示" Message:@"删除失败"];
                    });
                });
            }
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    //更新UI，返回
                    [[AutoLoginManager shareManager] updateUIAfterDeleteDevice:weakSelf.storageDevice];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    
                    [[ControllerHelper shareHelper] disconnectDevice:weakSelf.storageDevice];
                    //删除设备
                    [DeviceHelper deleteDeviceFromLocal:weakSelf.storageDevice.mac];
                });
            });
        }
    }];
}


#pragma mark -- setters
#pragma mark 设备状态
-(UILabel *)stateLabel{
    if (_stateLabel==nil) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, 70, 200, 30)];
        _stateLabel.font = [UIFont systemFontOfSize:18];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.textColor = [UIColor orangeColor];
    }
    return _stateLabel;
}

-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, self.stateLabel.bottom+5, kScreenWidth, kScreenHeight-self.stateLabel.bottom-5)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    }
    return _rootScrollView;
}


#pragma mark 储物区标题
- (StorageTitleView *)storageTitleView{
    if (_storageTitleView==nil) {
        _storageTitleView = [[StorageTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        _storageTitleView.titleStr = @"储物区";
        _storageTitleView.delegate=self;
        _storageTitleView.workType= [self.storageDevice.State[@"workType"] integerValue];
    }
    return _storageTitleView;
}

#pragma mark 储物区工作台
-(StorageContentView *)storageContentView{
    if (_storageContentView==nil) {
        _storageContentView=[[StorageContentView alloc] initWithFrame:CGRectMake(0, self.storageTitleView.bottom, kScreenWidth, 170)];
        _storageContentView.delegate=self;
        _storageContentView.humidityValue=[self.storageDevice.State[@"humidity"] integerValue];
        _storageContentView.temperatureValue=[self.storageDevice.State[@"temperature"] integerValue];
    }
    return _storageContentView;
}


#pragma mark 储米区标题
- (StorageTitleView *)storageRiceTitleView{
    if (_storageRiceTitleView==nil) {
        _storageRiceTitleView = [[StorageTitleView alloc] initWithFrame:CGRectMake(0, self.storageContentView.bottom+10, kScreenWidth, 40)];
        _storageRiceTitleView.titleStr = @"储米区";
        _storageRiceTitleView.delegate=self;
        _storageRiceTitleView.workType=[self.storageDevice.State[@"riceWorkState"] integerValue];
    }
    return _storageRiceTitleView;
}

#pragma mark 储米区工作台
-(StorageRiceContentView *)storageRiceContentView{
    if (_storageRiceContentView==nil) {
        _storageRiceContentView=[[StorageRiceContentView alloc] initWithFrame:CGRectMake(0, self.storageRiceTitleView.bottom, kScreenWidth, 170)];
        _storageRiceContentView.riceHumidityValue=[self.storageDevice.State[@"riceHumidity"] integerValue];;
        _storageRiceContentView.outRiceValue=[self.storageDevice.State[@"outRice"] integerValue];
        _storageRiceContentView.lastRiceValue=[self.storageDevice.State[@"lastRice"] integerValue];
    }
    return _storageRiceContentView;
}

@end
