//
//  AutoLoginManager.m
//  Product
//
//  Created by 梁家誌 on 16/9/2.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "AutoLoginManager.h"
#import "ControllerHelper.h"
#import "MeasurementsManager.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "NotificationHandler.h"
#import "DeviceStateListener.h"
#import "DeviceConnectStateCheckService.h"
#import "YTKKeyValueStore.h"

#define APPLE_ID 1126623839
#import "JSON.h"

@interface AutoLoginManager (){
    BOOL _firstDeviceList;//第一次拉取到云端订阅列表，为NO，无需判断设备重置
    BOOL _hasAddNotifList;//防止多次注册通知，无通知为NO
    
    YTKKeyValueStore  *YTKHelper;
}


@property (nonatomic,strong) NSMutableArray *deviceListArr;//设备字典数组
@property (nonatomic,strong) DeviceConnectStateCheckService *connectService;//连接服务


@end

@implementation AutoLoginManager

+(instancetype)shareManager{
    @synchronized (self) {
        static AutoLoginManager *manager = nil;
        if (manager == nil) {
            manager = [[[self class] alloc]init];
        }
        return manager;
    }
}

#pragma mark 自动登录，完成XLinkSDK登录-拉取订阅列表-拉取设备扩展属性=拉取用户信息=拉取用户扩展属性
- (void)startAutoLogin{
    _hasAddNotifList = NO;
    _firstDeviceList = NO;
    
    _connectService = [DeviceConnectStateCheckService share];
    //0.初始化数组
    _deviceListArr = @[].mutableCopy;
    _deviceModelArr = @[].mutableCopy;
    //本地@“devices”
    _deviceListArr=[[NSMutableArray alloc]initWithArray:[DeviceHelper getAllDeviceFromLocal]];
    //dict转deviceModel
    [self updateDeviceListView];
    
    //1.添加XLinkSDK监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnDeviceStateChanged:) name:kOnDeviceStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeviceViewUpdateUI:) name:kDeviceViewUpdateUI object:nil];
    
    [self addNoti];
    
    //获取设备列表
    [self getDeviceList];
    
    [[NotificationHandler shareHendler] initXlinkLocalNotification];//初始化本地通知，如不需要忽略
}

#pragma mark 退出登录，停止监听SDK的通知，清空列表数据
- (void)loginOut{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_deviceListArr removeAllObjects];
    [_deviceModelArr removeAllObjects];
     _firstDeviceList = NO;
}

#pragma mark 添加通知
- (void)addNoti{
    if (!_hasAddNotifList) {
        _hasAddNotifList = YES;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnConnectDevice:) name:kOnConnectDevice object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvLocalPipeData object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeData object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeSyncData object:nil];
    }
   
}

#pragma mark 移除通知
-(void)removeNoti{
    _hasAddNotifList = NO;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
}


#pragma mark -- Public Methods
#pragma mark 从云端获取设备列表
-(void)getDeviceList{
    if ([self isSend]) {
        @synchronized (self) {
            NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
            if (userDic != nil) {
                [HttpRequest getDeviceListWithUserID:[userDic objectForKey:@"user_id"] withAccessToken:[userDic objectForKey:@"access_token"] withVersion:@(0) didLoadData:^(id result, NSError *err) {
                    if (err) {
                        if (err.code==4031003) {
                            AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                            [appDelegate updateAccessToken];
                        }
                        MyLog(@"getDeviceList--error:%@",err);
                    }else{
                        _deviceListArr=[[NSMutableArray alloc]initWithArray:[DeviceHelper getDeviceDicList:[result objectForKey:@"list"]]];
                        [DeviceHelper saveDeviceListToLocal:_deviceListArr];
                        [self performSelectorOnMainThread:@selector(updateDeviceListView) withObject:nil waitUntilDone:NO];
                    }
                }];
            }
        }
    }else{
        [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(getDeviceList) object:nil];
    }
}

