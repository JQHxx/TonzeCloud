//
//  DeviceFunctionViewController.m
//  Product
//
//  Created by Xlink on 16/1/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DeviceFunctionViewController.h"
#import "ControllerButtonView.h"
#import "StartFunctionView.h"
#import "TimePickerView.h"
#import "ControllerHelper.h"
#import "Transform.h"
#import "DeviceHelper.h"
#import "DeviceProgressViewController.h"
#import "UpgradeViewController.h"
#import "PreferenceViewController.h"
#import "ShareListViewController.h"
#import "AppDelegate.h"
#import "DeviceCloudMenuViewController.h"
#import "KettleStartFunctionView.h"
#import "SmartSettingViewController.h"
#import "DrinkPlanViewController.h"
#import "NSData+Extension.h"
#import "DeviceViewController.h"
#import "AutoLoginManager.h"
#import "decompressionStartView.h"
#import "ChoiceMenuView.h"
#import "KettleTemView.h"
#import "SVProgressHUD.h"
#import "CharacterTeaView.h"
#import "BabyModelView.h"
#import "PreferenceCloudMenuViewController.h"
#import "DeviceCloudMenuViewController.h"
#import "CloudMenuDetailViewController.h"


@interface DeviceFunctionViewController ()<FunctionDelegate,StartFunctionDelegate,KettleStartFunctionDelegate,decompressionStartFunctionDelegate,UITextFieldDelegate,UIAlertViewDelegate,ChoiceMenuDelegate,KettleTemDelegate,CharacterTeaDelegate,BabyStartFunctionDelegate>{
    NSArray                 * functionArr;
    NSArray                 * functionImgArr;
    NSArray *feelArr;       //口感
    NSInteger               currentFeel;
    StartFunctionView       * startFuncView;
    KettleStartFunctionView * kettleStartView;
    decompressionStartView  * decompressionStartview;
    ChoiceMenuView          * choiceStartView;
    TimePickerView          * timePicker;
    KettleTemView           * kettleTemView;
    CharacterTeaView        * characterTeaView;
    BabyModelView           * babyModelView;
    NSInteger               functionIndex;
    NSMutableArray          * btnViewArr;
    UIAlertAction           * OkBtnEnabledAction;
    AppDelegate             * appDelegate;

    NSNumber *maxHours;     //烹饪功能最大时间
    NSNumber *maxMinutess;  //烹饪功能最大分钟
    NSNumber *minHours;     //烹饪功能最小时间
    NSNumber *minMinutes;   //烹饪功能最小分钟
    
    
}

@end

@implementation DeviceFunctionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=self.model.deviceName;
    self.rightImageName=@"更多";
    
    startFuncView=[[StartFunctionView alloc]initWithNibName:@"StartFunctionView" bundle:nil];
    kettleStartView=[[KettleStartFunctionView alloc]initWithNibName:@"KettleStartFunctionView" bundle:nil];
    decompressionStartview = [[decompressionStartView alloc]initWithNibName:@"decompressionStartView" bundle:nil];
    choiceStartView=[[ChoiceMenuView alloc]initWithNibName:@"ChoiceMenuView" bundle:nil];
    kettleTemView=[[KettleTemView alloc]initWithNibName:@"KettleTemView" bundle:nil];
    characterTeaView=[[CharacterTeaView alloc]initWithNibName:@"CharacterTeaView" bundle:nil];
    babyModelView=[[BabyModelView alloc]initWithNibName:@"BabyModelView" bundle:nil];
    btnViewArr=[[NSMutableArray alloc]init];
    
    [self initDeviceControlView];
    
    appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeviceFunctionViewUpdateUI:) name:@"DeviceFunctionViewUpdateUI" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnConnectDevice:) name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnDeviceStateChanged:) name:kOnDeviceStateChanged object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeSyncData object:nil];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceFunctionViewUpdateUI" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnDeviceStateChanged object:nil];
    
    [SVProgressHUD dismiss];
    [startFuncView dismissView];
    [kettleStartView dismissView];
    [choiceStartView dismissView];
    [kettleTemView dismissView];
    [characterTeaView dismissView];
    [babyModelView dismissView];
    [decompressionStartview dismissView];
}

