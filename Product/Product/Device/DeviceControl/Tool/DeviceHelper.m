//
//  DeviceHelper.m
//  Product
//
//  Created by Xlink on 15/12/30.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "DeviceHelper.h"
#import "DeviceDefines.h"
#import "DeviceModel.h"
#import "YTKKeyValueStore.h"
#import "Transform.h"
#import "NSData+Extension.h"
#import "MeasurementsModel.h"
#import "AppDelegate.h"
#import "ThermometerModel.h"
#import "BPMeterModel.h"
#import "MeasurementsManager.h"
#import "Product-Swift.h"
#import "AutoLoginManager.h"
#import "StorageDeviceHelper.h"

@implementation DeviceHelper


///通过设备的mac获取设备的类型
+(int)getDeviceTypeWithMac:(NSString *)mac{
    //    NSDictionary *device=[NSUserDefaultInfos getDicValueforKey:mac];
    
    DeviceEntity *device=[self getDeviceFromLocalWithMacAddr:mac];
    
    if (device) {
        
        return [self getDeviceTypeWithProductID:device.productID];
        
    } else {
        return DeviceTypeUnknow;    //没有设备名称
    }
}

///通过设备的PID获取设备的类型
+(DeviceType)getDeviceTypeWithProductID:(NSString *)productID {
    if ([productID isEqualToString:CLOUD_COOKER_PRODUCT_ID]) {
        return CLOUD_COOKER;
    }else if ([productID isEqualToString:WATER_COOKER_PRODUCT_ID]){
        return WATER_COOKER;
    }else if ([productID isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]){
        return WATER_COOKER_16AIG;
    }else if ([productID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]){
        return COOKFOOD_KETTLE;
    }else if ([productID isEqualToString:CLOUD_KETTLE_PRODUCT_ID]){
        return CLOUD_KETTLE;
    }else if ([productID isEqualToString:THERMOMETER_PRODUCT_ID]){
        return DeviceTypeThermometer;
    }else if ([productID isEqualToString:CLINK_BPM_PRODUCT_ID]){
        return DeviceTypeBPMeter;
    }else if ([productID isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]){
        return DeviceTypeElectricCooker;
    }else if ([productID isEqualToString:SCALE_PRODUCT_ID]){
        return DeviceTypeScale;
    } else if ([productID isEqualToString:CABINETS_PRODUCT_ID]){
        return DeviceTypeCaninets;
    } else{
        return DeviceTypeUnknow;
    }
}

///通过设备的mac获取设备类型的默认名称
+(NSString *)getDeviceTypeStrWithMac:(NSString *)mac{
    
    int type=[self getDeviceTypeWithMac:mac];
    
    NSString *typeStr=@"";
    switch (type) {
        case WATER_COOKER:
            typeStr=@"云智能隔水炖";
            break;
        case WATER_COOKER_16AIG:
            typeStr=@"云智能隔水炖16AIG";
            break;
        case ELECTRIC_COOKER:
            typeStr=@"云智能电饭煲";
            break;
        case COOKFOOD_KETTLE:
            typeStr=@"云智能健康大厨";
            break;
        case CLOUD_COOKER:
            typeStr=@"云智能电炖锅";
            break;
        case CABINETS:
            typeStr=@"智能厨物柜";
            break;
        default:
            typeStr=@"设备";
            break;
    }
    
    return typeStr;
}

///通过DeviceEntity获取设备的名称，名称为空则通过设备类型返回默认名称
+(NSString *)getDeviceName:(DeviceEntity *)device{
    NSString *key=[[device getMacAddressSimple] stringByAppendingString:@"name"];
    NSString *name=[NSUserDefaultInfos getValueforKey:key];
    if (kIsEmptyString(name)) {
        if ([device.productID isEqualToString:WATER_COOKER_PRODUCT_ID]) {
            name=@"云智能隔水炖";
        }else if ([device.productID isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]){
            name=@"云智能IH电饭煲";
        }else if ([device.productID isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]){
            name=@"云智能隔水炖16AIG";
        }else if ([device.productID isEqualToString:CLOUD_COOKER_PRODUCT_ID]){
            name=@"云智能电炖锅";
        } else if ([device.productID isEqualToString:CLOUD_KETTLE_PRODUCT_ID]) {
            name = @"云智能私享壶";
        }else if ([device.productID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]){
            name=@"云智能健康大厨";
        }  else if ([device.productID isEqualToString:CLINK_BPM_PRODUCT_ID]) {
            name = @"蓝牙智能血压计";
        } else if ([device.productID isEqualToString:THERMOMETER_PRODUCT_ID]){
            name = @"蓝牙智能体温贴";
        } else if ([device.productID isEqualToString:SCALE_PRODUCT_ID]){
            name = @"体质健康分析仪";
        } else if ([device.productID isEqualToString:CABINETS_PRODUCT_ID]){
            name = @"智能厨物柜";
        } else {
            name = @"未知设备";
        }
    }
    return name;
}
///通过云端的用户历史记录MeasurementsModel获取蓝牙设备的名称，名称为空则通过设备类型返回默认名称
+(NSString *)getBLEDeviceName:(MeasurementsModel *)measurement{
    
    //1.获取设备列表的deviceModelList
    NSArray *array = [AutoLoginManager shareManager].getDeviceModelArr;
    
    //2.根据类型查询设备名称
    NSString *name = @"";
    switch (measurement.type) {
        case MeasurementType_Temp:
            name = @"蓝牙智能体温贴";
            for (DeviceModel *model in array) {
                if ([model isMemberOfClass:[ThermometerModel class]]) {
                    ThermometerModel *tempDevice = (ThermometerModel *)model;
                    if ([tempDevice.BLEMacAddress isEqualToString:measurement.mac]) {
                        name = tempDevice.deviceName;
                        break;
                    }
                }
            }
            break;
        case MeasurementType_BPMeter:
            name = @"蓝牙智能血压计";
            for (DeviceModel *model in array) {
                if ([model isMemberOfClass:[BPMeterModel class]]) {
                    BPMeterModel *BPDevice = (BPMeterModel *)model;
                    if ([BPDevice.BLEMacAddress isEqualToString:measurement.mac]) {
                        name = BPDevice.deviceName;
                        break;
                    }
                }
            }
            break;
        default:
            break;
    }
    
    return name;
}