#pragma mark 获取列表后更新UI
-(void)updateDeviceListView{
    @synchronized (self) {
        //新设备列表
        NSMutableArray *tem = [NSMutableArray array];
        NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
        if (userDic && [userDic.allKeys containsObject:@"access_token"]) {
            NSString *token = [userDic objectForKey:@"access_token"];
            if (token && token.length) {
                __weak typeof(self) weakSelf=self;
                for (NSDictionary *dic in _deviceListArr) {
                    DeviceEntity *device=[[DeviceEntity alloc] initWithDictionary:dic];
                    if (![device.productID isEqualToString:CLINK_BPM_PRODUCT_ID] && ![device.productID isEqualToString:THERMOMETER_PRODUCT_ID] && ![device.productID isEqualToString:SCALE_PRODUCT_ID]) {
                        DeviceModel  *aDevice=[[DeviceModel alloc] initWithDeviceEntity:device];
                        aDevice.role=[dic[@"role"] integerValue];
                        DeviceEntity *deviceEntity = [[DeviceConnectStateCheckService share] getDeviceFromeDeviceModel:aDevice];
                        if (device && !deviceEntity) [_connectService addDevice:device];
                        [_connectService startIfNecessary];
                    }
                    
                    __block DeviceModel *model;
                    if ([device.productID isEqualToString:CLINK_BPM_PRODUCT_ID]) {
                        BPMeterModel *bpmeter = [[BPMeterModel alloc] init];
                        bpmeter.mac        = dic[@"macAddress"];
                        NSString *name     = bpmeter.nameFromLocal;
                        NSString *typeName = [DeviceHelper getDeviceName:device];
                        bpmeter.deviceName = name ? name:typeName;
                        bpmeter.deviceType = DeviceTypeBPMeter;
                        bpmeter.productID  = device.productID;
                        bpmeter.deviceID   = device.deviceID;
                        bpmeter.uuid       = bpmeter.uuidFromLocal;
                        bpmeter.role       = [dic[@"role"] integerValue];
                        model = bpmeter;
                    } else if ([device.productID isEqualToString:THERMOMETER_PRODUCT_ID]) {
                        ThermometerModel *tmpMeter = [[ThermometerModel alloc]init];
                        tmpMeter.mac        = dic[@"macAddress"];
                        NSString *name      = tmpMeter.nameFromLocal;
                        NSString *typeName = [DeviceHelper getDeviceName:device];
                        tmpMeter.deviceName = name ? name:typeName;
                        tmpMeter.deviceType = DeviceTypeThermometer;
                        tmpMeter.deviceName = dic[@"deviceName"];
                        tmpMeter.productID  = device.productID;
                        tmpMeter.deviceID   = device.deviceID;
                        tmpMeter.uuid       = tmpMeter.uuidFromLocal;
                        tmpMeter.role       = [dic[@"role"] integerValue];
                        model = tmpMeter;
                    } else if ([device.productID isEqualToString:SCALE_PRODUCT_ID]) {
                        BLEDeviceModel *scale = [[BLEDeviceModel alloc]init];
                        scale.mac = dic[@"macAddress"];
                        NSString *name      = scale.nameFromLocal;
                        NSString *typeName = [DeviceHelper getDeviceName:device];
                        scale.deviceName = name ? name:typeName;
                        scale.deviceType = DeviceTypeScale;
                        scale.productID  = device.productID;
                        scale.deviceID   = device.deviceID;
                        scale.role       = [dic[@"role"] integerValue];
                        model = scale;
                        
                        NSNumber *userID=[userDic valueForKey:@"user_id"];
                        [model unsubscribeWithUserID:userID accessToken:token result:^(NSError *error) {
                            if (!error) {
                                [weakSelf updateUIAfterDeleteBLEDevice:(BLEDeviceModel *)model];
                            }
                        }];
                    } else {
                        model = [[DeviceModel alloc]init];
                        model.deviceName=[DeviceHelper getDeviceName:device];
                        model.isOnline=YES;
                        model.deviceType=[DeviceHelper getDeviceTypeWithMac:[device getMacAddressSimple]];
                        model.deviceID=[device getDeviceID];
                        model.mac=[device getMacAddressSimple];
                        model.State= [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"在线",@"state", nil];
                        model.productID=device.productID;
                        model.role  =[dic[@"role"] integerValue];
                        
                    }
                    
                    if ([_deviceModelArr containsObject:model]) {
                        for (DeviceModel *deviceModel in _deviceModelArr) {
                            if ([device.productID isEqualToString:CLOUD_COOKER_PRODUCT_ID] || [device.productID isEqualToString:ELECTRIC_COOKER_PRODUCT_ID] || [device.productID isEqualToString:WATER_COOKER_PRODUCT_ID] || [device.productID isEqualToString:CLOUD_KETTLE_PRODUCT_ID] || [device.productID isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]|| [device.productID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]|| [device.productID isEqualToString:CABINETS_PRODUCT_ID]) {
                                if ([deviceModel.mac isEqualToString:model.mac]) {
                                    model.isOnline = deviceModel.isOnline;
                                    model.State = deviceModel.State;
                                    [tem addObject:model];
                                    break;
                                }
                            }else if ([device.productID isEqualToString:THERMOMETER_PRODUCT_ID] || [device.productID isEqualToString:CLINK_BPM_PRODUCT_ID]|| [device.productID isEqualToString:SCALE_PRODUCT_ID]){
                                if ([deviceModel.mac isEqualToString:model.mac]) {
                                    BLEDeviceModel *meterDevice = (BLEDeviceModel *)model;
                                    BLEDeviceModel *newDevice = (BLEDeviceModel *)deviceModel;
                                    meterDevice.deviceName = deviceModel.deviceName;
                                    meterDevice.BLEMacAddress = newDevice.BLEMacAddress;
                                    meterDevice.uuid = newDevice.uuid;
                                    [tem addObject:meterDevice];
                                    break;
                                }
                            }
                        }
                    }else{
                        [tem addObject:model];
                    }
                    
                    
                    //获取名字
                    [HttpRequest getDevicePropertyWithDeviceID:[NSNumber numberWithInt:model.deviceID] withProductID:model.productID withAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                        if (result) {
                            NSString *key=[model.mac stringByAppendingString:@"name"];
                            NSString *name=[result objectForKey:key];
                            if (name.length>0) {
                                if ([name isEqualToString:@"未知设备"]) {
                                    model.deviceName=[DeviceHelper productDefaultName:model.productID];
                                }else{
                                    model.deviceName=name;
                                }
                                [NSUserDefaultInfos putKey:key andValue:model.deviceName];
                                
                            }
                            if (result[@"mac"] && [model isKindOfClass:[BLEDeviceModel class]]) {
                                ((BLEDeviceModel *)model).BLEMacAddress = result[@"mac"];
                            }
                            
                            if (result[@"name"]) {
                                model.deviceName = result[@"name"];
                            }
                            //拉取到蓝牙设备的测量结果，存储单例中
                            if ([((NSDictionary *)result).allKeys containsObject:@"measurements"] && model.deviceType != DeviceTypeScale) {
                                [[MeasurementsManager shareManager] checkAndUpdateWithDicts:result[@"measurements"] BLEAddress:result[@"mac"]];
                            }
                            [weakSelf postNotificationToReloadData];
                        }
                    }];
                }
                
                for (DeviceModel *model in _deviceModelArr) {
                    if (![tem containsObject:model]) {
                        if (_firstDeviceList) {
                            //注意，在此发送重置广播
                            [[NSNotificationCenter defaultCenter] postNotificationName:KDelectDevice object:model.deviceName];
                        }
                        DeviceEntity *dev = [[DeviceConnectStateCheckService share] getDeviceFromeDeviceModel:model];
                        if (dev) {
                            [weakSelf updateUIAfterDeleteDeviceEntity:dev];
                        }else{
                            [weakSelf updateUIAfterDeleteBLEDevice:(BLEDeviceModel *)model];
                        }
                        break;
                    }
                }
                                
                _deviceModelArr = [NSMutableArray arrayWithArray:tem];
                [_connectService startIfNecessary];
                
                if (_deviceListArr.count == 0) {
                    _deviceModelArr=[[NSMutableArray alloc]init];
                }
                [self postNotificationToReloadData];
            }
        }
    }
    _firstDeviceList = YES;
}