#pragma mark --Custom Delegate
#pragma mark ControllerButtonView Delegate
-(void)selectFunction:(id)sender{
    if ([[self.model.State objectForKey:@"state"]isEqualToString:@"离线"]) {
        [self showOfflineAlertView];
        return;
    }
    
    UIButton *btn=sender;
    functionIndex=btn.tag;
    if (self.model.deviceType==CLOUD_KETTLE) {
        if (functionIndex == 2) {
            kettleTemView.model = self.model;
            [kettleTemView showInView:self.view];
        }else if (functionIndex ==3) {
            CloudMenuDetailViewController *cloudDetailVC = [[CloudMenuDetailViewController alloc] init];
            cloudDetailVC.model = self.model;
            cloudDetailVC.menuid = 13917;
            [self.navigationController pushViewController:cloudDetailVC animated:YES];

        }else if(functionIndex==4){
            
            characterTeaView.delegate=self;
            [characterTeaView showInView:self.view];
        }else if (functionIndex == 5){
            babyModelView.delegate=self;
            [babyModelView showInView:self.view];
        }else{
            kettleStartView.delegate=self;
            [kettleStartView showInView:self.view];
            [kettleStartView updateUIwithFunctionIndex:functionIndex];
        }
    }else if(self.model.deviceType == COOKFOOD_KETTLE){
        if (functionIndex == 0) {
            choiceStartView.delegate = self;
            [choiceStartView showInView:self.view];
            switch (functionIndex) {
                case 0:
                {
                    maxHours = @(12);
                    minHours = @(0);
                    minMinutes = @(1);
                    break;
                }
                default:
                    break;
            }
        }else{
            kettleStartView.delegate=self;
            kettleStartView.canSetchoiceMenu = YES;
            [kettleStartView showInView:self.view];
            [kettleStartView updateUIwithFunctionIndex:functionIndex];
        }
    }else if (self.model.deviceType==WATER_COOKER_16AIG && (functionIndex == 2 || functionIndex == 3)) {
        //降压粥、降压汤
        decompressionStartview.delegate=self;
        decompressionStartview.model = self.model;
        if (functionIndex == 2) {
            decompressionStartview.preference = @"降压粥";
            [TonzeHelpTool sharedTonzeHelpTool].prefrenceType=@"降压粥";
        }else if (functionIndex == 3){
            decompressionStartview.preference = @"降压汤";
            [TonzeHelpTool sharedTonzeHelpTool].prefrenceType=@"降压汤";
        }
        [decompressionStartview showInView:self.view];
    }else{
        if (self.model.deviceType==CLOUD_COOKER) {
            if (functionIndex==0) {
                startFuncView.canSetWorkTime=YES;
            }else{
                startFuncView.canSetWorkTime=NO;
            }
        }else if (self.model.deviceType==WATER_COOKER){
            if (functionIndex==0) {
                startFuncView.canSetWorkTime=YES;
            }else{
                startFuncView.canSetWorkTime=NO;
            }
        }else if (self.model.deviceType==ELECTRIC_COOKER){
            if (functionIndex==0||functionIndex==3||functionIndex==5||functionIndex==2) {
                startFuncView.canSetWorkTime=YES;
            }else{
                startFuncView.canSetWorkTime=NO;
            }
        }else if (self.model.deviceType==WATER_COOKER_16AIG){
            if (functionIndex==0) {
                startFuncView.canSetWorkTime=YES;
            }else{
                startFuncView.canSetWorkTime=NO;
            }
        }
        startFuncView.delegate=self;
        [startFuncView showInView:self.view];
        if (self.model.deviceType==ELECTRIC_COOKER){
            if (functionIndex==0) {
                //设置口感
                startFuncView.timeLbl.text=[feelArr objectAtIndex:1];
                currentFeel=1;
                startFuncView.titleLbl.text=@"口感";
            }else{
                startFuncView.titleLbl.text=[NSString stringWithFormat:@"%@时间",[functionArr objectAtIndex:functionIndex]];
                startFuncView.timeLbl.text=@"1小时30分";
                switch (functionIndex) {
                        
                    case 2:
                    {
                        maxHours = @(2);
                        minHours = @(0);
                        minMinutes = @(50);
                        break;
                    }
                    case 3:
                    {
                        maxHours = @(2);
                        minHours = @(0);
                        minMinutes = @(45);
                        startFuncView.timeLbl.text=@"1小时00分";
                        break;
                    }
                    case 5:
                    {
                        maxHours = @(4);
                        minHours = @(1);
                        minMinutes = @(30);
                        startFuncView.timeLbl.text=@"2小时00分";
                        break;
                    }
                    case 6:
                    {
                        maxHours = @(24);
                        minHours = @(0);
                        minMinutes = @(1);
                        break;
                    }
                    default:
                        break;
                }
            }
            
        }else if (self.model.deviceType==CLOUD_COOKER){
            startFuncView.titleLbl.text=[NSString stringWithFormat:@"%@时间",[functionArr objectAtIndex:functionIndex]];
            startFuncView.timeLbl.text=@"1小时30分";
            switch (functionIndex) {
                case 0:
                {
                    maxHours = @(24);
                    minHours = @(0);
                    minMinutes = @(1);
                    break;
                }
                default:
                    break;
            }
        }else if (self.model.deviceType==WATER_COOKER){
            startFuncView.titleLbl.text=[NSString stringWithFormat:@"%@时间",[functionArr objectAtIndex:functionIndex]];
            startFuncView.timeLbl.text=@"1小时30分";
            switch (functionIndex) {
                case 0:
                {
                    maxHours = @(24);
                    minHours = @(0);
                    minMinutes = @(1);
                    break;
                }
                default:
                    break;
            }
        }else if (self.model.deviceType==WATER_COOKER_16AIG){
            startFuncView.titleLbl.text=[NSString stringWithFormat:@"%@时间",[functionArr objectAtIndex:functionIndex]];
            startFuncView.timeLbl.text=@"2小时00分";
            switch (functionIndex) {
                case 0:
                {
                    maxHours = @(23);
                    minHours = @(0);
                    minMinutes = @(1);
                    break;
                }
                default:
                    break;
            }
        }else{
            startFuncView.titleLbl.text=[NSString stringWithFormat:@"%@时间",[functionArr objectAtIndex:functionIndex]];
            startFuncView.timeLbl.text=@"1小时30分";
        }
    }
}

