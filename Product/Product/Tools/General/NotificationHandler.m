//
//  NotificationHandler.m
//  Product
//
//  Created by Xlink on 15/12/14.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "NotificationHandler.h"
#import "DeviceEntity.h"
#import "AppDelegate.h"
#import "DeviceDefines.h"
#import "NSUserDefaultInfos.h"
#import "NotiModel.h"
#import "DBManager.h"
#import "DeviceModel.h"
#import "DeviceHelper.h"
#import "HttpRequest.h"
#import "ShareModel.h"
#import "Transform.h"
#import "YTKKeyValueStore.h"
#import "NSData+Extension.h"
#import "AutoLoginManager.h"
#import <AudioToolbox/AudioToolbox.h>


@implementation NotificationHandler{
    AppDelegate *appDelegate;
    
    YTKKeyValueStore *YTKHelper;
    
    NSString *inviteCode;
    
    NSDictionary *selctRemindDic;
    
    NSMutableDictionary *stateDic; //记录设备工作类型，如果是开始工作就用最新工作类型，取消工作和完成工作则显示上一工作类型，因为硬件返回推送信息中没有设备工作类型，所以只能这样获取（空闲状态不添加到该数组）
    
    NSString *curInviteCode;
    
    NotiModel *lastNotiModel;//记录上一个Notify，如果时间、名称、类型、工作状态都一样，则不再重复弹框
    AutoLoginManager *manager;
    
}


+(instancetype)shareHendler{
    static NotificationHandler *handler = nil;
    if (handler == nil) {
        handler = [[[self class] alloc]init];
    }
    return handler;
}

-(void)initXlinkLocalNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (!appDelegate) {
        appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    manager = [AutoLoginManager shareManager];
    
    if (!YTKHelper) {
        YTKHelper = [[YTKKeyValueStore alloc] initDBWithName:@"TJProduct.db"];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnRecvLocalPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnRecvPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnRecvPipeSyncData:) name:kOnRecvPipeSyncData object:nil];
    stateDic=[[NSMutableDictionary alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearNotiIconNum) name:@"clearNotiIconNum" object:nil];
    
    [self setNextRemindNoti];
    
}





- (void)OnRecvLocalPipeData:(NSNotification *)noti{
    NotiModel *model=[self NotificationHandler:noti];
    if (model) {
        if ([model.deviceType isEqualToString:@""] || !model.deviceType) {
            if ([model.notiState isEqualToString:@"已取消"]) {
                return;
            }
            [self configNotification:[NSString stringWithFormat:@"%@ %@ %@",[model.time substringWithRange:NSMakeRange(11, 5)],model.deviceName,model.notiState]];
        }else{
            [self configNotification:[NSString stringWithFormat:@"%@ %@/%@ %@",[model.time substringWithRange:NSMakeRange(11, 5)],model.deviceName,model.deviceType,model.notiState]];
        }
        
        //保存到本地;
        [[DBManager shareManager]insertNoti:model];
    }
    
    
}
- (void)OnRecvPipeData:(NSNotification *)noti{
    NotiModel *model=[self NotificationHandler:noti];
    if (model) {
        
        if ([model.deviceType isEqualToString:@""] || !model.deviceType) {
            if ([model.notiState isEqualToString:@"已取消"]) {
                return;
            }
            [self configNotification:[NSString stringWithFormat:@"%@ %@ %@",[model.time substringWithRange:NSMakeRange(11, 5)],model.deviceName,model.notiState]];
        }else{
            [self configNotification:[NSString stringWithFormat:@"%@ %@/%@ %@",[model.time substringWithRange:NSMakeRange(11, 5)],model.deviceName,model.deviceType,model.notiState]];
        }
        
        //保存到本地;
        [[DBManager shareManager]insertNoti:model];
    }
    
    
}
- (void)OnRecvPipeSyncData:(NSNotification *)noti{
    NotiModel *model=[self NotificationHandler:noti];
    if (model) {
        
        if ([model.deviceType isEqualToString:@""] || !model.deviceType) {
            if ([model.notiState isEqualToString:@"已取消"]) {
                return;
            }
            [self configNotification:[NSString stringWithFormat:@"%@ %@ %@",[model.time substringWithRange:NSMakeRange(11, 5)],model.deviceName,model.notiState]];
        }else{
            [self configNotification:[NSString stringWithFormat:@"%@ %@/%@ %@",[model.time substringWithRange:NSMakeRange(11, 5)],model.deviceName,model.deviceType,model.notiState]];
        }
        
        //保存到本地;
        [[DBManager shareManager]insertNoti:model];
        
    }
    
    
}


