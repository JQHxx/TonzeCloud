//
//  PreferenceDetailViewController.m
//  Product
//
//  Created by Xlink on 16/1/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "PreferenceDetailViewController.h"
#import "ControllerHelper.h"
#import "PreferenceViewController.h"
#import "PreferenceModel.h"



@interface PreferenceDetailViewController ()
{
    NSArray *typeArr;
    
    NSInteger minMinutes,minHours,maxMinutes,maxHours, defaultHour, defaultMinute;
    
}

@end

@implementation PreferenceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor=[UIColor bgColor_Gray];
    self.baseTitle=@"工作类型";
    
    if (self.model.deviceType==CLOUD_COOKER) {
        typeArr =[[NSArray alloc]initWithObjects:@"炖汤",@"煮粥",@"营养保温", nil];
        [typeLbl setText:[typeArr objectAtIndex:self.selectedType]];
        
        if (self.selectedType==0) {
            minHours   = 0;
            minMinutes = 1;
            maxHours   = 23;
            maxMinutes = 59;
            defaultHour = 1;
            defaultMinute = 30;
        }
        
    }else if (self.model.deviceType==WATER_COOKER){
        typeArr =[[NSArray alloc]initWithObjects:@"炖煮",@"营养保温", nil];
        [typeLbl setText:[typeArr objectAtIndex:self.selectedType]];
        
        if (self.selectedType==0) {
            minHours   = 0;
            minMinutes = 1;
            maxHours   = 24;
            maxMinutes = 0;
            defaultHour = 1;
            defaultMinute = 30;
        }

    
    }else if (self.model.deviceType==CLOUD_KETTLE){
        typeArr =[[NSArray alloc]initWithObjects:@"煮水",@"煮水除氯",@"保温", nil];
        [typeLbl setText:[typeArr objectAtIndex:self.selectedType]];
    } else if (self.model.deviceType==COOKFOOD_KETTLE){
        typeArr =[[NSArray alloc]initWithObjects:@"三杯鸡",@"黄焖鸡",@"红烧鱼",@"红焖排骨",@"清炖鸡",@"老火汤",@"红烧肉",@"东坡肘子",@"口水鸡",@"滑香鸡",@"茄子煲",@"梅菜扣肉",nil];
        [typeLbl setText:[typeArr objectAtIndex:self.selectedType]];
    }
    else{
        typeArr =[[NSArray alloc]initWithObjects:@"精华煮",@"超快煮",@"煮粥",@"蒸煮",@"热饭",@"营养保温",@"煲汤", nil];
        [typeLbl setText:[typeArr objectAtIndex:self.selectedType]];
        
        if (self.selectedType==2) {
            minHours   = 0;
            minMinutes = 50;
            maxHours   = 2;
            maxMinutes = 0;
            defaultHour = 1;
            defaultMinute = 30;
            
        }else if (self.selectedType==3){
            minHours   = 0;
            minMinutes = 45;
            maxHours   = 2;
            maxMinutes = 0;
            defaultHour = 1;
            defaultMinute = 0;
        }else if (self.selectedType==6){
            minHours   = 1;
            minMinutes = 30;
            maxHours   = 4;
            maxMinutes = 0;
            defaultHour = 2;
            defaultMinute = 0;
        }
    }
    
    //圆角
    completeBtn.layer.masksToBounds=YES;
    completeBtn.layer.cornerRadius=20.0f;
    
    if ([typeLbl.text isEqualToString:@"保温"]||[typeLbl.text isEqualToString:@"营养保温"]||[typeLbl.text isEqualToString:@"热饭"]||[typeLbl.text isEqualToString:@"超快煮"]||[typeLbl.text isEqualToString:@"精华煮"]||(self.model.deviceType==CLOUD_COOKER&&[typeLbl.text isEqualToString:@"煮粥"])||self.model.deviceType==CLOUD_KETTLE||self.model.deviceType==COOKFOOD_KETTLE) {
        
        //某些功能不需要设置时间
        [self hiddenTimePicker];
    }
    
    [self setDefaultTime];
}

///默认时间
- (void)setDefaultTime {
    if (minHours > 0) {
        defaultHour -= 1;
    }
    if (defaultHour == 0) {
        defaultMinute = defaultMinute - minMinutes;
    }
    [timePicker selectRow:defaultHour inComponent:0 animated:false];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self pickerView:timePicker didSelectRow:defaultHour inComponent:0];
        [timePicker selectRow:defaultMinute inComponent:1 animated:false];
        [self pickerView:timePicker didSelectRow:defaultMinute inComponent:1];
    });
    
}

