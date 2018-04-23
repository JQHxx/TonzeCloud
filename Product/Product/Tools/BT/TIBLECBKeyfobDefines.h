//
//  TIBLECBKeyfobDefines.h
//  TI-BLE-Demo
//
//  Created by Ole Andreas Torvmark on 10/31/11.
//  Copyright (c) 2011 ST alliance AS. All rights reserved.
//

#define SCALE_NAME @"FSRK-FRK-001"  //营养秤

#ifndef TI_BLE_Demo_TIBLECBKeyfobDefines_h
#define TI_BLE_Demo_TIBLECBKeyfobDefines_h

enum{
    g = 0x01,               //g:克
    oz = 0x02,              //oz:盎司
    lb_oz = 0x04,           //lb,oz:磅,盎司
    ml = 0x08,              //ml:毫升
    fl_oz = 0x10,           //fl,oz:液量盎司
    kg = 0x20,              //kg:千克
}UNIT_OF_WEIGHT;

enum{
    TempWeightBattry = 0x00,                 //临时重量，未超重，电量正常,重量有效
    SteadyWeightBattry = 0x01,               //稳定重量，未超重，电量正常,重量有效
    TempAndOverWeightVoltage = 0x02,         //临时重量，超重，电量正常,重量显示为0
    SteadyAndOverWeightBattry = 0x03,        //稳定重量，超重，电量正常,重量显示为0
    TempWeightLowBattry = 0x04,              //临时重量，未超重，电量低,重量显示为0
    SteadyWeightLowBattry = 0x05,            //稳定重量，未超重，电量低,重量显示为0
    TempAndOverWeightLowBattry = 0x06,       //临时重量，超重，电量低,重量显示为0
    SteadyAndOverWeightLowBattry = 0x07,     //稳定重量，超重，电量低,重量显示为0
    TareTempWeightBattry = 0x08,             //临时重量，未超重，电量正常,重量有效,负数
    TareSteadyWeightBattry = 0x09,           //稳定重量，未超重，电量正常,重量有效,负数
    TareTempAndOverWeightVoltage = 0x0A,     //临时重量，超重，电量正常,重量显示为0,负数
    TareSteadyAndOverWeightBattry = 0x0B,    //稳定重量，超重，电量正常,重量显示为0,负数
    TareTempWeightLowBattry = 0x0C,          //临时重量，未超重，电量低,重量显示为0,负数
    TareSteadyWeightLowBattry = 0x0D,        //稳定重量，未超重，电量低,重量显示为0,负数
    TareTempAndOverWeightLowBattry = 0x0E,   //临时重量，超重，电量低,重量显示为0,负数
    TareSteadyAndOverWeightLowBattry = 0x0F, //稳定重量，超重，电量低,重量显示为0,负数
    InvalidValue = 0x10,                     //无效值
}WEIGHT_STATUS;

enum{
    Connecting  = 0,
    Connected = 1,
    Disconnected  = 2,
    DSanning = 3,
}STATE_DEVICE;




//service
#define Service_Data                                        0xFFF0
#define Service_Data_WeChat                                 0xFFB0

//characteristic
#define Characteristic_Data                                 0xFFF6
//微信秤
#define Characteristic_Data_WeChat                          0xFFB2
#endif
