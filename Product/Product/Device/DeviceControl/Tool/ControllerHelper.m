//
//  ControllerHelper.m
//  Product
//
//  Created by Xlink on 16/1/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "ControllerHelper.h"
#import "XLinkExportObject.h"
#import "DeviceHelper.h"
#import "Transform.h"
#import "SVProgressHUD.h"
#import "NSData+Extension.h"
#import "DeviceConnectStateCheckService.h"
#import "NSUserDefaultInfos.h"


@implementation ControllerHelper
+(instancetype)shareHelper{
    @synchronized (self) {
        static ControllerHelper *Helper = nil;
        if (Helper == nil) {
            Helper = [[[self class] alloc]init];
        }
        return Helper;
    }
}

///删除旧DeviceEntity，添加新DeviceEntity 
-(void)insertConnectArr:(DeviceEntity *)device{
    if (_connectedArr==nil) {
        _connectedArr=[[NSMutableArray alloc]init];
    }
    
    @synchronized (self) {
        [_connectedArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj getMacAddressSimple] isEqualToString:[device getMacAddressSimple]]) {
                *stop = YES;
                if (*stop == YES) {
                    [_connectedArr removeObjectAtIndex:idx];
                }
            }
        }];
        [_connectedArr addObject:device];
    }
}

-(void)removeConnectArr:(DeviceEntity *)device{
    @synchronized (self) {
        [_connectedArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj getMacAddressSimple] isEqualToString:[device getMacAddressSimple]]) {
                
                *stop = YES;
                
                if (*stop == YES) {
                    [_connectedArr removeObject:obj];
                }
                
            }
            
        }];
    }
    
}

-(DeviceEntity *)getNeedControllDevice:(NSString *)mac{
    @synchronized (self) {
        DeviceEntity *device=nil;
        for (DeviceEntity *d in _connectedArr) {
            if ([[d getMacAddressSimple] isEqualToString:mac]) {
                return device=d;
            }
        }
        return device;
    }
}


-(void)conncetDevice:(DeviceModel *)model{
    DeviceEntity *device=[DeviceHelper getDeviceFromLocalWithMacAddr:model.mac];
    if (device) {
        [[XLinkExportObject sharedObject]initDevice:device];
        [[XLinkExportObject sharedObject]connectDevice:device andAuthKey:device.accessKey];
    }
}

-(int)getDeviceState:(DeviceModel *)model{
    NSData * Data;
    if ([model.productID isEqualToString:CABINETS_PRODUCT_ID]) {
        Data=[Transform nsstringToHex:@"0000000000120000"];
    }else{
        Data=[Transform nsstringToHex:@"120000"];
    }
    
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        MyLog(@"发送查询设备(%@)状态>>：%@", device.getMacAddressSimple,[Data hexString]);
        if (device.connectStatus&ConnectStatusWANConnectSuccessfully) {
            return [[XLinkExportObject sharedObject] sendPipeData:device andPayload:Data];
        }else{
            return [[XLinkExportObject sharedObject] sendLocalPipeData:device andPayload:Data];
        }
    }
    return -1;
}


-(void)getCurrentPreference:(DeviceModel *)model{
    [SVProgressHUD show];
    if (self.overTimeTimer) {
        [self.overTimeTimer invalidate];
        self.overTimeTimer=nil;
    }
    
    self.overTimeTimer =[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(getPreferenceOverTime) userInfo:nil repeats:NO];
    
    NSData * Data;
    if (model.deviceType!=CLOUD_KETTLE&&model.deviceType!=COOKFOOD_KETTLE) {
        Data=[Transform nsstringToHex:@"110000"];
    }else{
        Data=[Transform nsstringToHex:@"11000005"];
    }
    
    
    
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:Data];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:Data];
        }
    }
}