///通过设备的PID，获取设备类型的默认名称
+ (NSString *)productDefaultName:(NSString *)productID {
    if ([productID isEqualToString:WATER_COOKER_PRODUCT_ID]) {
        return @"云智能隔水炖";
    }else if ([productID isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]){
        return @"云智能隔水炖16AIG";
    }else if ([productID isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]){
        return @"云智能电饭煲";
    }else if ([productID isEqualToString:CLOUD_COOKER_PRODUCT_ID]){
        return @"云智能电炖锅";
    } else if ([productID isEqualToString:CLOUD_KETTLE_PRODUCT_ID]) {
        return  @"云智能私享壶";
    }else if ([productID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]){
        return @"云智能健康大厨";
    } else if ([productID isEqualToString:CLINK_BPM_PRODUCT_ID]) {
        return  @"蓝牙智能血压计";
    } else if ([productID isEqualToString:THERMOMETER_PRODUCT_ID]){
        return  @"蓝牙智能体温贴";
    } else if ([productID isEqualToString:SCALE_PRODUCT_ID]){
        return  @"体质健康分析仪";
    } else if([productID isEqualToString:CABINETS_PRODUCT_ID]) {
        return @"智能厨物柜";
    }else{
        return  @"未知设备";
    }
}


+ (NSString *)productHelpDefaultName:(NSString *)productID {
    if ([productID isEqualToString:WATER_COOKER_PRODUCT_ID]) {
        return @"隔水炖";
    }else if ([productID isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]){
        return @"add隔水炖16AIG";
    }else if ([productID isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]){
        return @"电饭煲";
    }else if ([productID isEqualToString:CLOUD_COOKER_PRODUCT_ID]){
        return @"云炖锅";
    } else if ([productID isEqualToString:CLOUD_KETTLE_PRODUCT_ID]) {
        return  @"add云水壶";
    }else if ([productID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]){
        return @"自动烹饪锅";
    } else if ([productID isEqualToString:CLINK_BPM_PRODUCT_ID]) {
        return  @"血压计";
    } else if ([productID isEqualToString:THERMOMETER_PRODUCT_ID]){
        return  @"体温计";
    } else if ([productID isEqualToString:SCALE_PRODUCT_ID]){
        return  @"add体脂称";
    } else {
        return  @"未知设备";
    }
    return nil;
}
///炒菜锅通过设备推送的整形特征值，获取设备工作状态
+(NSString *)cookFoodgetDevicePustNotiWithType:(int)type{
    switch (type) {
        case 0:
            return @"已取消";//by liang
        case 1:
            return @"已开始";
        case 2:
            return @"已结束";
        case 3:
            return @"已取消！";
        case 4:
            return @"加食材";
        case 5:
            return @"干锅加水";
        case 6:
            return @"水溢出";
        case 7:
            return @"盖盖子";
        default:
            return @"";
    }
}
///通过设备推送的整形特征值，获取设备工作状态
+(NSString *)getDevicePustNotiWithType:(int)type{
    
    switch (type) {
        case 0:
            return @"已取消";//by liang
        case 1:
            return @"已开始";
        case 2:
            return @"已完成";
        case 3:
            return @"加食材";
        case 4:
            return @"加水";
        case 5:
            return @"盖盖子";
        case 6:
            return @"已取消";
        case 7:
            return @"加上壶";
        case 8:
            return @"壶离座";
        default:
            return @"";
    }
}

///在原设备字典的基础上添加两个key
+(NSDictionary *)getDeviceDictionary:(NSDictionary *)dic{
    NSMutableDictionary *DeviceDic=[[NSMutableDictionary alloc]initWithDictionary:dic];
    [DeviceDic setObject:[dic objectForKey:@"macAddress"] forKey:@"mac"];
    [DeviceDic setObject:[dic objectForKey:@"deviceID"] forKey:@"deviceid"];
    
    return DeviceDic;
}

///DeviceModel反序列化
+(NSDictionary *)getDeviceDictionaryFromModel:(DeviceModel *)model{
    DeviceEntity *device=[self getDeviceFromLocalWithMacAddr:model.mac];
    if(!device) return nil;
    return [device getDictionaryFormat];
}

#pragma mark 其他

+(NSArray *)getDeviceListArray:(NSString*)ArrayStr{
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    NSArray *macArr=[ArrayStr componentsSeparatedByString:@","];
    for (NSString *macStr in macArr) {
        DeviceEntity *device= [self getDeviceFromLocalWithMacAddr:macStr];
        [arr addObject:device];
    }
    return arr;
}