-(NotiModel *)NotificationHandler:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    
    NSString *deviceName=[DeviceHelper getDeviceName:device];
    
    NSString *funtionType=@"";   //工作类型
    NSString *content=@"";
    NSString *deviceID=[NSString stringWithFormat:@"%i",device.deviceID];
    int notiType = 0;
    NSData *recvData=[dict objectForKey:@"payload"];
    const Byte *buf = (Byte *)[recvData bytes];
    
    
    
    if (buf[0] == D_GET_DEVICE_STA || buf[0] == D_SET_DEVICE_STA || buf[0]==D_REPORT_DEVICE_STA) {  //获取设备状态\设置设备状态
        //保存设备状态到stateDic中
        NSDictionary *dic = [DeviceHelper getStateDicWithDevice:device Data:recvData];
        if (kIsDictionary(dic)) {
            if (![dic[@"state"] isEqualToString:@"空闲"]) {
                stateDic[[device getMacAddressSimple]] = dic[@"state"];
            }
            if ([dic[@"state"] isEqualToString:@"云菜谱"]) {
                if (dic[@"name"]) {
                    stateDic[[device getMacAddressSimple]] = dic[@"name"];
                }
            }
        }
    }
    if (buf[0]==D_REPORT_DEVICE_STA) {
        //buf[0]==0x15为设备上报状态
        ///注意：以下的case名不一定对应报警状态，因为各设备的数字代表状态不同，例如电饭煲的04代表干烧，而隔水炖的03代表干烧，这里不做所有适配
        int feedback=buf[3];
        if ([device.productID isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]) { //电饭锅
            switch (feedback) {
                case FREE:
                {
                    NSLog(@"设备处于空闲");
                    
                    int Type=buf[4];
                    NSLog(@"推送提醒   状态%i",Type);
                    notiType=COMPLETE;
                    
                    DeviceModel *deviceModel = [manager getModelWithMac:[device getMacAddressSimple]];
                    if (!deviceModel) {
                        return nil;
                    }
                    
                    NSString *funtion=[deviceModel.State objectForKey:@"state"];
                    if ([funtion isEqualToString:@"云菜谱"]) {
                        funtion = [deviceModel.State objectForKey:@"name"];
                    }
                    
                    if (Type==0) {
                        [stateDic setObject:funtion forKey:[device getMacAddressSimple]];
                        funtionType=funtion;
                    }else{
                        
                        funtionType=[stateDic objectForKey:[device getMacAddressSimple]];
                    }
                    content=[DeviceHelper getDevicePustNotiWithType:Type];
                    
                    break;
                }
                case SENSOR_UNUSUAL:
                {
                    int unusualType=buf[4];
                    NSLog(@"传感器异常    异常类型=%i",unusualType);
                    notiType=ERROR;
                    content=@"传感器异常";
                }
                    break;
                case OVERHEATING:
                {
                    int hotTem=buf[4];
                    NSLog(@"干烧报警   过热温度=%i",hotTem);
                    notiType=ERROR;
                    content=@"干烧报警";
                }
                    break;
                case DRY_STATE:{
                    int dryType=buf[4];
                    NSLog(@"电路系统异常    异常状态%i",dryType);
                    
                    
                    notiType=ERROR;
                    content=@"电路系统异常";
                }
                    break;
                case NO_POT_ALARM:{
                    int alermType=buf[4];
                    NSLog(@"无锅报警   异常状态%i",alermType);
                    notiType=ERROR;
                    content=@"无锅报警";
                }
                    break;
                case POWER_VOLTAGE:{
                    int Type=buf[4];
                    NSLog(@"电网电压异常   异常状态%i",Type);
                    notiType=ERROR;
                    content=@"电压异常";
                }
                    break;
                case BATTERY_VOLTAGE:{
                    int Type=buf[4];
                    NSLog(@"电池电压异常   异常状态%i  %@",Type,dict);
                    
                    notiType=ERROR;
                    content=@"电池电压异常";
                }
                    break;
                case 0x11:{
                    int Type=buf[4];
                    NSLog(@"推送提醒   状态%i",Type);
                    notiType=COMPLETE;
                    
                    DeviceModel *deviceModel = [manager getModelWithMac:[device getMacAddressSimple]];
                    if (!deviceModel) {
                        return nil;
                    }
                    if (Type <= 0 || Type >= 7) {
                        return nil;
                    }
                    NSString *commandType=[NSUserDefaultInfos getValueforKey:@"commandType"];
                    NSString *funtion =[deviceModel.State objectForKey:@"state"];
                    if ([[deviceModel.State objectForKey:@"state"] isEqualToString:@"空闲"]||[[deviceModel.State objectForKey:@"state"] isEqualToString:@"在线"]) {
                        funtion =commandType;
                    }if ([funtion isEqualToString:@"云菜谱"]) {
                        funtion = [deviceModel.State objectForKey:@"name"];
                    }
                    
                    if (Type==1) {
                        NSString *name=[NSUserDefaultInfos getValueforKey:@"name"];
                        if (name != nil) {
                            funtionType=name;
                        } else {
                            [stateDic setObject:funtion forKey:[device getMacAddressSimple]];
                            funtionType=funtion;
                        }
                        
                    }else{
                        
                        funtionType=[stateDic objectForKey:[device getMacAddressSimple]];
                    }
                    
                    content=[DeviceHelper getDevicePustNotiWithType:Type];
                }
                default:
                    break;
            }
            
        }else if ( [device.productID isEqualToString:CLOUD_COOKER_PRODUCT_ID]){ //云炖锅
            switch (feedback) {
                case FREE:
                {
                    NSLog(@"设备处于空闲");
                    
                    int Type=buf[4];
                    NSLog(@"推送提醒   状态%i",Type);
                    notiType=COMPLETE;
                    
                    DeviceModel *deviceModel = [manager getModelWithMac:[device getMacAddressSimple]];
                    if (!deviceModel) {
                        return nil;
                    }
                    if (Type <= 0 || Type >= 7) {
                        return nil;
                    }
                    
                    funtionType=[stateDic objectForKey:[device getMacAddressSimple]];
                    content=[DeviceHelper getDevicePustNotiWithType:Type];
                    
                    break;
                }
                case SENSOR_UNUSUAL:
                {
                    int unusualType=buf[4];
                    NSLog(@"传感器异常    异常类型=%i",unusualType);
                    notiType=ERROR;
                    content=@"传感器异常";
                }
                    break;
                case OVERHEATING:
                {
                    int dryType=buf[4];
                    NSLog(@"干烧状态   异常状态%i",dryType);
                    
                    
                    notiType=ERROR;
                    content=@"干烧状态";
                    
                }
                    break;
                case 0x09:{
                    int Type=buf[4];
                    NSLog(@"推送提醒   状态%i",Type);
                    notiType=COMPLETE;
                    DeviceModel *deviceModel = [manager getModelWithMac:[device getMacAddressSimple]];
                    if (!deviceModel) {
                        return nil;
                    }
                    NSString *commandType=[NSUserDefaultInfos getValueforKey:@"commandType"];
                    NSString *funtion =[deviceModel.State objectForKey:@"state"];
                    if ([[deviceModel.State objectForKey:@"state"] isEqualToString:@"空闲"]||[[deviceModel.State objectForKey:@"state"] isEqualToString:@"在线"]) {
                        funtion =commandType;
                    }
                    if ([funtion isEqualToString:@"云菜谱"]) {
                        funtion = [deviceModel.State objectForKey:@"name"];
                    }
                    
                    if (Type==1) {
                        NSString *name=[NSUserDefaultInfos getValueforKey:@"name"];
                        if (name != nil) {
                            funtionType=name;
                        } else {
                            [stateDic setObject:funtion forKey:[device getMacAddressSimple]];
                            funtionType=funtion;
                        }
                        
                    }else{
                        
                        funtionType=[stateDic objectForKey:[device getMacAddressSimple]];
                    }
                    content=[DeviceHelper getDevicePustNotiWithType:Type];
                }
                default:
                    break;
            }
            
        }else if ([device.productID isEqualToString:WATER_COOKER_PRODUCT_ID] || [device.productID isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]){ //隔水炖 & 隔水炖16AIG
            NSLog(@"---------------------22222222%@",[stateDic objectForKey:[device getMacAddressSimple]]);
            
            switch (feedback) {
                case FREE:
                {
                    NSLog(@"设备处于空闲");
                    
                    int Type=buf[4];
                    NSLog(@"推送提醒   状态%i",Type);
                    notiType=COMPLETE;
                    
                    DeviceModel *deviceModel = [manager getModelWithMac:[device getMacAddressSimple]];
                    if (!deviceModel) {
                        return nil;
                    }
                    
                    funtionType=[stateDic objectForKey:[device getMacAddressSimple]];
                    content=[DeviceHelper getDevicePustNotiWithType:Type];
                    
                    break;
                }
                case SENSOR_UNUSUAL:
                {
                    int unusualType=buf[4];
                    NSLog(@"传感器异常    异常类型=%i",unusualType);
                    notiType=ERROR;
                    content=@"传感器异常";
                }
                    break;
                case OVERHEATING:
                {
                    int dryType=buf[4];
                    NSLog(@"干烧状态   异常状态%i",dryType);
                    notiType=ERROR;
                    content=@"干烧状态";
                }
                    break;
                    
                case 0x08:
                    //隔水炖16A提示提醒0x08
                case 0x09:{
                    int Type=buf[4];
                    NSLog(@"推送提醒   状态%i",Type);
                    
                    notiType=COMPLETE;
                    
                    DeviceModel *deviceModel = [manager getModelWithMac:[device getMacAddressSimple]];
                    if (!deviceModel) {
                        return nil;
                    }
                    if (Type <= 0 || Type >= 6) {
                        return nil;
                    }
                    NSString *commandType=[NSUserDefaultInfos getValueforKey:@"commandType"];
                     NSString *funtion =[deviceModel.State objectForKey:@"state"];
                    if ([[deviceModel.State objectForKey:@"state"] isEqualToString:@"空闲"]||[[deviceModel.State objectForKey:@"state"] isEqualToString:@"在线"]) {
                        funtion =commandType;
                    }
                    if ([funtion isEqualToString:@"云菜谱"]) {
                        funtion = [deviceModel.State objectForKey:@"name"];
                    }
                    if (Type==1) {
                        NSString *name=[NSUserDefaultInfos getValueforKey:@"name"];
                        if (name != nil) {
                            funtionType=name;
                        } else {
                            [stateDic setObject:funtion forKey:[device getMacAddressSimple]];
                            funtionType=funtion;
                        }
                        
                    }else{
                        funtionType=[stateDic objectForKey:[device getMacAddressSimple]];
                    }
                    content=[DeviceHelper getDevicePustNotiWithType:Type];
                }
                default:
                    break;
                    
            }
        }else if ( [device.productID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]){ //自动烹饪锅
            switch (feedback) {
                    
                case FIRE_UNUSUAL:
                {
                    int unusualType=buf[4];
                    
                    switch (unusualType) {
                        case FREE:
                        {
                            int dryType=buf[4];
                            NSLog(@"内部故障   异常状态%i",dryType);
                            notiType=ERROR;
                            content=@"内部故障";
                        }
                            break;
                            
                        case SENSOR_UNUSUAL:
                        {
                            int dryType=buf[4];
                            NSLog(@"无锅报警   异常状态%i",dryType);
                            notiType=ERROR;
                            content=@"无锅报警";
                        }
                            break;
                        case OVERHEATING:
                        {
                            int dryType=buf[4];
                            NSLog(@"电网电压过高   异常状态%i",dryType);
                            notiType=ERROR;
                            content=@"电网电压过高";
                        }
                            break;
                        case DRY_STATE:
                        {
                            int dryType=buf[4];
                            NSLog(@" 电网电压过低   异常状态%i",dryType);
                            notiType=ERROR;
                            content=@" 电网电压过低";
                        }
                            break;
                        case NO_POT_ALARM:
                        {
                            int dryType=buf[4];
                            NSLog(@" 侧面传感器故障   异常状态%i",dryType);
                            notiType=ERROR;
                            content=@" 侧面传感器故障";
                        }
                            break;
                        case POWER_VOLTAGE:
                        {
                            int dryType=buf[4];
                            NSLog(@"底部传感器故障   异常状态%i",dryType);
                            notiType=ERROR;
                            content=@"底部传感器故障";
                        }
                            break;
                        case BATTERY_VOLTAGE:
                        {
                            int dryType=buf[4];
                            NSLog(@"WIFI连接故障   异常状态%i",dryType);
                            notiType=ERROR;
                            content=@"WIFI连接故障";
                        }
                            break;
                        case ESSENCE_COOK_COMMAND:
                        {
                            int dryType=buf[4];
                            NSLog(@"散热器过热保护   异常状态%i",dryType);
                            notiType=ERROR;
                            content=@"散热器过热保护";
                        }
                            break;
                        case ULTRAFAST_COOK_COMMAND:
                        {
                            int dryType=buf[4];
                            NSLog(@"干烧报警   异常状态%i",dryType);
                            notiType=ERROR;
                            content=@"干烧报警";
                        }
                            break;
                        case PORRIDGE_COMMAND:
                        {
                            int dryType=buf[4];
                            NSLog(@"网络故障   异常状态%i",dryType);
                            notiType=ERROR;
                            content=@"网络故障";
                        }
                            break;
                            
                    }
                }
                    break;
                    
                case PUSH_FIRE:{
                    
                    
                    int Type=buf[4];
                    NSLog(@"推送提醒   状态%i",Type);
                    
                    notiType=COMPLETE;
                    
                    DeviceModel *deviceModel = [manager getModelWithMac:[device getMacAddressSimple]];
                    if (!deviceModel) {
                        return nil;
                    }
                    if (Type <= 0 || Type >= 8) {
                        return nil;
                    }
                    NSString *commandType=[NSUserDefaultInfos getValueforKey:@"commandType"];
                    NSString *funtion =[deviceModel.State objectForKey:@"state"];
                    if ([[deviceModel.State objectForKey:@"state"] isEqualToString:@"空闲"]||[[deviceModel.State objectForKey:@"state"] isEqualToString:@"在线"]) {
                        funtion =commandType;
                    }
                    if ([funtion isEqualToString:@"云菜谱"]) {
                        funtion = [deviceModel.State objectForKey:@"name"];
                    }
                    if (Type==1) {
                        NSString *name=[NSUserDefaultInfos getValueforKey:@"name"];
                        if (name != nil) {
                            funtionType=name;
                        } else {
                            [stateDic setObject:funtion forKey:[device getMacAddressSimple]];
                            if (  [funtion isEqualToString:@"2"]) {
                                funtionType = @"三杯鸡";
                            } else if(  [funtion isEqualToString:@"3"]){
                                funtionType = @"黄焖鸡";
                            }else if(  [funtion isEqualToString:@"4"]){
                                funtionType = @"红烧鱼";
                            }else if(  [funtion isEqualToString:@"5"]){
                                funtionType = @"红焖排骨";
                            }else if(  [funtion isEqualToString:@"6"]){
                                funtionType = @"清炖鸡";
                            }else if(  [funtion isEqualToString:@"7"]){
                                funtionType = @"老火汤";
                            }else if(  [funtion isEqualToString:@"8"]){
                                funtionType = @"红烧肉";
                            }else if(  [funtion isEqualToString:@"9"]){
                                funtionType = @"东坡肘子";
                            }else if(  [funtion isEqualToString:@"10"]){
                                funtionType = @"口水鸡";
                            }else if(  [funtion isEqualToString:@"11"]){
                                funtionType = @"滑香鸡";
                            }else if(  [funtion isEqualToString:@"12"]){
                                funtionType = @"茄子煲";
                            }else if(  [funtion isEqualToString:@"13"]){
                                funtionType = @"梅菜扣肉";
                            }else if(  [funtion isEqualToString:@"空闲"]){
                                
                            }else{
                                
                                funtionType=funtion;
                            }
                        }
                    }else{
                        funtionType=[stateDic objectForKey:[device getMacAddressSimple]];
                    }
                    
                    content=[DeviceHelper cookFoodgetDevicePustNotiWithType:Type];
                }
                default:
                    break;
                    
            }
        }else if ( [device.productID isEqualToString:CLOUD_KETTLE_PRODUCT_ID]){
            //私享壶
            {
                switch (feedback) {
                    case FREE:
                    {
                        NSLog(@"设备处于空闲");
                        
                        int Type=buf[4];
                        NSLog(@"推送提醒   状态%i",Type);
                        notiType=COMPLETE;
                        
                        DeviceModel *deviceModel = [manager getModelWithMac:[device getMacAddressSimple]];
                        if (!deviceModel) {
                            return nil;
                        }
                        
                        funtionType=[stateDic objectForKey:[device getMacAddressSimple]];
                        content=[DeviceHelper getDevicePustNotiWithType:Type];
                        
                        break;
                    }
                    case 0x02:
                    {
                        int unusualType=buf[4];
                        NSLog(@"传感器异常    异常类型=%i",unusualType);
                        notiType=ERROR;
                        content=@"传感器异常";
                    }
                        break;
                    case 0x03:
                    {
                        int dryType=buf[4];
                        NSLog(@"干烧状态   异常状态%i",dryType);
                        notiType=ERROR;
                        content=@"干烧状态";
                    }
                        break;
                    case 0x08:
                    case 0x09:{
                        
                        
                        int Type=buf[4];
                        NSLog(@"推送提醒   状态%i",Type);
                        notiType=COMPLETE;
                        
                        DeviceModel *deviceModel = [manager getModelWithMac:[device getMacAddressSimple]];
                        if (!deviceModel) {
                            return nil;
                        }
                        if (Type <= 0 || Type >= 9) {
                            return nil;
                        }
                        NSString *commandType=[NSUserDefaultInfos getValueforKey:@"commandType"];
                        NSString *funtion =[deviceModel.State objectForKey:@"state"];
                        if ([[deviceModel.State objectForKey:@"state"] isEqualToString:@"空闲"]||[[deviceModel.State objectForKey:@"state"] isEqualToString:@"在线"]) {
                            funtion =commandType;
                        }
                        if ([funtion isEqualToString:@"云菜谱"]) {
                             funtion=[[deviceModel.State objectForKey:@"name"] isEqualToString:@"空闲"]?commandType:[deviceModel.State objectForKey:@"state"];
                        }
                        
                        if (Type==1) {
                            NSString *name=[NSUserDefaultInfos getValueforKey:@"name"];
                            if (name != nil) {
                                funtionType=name;
                            } else {
                                [stateDic setObject:funtion forKey:[device getMacAddressSimple]];
                                funtionType=funtion;
                            }

                        }else{
                            
                            funtionType=[stateDic objectForKey:[device getMacAddressSimple]];
                        }
                        content=[DeviceHelper getDevicePustNotiWithType:Type];
                    }
                    default:
                        break;
                        
                }
            }
        }
        
        
        
        if (![content isEqualToString:@""]) {
            
            NotiModel *model=[[NotiModel alloc]init];
            model.time=[NSUserDefaultInfos getCurrentDate];
            model.notiType=[NSString stringWithFormat:@"%i",notiType];
            model.deviceID=deviceID;
            model.deviceName=deviceName;
            
            model.deviceType=funtionType;
            
            model.notiState=content;
            
            //防止弹出重复的notif
            if (lastNotiModel) {
                if ([model isEqual:lastNotiModel]) {
                    return nil;
                }
            }else{
                lastNotiModel = model;
            }
            
            return model;
        }
    }else if(buf[5]==0x15&&buf[8]==0x09){   //智能厨物柜处理
        if ([device.productID isEqualToString:CABINETS_PRODUCT_ID]) {
            NSString *messageStr=nil;
            NSString *storageType=nil;
            if (buf[9]==0x07) {
                storageType=@"储米区";
                messageStr=@"缺米";
            }else if (buf[9]==0x08){
                storageType=@"储物区";
                messageStr=@"异常";
            }else if (buf[9]==0x09||buf[9]==0x0A||buf[9]==0x0B){
                storageType=@"储米区";
                messageStr=@"异常";
            }
            if (!kIsEmptyString(messageStr)) {
                NotiModel *model=[[NotiModel alloc]init];
                model.time=[NSUserDefaultInfos getCurrentDate];
                model.notiType=[NSString stringWithFormat:@"%i",ERROR];
                model.deviceID=[NSString stringWithFormat:@"%d",device.deviceID];
                model.deviceName=deviceName;
                model.deviceType=storageType;
                model.notiState=messageStr;
                if (lastNotiModel) {
                    if ([model isEqual:lastNotiModel]) {
                        return nil;
                    }
                }else{
                    lastNotiModel = model;
                }
                return model;
            }
        }
    }
    return nil;
}