#pragma mark 刷新设备名称
-(void)reloadDeviceName{
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    for (DeviceModel *model in _deviceModelArr) {
        kSelfWeak;
        [HttpRequest getDevicePropertyWithDeviceID:[NSNumber numberWithInteger:model.deviceID] withProductID:model.productID withAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
            if (result) {
                NSString *key=[model.mac stringByAppendingString:@"name"];
                NSString *name=[result objectForKey:key];
                model.deviceName=kIsEmptyString(name)?[DeviceHelper productDefaultName:model.productID]:name;
                if (!kIsEmptyString(name)) {
                    [NSUserDefaultInfos putKey:key andValue:name];
                }
                [weakSelf postNotificationToReloadData];
            }
        }];
    }
}

#pragma mark 判断是否登录云智易SDK
-(BOOL)hasLogin{
    BOOL tem = NO;
    NSDictionary *userDict = [NSUserDefaultInfos getDicValueforKey:USER_DIC];
    if (kIsDictionary(userDict)&&userDict.count>0){
        tem = YES;
    }else{
        MyLog(@"需要登录");
        tem = NO;
    }
    return tem;
}

#pragma mark 清除用户信息
-(void)clearAllUserData{
    //清除数据
    [[XLinkExportObject sharedObject] logout];
    [NSUserDefaultInfos removeObjectForKey:USER_ID];
    [NSUserDefaultInfos removeObjectForKey:USER_DIC];
    [[NotificationHandler shareHendler] cancelAllNoti];
    [[ControllerHelper shareHelper].connectedArr removeAllObjects];
    [[DeviceConnectStateCheckService share] stop];
    [[DeviceStateListener sharedListener] removeAllDeviceStateCheckService];
    [DeviceHelper saveDeviceListToLocal:[NSMutableArray array]];
    //停止检测测量结果
    [[MeasurementsManager shareManager] stopCheckAllBLEAddress];
    [[AutoLoginManager shareManager] loginOut];
    
}