#pragma mark - 保存设备缓存到本地(NSUserDefaults的@“devices”)
+(void)saveDeviceToLocal:(DeviceEntity *)device{
    NSMutableDictionary *deviceDic = [[NSMutableDictionary alloc] initWithDictionary:[DeviceHelper getDeviceDictionary:[device getDictionaryFormat]]];
    NSMutableArray *deviceArr = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"devices"]];
    BOOL hadOldDevice=NO;
    for (NSDictionary *dic in deviceArr) {
        if ([[dic objectForKey:@"macAddress"] isEqualToString:[deviceDic objectForKey:@"macAddress"]]) {
            hadOldDevice=YES;
            break;
        }
    }
    if (!hadOldDevice) {
        [deviceArr addObject:deviceDic];
    }else{
        for (int i=0;i<deviceArr.count;i++) {
            NSDictionary *dic=[deviceArr objectAtIndex:i];
            if ([[dic objectForKey:@"macAddress"] isEqual:[deviceDic objectForKey:@"macAddress"]]) {
                [deviceArr replaceObjectAtIndex:i withObject:deviceDic];
                break;
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:deviceArr forKey:@"devices"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(void)saveDeviceListToLocal:(NSMutableArray *)list{
    [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"devices"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
#pragma mark - 获取本地保存的设备
+(DeviceEntity *)getDeviceFromLocalWithMacAddr:(NSString *)macAddr{
    NSArray *arr = [[NSUserDefaults standardUserDefaults]objectForKey:@"devices"];
    for (NSDictionary *dict in arr) {
        DeviceEntity *device = [[DeviceEntity alloc] initWithDictionary:dict];
        if ([[device getMacAddressSimple] isEqualToString:macAddr]) {
            return device;
        }
    }
    return nil;
}

+(NSArray *)getAllDeviceFromLocal{
    
    NSArray *arr = [[NSUserDefaults standardUserDefaults]objectForKey:@"devices"];
    return arr;
}

+(void)putFeedbackDeviceToLocal:(NSString *)macAddress Data:(NSData*)data{
    
    uint8_t cmd_data[20];
    uint32_t cmd_len = (uint32_t)[data length];
    memset(cmd_data, 0, 20);
    [data getBytes:(void *)cmd_data length:cmd_len];
    
    if (cmd_data[0]==0x10) {
        //属于查询设备类型返回，保存到本地,用于获取设备类型   类型以devicemodel枚举为准
        int deviceType=cmd_data[3]+cmd_data[4];
        
        switch (deviceType) {
            case DEVICE_CLOUD_COOKER:
                deviceType=CLOUD_COOKER;
                break;
            case DEVICE_ELECTRIC_COOKER:
                deviceType=ELECTRIC_COOKER;
                break;
            case DEVICE_COOKFOOD_COOKER:
                deviceType=COOKFOOD_KETTLE;
                break;
            case DEVICE_WATER_COOKER:
                deviceType=WATER_COOKER;
                break;
            default:
                break;
        }
        
        int protocolVerison=cmd_data[5];
        int firmwareVersion=cmd_data[6]+cmd_data[7];
        NSDictionary *feedbackDeviceDic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",deviceType],@"deviceType",[NSString stringWithFormat:@"%i",protocolVerison],@"protocolVersion",[NSString stringWithFormat:@"%i",firmwareVersion],@"firmwareVersion", nil];
        [NSUserDefaultInfos putKey:macAddress andValue:feedbackDeviceDic];
    }
}
///传入DeviceEntity和设备状态数据NSData，生成设备状态字典
+(NSMutableDictionary *)getStateDicWithDevice:(DeviceEntity *)device Data:(NSData *)data{
    NSMutableDictionary *dic;
    uint8_t cmd_data[[data length]];
    uint32_t cmd_len = (uint32_t)[data length];
    memset(cmd_data, 0, [data length]);
    [data getBytes:(void *)cmd_data length:cmd_len];
    
    int deviceType=[self getDeviceTypeWithMac:[device getMacAddressSimple]];
    switch (deviceType) {
        case CLOUD_COOKER:
            if (cmd_data[0]==0x12||(cmd_data[0]==0x15&&cmd_data[3]!=0x09)||cmd_data[0]==0x14) {
                //筛选
                switch (cmd_data[3]) {
                    case 0x01:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"空闲",@"state", nil];
                        break;
                    case 0x02:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"传感器异常",@"state", nil];
                        break;
                    case 0x03:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"干烧状态",@"state", nil];
                        break;
                    case 0x04:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"炖汤",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x05:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"偏好",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x06:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"营养保温",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x07:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"煮粥",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[9]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[10]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[11]],@"tem", nil];
                        break;
                    case 0x08:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"云菜谱",@"state",[self getCloudMenuName:data],@"name",[NSString stringWithFormat:@"%i",cmd_data[24]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[25]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[26]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[27]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[28]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[29]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[30]],@"tem", nil];
                        
                        
                        break;
                    default:
                        break;
                }
                
            }
            break;
        case COOKFOOD_KETTLE:
            if (cmd_data[0]==0x12||(cmd_data[0]==0x15&&cmd_data[3]!=0x07)||cmd_data[0]==0x14) {
                NSString *PreferenceInfo=@"";
                int TypeIdentifier=cmd_data[4];   // @
                int secondIdentifier=cmd_data[5];
                NSArray *infoArr;
                if ([[NSString stringWithFormat:@"%C",(unichar)TypeIdentifier] isEqualToString:@"@"]&&[[NSString stringWithFormat:@"%C",(unichar)secondIdentifier] isEqualToString:@"|"]) {
                    //工作类型
                    
                    BOOL gotName = false;//如果已经获取了名字，则取一位accii码转化
                    for (int i=6;i<24;i++) {
                        if ((([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+3]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+6]] isEqualToString:@"|"])||([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+2]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+5]] isEqualToString:@"|"])||([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+3]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+5]] isEqualToString:@"|"])||([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+2]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+4]] isEqualToString:@"|"]))&&cmd_data[i+1]!=0xa5) {
                            
                            //判断是否已经获取了名字
                            gotName=true;
                        }
                        
                        if ([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"\0"]) {
                            break;
                        }
                        
                        if (gotName==true) {
                            
                            int acciiCode=cmd_data[i];
                            PreferenceInfo=[PreferenceInfo stringByAppendingString:[NSString stringWithFormat:@"%C",(unichar)acciiCode]];
                        }else {
                            int acciiCode=cmd_data[i]*pow(16, 2)+cmd_data[i+1];
                            i++;
                            PreferenceInfo=[PreferenceInfo stringByAppendingString:[NSString stringWithFormat:@"%C",(unichar)acciiCode]];
                        }
                        
                    }
                }
                //筛选
                switch (cmd_data[3]) {
                    case 0x01:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"空闲",@"state", nil];
                        break;
                    case 0x02:
                        switch (cmd_data[4]) {
                            case 0x01:
                                dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"内部故障",@"state", nil];
                                break;
                            case 0x02:
                                dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"干锅报警",@"state", nil];
                                break;
                            case 0x03:
                                dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"电网电压过高",@"state", nil];
                                break;
                            case 0x04:
                                dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"电网电压过低",@"state", nil];
                                break;
                            case 0x05:
                                dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"侧面传感器故障",@"state", nil];
                                break;
                            case 0x06:
                                dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"底部传感器故障",@"state", nil];
                                break;
                            case 0x07:
                                dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"WIFI连接故障",@"state", nil];
                                break;
                            case 0x08:
                                dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"散热器过热保护",@"state", nil];
                                break;
                            case 0x09:
                                dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"干烧报警",@"state", nil];
                                break;
                            case 0x0A:
                                dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"网络故障",@"state", nil];
                                break;
                            default:
                                break;
                        }
                        break;
                        //                        12 00 00 03 01 01 02 00 02 04
                    case 0x03:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"手动烹饪",@"state",
                             [NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",
                             [NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",
                             [NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",
                             [NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",
                             [NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",
                             [NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",
                             [NSString stringWithFormat:@"%i",cmd_data[10]],@"tem",nil];
                        break;
                    case 0x04:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%i",cmd_data[4]],@"state",
                             [NSString stringWithFormat:@"%i",cmd_data[5]],@"fire",
                             [NSString stringWithFormat:@"%i",cmd_data[6]],@"orderHour",
                             [NSString stringWithFormat:@"%i",cmd_data[7]],@"orderMin",
                             [NSString stringWithFormat:@"%i",cmd_data[8]],@"WorkHour",
                             [NSString stringWithFormat:@"%i",cmd_data[9]],@"WorkMin",
                             [NSString stringWithFormat:@"%i",cmd_data[10]],@"progress",
                             [NSString stringWithFormat:@"%i",cmd_data[11]],@"percent",
                             [NSString stringWithFormat:@"%i",cmd_data[12]],@"tem", nil];
                        break;
                    case 0x05:
                        infoArr=[PreferenceInfo componentsSeparatedByString:@"|"];
                        NSLog(@"%lu",(unsigned long)infoArr.count);
                        if (infoArr.count == 1) {
                            for (int i=4;i<16;i++) {
                                
                                int acciiCode=cmd_data[i]*pow(16, 2)+cmd_data[i+1];
                                i++;
                                PreferenceInfo=[PreferenceInfo stringByAppendingString:[NSString stringWithFormat:@"%C",(unichar)acciiCode]];
                            }
                            NSLog(@"%@",PreferenceInfo);
                            dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                 PreferenceInfo,@"state",
                                 [NSString stringWithFormat:@"%i",cmd_data[24]],@"fire",
                                 [NSString stringWithFormat:@"%i",cmd_data[25]],@"orderHour",
                                 [NSString stringWithFormat:@"%i",cmd_data[26]],@"orderMin",
                                 [NSString stringWithFormat:@"%i",cmd_data[27]],@"WorkHour",
                                 [NSString stringWithFormat:@"%i",cmd_data[28]],@"WorkMin",
                                 [NSString stringWithFormat:@"%i",cmd_data[29]],@"progress",
                                 [NSString stringWithFormat:@"%i",cmd_data[30]],@"percent",@"偏好",@"tem", nil];
                            
                        }else{
                            dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%@",infoArr[0]],@"state",
                                 [NSString stringWithFormat:@"%i",cmd_data[24]],@"fire",
                                 [NSString stringWithFormat:@"%i",cmd_data[25]],@"orderHour",
                                 [NSString stringWithFormat:@"%i",cmd_data[26]],@"orderMin",
                                 [NSString stringWithFormat:@"%i",cmd_data[27]],@"WorkHour",
                                 [NSString stringWithFormat:@"%i",cmd_data[28]],@"WorkMin",
                                 [NSString stringWithFormat:@"%i",cmd_data[29]],@"progress",
                                 [NSString stringWithFormat:@"%i",cmd_data[30]],@"percent",@"偏好",@"tem", nil];
                        }
                        break;
                    case 0x06:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"云菜谱",@"state",[self getCloudMenuName:data],@"name",
                             [NSString stringWithFormat:@"%i",cmd_data[24]],@"fire",
                             [NSString stringWithFormat:@"%i",cmd_data[25]],@"orderHour",
                             [NSString stringWithFormat:@"%i",cmd_data[26]],@"orderMin",
                             [NSString stringWithFormat:@"%i",cmd_data[27]],@"WorkHour",
                             [NSString stringWithFormat:@"%i",cmd_data[28]],@"WorkMin",
                             [NSString stringWithFormat:@"%i",cmd_data[29]],@"progress",
                             [NSString stringWithFormat:@"%i",cmd_data[30]],@"percent",
                             [NSString stringWithFormat:@"%i",cmd_data[30]],@"tem", nil];
                        break;
                    default:
                        break;
                }
            }
            break;
            
        case ELECTRIC_COOKER:
            if (cmd_data[0]==0x12||(cmd_data[0]==0x15&&cmd_data[3]!=0x11)||cmd_data[0]==0x14) {
                
                
                //筛选
                switch (cmd_data[3]) {
                    case 0x01:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"空闲",@"state", nil];
                        break;
                    case 0x02:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"传感器异常",@"state", nil];
                        break;
                    case 0x03:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"干烧报警",@"state", nil];
                        break;
                    case 0x04:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"电路异常",@"state", nil];
                        break;
                    case 0x05:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"无锅提醒",@"state", nil];
                        break;
                    case 0x06:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"电网电压异常",@"state", nil];
                        break;
                    case 0x07:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"电池电压异常",@"state", nil];
                        break;
                    case 0x08:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"精华煮",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"rice",[NSString stringWithFormat:@"%i",cmd_data[9]],@"feel",[NSString stringWithFormat:@"%i",cmd_data[10]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[11]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[12]],@"tem", nil];
                        break;
                    case 0x09:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"超快煮",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"rice",[NSString stringWithFormat:@"%i",cmd_data[9]],@"feel",[NSString stringWithFormat:@"%i",cmd_data[10]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[11]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[12]],@"tem", nil];
                        break;
                    case 0x0A:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"煮粥",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"feel",[NSString stringWithFormat:@"%i",cmd_data[9]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[10]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[11]],@"tem", nil];
                        break;
                    case 0x0B:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"蒸煮",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"feel",[NSString stringWithFormat:@"%i",cmd_data[9]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[10]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[11]],@"tem", nil];
                        break;
                    case 0x0C:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"热饭",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x0D:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"营养保温",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x0E:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"云菜谱",@"state",[self getCloudMenuName:data],@"name",[NSString stringWithFormat:@"%i",cmd_data[24]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[25]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[26]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[27]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[28]],@"rice",[NSString stringWithFormat:@"%i",cmd_data[29]],@"feel",[NSString stringWithFormat:@"%i",cmd_data[30]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[31]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[32]],@"tem", nil];
                        break;
                    case 0x0F:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"煲汤",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x10:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"偏好",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"rice",[NSString stringWithFormat:@"%i",cmd_data[9]],@"feel",[NSString stringWithFormat:@"%i",cmd_data[10]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[11]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[12]],@"tem", nil];
                        break;
                        
                    default:
                        break;
                }
                
            }
            break;
        case WATER_COOKER:
            if (cmd_data[0]==0x12||(cmd_data[0]==0x15&&cmd_data[3]!=0x09)||cmd_data[0]==0x14) {
                //筛选
                
                switch (cmd_data[3]) {
                    case 0x01:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"空闲",@"state", nil];
                        break;
                    case 0x02:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"传感器异常",@"state", nil];
                        break;
                    case 0x03:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"干烧状态",@"state", nil];
                        break;
                    case 0x04:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"炖煮",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x05:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"偏好",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x06:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"营养保温",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x07:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"煮粥",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x08:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"云菜谱",@"state",[self getCloudMenuName:data],@"name",[NSString stringWithFormat:@"%i",cmd_data[24]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[25]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[26]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[27]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[28]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[29]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[30]],@"tem", nil];
                        break;
                    default:
                        break;
                }
                
            }
            break;
        case CLOUD_KETTLE:
            if (cmd_data[0]==0x12||(cmd_data[0]==0x15&&cmd_data[3]!=0x08)||cmd_data[0]==0x14) {
                //筛选
                
                switch (cmd_data[3]) {
                    case 0x01:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"空闲",@"state", nil];
                        break;
                    case 0x02:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"传感器异常",@"state", nil];
                        break;
                    case 0x03:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"干烧状态",@"state", nil];
                        break;
                    case 0x04:
                        
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"煮水",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"chlorine",[NSString stringWithFormat:@"%i",cmd_data[9]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[10]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[11]],@"tem", nil];
                        break;
                    case 0x05:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"偏好",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x06:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"保温",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x07:
                        //云功能->云菜谱
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"云菜谱",@"state",
                             [self getCloudMenuName:data],@"name",
                             [NSString stringWithFormat:@"%i",cmd_data[24]],@"orderHour",
                             [NSString stringWithFormat:@"%i",cmd_data[25]],@"orderMin",
                             [NSString stringWithFormat:@"%i",cmd_data[26]],@"WorkHour",
                             [NSString stringWithFormat:@"%i",cmd_data[27]],@"WorkMin",
                             [NSString stringWithFormat:@"%i",cmd_data[28]],@"progress",
                             [NSString stringWithFormat:@"%i",cmd_data[29]],@"percent",
                             [NSString stringWithFormat:@"%i",cmd_data[30]],@"tem",
                             nil];
                        break;
                    default:
                        break;
                }
                
            }
            break;
        case WATER_COOKER_16AIG:
            if (cmd_data[0]==0x12||(cmd_data[0]==0x15&&cmd_data[3]!=0x09)||cmd_data[0]==0x14) {
                //筛选
                
                switch (cmd_data[3]) {
                    case 0x01:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"空闲",@"state", nil];
                        break;
                    case 0x02:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"传感器异常",@"state", nil];
                        break;
                    case 0x03:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"干烧状态",@"state", nil];
                        break;
                    case 0x04:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"炖煮",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    case 0x05:
                    case 0x06:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"云菜谱",@"state",
                             [self getCloudMenuName:data],@"name",
                             [NSString stringWithFormat:@"%i",cmd_data[24]],@"orderHour",
                             [NSString stringWithFormat:@"%i",cmd_data[25]],@"orderMin",
                             [NSString stringWithFormat:@"%i",cmd_data[26]],@"WorkHour",
                             [NSString stringWithFormat:@"%i",cmd_data[27]],@"WorkMin",
                             [NSString stringWithFormat:@"%i",cmd_data[28]],@"progress",
                             [NSString stringWithFormat:@"%i",cmd_data[29]],@"percent",
                             [NSString stringWithFormat:@"%i",cmd_data[30]],@"tem", nil];
                        break;
                    case 0x07:
                        dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"营养保温",@"state",[NSString stringWithFormat:@"%i",cmd_data[4]],@"orderHour",[NSString stringWithFormat:@"%i",cmd_data[5]],@"orderMin",[NSString stringWithFormat:@"%i",cmd_data[6]],@"WorkHour",[NSString stringWithFormat:@"%i",cmd_data[7]],@"WorkMin",[NSString stringWithFormat:@"%i",cmd_data[8]],@"progress",[NSString stringWithFormat:@"%i",cmd_data[9]],@"percent",[NSString stringWithFormat:@"%i",cmd_data[10]],@"tem", nil];
                        break;
                    default:
                        break;
                }
                
            }
            break;
        case CABINETS:  //厨物柜
            if (cmd_data[5]==0x12) {
                
                NSString *humidityStr=[NSString stringWithFormat:@"%i",cmd_data[9]];          //14  湿度
                NSString *temperatureStr=[NSString stringWithFormat:@"%i",cmd_data[10]];      //0D  温度
                NSString *typeStr=[NSString stringWithFormat:@"%i",cmd_data[11]];             //02  工作状态
                MyLog(@"储物区--湿度：%@,温度:%@,工作状态：%@",humidityStr,temperatureStr,typeStr);
                NSInteger workType=[typeStr integerValue];
                humidityStr=workType==3?@"0":humidityStr;
                temperatureStr=workType==3?@"0":temperatureStr;
                NSString *stateStr=[[StorageDeviceHelper sharedStorageDeviceHelper] getCabinetStateWithType:workType];
                
                NSString *riceHumidityStr=[NSString stringWithFormat:@"%i",cmd_data[12]];   //19  湿度
                NSString *outRiceStr=[NSString stringWithFormat:@"%i",cmd_data[13]];        //06  出米量
                NSString *lastRiceStr=[NSString stringWithFormat:@"%i",cmd_data[14]];       //46  剩余米量
                NSString *riceWorkTypeStr=[NSString stringWithFormat:@"%i",cmd_data[15]];   //02 工作状态
                NSString *riceWorkAbnormalTypeStr=[NSString stringWithFormat:@"%i",cmd_data[16]];   //02 异常状态
                MyLog(@"储米区--湿度：%ld,出米量:%ld, 剩余米量:%@,工作状态：%ld",(long)[riceHumidityStr integerValue],(long)[outRiceStr integerValue],lastRiceStr,[riceWorkTypeStr integerValue]);
                NSInteger abnormalType=[riceWorkAbnormalTypeStr integerValue];
                riceHumidityStr=abnormalType==1?@"0":riceHumidityStr;
                outRiceStr=abnormalType==3?@"0":outRiceStr;
                lastRiceStr=abnormalType==2?@"0":lastRiceStr;
                
                dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:stateStr,@"state",typeStr,@"workType",humidityStr,@"humidity",temperatureStr,@"temperature",riceHumidityStr,@"riceHumidity",outRiceStr,@"outRice",lastRiceStr,@"lastRice",riceWorkTypeStr,@"riceWorkState",nil];
            }
            break;
        default:
            break;

    }
    return dic;
}