#pragma mark StartFunctionDelegate
#pragma mark 选择时间
-(void)selectTime:(id)sender{
    if ([startFuncView.titleLbl.text isEqualToString:@"口感"]) {
        timePicker =[[TimePickerView alloc]initWithTitle:@"口感" delegate:self];
        timePicker.isSetTime=NO;
        timePicker.pickerStyle=PickerStyle_Time;
        [timePicker.locatePicker selectRow:1 inComponent:0 animated:YES];
        timePicker.isOrderType=NO;
        [timePicker showInView:self.view];
        [timePicker pickerView:timePicker.locatePicker didSelectRow:1   inComponent:0];
    }else{
        timePicker =[[TimePickerView alloc]initWithTitle:[NSString stringWithFormat:@"%@时间",[functionArr objectAtIndex:functionIndex]] delegate:self];
        timePicker.timeDisplayIn24=YES;
        timePicker.isSetTime=YES;
        timePicker.pickerStyle=PickerStyle_Time;
        timePicker.maxHours = maxHours;
        timePicker.minHours = minHours;
        timePicker.minMinutes = minMinutes;
        
        NSInteger selectHour=[startFuncView.timeLbl.text substringToIndex:2].integerValue-minHours.intValue;
        NSInteger selectMin=[startFuncView.timeLbl.text substringFromIndex:selectHour>9?4:3].integerValue;
        
        if (selectHour==0) {
            selectMin=selectMin-minMinutes.integerValue;
        }
        
        [timePicker.locatePicker selectRow:selectHour inComponent:0 animated:YES];
        [timePicker.locatePicker selectRow:selectMin inComponent:1 animated:YES];
        timePicker.isOrderType=NO;
        [timePicker showInView:self.view];
        [timePicker.locatePicker reloadComponent:1];
        [timePicker pickerView:timePicker.locatePicker didSelectRow:selectHour inComponent:0];
        [timePicker pickerView:timePicker.locatePicker didSelectRow:selectMin   inComponent:1];
    }
}

#pragma mark 立即启动
-(void)startFunction:(id)sender{
    if ([[self.model.State objectForKey:@"state"]isEqualToString:@"离线"]) {
        [self showOfflineAlertView];
        return;
    }
    
    if (self.model.deviceType==ELECTRIC_COOKER&&[startFuncView.titleLbl.text isEqualToString:@"口感"]) {
        [self.model.State setValue:[NSString stringWithFormat:@"%li",(long)currentFeel] forKey:@"feel"];
        [self.model.State setObject:@"00" forKey:@"WorkHour"];
        [self.model.State setObject:@"00" forKey:@"WorkMin"];
    }
    else{
        NSInteger selectHour=[startFuncView.timeLbl.text substringToIndex:2].integerValue;
        NSInteger selectMin=[startFuncView.timeLbl.text substringFromIndex:selectHour>9?4:3].integerValue;
        [self.model.State setObject:selectHour<10?[NSString stringWithFormat:@"0%li",(long)selectHour]:[NSString stringWithFormat:@"%li",(long)selectHour] forKey:@"WorkHour"];
        [self.model.State setObject:selectMin<10?[NSString stringWithFormat:@"0%li",(long)selectMin]:[NSString stringWithFormat:@"%li",(long)selectMin] forKey:@"WorkMin"];
        
    }
    if (self.model.deviceType==COOKFOOD_KETTLE) {
        
        [self.model.State setObject:choiceStartView.fireText.text forKey:@"firetext"];
        [self.model.State setObject:@"00" forKey:@"WorkHour"];
        [self.model.State setObject:@"00" forKey:@"WorkMin"];
    }
    if (self.model.deviceType == CLOUD_KETTLE) {
        [self.model.State setObject:babyModelView.heatValue forKey:@"heatvalue"];
        [self.model.State setObject:babyModelView.preserveHeatValue forKey:@"preserveheatvalue"];
        [self.model.State setObject:babyModelView.heatModel forKey:@"heatmodel"];
        [self.model.State setObject:@"00" forKey:@"orderHour"];
        [self.model.State setObject:@"00" forKey:@"orderHourMin"];
        [[ControllerHelper shareHelper] controllDevice:self.model];
    }
    [self.model.State setObject:[functionArr objectAtIndex:functionIndex] forKey:@"state"];
    [[ControllerHelper shareHelper] controllDevice:self.model];
}

#pragma mark 预约启动
-(void)orderStartFunction:(id)sender{
    timePicker =[[TimePickerView alloc]initWithTitle:@"预约时间" delegate:self];
    timePicker.timeDisplayIn24=YES;
    timePicker.isOrderType=YES;
    timePicker.isSetTime=YES;
    timePicker.pickerStyle=PickerStyle_Time;
    //获取当前时间
    NSString *time=[NSUserDefaultInfos getCurrentDate];
    int selectHour=[time substringWithRange:NSMakeRange(11, 2)].intValue;
    int selectMin=[time substringWithRange:NSMakeRange(14, 2)].intValue/5+1;
    
    //55分到59分处理
    if (selectMin==12) {
        selectHour++;
        selectMin=0;
    }
    
    [timePicker.locatePicker selectRow:selectHour inComponent:0 animated:YES];
    [timePicker.locatePicker selectRow:selectMin inComponent:1 animated:YES];
    [timePicker showInView:self.view];
    [timePicker pickerView:timePicker.locatePicker didSelectRow:selectHour inComponent:0];
    [timePicker pickerView:timePicker.locatePicker didSelectRow:selectMin  inComponent:1];
}