-(void)hiddenTimePicker{
    timeLbl.hidden=YES;
    timePickerView.hidden=YES;
    
    CGRect BtnRect=completeBtn.frame;
    
    BtnRect.origin.y=timePickerView.frame.origin.y;
    
    completeBtn.frame=BtnRect;
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeSyncData object:nil];

}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnConnectDevice object:nil];
     [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
     [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
     [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
     [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnDeviceStateChanged object:nil];

}


#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
        return 2;
 
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            if (minHours > 0) {
                return maxHours;
            } else {
                return maxHours+1;
            }
            break;
        case 1:
            if ([pickerView selectedRowInComponent:0]==0) {
                return 60-minMinutes;
            }else if ([pickerView selectedRowInComponent:0]==maxHours - minHours){
                return maxMinutes+1;
            }else{
                return 60;
            }
            break;
        default:
            return 1;
            break;
    }
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = view ? (UILabel *) view : [[UILabel alloc] initWithFrame:CGRectMake(50.0f, 0.0f, 90.0f, 30.0f)];
    if (component == 0) {
        if (minHours > 0) {
            myView.text = [NSString stringWithFormat:@"%ld", (long)row+1];
        } else {
            myView.text = [NSString stringWithFormat:@"%ld", (long)row];
        }
    } else if (component == 1) {
        if ([pickerView selectedRowInComponent:0]==0) {
            myView.text = [NSString stringWithFormat:@"%d", row+minMinutes];
        }else{
                myView.text = [NSString stringWithFormat:@"%ld", (long)row];
        }

        
    } else if(component==2){
        myView.text = @"小时";
    }else{
        myView.text = @"分钟";
    }
    myView.textAlignment = NSTextAlignmentCenter;
    
    myView.backgroundColor = [UIColor clearColor];
    

    return myView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
            
            if (row==minHours||row==maxHours - minHours) {
                [self reloadComponent1];
            }else if([pickerView numberOfRowsInComponent:1]!=60){
                [self reloadComponent1];
            } else if (minHours > 0 && row==minHours-1) {
                [self reloadComponent1];
            }
            
            break;
        case 1:
            break;
        default:
            break;
    }
    
    UILabel *label;
    label=(UILabel *)[pickerView viewForRow:row forComponent:component];
    [label setTextColor:UIColorFromRGB(0xff8314)];
    if (component==0) {
        label.text=[NSString stringWithFormat:@"%i小时",label.text.integerValue];
    }else{
        label.text=[NSString stringWithFormat:@"%i分钟",label.text.integerValue];
    }
    
}

- (void)reloadComponent1 {
    [timePicker reloadComponent:1];
    NSInteger curRow = [timePicker selectedRowInComponent:1];
    [self pickerView:timePicker didSelectRow:curRow inComponent:1];
}

-(IBAction)completeSetting:(id)sender{

    DeviceModel *controlModel=[[DeviceModel alloc]init];
    controlModel.deviceID=self.model.deviceID;
    controlModel.deviceType=self.model.deviceType;
    controlModel.deviceName=self.model.deviceName;
    controlModel.mac=self.model.mac;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    [dic setObject:[typeArr objectAtIndex:self.selectedType] forKey:@"state"];
    
    //by liang
    if (self.model.deviceType == ELECTRIC_COOKER && [[typeArr objectAtIndex:self.selectedType] isEqualToString:@"煲汤"]) {
        //煲汤最小为一个半小时，所以需要+1
        [dic setObject:[NSString stringWithFormat:@"%li",(long)[timePicker selectedRowInComponent:0]+1] forKey:@"WorkHour"];
    }else{
        [dic setObject:[NSString stringWithFormat:@"%li",(long)[timePicker selectedRowInComponent:0]] forKey:@"WorkHour"];
    }
    
    
    [dic setObject:[NSString stringWithFormat:@"%li",[timePicker selectedRowInComponent:0]==0?(long)[timePicker selectedRowInComponent:1]+minMinutes:(long)[timePicker selectedRowInComponent:1]] forKey:@"WorkMin"];
    
    controlModel.State=dic;
    
    [[ControllerHelper shareHelper]setDevicePreference:controlModel]; //发送命令
    
}

#pragma mark Device Delegate
-(void)OnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    [NSUserDefaultInfos putKey:@"name" andValue:[self.model.State objectForKey:@"name"]];
    if ([[device getMacAddressSimple]isEqualToString:self.model.mac]) {
        ///如果是设置偏好命令的返回就隐藏
        uint32_t cmd_len = (uint32_t)[recvData length];
        uint8_t cmd_data[cmd_len];
        memset(cmd_data, 0, cmd_len);
        [recvData getBytes:(void *)cmd_data length:cmd_len];
        if (cmd_data[0]==0x13) {
            PreferenceModel *pModel=[[PreferenceModel alloc]init];
            pModel.preferenceName=[typeArr objectAtIndex:self.selectedType];
            pModel.preferenceType=TYPE_WORKTYPE;
//            pModel.preferenceHour=timePickerView.isHidden?@"--":[NSString stringWithFormat:@"%li",(long)[timePicker selectedRowInComponent:0]];

            //by liang
            if (self.model.deviceType == ELECTRIC_COOKER && [[typeArr objectAtIndex:self.selectedType] isEqualToString:@"煲汤"]) {
                //煲汤最小为一个半小时，所以需要+1
                pModel.preferenceHour=timePickerView.isHidden?@"--":[NSString stringWithFormat:@"%li",(long)[timePicker selectedRowInComponent:0]+1];
            }else{
                pModel.preferenceHour=timePickerView.isHidden?@"--":[NSString stringWithFormat:@"%li",(long)[timePicker selectedRowInComponent:0]];
            }
            
            pModel.preferenceMin=timePickerView.isHidden?@"--":[timePicker selectedRowInComponent:0]==0?[NSString stringWithFormat:@"%li",(long)[timePicker selectedRowInComponent:1]+minMinutes]:[NSString stringWithFormat:@"%li",(long)[timePicker selectedRowInComponent:1]];

                dispatch_sync(dispatch_get_main_queue(), ^{
                      [[ControllerHelper shareHelper]dismissProgressView];
                    
                    //连续返回两级
                    NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
                    
                    PreferenceViewController *PreferenceVC=[self.navigationController.viewControllers objectAtIndex:index-2];
                    [PreferenceVC updateUI:pModel];
                    
                    [self.navigationController popToViewController:PreferenceVC animated:YES];
                });
        }

    }
    
}



@end