-(void)configNotification:(NSString *)alertBody{
    
    if (!notification) {
        notification=[[UILocalNotification alloc] init];
    }
    if (notification!=nil) {
        
        NSDate *now=[NSDate new];
        //        notification.fireDate=[now dateByAddingTimeInterval:10];//10秒后通知
        notification.fireDate=now;//通知
        notification.repeatInterval=0;//循环次数，kCFCalendarUnitWeekday一周一次
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.applicationIconBadgeNumber+=1; //应用的红色数字
        notification.soundName= UILocalNotificationDefaultSoundName;//声音，可以换成alarm.soundName = @"myMusic.caf"
        //去掉下面2行就不会弹出提示框
        notification.alertBody=alertBody;//提示信息 弹出提示框
        notification.alertAction = @"确定";  //提示框按钮
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)makeToastWithConfigNotification:(NSString *)alertBody{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  // 震动
    AudioServicesPlaySystemSound(1007);     //这个声音是是类似于QQ声音的
    
    [self configNotification:alertBody];
}

-(void)clearNotiIconNum{
    if (notification) {
        notification.applicationIconBadgeNumber=0;
    }
}

-(void)getShareList{
    
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    
    [HttpRequest getShareListWithAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"%@",result);
                [self handleArray:result];
            });
        });
        
    }];
    
}

