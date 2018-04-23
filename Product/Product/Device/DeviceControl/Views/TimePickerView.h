//
//  UICityPicker.h
//  DDMates
//
//  Created by ShawnMa on 12/16/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//

//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PickerStyle) {
    PickerStyle_CookFood,
    PickerStyle_Height,        //身高
    PickerStyle_Weight,         //体重
    PickerStyle_Humidity,       //湿度
    PickerStyle_Temperature,     //温度
    PickerStyle_HumidityRice,   //湿度米量
    PickerStyle_sportTime,      //运动时间
    PickerStyle_Age,
    PickerStyle_Time,
    PickerStyle_Sex,
    PickerStyle_setRunTime,//设置正在工作中的时间
    PickerStyle_Tem,
    PickerStyle_Date,
    PickerStyle_Mode,
    PickerStyle_TempDiff, //温差，范围：0.1-5℃
    PickerStyle_Minute, //分钟
    PickerStyle_BodyTemp,    //体温，35-41℃，分之0.1℃
    PickerStyle_Place,   //所在地区
    PickerStyle_DietTime,     //饮食时间段
    PickerStyle_Step,    //步数
};

@interface TimePickerView : UIActionSheet<UIPickerViewDelegate, UIPickerViewDataSource> {
@private
    BOOL isReloadComponent;
    NSInteger rowNum;
    
}

@property (nonatomic)PickerStyle pickerStyle;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel,*spLbl;
@property (strong, nonatomic) IBOutlet UIPickerView *locatePicker;
@property (strong, nonatomic) IBOutlet UIView *titleView;

@property(strong,nonatomic)  UIView *backgroudView;;

@property (nonatomic)BOOL timeDisplayIn24;  //是否为24小时制
@property (nonatomic, strong) NSNumber *maxHours;//最大的小时值
@property (nonatomic, strong) NSNumber *minHours;//最小的小时值
@property (nonatomic, strong) NSNumber *minMinutes;//最小的分钟值

@property (nonatomic)BOOL isOrderType;//是否为预约模式

@property(nonatomic)BOOL isSetTime  ;//是否为设置时间，如果no则设置口感
@property (nonatomic,strong)NSArray *valuesArray;   //选择值（饮食时间段）

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIActionSheetDelegate>*/)delegate;

- (void)showInView:(UIView *)view;

@end