/**
 *  根据云炖锅阶段命令获取阶段名称
 *
 *  @param progress 命令
 *
 *  @return 名称
 */
+(NSString *)getCloudCookerProgressStrWithProgress:(NSString *)progress{
    NSString *progressStr;
    int pro=progress.intValue;
    switch (pro) {
        case PRO_ORDER:
            progressStr=@"预约阶段";
            break;
        case PRO_WARMING:
            progressStr=@"升温阶段";
            break;
        case PRO_LITTLE_FIRE:
            progressStr=@"小火精炖阶段";
            break;
        case PRO_CONSTANT_TEM:
            progressStr=@"恒温精炖阶段";
            break;
        case PRO_BIG_FIRE:
            progressStr=@"大火快炖阶段";
            break;
        case PRO_LITTLE_FIR_SLOW:
            progressStr=@"小火慢熬";
            break;
        case PRO_COOLING:
            progressStr=@"降温阶段";
            break;
        case PRO_KEEP_TEM:
            progressStr=@"营养保温阶段";
            break;
        default:
            break;
    }
    
    return progressStr;
}


/**
 *  根据电饭煲阶段命令获取阶段名称
 *
 *  @param progress 命令
 *
 *  @return 名称
 */
+(NSString *)getElectricCookerProgressStrWithProgress:(NSString *)progress{
    NSString *progressStr;
    int pro=progress.intValue;
    
    switch (pro) {
        case 0x01:
            progressStr=@"预约阶段";
            break;
        case 0x02:
            progressStr=@"小火吸水";
            break;
        case 0x03:
            progressStr=@"大火加热";
            break;
        case 0x05:
            progressStr=@"沸腾维持";
            break;
        case 0x06:
            progressStr=@"焖饭";
            break;
        case 0x07:
            progressStr=@"降温";
            break;
        case 0x08:
            progressStr=@"恒温精煮";
            break;
        case 0x09:
            progressStr=@"恒温烘烤";
            break;
        case 0x0A:
            progressStr=@"小火精熬";
            break;
        case 0x0B:
            progressStr=@"小火精炖";
            break;
        case 0x0C:
            progressStr=@"恒温炖煮";
            break;
        case 0x0D:
            progressStr=@"恒温发酵";
            break;
        case 0x0E:
            progressStr=@"小火蒸煮";
            break;
        case 0x0F:
            progressStr=@"营养保温";
            break;
        default:
            break;
    }
    
    return progressStr;
}


