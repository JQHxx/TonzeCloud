//
//  SceneHelper.m
//  Product
//
//  Created by vision on 17/6/29.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SceneHelper.h"

@implementation SceneHelper

singleton_implementation(SceneHelper)

#pragma mark  获取设备标识
-(NSInteger)getEquipmentWithDeviceProductID:(NSString *)product_id{
    NSInteger equipment=0;
    if ([product_id isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]) {
        equipment=1;
    }else if ([product_id isEqualToString:CLOUD_KETTLE_PRODUCT_ID]){
        equipment=2;
    }else if ([product_id isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]){
        equipment=3;
    }else if ([product_id isEqualToString:CLOUD_COOKER_PRODUCT_ID]){
        equipment=4;
    }else if ([product_id isEqualToString:WATER_COOKER_PRODUCT_ID]){
        equipment=5;
    }else if ([product_id isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]){
        equipment=6;
    }
    return equipment;
}

+ (NSString *)ql_getDeviceCodeWithCloudMenu:(NSString *)cloudMenu productID:(NSString *)productID cookerTag:(NSInteger)cookerTag isPreference:(BOOL)isPreference{
    
    NSString *commandStr=@"140000";
    
    if ([productID isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]) {
        if (cookerTag == 1) {// -- 降压粥
            if (isPreference) {// -- 偏好指令
                commandStr =@"13000005";
                commandStr=[commandStr stringByAppendingString:cloudMenu];
                
            }else{// 启动指令
                commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"05",@"0000"]];
                NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
                commandStr=[commandStr stringByAppendingString:controlStr];
            }
        }else{ // -- 降压汤
            if (isPreference) {// -- 偏好指令
                commandStr =@"13000006";
                commandStr=[commandStr stringByAppendingString:cloudMenu];
            }else{// 启动指令
                commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"06",@"0000"]];
                NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
                commandStr=[commandStr stringByAppendingString:controlStr];
            }
        }
    }else if ([productID isEqualToString:WATER_COOKER_PRODUCT_ID] ||[productID isEqualToString:CLOUD_COOKER_PRODUCT_ID]){
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"08",@"0000"]];
        NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([productID isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]){
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"0E",@"0000"]];
        NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
        commandStr=[commandStr stringByAppendingString:controlStr];
        
    }else if ([productID isEqualToString:CLOUD_KETTLE_PRODUCT_ID]){
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"07",@"0000"]];
        NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
        commandStr=[commandStr stringByAppendingString:controlStr];
    }else if ([productID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]){
        commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"06",@"0000"]];
        NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
        commandStr=[commandStr stringByAppendingString:controlStr];
    }
    
    return commandStr;
}

@end