-(void)handleArray:(NSArray *)arr{
    
    NSDictionary *dic=[arr lastObject];
    if ([[dic objectForKey:@"share_mode"]isEqualToString:@"app"]&&[[dic objectForKey:@"state"]isEqualToString:@"pending"]) {
        
        NSString *fromID=[NSString stringWithFormat:@"%@",[dic objectForKey:@"from_id"]];
        
        inviteCode=[dic objectForKey:@"invite_code"];
        
        //        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@向你分享了设备",fromID] delegate:self cancelButtonTitle:@"接受" otherButtonTitles:@"拒绝", nil];
        //        [alertView show];
        if ([curInviteCode isEqualToString:inviteCode]) {
            return;
        }
        [self configNotification:[NSString stringWithFormat:@"%@向您分享了设备",fromID]];
        curInviteCode = inviteCode;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            curInviteCode = nil;
        });
        
    }
}

#pragma mark alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        //接受
        [self acceptShare];
    }else{
        [self refuseShare];
    }
}

#pragma mark 拒绝分享
-(void)refuseShare{
    //拒绝分享
    
    [HttpRequest denyShareWithInviteCode:inviteCode withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        
        if (!err) {
            
        }else{
            
        }
    }];
}


#pragma mark 接受分享
-(void)acceptShare{
    
    //接受分享
    [HttpRequest acceptShareWithInviteCode:inviteCode withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        
        if (!err) {
            __weak typeof(self) weakSelf = self;
            [HttpRequest getDeviceListWithUserID:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"user_id"] withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] withVersion:@(0) didLoadData:^(id result, NSError *err) {
                if (!err) {
                    
                    NSDictionary *dic = (NSDictionary *)result;
                    [weakSelf addDevice:dic];
                    
                } else {
                    if (err.code==4031003) {
                        
                    }
                }
            }];
            
        }else{
            if (err.code==4031003) {
                [manager updateAccessToken];
            }
            
        }
    }];
}