#pragma mark 缤纷果茶
#pragma mark CharacterTeaDelegate
-(void)fruitTeaFunction:(id)sender{
    self.model.isTea=YES;
    [TonzeHelpTool sharedTonzeHelpTool].teaType=@"水果茶";
    DeviceCloudMenuViewController *deviceCloudVC = [[DeviceCloudMenuViewController alloc] init];
    deviceCloudVC.model = self.model;
    [self.navigationController pushViewController:deviceCloudVC animated:YES];
}
-(void)scentedTeaStartFunction:(id)sender{
    self.model.isTea=YES;
    [TonzeHelpTool sharedTonzeHelpTool].teaType=@"花草茶";
    DeviceCloudMenuViewController *deviceCloudVC = [[DeviceCloudMenuViewController alloc] init];
    deviceCloudVC.model = self.model;
    [self.navigationController pushViewController:deviceCloudVC animated:YES];

}
#pragma mark kettleStartViewDelegate
#pragma mark 私享壶预约启动
-(void)kettleOrderStartFunction:(id)sender{
    if (self.model.deviceType ==COOKFOOD_KETTLE) {
        [self.model.State setObject:kettleStartView.FoodValueLbl.text forKey:@"FoodMenuName"];
    }
    TimePickerView *picker=sender;
    //预约模式
    NSInteger hour=[picker.locatePicker selectedRowInComponent:0];
    NSInteger min=[picker.locatePicker selectedRowInComponent:1]*5;
    
    //获取间隔
    NSTimeInterval interval=[NSUserDefaultInfos getDateIntervalWithHour:hour Min:min];
    hour=interval/3600;
    min=(interval-hour*3600)/60;
    
    [self.model.State setObject:[functionArr objectAtIndex:functionIndex] forKey:@"state"];
    [self.model.State setObject:kettleStartView.temValueLbl.text forKey:@"tem"];
    [self.model.State setObject:kettleStartView.modeValueLbl.text forKey:@"mode"];
    [self.model.State setObject:kettleStartView.chlorineSwitch.isOn?@"01":@"00" forKey:@"chlorine"];
    [self.model.State setObject:hour<10?[NSString stringWithFormat:@"0%li",(long)hour]:[NSString stringWithFormat:@"%li",(long)hour] forKey:@"orderHour"];
    [self.model.State setObject:min<10?[NSString stringWithFormat:@"0%li",(long)min]:[NSString stringWithFormat:@"%li",(long)min] forKey:@"orderMin"];
    
    if (self.model.deviceType ==COOKFOOD_KETTLE) {
        if (hour < 12) {
            [[ControllerHelper shareHelper] controllDevice:self.model];
        }else{
            [self showAlertWithTitle:@"提示" Message:@"最大预约时间为12小时"];
        }
    }else{
        [[ControllerHelper shareHelper]controllDevice:self.model];
    }
}
#pragma mark 私享壶立即启动
-(void)kettleStartFunction:(id)sender{
    if (self.model.deviceType ==COOKFOOD_KETTLE) {
        [self.model.State setObject:kettleStartView.FoodValueLbl.text forKey:@"FoodMenuName"];
    }
    [self.model.State setObject:[functionArr objectAtIndex:functionIndex] forKey:@"state"];
    [self.model.State setObject:kettleStartView.temValueLbl.text forKey:@"tem"];
    [self.model.State setObject:kettleStartView.modeValueLbl.text forKey:@"mode"];
    [self.model.State setObject:kettleStartView.chlorineSwitch.isOn?@"01":@"00" forKey:@"chlorine"];
    [self.model.State setObject:@"00" forKey:@"orderHour"];
    [self.model.State setObject:@"00" forKey:@"orderMin"];
    [[ControllerHelper shareHelper]controllDevice:self.model];
}

#pragma mark  decompressionStartFunctionDelegate
#pragma mark  降压粥/汤偏好详情
-(void)showPreferenceDetail:(id)sender{
    
    CloudMenuDetailViewController *cloudDetailVC = [[CloudMenuDetailViewController alloc] init];
    cloudDetailVC.model = self.model;
    cloudDetailVC.menuid = [sender integerValue];
    [self.navigationController pushViewController:cloudDetailVC animated:YES];
}

#pragma mark  降压粥/汤切换偏好
-(void)changePreferenceFunction:(id)sender{
   
    PreferenceCloudMenuViewController *cloudMenuVC = [[PreferenceCloudMenuViewController alloc] init];
    cloudMenuVC.model = self.model;
    [self.navigationController pushViewController:cloudMenuVC animated:YES];
}

#pragma mark  降压粥/汤立即启动
-(void)decompressionStartFunction:(id)sender{
    if ([[self.model.State objectForKey:@"state"]isEqualToString:@"离线"]) {
        [self showOfflineAlertView];
        return;
    }
    
    [self.model.State setObject:[functionArr objectAtIndex:functionIndex] forKey:@"state"];
    [self.model.State setObject:@"00" forKey:@"orderHour"];
    [self.model.State setObject:@"00" forKey:@"orderMin"];
    
    [[ControllerHelper shareHelper] controllDevice:self.model];
}