/**
 *  根据隔水炖阶段命令获取阶段名称
 *
 *  @param progress 命令
 *
 *  @return 名称
 */
+(NSString *)getWaterCookerProgressStrWithProgress:(NSString *)progress{
    NSString *progressStr;
    int pro=progress.intValue;
    switch (pro) {
        case 0x01:
            progressStr=@"预约阶段";
            break;
        case 0x02:
            progressStr=@"升温阶段";
            break;
        case 0x03:
            progressStr=@"小沸精炖阶段";
            break;
        case 0x05:
            progressStr=@"恒温精炖阶段";
            break;
        case 0x06:
            progressStr=@"沸腾快炖阶段";
            break;
        case 0x07:
            progressStr=@"降温阶段";
            break;
        case 0x08:
            progressStr=@"营养保温阶段";
            break;
        default:
            break;
    }
    
    return progressStr;
}

/**
 *  根据隔水炖16AIG阶段命令获取阶段名称
 *
 *  @param progress 命令
 *
 *  @return 名称
 */
+(NSString *)getWaterCooker16AIGProgressStrWithProgress:(NSString *)progress{
    NSString *progressStr;
    int pro=progress.intValue;
    switch (pro) {
        case 0x01:
            progressStr=@"预约阶段";
            break;
        case 0x02:
            progressStr=@"升温阶段";
            break;
        case 0x03:
            progressStr=@"小沸精炖阶段";
            break;
        case 0x05:
            progressStr=@"恒温精炖阶段";
            break;
        case 0x06:
            progressStr=@"沸腾快炖阶段";
            break;
        case 0x07:
            progressStr=@"降温阶段";
            break;
        case 0x08:
            progressStr=@"营养保温阶段";
            break;
        default:
            break;
    }
    
    return progressStr;
}
/**
 *  根据炒菜锅阶段命令获取阶段名称
 *
 *  @param progress 命令
 *
 *  @return 名称
 */
