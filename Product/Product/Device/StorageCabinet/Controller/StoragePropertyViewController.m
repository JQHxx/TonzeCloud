//
//  StoragePropertyViewController.m
//  Product
//
//  Created by vision on 17/10/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StoragePropertyViewController.h"
#import "StorageDeviceHelper.h"
#import "TimePickerView.h"

@interface StoragePropertyViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger          humidity;
    NSInteger          temperature;
    
    TimePickerView          *Picker;
    
}

@property (nonatomic,strong)UITableView *propertyTableView;

@end

@implementation StoragePropertyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"储物区设置";
    
    humidity=self.getHumidity;
    temperature=self.getTemprature;
    [self.view addSubview:self.propertyTableView];
    
    [[StorageDeviceHelper sharedStorageDeviceHelper] storageDeviceMac:self.model.mac SendDataForType:StorageDeviceSendTypeGetHumidity withValue:0]; //获取储物区湿度
    [[StorageDeviceHelper sharedStorageDeviceHelper] storageDeviceMac:self.model.mac SendDataForType:StorageDeviceSendTypeGetTemperature withValue:0]; //获取储物区温度
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storagePropertyOnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storagePropertyOnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storagePropertyOnPipeData:) name:kOnRecvPipeSyncData object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnRecvPipeSyncData object:nil];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text=indexPath.row==0?@"湿度":@"温度";
    cell.detailTextLabel.text=indexPath.row==0?[NSString stringWithFormat:@"%ld%%",(long)humidity]:[NSString stringWithFormat:@"%ld°C",(long)temperature];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *titleStr=nil;
    PickerStyle style;
    NSInteger rowValue;
    if (indexPath.row==0) {
        humidity = humidity<50?55:humidity;
        titleStr=@"湿度设置";
        style=PickerStyle_Humidity;
        rowValue=humidity-50;
    }else{
        temperature = temperature<13?16:temperature;
        titleStr=@"温度设置";
        style=PickerStyle_Temperature;
        rowValue=temperature-13;
    }
    
    Picker =[[TimePickerView alloc] initWithTitle:titleStr delegate:self];
    Picker.pickerStyle=style;
    [Picker.locatePicker selectRow:rowValue inComponent:0 animated:YES];
    [Picker showInView:self.view];
    [Picker pickerView:Picker.locatePicker didSelectRow:rowValue inComponent:0];
}

#pragma mark TimePickerViewDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (Picker.pickerStyle==PickerStyle_Humidity) {
            humidity = [Picker.locatePicker selectedRowInComponent:0]+50;  //湿度
            [[StorageDeviceHelper sharedStorageDeviceHelper] storageDeviceMac:self.model.mac SendDataForType:StorageDeviceSendTypeHumidity withValue:humidity]; //设置储物区湿度
        }else if (Picker.pickerStyle==PickerStyle_Temperature){
            temperature = [Picker.locatePicker selectedRowInComponent:0]+13;//温度
            [[StorageDeviceHelper sharedStorageDeviceHelper] storageDeviceMac:self.model.mac SendDataForType:StorageDeviceSendTypeTemperature withValue:temperature]; //设置储物区温度
        }
    }
}

#pragma mark -- NSNotification
-(void)storagePropertyOnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    if ([[device getMacAddressSimple] isEqualToString:self.model.mac]) {
        MyLog(@"storagePropertyOnPipeData = %s: %@", __func__, [recvData hexString]); //00 00 00 00 00 12 00 00 01 14 0D 02 19 06 46 02
        ///如果是控制命令的返回就隐藏
        uint32_t cmd_len = (uint32_t)[recvData length];
        uint8_t cmd_data[cmd_len];
        memset(cmd_data, 0, cmd_len);
        [recvData getBytes:(void *)cmd_data length:cmd_len];
        
        if (cmd_data[5]==0x11){
            MyLog(@"-----------智能厨物柜获取设备属性成功------------");
            if (cmd_data[8]==0x02) {
                humidity=cmd_data[9];
            }else if (cmd_data[8]==0x03){
                temperature=cmd_data[9];
            }
            __weak typeof(self) weakSelf=self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakSelf.propertyTableView reloadData];
                });
            });
        }else if (cmd_data[5]==0x13){
            NSString *messageStr=nil;
            if (cmd_data[8]==0x02) {
                humidity=cmd_data[9];
                messageStr=[NSString stringWithFormat:@"成功设置储物区湿度为%ld%%",(long)humidity];
            }else if (cmd_data[8]==0x03){
                temperature=cmd_data[9];
                messageStr=[NSString stringWithFormat:@"成功设置储物区温度为%ld°C",(long)temperature];
            }
            __weak typeof(self) weakSelf=self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakSelf.view makeToast:messageStr duration:1.0 position:CSToastPositionCenter];
                    [weakSelf.propertyTableView reloadData];
                });
            });
        }
        
    }
}


#pragma mark -- Getters
-(UITableView *)propertyTableView{
    if (!_propertyTableView) {
        _propertyTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kRootViewHeight) style:UITableViewStylePlain];
        _propertyTableView.dataSource=self;
        _propertyTableView.delegate=self;
        _propertyTableView.tableFooterView=[[UIView alloc] init];
        _propertyTableView.backgroundColor=[UIColor bgColor_Gray];
    }
    return _propertyTableView;
}




@end