- (void)postNotificationToReloadData{
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:kOnManagerDeviceStateChange object:nil];
}


#pragma mark -- NSNotification
#pragma mark 连接设备回调
- (void)OnConnectDevice:(NSNotification *)noti{
    @synchronized (self) {
        NSDictionary *dict = noti.object;
        DeviceEntity *device=[dict objectForKey:@"device"];
        NSNumber *result=[dict objectForKey:@"result"];
        if (result.intValue==0) {
            for (DeviceModel *model in _deviceModelArr) {
                if ([model.mac isEqualToString:[device getMacAddressSimple]]) {
                    //发送数据
                    NSData *Data;
                    if ([model.productID isEqualToString:CABINETS_PRODUCT_ID]) {
                        Data=[Transform nsstringToHex:@"0000000000120000"];
                    }else{
                        Data=[Transform nsstringToHex:@"120000"];
                    }
                    //获取最新状态
                    if (device.isWANOnline) {
                        [[XLinkExportObject sharedObject] sendPipeData:device andPayload:Data];
                    }else{
                        [[XLinkExportObject sharedObject] sendLocalPipeData:device andPayload:Data];
                    }
                    break;
                }
            }
        }
    }
}

#pragma mark 收到信息回调
-(void)OnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    MyLog(@"AutoLoginManager mac:%@ 收到信息回调 = %@",device.getMacAddressSimple,recvData);
    
    NSMutableDictionary *dic=[DeviceHelper getStateDicWithDevice:device Data:recvData];
    if (dic) {
        @synchronized (self) {
            DeviceModel *model;
            for (DeviceModel *m in _deviceModelArr) {
                if ([m.mac isEqualToString:[device getMacAddressSimple]]) {
                    model=m;
                    model.isOnline=YES;
                    if (![model.State isEqualToDictionary:dic]) {
                        model.State=dic;
                        [self postNotificationToReloadData];
                    }
                    break;
                }
            }
        }
    }
}