+(NSString *)getCookFoodProgressStrWithProgress:(NSString *)progress{
    NSString *progressStr;
    int pro=progress.intValue;
    switch (pro) {
        case 0x01:
            progressStr=@"预约阶段";
            break;
        case 0x02:
            progressStr=@"烹饪阶段";
            break;
        case 0x03:
            progressStr=@"烹饪开锅阶段";
            break;
        case 0x04:
            progressStr=@"收汁阶段";
            break;
        case 0x05:
            progressStr=@"收汁开锅阶段";
            break;
        case 0x06:
            progressStr=@"工作完成阶段";
            break;
        case 0x07:
            progressStr=@"保温阶段";
            break;
        default:
            break;
    }
    
    return progressStr;
}

/**
 *  根据云水壶阶段命令获取阶段名称
 *
 *  @param progress 命令
 *
 *  @return 名称
 */
+(NSString *)getCloudKettleProgressStrWithProgress:(NSString *)progress{
    NSString *progressStr;
    int pro=progress.intValue;
    switch (pro) {
        case 0x01:
            progressStr=@"预约阶段";
            break;
        case 0x02:
            progressStr=@"升温阶段";
            break;
        case 0x03:
            progressStr=@"沸腾阶段";
            break;
        case 0x04:
            progressStr=@"除氯阶段";
            break;
        case 0x05:
            progressStr=@"大火阶段";
            break;
        case 0x06:
            progressStr=@"小火阶段";
            break;
        case 0x07:
            progressStr=@"恒温阶段";
            break;
        case 0x08:
            progressStr=@"保温阶段";
            break;
        default:
            break;
    }
    
    return progressStr;
}