-(void)getCurrentPreference:(DeviceModel *)model andString:(NSString *)preferenceString{
    NSData * Data;
    if (model.deviceType!=CLOUD_KETTLE&&model.deviceType!=COOKFOOD_KETTLE) {
        Data=[Transform nsstringToHex:@"110000"];
        if ([preferenceString isEqualToString:@"降压粥"]) {
            Data=[Transform nsstringToHex:@"11000005"];
        }else if ([preferenceString isEqualToString:@"降压汤"]) {
            Data=[Transform nsstringToHex:@"11000006"];
        }
    }else{
        Data=[Transform nsstringToHex:@"11000005"];
    }
    MyLog(@"获取（%@）%@偏好－－－data:%@",model.deviceName,preferenceString,[Data hexString]);
    
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:Data];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:Data];
        }
    }
}

-(void)controllDevice:(DeviceModel *)model{
    [SVProgressHUD show];
    
    if (self.overTimeTimer) {
        [self.overTimeTimer invalidate];
        self.overTimeTimer=nil;
    }
    
    self.overTimeTimer =[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(sendControllCommandOverTime) userInfo:nil repeats:NO];
    
    switch (model.deviceType) {
        case CLOUD_COOKER:
            [self sendCommandToCloudCooker:model];
            break;
        case WATER_COOKER:
            [self sendCommandToWaterCooker:model];
            break;
        case ELECTRIC_COOKER:
            [self sendCommandToElectricCooker:model];
            break;
        case CLOUD_KETTLE:
            [self sendCommandToCloudKettle:model];
            break;
        case WATER_COOKER_16AIG:
            [self sendCommandToWaterCooker16A:model];
            break;
        case COOKFOOD_KETTLE:
            [self sendCookFoodToElectricCooker:model];
            break;
        default:
            break;
    }
}

#pragma mark 私享壶属性
-(void)setDeviceAttribute:(DeviceModel *)model{
    [SVProgressHUD show];
    
    if (self.overTimeTimer) {
        [self.overTimeTimer invalidate];
        self.overTimeTimer=nil;
    }
    
    self.overTimeTimer =[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(sendControllCommandOverTime) userInfo:nil repeats:NO];
    
    NSString *commandStr=@"130000";
    NSString *commandType=[model.Attribute objectForKey:@"attribute"];
    if ([commandType isEqualToString:@"煮水"]) {
        NSString *chlorine=[model.Attribute objectForKey:@"chlorine"];
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"04%@",chlorine]];
    }else{
        
        int tem = [[model.Attribute objectForKey:@"tem"] intValue];
        NSString *temStr = [NSString stringWithFormat:@"%02X",tem];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"06%@",temStr]];
        
    }
    
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"Set Attribute Data Transmit send: %@",[sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
}

-(void)getDeviceAttribute:(DeviceModel *)model{
    [SVProgressHUD show];
    
    if (self.overTimeTimer) {
        [self.overTimeTimer invalidate];
        self.overTimeTimer=nil;
    }
    
    self.overTimeTimer =[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(getPreferenceOverTime) userInfo:nil repeats:NO];
    
    NSData * TemData;
    TemData=[Transform nsstringToHex:@"11000006"]; //温度
    
    NSLog(@"Get Attribute Data Transmit send: %@", [TemData hexString]);
    
    NSData *chlorineData=[Transform nsstringToHex:@"11000004"];//除氯
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:TemData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:TemData];
        }
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:chlorineData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:chlorineData];
        }
    }
}


-(void)setDevicePreference:(DeviceModel *)model{
    
    [SVProgressHUD show];
    
    if (self.overTimeTimer) {
        [self.overTimeTimer invalidate];
        self.overTimeTimer=nil;
    }
    
    self.overTimeTimer =[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(getPreferenceOverTime) userInfo:nil repeats:NO];
    
    switch (model.deviceType) {
        case CLOUD_COOKER:
            [self sendPreferenceCommandToCloundCooker:model];
            break;
        case WATER_COOKER:
            [self sendPreferenceCommandToWaterCooker:model];
            break;
        case ELECTRIC_COOKER:
            [self sendPreferenceCommandToElectricCooker:model];
            break;
        case CLOUD_KETTLE:
            [self sendPreferenceCommandToCloudKettle:model];
            break;
        case COOKFOOD_KETTLE:
            [self sendPreferenceCommandToCookFoodCooker:model];
            break;
        case WATER_COOKER_16AIG:
            [self sendPreferenceCommandToWaterCooker16AIGCooker:model];
            break;

        default:
            break;
    }
}
-(void)sendControllCommandOverTime{
    [SVProgressHUD showErrorWithStatus:@"发送失败"];
}