#pragma mark 设备状态改变回调
- (void)OnDeviceStateChanged:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    DeviceModel *devModel = [[DeviceModel alloc] initWithDeviceEntity:device];
    
    @synchronized (self) {
        if ([_deviceModelArr containsObject:devModel]) {
            for (int i=0; i<_deviceModelArr.count; i++) {
                DeviceModel *tem = _deviceModelArr[i];
                if ([tem.mac isEqualToString:devModel.mac]) {
                    if (tem.deviceID != 0 && devModel.deviceID == 0) {
                        devModel.deviceID = tem.deviceID;
                        device.deviceID = tem.deviceID;
                    }
                    if(tem.State) devModel.State = tem.State;
                    devModel.role=tem.role;
                    
                    if (![device.productID isEqualToString:CLINK_BPM_PRODUCT_ID] &&
                        ![device.productID isEqualToString:THERMOMETER_PRODUCT_ID] &&
                        ![device.productID isEqualToString:SCALE_PRODUCT_ID]) {
                        [_deviceModelArr replaceObjectAtIndex:i withObject:devModel];
                    }
                    break;
                }
            }
        }else{
            return;
        }
        
        
        //2.当设备状态改变才更新界面
        if (device.isConnected) {
            devModel.isOnline=YES;
            [devModel.State setObject:@"在线" forKey:@"state"];
            //通知外部刷新界面
            [[NSNotificationCenter defaultCenter] postNotificationName:kOnManagerDeviceStateChange object:devModel];
            
            //添加到设备工作状态监测服务
            [[DeviceStateListener sharedListener] removeDevice:devModel];
            [[DeviceStateListener sharedListener] listenForDevice:devModel stateChangeHandler:^BOOL(DeviceModel *subDevice, NSInteger state, NSError *error) {
                if (state==112) {
                    //连接成功，保存连接成功的DeviceEntity
                    [[ControllerHelper shareHelper] insertConnectArr:device];
                }else if (state==113){
                    //离线
                    [[NSNotificationCenter defaultCenter] postNotificationName:kOnManagerDeviceStateChange object:devModel];
                }else if (state==200){//设备状态查询15秒没有回包，定义state=200
                    //连接断开，移除连接断开的DeviceEntity
                    [[ControllerHelper shareHelper] removeConnectArr:device];
                    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:kOnDeviceStateChanged object:@{@"device" : device}];
                }
                return YES;
            }];
            
            //连接成功，保存连接成功的DeviceEntity
            [[ControllerHelper shareHelper] insertConnectArr:device];
            
        }else{
            [[DeviceStateListener sharedListener] removeDevice:devModel];
            devModel.isOnline=NO;
            [devModel.State setObject:@"离线" forKey:@"state"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kOnManagerDeviceStateChange object:devModel];
            //设备离线之后不必在这里去调用connectDevice，_connectService会自动调用
            [_connectService startIfNecessary];
        }
    }
}


#pragma mark 根据单个设备更新设备数据
-(void)DeviceViewUpdateUI:(NSNotification *)noti{
    DeviceModel *model=noti.object;
    @synchronized (self) {
        if (model) {
            for (int i=0; i<_deviceModelArr.count; i++) {
                DeviceModel *m=[_deviceModelArr objectAtIndex:i];
                if ([model.mac isEqualToString:m.mac]) {
                    [_deviceModelArr replaceObjectAtIndex:i withObject:model];
                    break;
                }
            }
        }
    }
    [self postNotificationToReloadData];
}

//判断是否拉取云端数据
- (BOOL)isSend{
    static NSTimeInterval time = 0;
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    BOOL isSend = false;
    if (curTime - time >= 1) {
        time = curTime;
        isSend = true;
    }
    return isSend;
}



-(void)updateUIAfterDeleteDeviceEntity:(DeviceEntity *)device{
    [self removeDeviceEntityFromeApp:device];
    DeviceModel *deviceModel = [[DeviceModel alloc] initWithDeviceEntity:device];
    [self updateUIAfterDeleteDevice:deviceModel];
}