///从本地中删除某个mac地址的设备
+(void)deleteDeviceFromLocal:(NSString*)mac{
    
    NSString *key=[mac stringByAppendingString:@"name"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];//删除本地名字
    
    NSMutableArray *deviceArr = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"devices"]];
    
    
    for (int i=0;i<deviceArr.count;i++) {
        NSDictionary *dic =[deviceArr objectAtIndex:i];
        if ([[dic objectForKey:@"macAddress"] isEqualToString:mac]) {
            
            if ([[dic objectForKey:@"productID"]isEqualToString:CLOUD_KETTLE_PRODUCT_ID]) {
                //如果是私享壶，就要删除提醒
                YTKKeyValueStore *ytkHelper=[[YTKKeyValueStore alloc]initDBWithName:@"TJProduct.db"];
                
                //查询条件
                NSDictionary *queryDic=@{@"deviceid":@{@"$in":@[[NSString stringWithFormat:@"%@",[dic objectForKey:@"macAddress"]]]}};
                NSDictionary *sqlDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",queryDic,@"query", nil];
                [ytkHelper removeData:[Transform DataToJsonString:sqlDic]];
                NSDictionary *sqlPlanDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_PLAN_TABLE,@"table",queryDic,@"query", nil];
            }else if ([[dic objectForKey:@"productID"]isEqualToString:THERMOMETER_PRODUCT_ID]){
                
                //停止检测测量结果
                BLEDeviceModel *bleDevice;
                for (DeviceModel *model in [AutoLoginManager shareManager].getDeviceModelArr) {
                    if ([model isMemberOfClass:[BPMeterModel class]] || [model isMemberOfClass:[ThermometerModel class]]) {
                        if ([((BLEDeviceModel *)model).BLEMacAddress isEqualToString:mac]) {
                            bleDevice = (BLEDeviceModel *)model;
                            [[MeasurementsManager shareManager] stopCheckBLEAddress:((BLEDeviceModel *)model).BLEMacAddress];
                            break;
                        }
                    }
                }
                //体温计需要删除本地数据库
                NSString *userID=[NSString stringWithFormat:@"%@", [[NSUserDefaultInfos getValueforKey:USER_DIC] valueForKey:@"user_id"]];
                [[DBManager shareManager] deleteAllBodyTempRecords:(ThermometerModel *)bleDevice loginUserId:userID.integerValue];
                
                //删除设备历史数据
                [[DBManager shareManager] deleteAllBodyTempRecords:(ThermometerModel *)bleDevice loginUserId:0];
                
            }else if ([[dic objectForKey:@"productID"]isEqualToString:CLINK_BPM_PRODUCT_ID]){
                
                //停止检测测量结果
                BLEDeviceModel *bleDevice;
                for (DeviceModel *model in [AutoLoginManager shareManager].getDeviceModelArr) {
                    if ([model isMemberOfClass:[BPMeterModel class]] || [model isMemberOfClass:[ThermometerModel class]]) {
                        if ([((BLEDeviceModel *)model).BLEMacAddress isEqualToString:mac]) {
                            bleDevice = (BLEDeviceModel *)model;
                            [[MeasurementsManager shareManager] stopCheckBLEAddress:((BLEDeviceModel *)model).BLEMacAddress];
                            
                            break;
                        }
                    }
                }
                //血压计需要删除本地数据库
                NSString *userID=[NSString stringWithFormat:@"%@", [[NSUserDefaultInfos getValueforKey:USER_DIC] valueForKey:@"user_id"]];
                    //删除用户历史数据
                [[DBManager shareManager] deleteAllBPRecords:(BPMeterModel *)bleDevice loginUserId:userID.integerValue];
               
                //删除设备历史数据
                [[DBManager shareManager] deleteAllBPRecords:(BPMeterModel *)bleDevice loginUserId:0];
            }
            
            
            [deviceArr removeObject:dic];
            break;
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:deviceArr forKey:@"devices"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (void)removeRemindsOfMac:(NSString *)mac{
    YTKKeyValueStore *ytkHelper=[[YTKKeyValueStore alloc]initDBWithName:@"TJProduct.db"];
    NSDictionary *queryDic=@{@"deviceid":@{@"$in":@[[NSString stringWithFormat:@"%@",mac]]}};
    NSDictionary *sqlDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",queryDic,@"query", nil];
    [ytkHelper removeData:[Transform DataToJsonString:sqlDic]];
    NSDictionary *sqlPlanDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_PLAN_TABLE,@"table",queryDic,@"query", nil];
    [ytkHelper removeData:[Transform DataToJsonString:sqlPlanDic]];
}

#pragma mark - 删除一个云水壶的所有饮水计划
+ (void)removeAllRemindOfMac:(NSString *)mac{
    YTKKeyValueStore *ytkHelper=[[YTKKeyValueStore alloc]initDBWithName:@"TJProduct.db"];
    //1.获取mac所有的饮水计划
    //排序条件
    NSDictionary *orderDic=[[NSDictionary alloc]initWithObjectsAndKeys:@"asc",@"time", nil];
    //查询条件
    NSDictionary *queryDic=@{@"deviceid":@{@"$in":@[mac]}};
    
    NSDictionary *sqlDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",orderDic,@"order",queryDic,@"query", nil];
    
    NSDictionary *resultDic=[ytkHelper queryDataWithJSON:[Transform DataToJsonString:sqlDic]];
    
    NSMutableArray *reminds=[resultDic objectForKey:@"list"];
    
    //2.for循环删除
    for (NSDictionary *dic in reminds) {
        
        NSInteger remindID = [[dic objectForKey:@"id"] integerValue];
        
        NSDictionary *queryDic=@{@"deviceid":@{@"$in":@[mac]},@"id":@{@"$in":@[[NSString stringWithFormat:@"%li",(long)remindID]]}};
        
        
        NSDictionary *sqlDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",queryDic,@"query", nil];
        
        [ytkHelper removeData:[Transform DataToJsonString:sqlDic]];
    }
}