#pragma mark 降压粥/汤预约启动
-(void)decompressionOrderStartFunction:(id)sender{
    timePicker =[[TimePickerView alloc]initWithTitle:@"预约时间" delegate:self];
    timePicker.timeDisplayIn24=YES;
    timePicker.isOrderType=YES;
    timePicker.isSetTime=YES;
    timePicker.pickerStyle=PickerStyle_Time;
    //获取当前时间
    NSString *time=[NSUserDefaultInfos getCurrentDate];
    int selectHour=[time substringWithRange:NSMakeRange(11, 2)].intValue;
    int selectMin=[time substringWithRange:NSMakeRange(14, 2)].intValue/5+1;
    //55分到59分处理
    if (selectMin==12) {
        selectHour++;
        selectMin=0;
    }
    [timePicker.locatePicker selectRow:selectHour inComponent:0 animated:YES];
    [timePicker.locatePicker selectRow:selectMin inComponent:1 animated:YES];
    [timePicker showInView:self.view];
    [timePicker pickerView:timePicker.locatePicker didSelectRow:selectHour inComponent:0];
    [timePicker pickerView:timePicker.locatePicker didSelectRow:selectMin  inComponent:1];
}
#pragma mark UIActionSheetDelegate (TimePickerView)
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (timePicker.isOrderType) {
            if ([[self.model.State objectForKey:@"state"]isEqualToString:@"离线"]) {
                [self showOfflineAlertView];
                return;
            }
            if (self.model.deviceType==ELECTRIC_COOKER&&[startFuncView.titleLbl.text isEqualToString:@"口感"]) {
                [self.model.State setValue:[NSString stringWithFormat:@"%li",(long)currentFeel] forKey:@"feel"];
                [self.model.State setObject:@"00" forKey:@"WorkHour"];
                [self.model.State setObject:@"00" forKey:@"WorkMin"];
            }
            
            NSInteger selectHour=[startFuncView.timeLbl.text substringToIndex:2].integerValue;
            NSInteger selectMin=[startFuncView.timeLbl.text substringFromIndex:selectHour>9?4:3].integerValue;
            [self.model.State setObject:selectHour<10?[NSString stringWithFormat:@"0%li",(long)selectHour]:[NSString stringWithFormat:@"%li",(long)selectHour] forKey:@"WorkHour"];
            [self.model.State setObject:selectMin<10?[NSString stringWithFormat:@"0%li",(long)selectMin]:[NSString stringWithFormat:@"%li",(long)selectMin] forKey:@"WorkMin"];
            //预约模式
            NSInteger hour=[timePicker.locatePicker selectedRowInComponent:0];
            NSInteger min=[timePicker.locatePicker selectedRowInComponent:1]*5;
            
            //获取间隔
            NSTimeInterval interval=[NSUserDefaultInfos getDateIntervalWithHour:hour Min:min];
            hour=interval/3600;
            min=(interval-hour*3600)/60;
            [self.model.State setObject:[functionArr objectAtIndex:functionIndex] forKey:@"state"];
            [self.model.State setObject:hour<10?[NSString stringWithFormat:@"0%li",(long)hour]:[NSString stringWithFormat:@"%li",(long)hour] forKey:@"orderHour"];
            [self.model.State setObject:min<10?[NSString stringWithFormat:@"0%li",(long)min]:[NSString stringWithFormat:@"%li",(long)min] forKey:@"orderMin"];
            
            [[ControllerHelper shareHelper] controllDevice:self.model];
        }else{
            if (timePicker.isSetTime) {
                //确定
                NSInteger hour=[timePicker.locatePicker selectedRowInComponent:0]+minHours.integerValue;
                NSInteger min;
                if (hour==minHours.integerValue) {
                    min=[timePicker.locatePicker selectedRowInComponent:1]+minMinutes.integerValue;
                }else{
                    min=[timePicker.locatePicker selectedRowInComponent:1];
                }
                startFuncView.timeLbl.text=[NSString stringWithFormat:@"%li小时%li分钟",(long)hour,(long)min];
            }else{
                currentFeel=[timePicker.locatePicker selectedRowInComponent:0];
                switch (currentFeel) {
                    case 0:
                        startFuncView.timeLbl.text=@"香韧";
                        break;
                    case 1:
                        startFuncView.timeLbl.text=@"标准";
                        break;
                    case 2:
                        startFuncView.timeLbl.text=@"香软";
                        break;
                    default:
                        break;
                }
            }
        }
    }
}
#pragma mark UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text.length>16||textField.text.length<1) {
         [self showAlertWithTitle:@"提示" Message:@"昵称仅支持1-16个字符"];
    }
    return YES;
}
#pragma mark --NSNotification Methods
#pragma mark 更新设备状态
-(void)DeviceFunctionViewUpdateUI:(NSNotification *)noti{
    self.model=noti.object;
    [stateIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
    stateLbl.text=[self.model.State objectForKey:@"state"];
}

#pragma mark 连接回调
- (void)OnConnectDevice:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *Data=[Transform nsstringToHex:@"120000"];
    
    //获取最新状态
    if (device.isWANOnline) {
        [[XLinkExportObject sharedObject] sendPipeData:device andPayload:Data];
    }else{
        [[XLinkExportObject sharedObject] sendLocalPipeData:device andPayload:Data];
    }
}