-(void)getPreferenceOverTime{
    [SVProgressHUD showErrorWithStatus:@"获取偏好失败"];
}


#pragma mark 云炖锅
-(void)sendCommandToCloudCooker:(DeviceModel *)model{
    NSString *commandType=[model.State objectForKey:@"state"];
    NSString *commandStr=@"140000";
    if ([commandType isEqualToString:@"空闲"]) {
        commandStr=[commandStr stringByAppendingString:@"01"];
        
    }else if ([commandType isEqualToString:@"炖汤"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=[NSString stringWithFormat:@"%02X",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = [NSString stringWithFormat:@"%02X",workmin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",orderHour,orderMin,workHour,workMin]];
        
    }else if ([commandType isEqualToString:@"偏好"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"05",orderHour,orderMin]];
        
    }else if ([commandType isEqualToString:@"营养保温"]){
        
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"06",orderHour,orderMin]];
    }else if ([commandType isEqualToString:@"煮粥"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        NSString *feel=@"00";   //口感
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@",@"07",orderHour,orderMin,feel]];
    }else if ([commandType isEqualToString:@"云菜谱"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"08",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"%@",[model.State objectForKey:@"cloudMenu"]];
        
        commandStr=[commandStr stringByAppendingString:controlStr];

    }
    
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"云炖锅(%@)发送>>命令: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
}

-(void)sendPreferenceCommandToCloundCooker:(DeviceModel *)model{
    NSString *commandStr=@"13000005";
    NSString *commandType=[model.State objectForKey:@"state"];
    if ([commandType isEqualToString:@"炖汤"]) {
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=workhour<10?[NSString stringWithFormat:@"0%i",workhour]:[NSString stringWithFormat:@"%i",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = workmin<10?[NSString stringWithFormat:@"0%i",workmin]:[NSString stringWithFormat:@"%i",workmin];
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,workHour,workMin]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"030264560041023256%@%@03193e1800",[NSString stringWithFormat:@"%02X",workhour],[NSString stringWithFormat:@"%02X",workmin]];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
    }else if([commandType isEqualToString:@"保温"] || [commandType isEqualToString:@"营养保温"]){
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",@"营养保温",@"99",@"99"]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"0205643e010003193e18"];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"煮粥"]){
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,@"99",@"99"]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"02016456011903193e18"];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"云菜谱"]){
        
        NSString *controlStr= [model.State objectForKey:@"cloudMenu"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }
    
    
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"云炖锅(%@)发送>>偏好: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
}
#pragma mark 炒菜锅
-(void)sendCookFoodToElectricCooker:(DeviceModel *)model{
    
    NSString *commandType=[model.State objectForKey:@"state"];
    NSString *foodStr=[model.State objectForKey:@"FoodMenuName"];
    NSString *commandStr=@"140000";
    
    if ([commandType isEqualToString:@"空闲"]) {
        commandStr=[commandStr stringByAppendingString:@"01"];
        
    }
    else if ([commandType isEqualToString:@"手动烹饪"]){
        
        NSArray *array = [[NSArray alloc] initWithObjects:@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"0A", nil];
        
        int WorkHour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=[NSString stringWithFormat:@"%02X",WorkHour];
        
        int WorkMin=[[model.State objectForKey:@"WorkMin"]intValue];
        NSString *workMin=[NSString stringWithFormat:@"%02X",WorkMin];
        
        NSString *FireStr=[model.State objectForKey:@"firetext"];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@%@",@"03",@"01",@"01",workHour,workMin,array[[FireStr intValue]]]];
    }else if ([commandType isEqualToString:@"偏好"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"05",orderHour,orderMin]];
        
    }else if ([commandType isEqualToString:@"云菜谱"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        NSString *controlStr=[NSString stringWithFormat:@"%@",[model.State objectForKey:@"cloudMenu"]];

        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@",@"06",controlStr,orderHour,orderMin]];

    }
    else if ([commandType isEqualToString:@"一键烹饪"]){
        
        if ([foodStr isEqualToString:@"三杯鸡"]) {
            
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"02",@"10",orderHour,orderMin]];
            
        } else if ([foodStr isEqualToString:@"黄焖鸡"]){
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"03",@"04",orderHour,orderMin]];
            
        }else if ([foodStr isEqualToString:@"红烧鱼"]){
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"04",@"03",orderHour,orderMin]];
        }else if ([foodStr isEqualToString:@"红焖排骨"]){
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"05",@"15",orderHour,orderMin]];
            
        }else if ([foodStr isEqualToString:@"清炖鸡"]){
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"06",@"11",orderHour,orderMin]];
        }else if ([foodStr isEqualToString:@"老火汤"]){
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"07",@"07",orderHour,orderMin]];
        }else if ([foodStr isEqualToString:@"红烧肉"]){
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"08",@"05",orderHour,orderMin]];
        }else if ([foodStr isEqualToString:@"东坡肘子"]){
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"09",@"06",orderHour,orderMin]];
        }else if ([foodStr isEqualToString:@"口水鸡"]){
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"0a",@"12",orderHour,orderMin]];
            
        }else if ([foodStr isEqualToString:@"滑香鸡"]){
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"0b",@"14",orderHour,orderMin]];
            
        }else if ([foodStr isEqualToString:@"茄子煲"]){
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"0c",@"02",orderHour,orderMin]];
            
        }else if ([foodStr isEqualToString:@"梅菜扣肉"]){
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",@"0d",@"17",orderHour,orderMin]];
            
        }
    }
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"炒菜锅(%@)发送>>命令: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
            
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
        
    }
}
-(void)sendPreferenceCommandToCookFoodCooker:(DeviceModel *)model{
    
    NSString *commandStr=@"13000005";
    NSString *commandType=[model.State objectForKey:@"state"];
    if ([commandType isEqualToString:@"黄焖鸡"]) {
        
        NSString *controlStr=[NSString stringWithFormat:@"407C9ec471169e217C30307C30307C000000000004"];
        commandStr=[commandStr stringByAppendingString:controlStr];
    }else if([commandType isEqualToString:@"三杯鸡"]){
        
        NSString *controlStr=[NSString stringWithFormat:@"407C4e09676f9e217C30307C30307C000000000010"];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if([commandType isEqualToString:@"红烧鱼"]){
        
        NSString *controlStr=[NSString stringWithFormat:@"407C7ea270e79c7c7C30307C30307C000000000003"];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if([commandType isEqualToString:@"红焖排骨"]){
        
        NSString *controlStr=[NSString stringWithFormat:@"407C7ea2711663929aa87C30307C30307C00000015"];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if([commandType isEqualToString:@"清炖鸡"]){
        
        NSString *controlStr=[NSString stringWithFormat:@"407C6e0570969e217C30307C30307C000000000011"];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if([commandType isEqualToString:@"老火汤"]){
        
        NSString *controlStr=[NSString stringWithFormat:@"407C8001706b6c647C30307C30307C000000000007"];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if([commandType isEqualToString:@"红烧肉"]){
        
        NSString *controlStr=[NSString stringWithFormat:@"407C7ea270e780897C30307C30307C000000000005"];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if([commandType isEqualToString:@"东坡肘子"]){
        
        NSString *controlStr=[NSString stringWithFormat:@"407C4e1c576180985b507C30307C30307C00000006"];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if([commandType isEqualToString:@"口水鸡"]){
        
        
        NSString *controlStr=[NSString stringWithFormat:@"407C53e36c349e217C30307C30307C000000000012"];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if([commandType isEqualToString:@"滑香鸡"]){
        
        
        NSString *controlStr=[NSString stringWithFormat:@"407C6ed199999e217C30307C30307C000000000014"];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if([commandType isEqualToString:@"茄子煲"]){
        
        
        NSString *controlStr=[NSString stringWithFormat:@"407C83045b5071727C30307C30307C000000000002"];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if([commandType isEqualToString:@"梅菜扣肉"]){
        
        
        NSString *controlStr=[NSString stringWithFormat:@"407C688583dc626380897C30307C30307C00000017"];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"云菜谱"]){
        
        NSString *controlStr= [model.State objectForKey:@"cloudMenu"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
    }
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"云炖锅(%@)发送>>偏好: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
    
    
}

#pragma mark 隔水炖
-(void)sendCommandToWaterCooker:(DeviceModel *)model{
    
    NSString *commandType=[model.State objectForKey:@"state"];
    NSString *commandStr=@"140000";
    if ([commandType isEqualToString:@"空闲"]) {
        commandStr=[commandStr stringByAppendingString:@"01"];
        
    }else if ([commandType isEqualToString:@"炖煮"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=[NSString stringWithFormat:@"%02X",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = [NSString stringWithFormat:@"%02X",workmin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",orderHour,orderMin,workHour,workMin]];
        
    }else if ([commandType isEqualToString:@"偏好"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"05",orderHour,orderMin]];
        
    }else if ([commandType isEqualToString:@"营养保温"]){
        
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"06",orderHour,orderMin]];
    }else if ([commandType isEqualToString:@"云菜谱"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"08",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"%@",[model.State objectForKey:@"cloudMenu"]];
        
        commandStr=[commandStr stringByAppendingString:controlStr];

    }
    
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"隔水炖(%@)发送>>命令: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
}

-(void)sendPreferenceCommandToWaterCooker:(DeviceModel *)model{
    NSString *commandStr=@"13000005";
    NSString *commandType=[model.State objectForKey:@"state"];
    if ([commandType isEqualToString:@"炖煮"]) {
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=workhour<10?[NSString stringWithFormat:@"0%i",workhour]:[NSString stringWithFormat:@"%i",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = workmin<10?[NSString stringWithFormat:@"0%i",workmin]:[NSString stringWithFormat:@"%i",workmin];
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,workHour,workMin]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"030164560A00043256%@%@03284218",[NSString stringWithFormat:@"%02X",workhour],[NSString stringWithFormat:@"%02X",workmin]];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
    }else if([commandType isEqualToString:@"保温"] || [commandType isEqualToString:@"营养保温"]){
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",@"营养保温",@"99",@"99"]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"020564420A0003284218"];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"云菜谱"]){
        
        NSString *controlStr= [model.State objectForKey:@"cloudMenu"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"隔水炖(%@)发送>>偏好: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
}

#pragma mark 电饭煲
-(void)sendCommandToElectricCooker:(DeviceModel *)model{
    
    NSString *commandType=[model.State objectForKey:@"state"];
    NSString *commandStr=@"140000";
    if ([commandType isEqualToString:@"空闲"]) {
        commandStr=[commandStr stringByAppendingString:@"01"];
        
    }else if ([commandType isEqualToString:@"精华煮"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        int feel=[[model.State objectForKey:@"feel"] intValue]+1;
        NSString *feelStr=[NSString stringWithFormat:@"%02X",feel];
        
        NSString *riceFellStr=@"00";
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"08",orderHour,orderMin,riceFellStr,feelStr]];
        
    }else if ([commandType isEqualToString:@"超快煮"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        NSString *feelStr=@"00";
        NSString *riceFellStr=@"00";
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"09",orderHour,orderMin,riceFellStr,feelStr]];
        
    }else if ([commandType isEqualToString:@"煮粥"]){
        
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=[NSString stringWithFormat:@"%02X",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = [NSString stringWithFormat:@"%02X",workmin];
        
        NSString *feelStr=@"00";
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@%@",@"0A",orderHour,orderMin,workHour,workMin,feelStr]];
    }else if ([commandType isEqualToString:@"蒸煮"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=[NSString stringWithFormat:@"%02X",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = [NSString stringWithFormat:@"%02X",workmin];
        
        NSString *feelStr=@"00";
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@%@",@"0B",orderHour,orderMin,workHour,workMin,feelStr]];
        
    }else if ([commandType isEqualToString:@"热饭"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"0C",orderHour,orderMin]];
    }else if ([commandType isEqualToString:@"营养保温"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"0D",orderHour,orderMin]];
    }else if ([commandType isEqualToString:@"云菜谱"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"0E",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"%@",[model.State objectForKey:@"cloudMenu"]];
        
        commandStr=[commandStr stringByAppendingString:controlStr];

    }else if ([commandType isEqualToString:@"煲汤"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=[NSString stringWithFormat:@"%02X",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = [NSString stringWithFormat:@"%02X",workmin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"0F",orderHour,orderMin,workHour,workMin]];
    }else if ([commandType isEqualToString:@"偏好"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"10",orderHour,orderMin]];
        
    }
    
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"电饭煲(%@)发送>>命令: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
}

-(void)sendPreferenceCommandToElectricCooker:(DeviceModel *)model{
    
    NSString *commandStr=@"13000010";
    NSString *commandType=[model.State objectForKey:@"state"];
    if ([commandType isEqualToString:@"煮粥"]) {
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=workhour<10?[NSString stringWithFormat:@"0%i",workhour]:[NSString stringWithFormat:@"%i",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = workmin<10?[NSString stringWithFormat:@"0%i",workmin]:[NSString stringWithFormat:@"%i",workmin];
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,workHour,workMin]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"0504643c00a03f000e000164040a00000007000164020a0000000f00026402055a00%@%@0002640503460018",[NSString stringWithFormat:@"%02X",workhour],[NSString stringWithFormat:@"%02X",workmin]];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
    }else if([commandType isEqualToString:@"精华煮"]){
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,@"99",@"99"]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"0208640000000003000002640503460018"];
        
        
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"超快煮"]){
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,@"99",@"99"]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"0207640000000003000002640503460018"];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"热饭"]){
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,@"99",@"99"]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"03046405036441001e00026405146400000a0002640503460018"];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"煲汤"]) {
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=workhour<10?[NSString stringWithFormat:@"0%i",workhour]:[NSString stringWithFormat:@"%i",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = workmin<10?[NSString stringWithFormat:@"0%i",workmin]:[NSString stringWithFormat:@"%i",workmin];
        
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,workHour,workMin]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"0504643c008241000f000264040a82000005000264020a82000028000264021e8200%@%@0002640503460018",[NSString stringWithFormat:@"%02X",workhour],[NSString stringWithFormat:@"%02X",workmin]];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
    }else if ([commandType isEqualToString:@"蒸煮"]) {
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=workhour<10?[NSString stringWithFormat:@"0%i",workhour]:[NSString stringWithFormat:@"%i",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = workmin<10?[NSString stringWithFormat:@"0%i",workmin]:[NSString stringWithFormat:@"%i",workmin];
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,workHour,workMin]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"0504643c008246000a000264050582000003000264050f82000023000264020f8200%@%@0002640503460018",[NSString stringWithFormat:@"%02X",workhour],[NSString stringWithFormat:@"%02X",workmin]];
        
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
    }else if([commandType isEqualToString:@"保温"] || [commandType isEqualToString:@"营养保温"]){
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",@"营养保温",@"99",@"99"]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"0203643c00460003000002640503460018"];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"云菜谱"]){
        
        NSString *controlStr= [model.State objectForKey:@"cloudMenu"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"电饭煲(%@)发送>>偏好: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
}
#pragma mark 私享壶

-(void)sendCommandToCloudKettle:(DeviceModel *)model{
    
    NSString *commandType=[model.State objectForKey:@"state"];
    NSString *commandStr=@"140000";
    if ([commandType isEqualToString:@"空闲"]) {
        commandStr=[commandStr stringByAppendingString:@"01"];
        
    }else if ([commandType isEqualToString:@"煮水"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        NSString *chlorine=[model.State objectForKey:@"chlorine"];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@",@"04",orderHour,orderMin,chlorine]];
        
    }else if ([commandType isEqualToString:@"母婴模式"]){
  
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        if ([[model.State objectForKey:@"heatmodel"] isEqualToString:@"冲奶粉"]) {
        
                        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
            NSString *controlStr=[NSString stringWithFormat:@"51b259767c890000000000000000000000000000020164623c0000140600%ld3c00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",[[model.State objectForKey:@"heatvalue"] integerValue]];
            commandStr=[commandStr stringByAppendingString:controlStr];

            } else {
                        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
            NSString *controlStr=[NSString stringWithFormat:@"6e296bcd4e730000000000000000000000000000010600%ld3c0018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",[[model.State objectForKey:@"preserveheatvalue"] integerValue]];
                commandStr=[commandStr stringByAppendingString:controlStr];
            }
        }else if ([commandType isEqualToString:@"红茶"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"7ea2833600000000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"白豪银针"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"767D8C6A94F69488000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"白牡丹"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"767d72614e390000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"贡眉"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"8d21770900000000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"寿眉"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"5bff770900000000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"黑茶"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"9ed1833600000000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"黄茶"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"9ec4833600000000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"绿茶"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"7eff833600000000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"乌龙茶"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"4e4c9f9983360000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"普洱茶"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"666e6d3183360000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"沱茶"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"6cb1833600000000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"铁观音"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"94c189c297f30000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"武夷岩茶"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"6b6659375ca98336000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"砖茶"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"7816833600000000000000000000000000000000020164623C00001406005A3C00180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"保温"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        int tem=[[model.State objectForKey:@"tem"]intValue];
        NSString *temStr=[NSString stringWithFormat:@"%02X",tem];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@",@"06",orderHour,orderMin,temStr]];
        
    }else if ([commandType isEqualToString:@"偏好"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"05",orderHour,orderMin]];
        
    }else if ([commandType isEqualToString:@"云菜谱"]){
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
        NSString *controlStr=[NSString stringWithFormat:@"%@",[model.State objectForKey:@"cloudMenu"]];
        
        commandStr=[commandStr stringByAppendingString:controlStr];

    }
    
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"私享壶(%@)发送>>命令: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
}
-(void)sendPreferenceCommandToCloudKettle:(DeviceModel *)model{
    NSString *commandStr=@"13000005";
    NSString *commandType=[model.State objectForKey:@"state"];
    if ([commandType isEqualToString:@"煮水"]) {
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,@"99",@"99"]]];
        
        
        NSString *controlStr=[NSString stringWithFormat:@"020164623c0000140600443c001800"];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
    }else if([commandType isEqualToString:@"煮水除氯"]){
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,@"99",@"99"]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"030164623c0000140217003c0000050600443c001800"];
        
        
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if([commandType isEqualToString:@"保温"]){
        
        commandStr=[commandStr stringByAppendingString:[self getPreferenceName:[NSString stringWithFormat:@"@|%@|%@|%@|",commandType,@"99",@"99"]]];
        
        NSString *controlStr=[NSString stringWithFormat:@"010600443c001800"];
        if (controlStr.length<200) {
            for (NSInteger i=controlStr.length-1; i<200; i++) {
                controlStr=[controlStr stringByAppendingString:@"0"];
            }
        }
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([commandType isEqualToString:@"云菜谱"]){
        
        NSString *controlStr= [model.State objectForKey:@"cloudMenu"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }
    
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"私享壶(%@)发送>>命令: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
}

#pragma mark 隔水炖16A
-(void)sendCommandToWaterCooker16A:(DeviceModel *)model{
    
    NSString *commandType=[model.State objectForKey:@"state"];
    NSString *commandStr=@"140000";
    if ([commandType isEqualToString:@"空闲"]) {
        commandStr=[commandStr stringByAppendingString:@"01"];
        
    }else if ([commandType isEqualToString:@"炖煮"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=[NSString stringWithFormat:@"%02X",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = [NSString stringWithFormat:@"%02X",workmin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"04",orderHour,orderMin,workHour,workMin]];
        
    }else if ([commandType isEqualToString:@"降压粥"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=[NSString stringWithFormat:@"%02X",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = [NSString stringWithFormat:@"%02X",workmin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"05",orderHour,orderMin,workHour,workMin]];
        
    }else if ([commandType isEqualToString:@"降压汤"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
        NSString *workHour=[NSString stringWithFormat:@"%02X",workhour];
        
        int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
        NSString *workMin = [NSString stringWithFormat:@"%02X",workmin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"06",orderHour,orderMin,workHour,workMin]];
        
    }
    else if ([commandType isEqualToString:@"云菜谱"]){
        
        if ([[model.State objectForKey:@"tag_id"] integerValue]==3) {
              [model.State setObject:@"降压粥" forKey:@"state"];
            int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
            NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
            
            int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
            NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
            
            int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
            NSString *workHour=[NSString stringWithFormat:@"%02X",workhour];
            
            int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
            NSString *workMin = [NSString stringWithFormat:@"%02X",workmin];
            
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"05",orderHour,orderMin,workHour,workMin]];        } else {
                  [model.State setObject:@"降压汤" forKey:@"state"];
                int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
                NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
                
                int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
                NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
                
                int workhour=[[model.State objectForKey:@"WorkHour"] intValue];
                NSString *workHour=[NSString stringWithFormat:@"%02X",workhour];
                
                int workmin = [[model.State objectForKey:@"WorkMin"] intValue];
                NSString *workMin = [NSString stringWithFormat:@"%02X",workmin];
                
                commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@",@"06",orderHour,orderMin,workHour,workMin]];     }
    }
    else if ([commandType isEqualToString:@"营养保温"]){
        
        int orderhour=[[model.State objectForKey:@"orderHour"] intValue];
        NSString *orderHour=[NSString stringWithFormat:@"%02X",orderhour];
        
        int ordermin=[[model.State objectForKey:@"orderMin"]intValue];
        NSString *orderMin=[NSString stringWithFormat:@"%02X",ordermin];
        
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"07",orderHour,orderMin]];
    }
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"隔水炖16A(%@)发送>>命令: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }
}
-(void)sendPreferenceCommandToWaterCooker16AIGCooker:(DeviceModel *)model{
    
    NSString *commandStr=nil;;
    NSString *commandType=[model.State objectForKey:@"state"];

    if ([commandType isEqualToString:@"云菜谱"]){
        
        if ([[TonzeHelpTool sharedTonzeHelpTool].prefrenceType isEqualToString:@"降压粥"]) {
            commandStr =@"13000005";
        } else {
            commandStr =@"13000006";
        }
        
        NSString *controlStr= [model.State objectForKey:@"cloudMenu"];
        
        commandStr=[commandStr stringByAppendingString:controlStr];

    }
    
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        
        NSData *sendData=[Transform nsstringToHex:commandStr];
        
        NSLog(@"隔水炖16AIG(%@)发送>>命令: %@",[device getMacAddressSimple], [sendData hexString]);
        
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject]sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:sendData];
        }
    }

}
#pragma mark 其他
-(void)disconnectDevice:(DeviceModel *)model{
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        [[XLinkExportObject sharedObject]  disconnectDevice:device withReason:0];
    }
}