- (void)removeDeviceEntityFromeApp:(DeviceEntity *)device{
    DeviceModel *deviceModel = [[DeviceModel alloc] initWithDeviceEntity:device];
    //1.
    [_connectService removeDevice:device];
    //2.
    [[DeviceStateListener sharedListener] removeDevice:deviceModel];
    //3.
    [[ControllerHelper shareHelper] removeConnectArr:device];
    //4.
    [[XLinkExportObject sharedObject] disconnectDevice:device withReason:0];
    //5.
    //删除设备
    [DeviceHelper deleteDeviceFromLocal:device.getMacAddressSimple];
}

- (void)removeDeviceModelFromeApp:(DeviceModel *)device{
    DeviceEntity *deviceEntity = [DeviceHelper getDeviceFromLocalWithMacAddr:device.mac];
    [self removeDeviceEntityFromeApp:deviceEntity];
}

#pragma mark  删除体脂称后更新界面
-(void)updateUIAfterDeleteBLEDevice:(BLEDeviceModel *)device{
    @synchronized (self) {
        for (NSDictionary *dic in _deviceListArr) {
            NSString *mac;
            if ([device isMemberOfClass:[BLEDeviceModel class]]) {
                mac = device.uuid;
            }else if ([device isMemberOfClass:[DeviceModel class]]){
                mac = device.mac;
            }
            if (dic.allKeys.count == 4) {
                NSString *dicMac = [dic objectForKey:@"uuid"];
                if ([dicMac isEqualToString:mac]) {
                    //移除设备
                    [_deviceListArr removeObject:dic];
                    break;
                }
            }
            
            mac = [dic objectForKey:@"macAddress"];
            if ([mac isEqualToString:device.mac]) {
                //移除设备
                [_deviceListArr removeObject:dic];
                break;
            }
        }
        
        for (DeviceModel *model in _deviceModelArr) {
            if ([model.mac isEqualToString:device.mac]) {
                [_deviceModelArr removeObject:model];
                break;
            }
        }
    }
    [self postNotificationToReloadData];
}

#pragma mark  用户手动删除设备后删除manager的缓存设备数据
-(void)updateUIAfterDeleteDevice:(DeviceModel *)device{
    @synchronized (self) {
        for (NSDictionary *dic in _deviceListArr) {
            if ([[dic objectForKey:@"macAddress"]isEqualToString:device.mac]) {
                //从重连服务中移除设备，避免重连已删除的设备
                DeviceEntity *deviceEntity = [[DeviceEntity alloc] initWithDictionary:dic];
                [self removeDeviceEntityFromeApp:deviceEntity];
                
                //移除设备
                [_deviceListArr removeObject:dic];
                break;
            }
        }
        
        for (DeviceModel *model in _deviceModelArr) {
            if ([model.mac isEqualToString:device.mac]) {
                [_deviceModelArr removeObject:model];
                break;
            }
        }
    }
    
    [self postNotificationToReloadData];
}


#pragma mark 更新accessToken
-(void)updateAccessToken{
    NSString *openId = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *token = [NSUserDefaultInfos getValueforKey:USER_TOKEN];
    if (openId && openId.length && token && token.length) {
        [HttpRequest thirdAuthWithOpenID:openId withToken:token didLoadData:^(NSDictionary *result, NSError *err) {
            if (err) {
                NSLog(@"err %@",err);
            }else{
                if (result) {
                    [NSUserDefaultInfos putKey:USER_DIC andValue:result];
                }
            }
        }];
    }
}


-(DeviceModel *)getModelWithMac:(NSString *)mac{
    @synchronized (self) {
        for (DeviceModel *model in _deviceModelArr) {
            if ([model.mac isEqualToString:mac]) {
                return model;
            }
        }
    }
    
    return nil;
}

///列表显示的模型
- (NSMutableArray *)getDeviceModelArr{
    return _deviceModelArr;
}

///水壶先判断本地再添加默认饮水计划
- (void)checkAndAddReminds:(NSString *)mac{
    NSLog(@"%s",__func__);
    BOOL has = NO;
    for (NSDictionary *deviceDict in _deviceListArr) {
        if ([[deviceDict objectForKey:@"macAddress"]isEqualToString:mac]) {
            NSLog(@"设备已经添加！");
            has = YES;
            break;
        }
    }
    if (!has) {
        //水壶添加默认饮水计划
        [DeviceHelper removeRemindsOfMac:mac];
        NSLog(@"水壶添加默认饮水计划");
        [self initRemindWithMac:mac];
    }
}