#pragma mark 收到信息回调
-(void)OnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    self.model.deviceName=[DeviceHelper getDeviceName:device];
    if ([[device getMacAddressSimple ] isEqualToString:self.model.mac]) {
        MyLog(@"DeviceFuntionVCrecvData: %@", [recvData hexString]);
        
        
        
        ///如果是控制命令的返回就隐藏
        uint32_t cmd_len = (uint32_t)[recvData length];
        uint8_t cmd_data[cmd_len];
        memset(cmd_data, 0, cmd_len);
        [recvData getBytes:(void *)cmd_data length:cmd_len];
        
        if (cmd_data[0]==0x16&&self.model.role ==0) {
            //重置设备返回命令
            [[ControllerHelper shareHelper]dismissProgressView];
            [self disbindingDevice];
            return;
        }
        
        if (cmd_data[0]==0x14) {
            [[ControllerHelper shareHelper] dismissProgressView];
        }
        self.model.isOnline=YES;
        NSMutableDictionary *dic=[DeviceHelper getStateDicWithDevice:device Data:recvData];
        
        if (dic) {
            self.model.State=dic;
            [NSUserDefaultInfos putKey:@"name" andValue:[self.model.State objectForKey:@"name"]];
            [NSUserDefaultInfos putKey:@"commandType" andValue:[self.model.State objectForKey:@"state"]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self updateUI];
                });
            });
        }
    }
}

#pragma mark 设备状态改变回调
- (void)OnDeviceStateChanged:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    
    if ([[device getMacAddressSimple ]isEqualToString:self.model.mac]) {
        //当设备状态改变才更新界面
        if (device.isConnected) {
            self.model.isOnline=YES;
            [self.model.State setObject:@"在线" forKey:@"state"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self updateUI];
                });
            });
        }else{
            self.model.isOnline=NO;
            [self.model.State setObject:@"离线" forKey:@"state"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self updateUI];
                });
            });
        }
    }
}

#pragma mark 输入框处理通知
- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    OkBtnEnabledAction.enabled = textField.text.length >= 1;
}

#pragma mark --Response Methods
#pragma mark  云菜谱
-(IBAction)cloudMenuSelected:(id)sender{
    if (self.model.deviceType==DeviceTypeCloudKettle) {
        self.model.isTea=NO;
    }
    if ([[self.model.State objectForKey:@"state"]isEqualToString:@"离线"]) {
        [self showOfflineAlertView];
        return;
    }
    [self performSegueWithIdentifier:@"ToCloudMenuView" sender:nil];
}

#pragma mark 偏好
-(IBAction)preferenceSelected:(id)sender{
    if ([[self.model.State objectForKey:@"state"]isEqualToString:@"离线"]) {
        [self showOfflineAlertView];
        return;
    }
    [self performSegueWithIdentifier:@"toPreferenceView" sender:nil];
}

#pragma mark  返回方法
-(void)leftButtonAction{
    NSArray *vcArray = self.navigationController.viewControllers;
    for(UIViewController *vc in vcArray){
        if ([vc isKindOfClass:[DeviceViewController class]]){
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

#pragma mark 更多按钮事件
-(void)rightButtonAction{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *shareButtonTitle = NSLocalizedString(@"分享管理", nil);
    NSString *updateButtonTitle = NSLocalizedString(@"固件升级", nil);
    NSString *renameButtonTitle = NSLocalizedString(@"重命名", nil);
    NSString *deleteButtonTitle = NSLocalizedString(@"删除", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __block __typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:shareButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf performSegueWithIdentifier:@"toShareListView" sender:nil];
    }];
    
    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:updateButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (weakSelf) {
            if (!weakSelf.model.isOnline) {
                [weakSelf showOfflineAlertView];
                return;
            }
            
            UpgradeViewController *upgradeVC=[[UpgradeViewController alloc]initWithNibName:@"UpgradeViewController" bundle:nil];
            upgradeVC.deviceType=weakSelf.model.deviceType;
            upgradeVC.device=[[ControllerHelper shareHelper]getNeedControllDevice:self.model.mac];
            [weakSelf.navigationController pushViewController:upgradeVC animated:YES];
        }
    }];
    
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:renameButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf showNameAlertController];
    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [weakSelf showDeleteAlertController];
    }];
    [alertController addAction:renameAction];
    [alertController addAction:cancelAction];
    
    if (self.model.role==0) {
        //管理员才能显示
        [alertController addAction:shareAction];
        [alertController addAction:updateAction];
    }
    
    if (self.model.deviceType==CLOUD_KETTLE) {
        NSString *smartButtonTitle = NSLocalizedString(@"智能设置", nil);
        UIAlertAction *smartAction = [UIAlertAction actionWithTitle:smartButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (weakSelf) {
                if (!weakSelf.model.isOnline) {
                    [self showOfflineAlertView];
                }
                [weakSelf performSegueWithIdentifier:@"toSmartSettingView" sender:nil];
            }
        }];
        [alertController addAction:smartAction];
    }
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark--饮水计划
- (void)drinkButton{
        [self performSegueWithIdentifier:@"toDrinkPlanView" sender:nil];

}
#pragma mark 跳转事件
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toProgressView"]) {
        DeviceProgressViewController *progressVC=[segue destinationViewController];
        progressVC.model=self.model;
    }else if ([segue.identifier isEqualToString:@"toPreferenceView"]){
        PreferenceViewController *preferenceVC=[segue destinationViewController];
        preferenceVC.model=self.model;
    }else if ([segue.identifier isEqualToString:@"toShareListView"]){
        ShareListViewController *shareListVC=[segue destinationViewController];
        shareListVC.model=self.model;
    }else if ([segue.identifier isEqualToString:@"ToCloudMenuView"]){
        DeviceCloudMenuViewController *cloudMenuVC=[segue destinationViewController];
        cloudMenuVC.model=self.model;
    }else if ([segue.identifier isEqualToString:@"toSmartSettingView"]){
        SmartSettingViewController *smartVC=[segue destinationViewController];
        smartVC.model=self.model;
        
    }else if ([segue.identifier isEqualToString:@"toDrinkPlanView"]){
        DrinkPlanViewController *planVC=[segue destinationViewController];
        planVC.model=self.model;
    }
}