-(void)resteDevice:(DeviceModel *)model{
    [SVProgressHUD show];
    
    if (self.overTimeTimer) {
        [self.overTimeTimer invalidate];
        self.overTimeTimer=nil;
    }
    
    self.overTimeTimer =[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(sendControllCommandOverTime) userInfo:nil repeats:NO];
    
    NSString *commandStr=@"16AA0000";
    DeviceEntity *device=[self getNeedControllDevice:model.mac];
    if (device) {
        NSData *sendData=[Transform nsstringToHex:commandStr];
        MyLog(@"重置设备发送指令：%@",sendData);
        if (device.isWANOnline) {
            [[XLinkExportObject sharedObject] sendPipeData:device andPayload:sendData];
        }else{
            [[XLinkExportObject sharedObject] sendLocalPipeData:device andPayload:sendData];
        }
    }
}

-(void)disconnectAllDevices{
    for (DeviceEntity *device in _connectedArr) {
        [[XLinkExportObject sharedObject] disconnectDevice:device withReason:0];
    }
}

-(NSString *)getPreferenceName:(NSString *)name{
    NSString *pName=@""; //名字标识符，用于适配云菜谱或者工作类型
    
    for (int i=0;i<name.length;i++) {
        int asciiCode = [name characterAtIndex:i];
        pName=[pName stringByAppendingString:[NSString stringWithFormat:@"%02X",asciiCode]];
    }
    
    if (pName.length<39) {
        for (NSInteger i=pName.length-1; i<39; i++) {
            pName=[pName stringByAppendingString:@"0"];
        }
    }
    
    return pName;
}

-(void)dismissProgressView{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (self.overTimeTimer) {
                [self.overTimeTimer invalidate];
                self.overTimeTimer=nil;
            }
            [SVProgressHUD dismiss];
        });
    });
    
    
    
}


@end