- (void)addDevice:(NSDictionary *)dic{
    //获取分享列表
    [HttpRequest getShareListWithAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        if (!err) {
            NSArray *tem = (NSArray *)result;
            
            for (NSDictionary *newsDict in tem) {
                ShareModel *model = [[ShareModel alloc] init];
                [model setValuesForKeysWithDictionary:newsDict];
                model.to_id = newsDict[@"user_id"];
                if ([model.invite_code isEqualToString:inviteCode]) {
                    
                    for (NSDictionary *deviceDic in dic[@"list"]) {
                        if ([@([deviceDic[@"id"] intValue]) isEqualToNumber:model.device_id]) {
                            DeviceEntity *newDevice = [[DeviceEntity alloc] initWithMac:deviceDic[@"mac"] andProductID:deviceDic[@"product_id"]];
                            newDevice.deviceID = [deviceDic[@"id"] intValue];
                            newDevice.accessKey = deviceDic[@"access_key"];
                            
                            [DeviceHelper saveDeviceToLocal:newDevice];
                            
                            //                            [appDelegate.deviceVC updateUIAfterAddDevice:newDevice];
                            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:kOnManagerDeviceStateChange object:nil];
                            
                        }
                        
                    }
                    break;
                }
            }
            
        }else{
            if (err.code==4031003) {
                [manager updateAccessToken];
            }
            
            
        }
    }];
}