#pragma mark--Custom Methods
#pragma mark 初始化界面
-(void)initDeviceControlView{
    UIButton *drinkBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, SCREEN_HEIGHT-60, 50, 50)];
    [drinkBtn setImage:[UIImage imageNamed:@"ic_sxh_plan"] forState:UIControlStateNormal];
    drinkBtn.layer.cornerRadius = 25;
    [drinkBtn addTarget:self action:@selector(drinkButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:drinkBtn];
    
    if (self.model.deviceType==CLOUD_COOKER) {
        //云炖锅
        drinkBtn.hidden = YES;
        [deviceIV setImage:[UIImage imageNamed:@"设备控制云炖锅"]];
        stateLbl.text=[self.model.State objectForKey:@"state"];
        [stateIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
    
        functionArr=[[NSArray alloc]initWithObjects:@"炖汤",@"煮粥",@"营养保温", nil];
        functionImgArr=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"云炖锅炖汤"],[UIImage imageNamed:@"云炖锅煮粥"],[UIImage imageNamed:@"云炖锅营养保温1"], nil];
    }else if (self.model.deviceType==WATER_COOKER){
        //隔水炖
        drinkBtn.hidden = YES;
        [deviceIV setImage:[UIImage imageNamed:@"设备控制隔水炖"]];
        stateLbl.text=[self.model.State objectForKey:@"state"];
        [stateIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
        
        //scrollview增加function button
        functionArr=[[NSArray alloc]initWithObjects:@"炖煮",@"营养保温", nil];
        functionImgArr=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"隔水炖炖汤"],[UIImage imageNamed:@"隔水炖营养保温1"], nil];
    }else if (self.model.deviceType==COOKFOOD_KETTLE){
        //炒菜锅
        drinkBtn.hidden = YES;
        [deviceIV setImage:[UIImage imageNamed:@"自动烹饪锅"]];
        stateLbl.text=[self.model.State objectForKey:@"state"];
        [stateIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
        //scrollview增加function button
        functionArr=[[NSArray alloc]initWithObjects:@"手动烹饪",@"一键烹饪",nil];
        functionImgArr=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"ic_prg_one"],[UIImage imageNamed:@"ic_prg_wifi"], nil];
    }else if (self.model.deviceType==ELECTRIC_COOKER){
        //电饭煲
        drinkBtn.hidden = YES;
        [deviceIV setImage:[UIImage imageNamed:@"设备控制电饭煲"]];
        stateLbl.text=[self.model.State objectForKey:@"state"];
        [stateIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
        
        //scrollview增加function button
        functionArr=[[NSArray alloc]initWithObjects:@"精华煮",@"超快煮",@"煮粥",@"蒸煮",@"热饭",@"煲汤",@"营养保温", nil];
        functionImgArr=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"电饭煲精华煮"],[UIImage imageNamed:@"电饭煲超快煮"],[UIImage imageNamed:@"电饭煲煮粥"],[UIImage imageNamed:@"电饭煲蒸煮"],[UIImage imageNamed:@"电饭煲热饭"],[UIImage imageNamed:@"电饭煲煲汤"],[UIImage imageNamed:@"电饭煲营养保温1"], nil];
        feelArr=[[NSArray alloc]initWithObjects:@"香软",@"标准",@"香韧", nil];
    }else if(self.model.deviceType==CLOUD_KETTLE){
        //私享壶
        drinkBtn.hidden = NO;
        [deviceIV setImage:[UIImage imageNamed:@"云水壶"]];
        stateLbl.text=[self.model.State objectForKey:@"state"];
        [stateIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
        [cloudMenuBtn setTitle:@"云功能" forState:UIControlStateNormal];
        
        //scrollview增加function button
        functionArr=[[NSArray alloc]initWithObjects:@"煮水",@"保温",@"煮茶",@"煮咖啡",@"缤纷果茶",@"母婴模式",nil];
        functionImgArr=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"煮水"],[UIImage imageNamed:@"隔水炖营养保温1"], [UIImage imageNamed:@"煮茶"], [UIImage imageNamed:@"煮咖啡"],[UIImage imageNamed:@"水果茶"],[UIImage imageNamed:@"母婴"],nil];
    }else if (self.model.deviceType==WATER_COOKER_16AIG){
        //隔水炖16A
        drinkBtn.hidden = YES;
        [deviceIV setImage:[UIImage imageNamed:@"geshuidun2_control"]];
        stateLbl.text=[self.model.State objectForKey:@"state"];
        [stateIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
        
        //scrollview增加function button
        functionArr=[[NSArray alloc]initWithObjects:@"炖煮",@"营养保温",@"降压粥",@"降压汤", nil];
        functionImgArr=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"隔水炖炖汤"],[UIImage imageNamed:@"隔水炖营养保温1"],[UIImage imageNamed:@"降压粥"],[UIImage imageNamed:@"降压汤"], nil];
        
        cloudMenuBtn.hidden = preferenceBtn.hidden = YES;
    }
    
    for (int i=0 ;i<functionArr.count;i++) {
        ControllerButtonView *btnView=[[ControllerButtonView alloc]initWithNibName:@"ControllerButtonView" bundle:nil];
        float gap=(SCREEN_WIDTH-85*3)/4;
        btnView.view.frame=CGRectMake(85*(i%3)+gap*(i%3+1),(i/3)*btnView.view.height+10*(i/3+1), btnView.view.width, btnView.view.height);
        btnView.functionBtn.tag=i;
        [btnView.functionBtn setBackgroundImage:[functionImgArr objectAtIndex:i] forState:UIControlStateNormal];
        btnView.functionLbl.text=[functionArr objectAtIndex:i];
        btnView.delegate=self;
        [btnViewArr addObject:btnView];
        [functionScrollView addSubview:btnView.view];
    }
    functionScrollView.contentSize=CGSizeMake(SCREEN_WIDTH, (btnViewArr.count/3+1)*120+(btnViewArr.count/3+1)*15);
}