///水壶直接添加默认饮水计划
- (void)andAddRemindsWithOutCheck:(NSString *)mac{
    NSLog(@"%s",__func__);
    //水壶添加默认饮水计划
    [DeviceHelper removeRemindsOfMac:mac];
    NSLog(@"水壶添加默认饮水计划");
    [self initRemindWithMac:mac];
}

#pragma mark 初始化8个提醒
-(void)initRemindWithMac:(NSString *)mac{
    NSString *currentDate=[NSUserDefaultInfos getCurrentDate];
    NSString *userid=[NSUserDefaultInfos getValueforKey:USER_ID];
    
    if (!YTKHelper) {
        YTKHelper = [[YTKKeyValueStore alloc] initDBWithName:@"TJProduct.db"];
    }
    
    for (int i=0; i<8; i++) {
        switch (i) {
            case 0:
            {
                NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:currentDate,@"date",@"08:00",@"time",@"200ml",@"value",@"0",@"isOn",mac,@"deviceid",userid,@"userid", nil];
                
                NSDictionary *insertDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data", nil];
                
                [YTKHelper insertDataWithJSON:[Transform DataToJsonString:insertDic]];
                
            }
                break;
            case 1:
            {
                NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:currentDate,@"date",@"09:00",@"time",@"200ml",@"value",@"0",@"isOn",mac,@"deviceid",userid,@"userid", nil];
                
                NSDictionary *insertDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data", nil];
                
                [YTKHelper insertDataWithJSON:[Transform DataToJsonString:insertDic]];
                
            }
                break;
            case 2:
            {
                NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:currentDate,@"date",@"11:30",@"time",@"200ml",@"value",@"0",@"isOn",mac,@"deviceid",userid,@"userid", nil];
                
                NSDictionary *insertDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data", nil];
                
                [YTKHelper insertDataWithJSON:[Transform DataToJsonString:insertDic]];
                
            }
                break;
            case 3:
            {
                NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:currentDate,@"date",@"13:30",@"time",@"200ml",@"value",@"0",@"isOn",mac,@"deviceid",userid,@"userid", nil];
                
                NSDictionary *insertDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data", nil];
                
                [YTKHelper insertDataWithJSON:[Transform DataToJsonString:insertDic]];
                
            }
                break;
            case 4:
            {
                NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:currentDate,@"date",@"15:30",@"time",@"200ml",@"value",@"0",@"isOn",mac,@"deviceid",userid,@"userid", nil];
                
                NSDictionary *insertDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data", nil];
                
                [YTKHelper insertDataWithJSON:[Transform DataToJsonString:insertDic]];
                
            }
                break;
            case 5:
            {
                NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:currentDate,@"date",@"17:30",@"time",@"200ml",@"value",@"0",@"isOn",mac,@"deviceid",userid,@"userid", nil];
                
                NSDictionary *insertDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data", nil];
                
                [YTKHelper insertDataWithJSON:[Transform DataToJsonString:insertDic]];
                
            }
                break;
            case 6:
            {
                NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:currentDate,@"date",@"19:00",@"time",@"200ml",@"value",@"0",@"isOn",mac,@"deviceid",userid,@"userid", nil];
                
                NSDictionary *insertDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data", nil];
                
                [YTKHelper insertDataWithJSON:[Transform DataToJsonString:insertDic]];
                
            }
                break;
            case 7:
            {
                NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:currentDate,@"date",@"20:15",@"time",@"200ml",@"value",@"0",@"isOn",mac,@"deviceid",userid,@"userid", nil];
                
                NSDictionary *insertDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data", nil];
                
                [YTKHelper insertDataWithJSON:[Transform DataToJsonString:insertDic]];
                
            }
                break;
            default:
                break;
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==10000) {
        if (buttonIndex==1) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d",APPLE_ID]];
            [[UIApplication sharedApplication]openURL:url];
        }
    }
}




@end