#pragma mark 处理提醒喝水通知
-(void)setNextRemindNoti{
    
    [self cancelAllNoti];
    
    
    //触发下一个通知时间
    
    selctRemindDic=[self getNextRemindInterval];
    if (selctRemindDic!=nil) {
        if (!notification) {
            notification=[[UILocalNotification alloc] init];
        }
        if (notification!=nil) {
            
            
            NSDate *now=[NSDate new];
            
            //        selctRemindDic=[self getNextRemindInterval];
            
            notification.fireDate=[now dateByAddingTimeInterval:[[selctRemindDic objectForKey:@"interval"] doubleValue]];//定时通知
            notification.repeatInterval=0;//循环次数，kCFCalendarUnitWeekday一周一次
            notification.timeZone=[NSTimeZone defaultTimeZone];
            notification.applicationIconBadgeNumber+=1; //应用的红色数字
            notification.soundName= UILocalNotificationDefaultSoundName;//声音，可以换成alarm.soundName = @"myMusic.caf"
            
            //设置info
            NSDictionary *info =[[NSDictionary alloc]initWithObjectsAndKeys:@"remind",@"key",[[selctRemindDic  objectForKey:@"data"] objectForKey:@"time"],@"time", nil];
            
            
            [NSDictionary dictionaryWithObject:@"remind"forKey:@"key"];
            
            notification.userInfo = info;
            
            //去掉下面2行就不会弹出提示框
            //            notification.alertTitle=[[selctRemindDic  objectForKey:@"data"] objectForKey:@"time"]; //iOS 8.2以下用这个方法会crash，所以把time放到UserInfo
            //
            //
            
            notification.alertBody=[NSString stringWithFormat:@"喝水量:%@",[[selctRemindDic  objectForKey:@"data"] objectForKey:@"value"]];//提示信息 弹出提示框
            //        notification.userInfo=selctRemindDic;
            notification.alertAction = @"确定";  //提示框按钮
            
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
        
    }
    
    
}

-(void)cancelAllNoti{// 获得 UIApplication
    
    UIApplication *app = [UIApplication sharedApplication];
    
    //获取本地推送数组
    
    NSArray *localArray = [app scheduledLocalNotifications];
    
    //声明本地通知对象
    
    UILocalNotification *localNotification;
    
    if (localArray) {
        
        for (UILocalNotification *noti in localArray) {
            
            [app cancelLocalNotification:noti];
            
        }
        
    }
}


-(void)insertRemindRecord{
    
    NSString *currentDate=[NSUserDefaultInfos getCurrentDate];
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    
    NSNumber *userid=[userDic objectForKey:@"user_id"];
    
    //获取年份
    NSNumber *year=[NSNumber numberWithInteger:[[currentDate substringToIndex:4] integerValue]];
    NSNumber *month=[NSNumber numberWithInteger:[[currentDate substringWithRange:NSMakeRange(5, 2)] integerValue]];
    NSNumber *day=[NSNumber numberWithInteger:[[currentDate substringWithRange:NSMakeRange(8, 2)] integerValue]];
    NSString *time=[currentDate substringFromIndex:11];
    
    //时间戳
    NSNumber *timeSP=[NSNumber numberWithInteger:[[NSUserDefaultInfos getTimeSP] integerValue]];
    
    NSDictionary *remindDic=[selctRemindDic objectForKey:@"data"];
    
    NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:year,@"year",month,@"month",day,@"day",time,@"time",currentDate,@"date",[remindDic objectForKey:@"value"],@"value",[remindDic objectForKey:@"deviceid"],@"deviceid",timeSP,@"timeSP",userid,@"user_id", nil];
    
    NSDictionary *insertDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_PLAN_TABLE,@"table",dataDic,@"data", nil];
    
    [YTKHelper insertDataWithJSON:[Transform DataToJsonString:insertDic]];
    
    //通知更新界面
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Drink_Plan_Reload_TB" object:nil];
}