#pragma mark 更新设备状态
-(void)updateUI{
    if ([[self.model.State objectForKey:@"state"]isEqualToString:@"离线"]||[[self.model.State objectForKey:@"state"]isEqualToString:@"空闲"]||[[self.model.State objectForKey:@"state"]isEqualToString:@"在线"]) {
        [stateIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
        stateLbl.text=[self.model.State objectForKey:@"state"];
    }else{
        [[ControllerHelper shareHelper]dismissProgressView];
        if (!self.navigationController.isBeingDismissed && !self.navigationController.isMovingToParentViewController) {
            [self performSegueWithIdentifier:@"toProgressView" sender:nil];
        }
    }
}

#pragma mark 设备离线提示
-(void)showOfflineAlertView{
    NSString *ButtonTitle = NSLocalizedString(@"确定", nil);
    NSString *title=@"设备已离线";
    NSString *message=@"请检查设备是否连接电源、WIFI是否正常后再重新连接";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    __block __typeof(self) weakSelf = self;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:ButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (weakSelf) {
            [[ControllerHelper shareHelper] conncetDevice:weakSelf.model];//连接设备
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
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"请输入新的名字"];
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
             [self showAlertWithTitle:@"提示" Message:@"昵称仅支持1-16个字符"];
            
        }else{
            self.baseTitle=alertController.textFields.firstObject.text;
            self.model.deviceName=alertController.textFields.firstObject.text;
            NSString *key=[self.model.mac stringByAppendingString:@"name"];
            [NSUserDefaultInfos putKey:key andValue:alertController.textFields.firstObject.text];
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:self.model.deviceName,key, nil];
            NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
            [HttpRequest setDevicePropertyDictionary:dic withDeviceID:[NSNumber numberWithInt:self.model.deviceID] withProductID:self.model.productID withAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                if (err) {
                    if (err.code==4031003) {
                        [appDelegate updateAccessToken];
                    }
                    NSLog(@"重命名 err");
                }else{
                    NSLog(@"重命名成功");
                }
            }];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:kDeviceViewUpdateUI object:self.model];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
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
    NSString *message =(!self.model.isOnline&&self.model.role==0)?@"离线状态下成功删除设备，再次绑定设备时，需要重置硬件设备": NSLocalizedString(@"确定要删除当前设备？", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.model.role==0&&self.model.isOnline) {
            [[ControllerHelper shareHelper] resteDevice:self.model]; //设置在线时，管理员需要重置设备
        }else{
            [self disbindingDevice];
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
    [HttpRequest unsubscribeDeviceWithUserID:[userDic objectForKey:@"user_id"] withAccessToken:[userDic objectForKey:@"access_token"] withDeviceID:[NSNumber numberWithInt:self.model.deviceID] didLoadData:^(id result, NSError *err) {
        if (err) {
            if (err.code==4001034) {
                //返回这个证明已经取消订阅了该设备
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //更新UI，返回
                        [[AutoLoginManager shareManager] updateUIAfterDeleteDevice:self.model];
                        [self.navigationController popViewControllerAnimated:YES];
                        [[ControllerHelper shareHelper] disconnectDevice:self.model];
                        //删除设备
                        [DeviceHelper deleteDeviceFromLocal:self.model.mac];
                        [[AutoLoginManager shareManager] getDeviceList];
                    });
                });
            }else if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [self showAlertWithTitle:@"提示" Message:@"删除失败"];
                    });
                });
            }
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    //更新UI，返回
                    [[AutoLoginManager shareManager] updateUIAfterDeleteDevice:self.model];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    [[ControllerHelper shareHelper] disconnectDevice:self.model];
                    //删除设备
                    [DeviceHelper deleteDeviceFromLocal:self.model.mac];
                });
            });
        }
    }];
}

@end