+(NSMutableArray *)getDeviceDicList:(NSArray *)list{
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    for (NSDictionary *dic in list) {
        NSMutableDictionary *mdic=[NSMutableDictionary dictionary];
        NSString *productId = dic[@"product_id"];
        if (![productId isEqualToString:LOWERSUGARCOOKER_PRODUCT_ID]) {
            NSString *deviceName;
            NSString *deviceValue=[dic objectForKey:[dic[@"mac"] stringByAppendingString:@"name"]];
            if (!kIsEmptyString(deviceValue)&&![deviceValue isEqualToString:@"未知设备"]) {
                deviceName=deviceValue;
                MyLog(@"mac--name:%@",deviceName);
            }else{
                if ([productId isEqualToString:WATER_COOKER_PRODUCT_ID]) {
                    deviceName=@"云智能隔水炖";
                }else if ([productId isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]){
                    deviceName=@"云智能隔水炖16AIG";
                }else if ([productId isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]){
                    deviceName=@"云智能IH电饭煲";
                }else if ([productId isEqualToString:CLOUD_COOKER_PRODUCT_ID]){
                    deviceName=@"云智能电炖锅";
                } else if ([productId isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]){
                    deviceName=@"云智能健康大厨";
                }else if ([productId isEqualToString:CLOUD_KETTLE_PRODUCT_ID]) {
                    deviceName = @"云智能私享壶";
                }else if ([productId isEqualToString:THERMOMETER_PRODUCT_ID]) {
                    deviceName = @"蓝牙智能体温贴";
                } else if ([productId isEqualToString:CLINK_BPM_PRODUCT_ID]) {
                    deviceName = @"蓝牙智能血压计";
                } else if ([productId isEqualToString:SCALE_PRODUCT_ID]) {
                    deviceName = @"体质健康分析仪";
                } else if ([productId isEqualToString:CABINETS_PRODUCT_ID])  {
                    deviceName = @"智能厨物柜";
                }
            }
            
            
            [mdic setValue:@"" forKey:@"mcuHardVersion"];
            [mdic setValue:deviceName forKey:@"deviceName"];
            [mdic setValue:dic[@"id"] forKey:@"deviceID"];
            [mdic setValue:dic[@"product_id"] forKey:@"productID"];
            [mdic setValue:@"" forKey:@"mcuSoftVersion"];
            [mdic setValue:dic[@"mac"]  forKey:@"macAddress"];
            [mdic setValue:dic[@"mcu_version"] forKey:@"version"];
            [mdic setValue:[NSNumber numberWithBool:TRUE] forKey:@"deviceInit"];
            [mdic setValue:dic[@"access_key"] forKey:@"accessKey"];
            NSInteger roleInt=[dic[@"role"] integerValue];
            [mdic setValue:[NSNumber numberWithInteger:roleInt] forKey:@"role"];// 判断是否是管理员
            [arr addObject:mdic];
        }
        
    }
    return arr;
}

+(NSString *)getDeviceTypeFromDeviceID:(NSNumber *)deviceID{
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"devices"];
    for (NSDictionary *dict in arr) {
        NSInteger device_id=[[dict objectForKey:@"deviceID"] integerValue];
        if (device_id==[deviceID integerValue]) {
            if ([[dict objectForKey:@"productID"] isEqualToString:CLOUD_COOKER_PRODUCT_ID]) {
                //云炖锅
                return @"云智能电炖锅";
            }else   if ([[dict objectForKey:@"productID"]isEqualToString:WATER_COOKER_PRODUCT_ID]) {
                //隔水炖
                return @"云智能隔水炖";
            }else   if ([[dict objectForKey:@"productID"]isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]) {
                //隔水炖16AIG
                return @"云智能隔水炖16AIG";
            }else   if ([[dict objectForKey:@"productID"]isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]) {
                //炒菜锅
                return @"云智能健康大厨";
            }else   if ([[dict objectForKey:@"productID"]isEqualToString:CLOUD_KETTLE_PRODUCT_ID]) {
                //私享壶
                return @"云智能私享壶";
            }else if  ([[dict objectForKey:@"productID"]isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]){
                //电饭煲
                return @"云智能电饭煲";
            }else if  ([[dict objectForKey:@"productID"]isEqualToString:CABINETS_PRODUCT_ID]){
                //电饭煲
                return @"智能厨物柜";
            }
        }
        
    }
    return nil;
}

///NSData的云菜谱名称转换为NSString的云菜谱名称
+(NSString *)getCloudMenuName:(NSData *)data{
    
    
    uint8_t cmd_data[[data length]];
    uint32_t cmd_len = (uint32_t)[data length];
    memset(cmd_data, 0, [data length]);
    [data getBytes:(void *)cmd_data length:cmd_len];
    
    NSString *PreferenceInfo=@"";
    
    //云菜谱
    //获取云菜谱名称方法1
    int index = 27;
    int endCount = 0;//@"|"出现的次数，倒数第三次为名称结束符
    for (; index>0; index--) {
        if ([[NSString stringWithFormat:@"%C",(unichar)cmd_data[index]] isEqualToString:@"|"]) {
            endCount ++;
            if (endCount == 3) {
                break;
            }
        }
    }
    for (int i=6;i<index;i++) {
        int acciiCode=cmd_data[i]*256+cmd_data[i+1];
        i++;
        
        PreferenceInfo=[PreferenceInfo stringByAppendingString:[NSString stringWithFormat:@"%C",(unichar)acciiCode]];
    }
    
    if (index <= 0) {
        //获取云菜谱名称方法2
        for (int i=4;i<23;i++) {
            
            if ([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"\0"]) {
                break;
            }
            
            
            int acciiCode=cmd_data[i]*pow(16, 2)+cmd_data[i+1];
            i++;
            PreferenceInfo=[PreferenceInfo stringByAppendingString:[NSString stringWithFormat:@"%C",(unichar)acciiCode]];
        }
    }

    return PreferenceInfo;
}

//设置一段文本的位置的字体大小、偏移水平基线的位置 （number大于0偏上）
+ (void)setTextOnRange:(NSRange)range onLabel:(UILabel *)label toFont:(UIFont *)font andBaselineOffset:(NSNumber *)number {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    [str addAttribute:NSFontAttributeName value:font range:range];
    [str addAttribute:NSBaselineOffsetAttributeName value:number range:range];
    label.attributedText = str;
}


@end