//获取下一条提醒距离当前时间的秒数
-(NSDictionary *)getNextRemindInterval{
    
    
    //排序条件
    NSDictionary *orderDic=[[NSDictionary alloc]initWithObjectsAndKeys:@"desc",@"date", nil];
    
    NSString *str = [NSUserDefaultInfos getValueforKey:USER_ID];
    
    if (str != nil) {
        //查询条件
        NSDictionary *queryDic=@{@"isOn":@{@"$in":@[@"1"]},@"userid":@{@"$in":@[str]}};
        
        NSDictionary *sqlDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",orderDic,@"order",queryDic,@"query", nil];
        
        //获取所有打开的闹钟
        NSDictionary *resultDic=[YTKHelper queryDataWithJSON:[Transform DataToJsonString:sqlDic]];
        
        NSArray *allArr=[resultDic objectForKey:@"list"];
        
        if (allArr.count<1) {
            return nil;
        }
        //    NSString *today=[NSUserDefaultInfos getCurrentDate];
        
        NSTimeInterval interval = 0.0;
        NSDictionary *dataDic;
        
        
        for (int i=0; i<allArr.count; i++) {
            
            NSDictionary *remindDic=[allArr objectAtIndex:i];
            
            NSString *time=[remindDic objectForKey:@"time"];
            
            NSInteger hour=[[time substringToIndex:2] integerValue];
            NSInteger min=[[time substringFromIndex:3] integerValue];
            
            //获取最近的提醒
            if (i==0) {
                interval=[NSUserDefaultInfos getDateIntervalWithHour:hour Min:min];
                dataDic=remindDic;
                
            }else{
                
                if ([NSUserDefaultInfos getDateIntervalWithHour:hour Min:min]<interval) {
                    interval=[NSUserDefaultInfos getDateIntervalWithHour:hour Min:min];
                    dataDic=remindDic;
                }
            }
        }
        
        return [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",interval],@"interval",dataDic,@"data", nil];
        
    }
    
    return nil;
}

@end
