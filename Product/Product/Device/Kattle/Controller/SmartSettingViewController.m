//
//  SmartSettingViewController.m
//  Product
//
//  Created by Feng on 16/3/19.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "SmartSettingViewController.h"
#import "TimePickerView.h"
#import "ControllerHelper.h"
#import "NSData+Extension.h"

//手动重置弹框
#import "DeviceViewController.h"
#import "DeviceConnectStateCheckService.h"
#import "DeviceHelper.h"

@interface SmartSettingViewController ()<UIAlertViewDelegate>{

    TimePickerView *picker;
}

@end

@implementation SmartSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"智能设置";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    //离线界面处理
    if (!self.model.isOnline) {
        temBtn.enabled=NO;
        [temBtn setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
        chlorineSwith.enabled=NO;
    }else{
        temBtn.enabled=YES;
       [temBtn setBackgroundColor:[UIColor clearColor]];
        chlorineSwith.enabled=YES;
    }
    if (self.model.Attribute==nil) {
        self.model.Attribute=[[NSMutableDictionary alloc]init];
    }
    
    [self initValue];
    
    [[ControllerHelper shareHelper]getDeviceAttribute:self.model];
    
}

-(void)initValue{
    chlorineSwith.on=[NSUserDefaultInfos getIntValueforKey:DEFAULT_CHLORINE];
    temValueLbl.text=[NSString stringWithFormat:@"%i℃",[NSUserDefaultInfos getIntValueforKey:DEFAULT_TEM]?[NSUserDefaultInfos getIntValueforKey:DEFAULT_TEM]:80];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeSyncData object:nil];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
}


-(IBAction)selectChlorine:(id)sender{
    [self.model.Attribute setObject:@"煮水" forKey:@"attribute"];
    [self.model.Attribute setObject:chlorineSwith.isOn?@"01":@"00" forKey:@"chlorine"];
    [[ControllerHelper shareHelper] setDeviceAttribute:self.model];
}

-(IBAction)selectTem:(id)sender{
    picker=[[TimePickerView alloc]initWithTitle:@"默认保温设置" delegate:self];
    picker.pickerStyle=PickerStyle_Tem;
    NSInteger selectRow=100-temValueLbl.text.integerValue ;
    [picker.locatePicker selectRow:selectRow inComponent:0 animated:YES];
    [picker showInView:self.view];
    [picker pickerView:picker.locatePicker didSelectRow:selectRow inComponent:0];
}

#pragma mark pickerview回调
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        
        return;
    }else{
        if (picker.pickerStyle==PickerStyle_Tem) {
            temValueLbl.text=[NSString stringWithFormat:@"%li℃",100-[picker.locatePicker selectedRowInComponent:0]];
            
            //发送数据
            [self.model.Attribute setObject:@"保温" forKey:@"attribute"];
            [self.model.Attribute setObject:[NSString stringWithFormat:@"%ld",
                                             100-[picker.locatePicker selectedRowInComponent:0]] forKey:@"tem"];
            [[ControllerHelper shareHelper]setDeviceAttribute:self.model];
        }
    }
    
}

#pragma mark SDK
-(void)OnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    [NSUserDefaultInfos putKey:@"name" andValue:[self.model.State objectForKey:@"name"]];
    uint32_t cmd_len = (uint32_t)[recvData length];
    uint8_t cmd_data[cmd_len];
    memset(cmd_data, 0, cmd_len);
    [recvData getBytes:(void *)cmd_data length:cmd_len];
    
    NSLog(@"Attribute Data Transmit recv: %@", [recvData hexString]);
    
    if ([[device getMacAddressSimple]isEqualToString:self.model.mac]) {
        if (cmd_data[0]==0x13&&(cmd_data[3]==0x06||cmd_data[3]==0x04)) {
            //设置成功
            [[ControllerHelper shareHelper]dismissProgressView];
            
            [self showAlertWithTitle:nil Message:@"设置成功"];
            if (cmd_data[3]==0x04) {
                //煮水属性
                [NSUserDefaultInfos putInt:DEFAULT_CHLORINE andValue:cmd_data[4]];
                
            }else if (cmd_data[3]==0x06){
            //保温属性
                [NSUserDefaultInfos putInt:DEFAULT_TEM andValue:cmd_data[4]];
   
            }
            
        }else if (cmd_data[0]==0x11&&(cmd_data[3]==0x06||cmd_data[3]==0x04)){
        //获取成功
            [[ControllerHelper shareHelper]dismissProgressView];
            
            if (cmd_data[3]==0x04) {
                //煮水属性
                [NSUserDefaultInfos putInt:DEFAULT_CHLORINE andValue:cmd_data[4]];
                
            }else if (cmd_data[3]==0x06){
                //保温属性
                [NSUserDefaultInfos putInt:DEFAULT_TEM andValue:cmd_data[4]];
 
            }
    
           [self performSelectorOnMainThread:@selector(initValue) withObject:nil waitUntilDone:NO];
        }
    }
}


@end
