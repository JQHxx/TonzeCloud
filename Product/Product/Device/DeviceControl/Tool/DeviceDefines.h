//
//  DeviceDefines.h
//  Product
//
//  Created by Xlink on 15/12/14.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#ifndef DeviceDefines_h
#define DeviceDefines_h

#define D_GET_DEVICE_INFO 0x10   //查询设备类型
#define D_GET_DEVICE_PROP 0x11    //获取设备属性
#define D_GET_DEVICE_STA 0x12    //获取设备状态
#define D_SET_DEVICE_PROP  0x13     //设置设备属性
#define D_SET_DEVICE_STA  0x14       //设置设备状态
#define D_REPORT_DEVICE_STA 0x15      //设备上报状态


#define DEVICE_WATER_COOKER  0x0030              // 隔水炖
#define DEVICE_ELECTRIC_COOKER  0x0031         //电饭煲
#define DEVICE_CLOUD_COOKER  0x0032           //云炖锅
#define DEVICE_COOKFOOD_COOKER  0x0038           //炒菜锅

#define FREE 0x01                            //空闲
#define SENSOR_UNUSUAL 0x02                 //传感器异常
#define OVERHEATING 0x03                    //过热异常
#define DRY_STATE 0x04                       //干烧状态、电路系统异常
#define NO_POT_ALARM 0x05                   //无锅报警
#define POWER_VOLTAGE 0x06                  //电网电压异常
#define BATTERY_VOLTAGE 0x07                //电池电压异常
#define ESSENCE_COOK_COMMAND 0x08           //精华煮命令
#define ULTRAFAST_COOK_COMMAND 0x09         //超快煮命令
#define PORRIDGE_COMMAND 0x0A               //煮粥命令
#define COOKING_COMMAND 0x0B                //蒸煮命令
#define HOT_MEALS_COMMAND 0x0C              //热饭
#define NUTRITION_INSULATION_COMMAND 0x0D   //营养保温命令
#define CLOUD_RECIPES_COMMAND 0x0E          //云菜谱命令
#define SOUP_COMMAND_COMMAND 0x0F           //煲汤命令
#define PUSH_NOTI 0x10                      //推送提醒

#define FIRE 0x01                            //空闲
#define FIRE_UNUSUAL 0x02                    //异常
#define FIRE_MANUAL 0x03                          //手动烹饪
#define FIRE_VOLUNTARY 0x04                       //一键烹饪
#define FIRE_MENU 0x05                       //偏好命令
#define FIRE_RECIPES_COMMAND 0x06            //云菜谱命令
#define PUSH_FIRE 0x07                      //推送提醒

#define PRO_ORDER 0x01                       //预约阶段
#define PRO_WARMING 0x02                     //升温阶段
#define PRO_LITTLE_FIRE 0x03    //小火精炖阶段
#define PRO_CONSTANT_TEM 0x05   //恒温精炖阶段
#define PRO_BIG_FIRE 0x06 //大火快炖阶段
#define PRO_LITTLE_FIR_SLOW 0x07    //小火慢熬
#define PRO_COOLING 0x08   //降温阶段
#define PRO_KEEP_TEM 0x09   //营养保温阶段


#endif /* DeviceDefines_h */
