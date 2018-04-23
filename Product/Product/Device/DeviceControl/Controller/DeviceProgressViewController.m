//
//  DeviceProgressViewController.m
//  Product
//
//  Created by Xlink on 16/1/21.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DeviceProgressViewController.h"
#import "DeviceDefines.h"
#import "DeviceHelper.h"
#import "ControllerHelper.h"
#import "Transform.h"
#import "XLinkExportObject.h"
#import "TimePickerView.h"
#import "UpgradeViewController.h"
#import "ShareListViewController.h"
#import "AppDelegate.h"
#import "DeviceProgressCell.h"
#import "SmartSettingViewController.h"
#import "DrinkPlanViewController.h"
#import "DeviceFunctionViewController.h"
#import "NSData+Extension.h"
#import "DeviceStateListener.h"
#import "DeviceConnectStateCheckService.h"
#import "DeviceViewController.h"
#import "DeviceHelper.h"
#import "AutoLoginManager.h"
#import "LiuXSlider.h"
#import "LSPaoMaView.h"
#import "SVProgressHUD.h"

@interface DeviceProgressViewController ()<UITextFieldDelegate,UIAlertViewDelegate>{
    TimePickerView      * timePicker;
    BOOL                isResetTime;   //是否正在重置时间
    BOOL                needPopToView; //是否需要返回
    DeviceModel         * cacheModel;
    UIAlertAction       * OkBtnEnabledAction;

    NSTimer             * getProgressTimer;
    AppDelegate         * appDelegate;

    NSNumber            * maxHours;
    NSNumber            * minHours;
    NSNumber            * minMinutes;

    UILabel             * textLabel;
    LiuXSlider          * slider;
    LSPaoMaView         * paomav;
    int                 fireNumber;
    int                 paoma;
}

@end

@implementation DeviceProgressViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=self.model.deviceName;
    self.rightImageName=@"更多";
    
    textLabel = [[UILabel alloc] init];
    paoma = 1;
    appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    needPopToView=YES;
    isResetTime=NO;
    
    cacheModel=nil;
    
    [self initDeviceProgressView];
    [self updateUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnConnectDevice:) name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnDeviceStateChanged:) name:kOnDeviceStateChanged object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnAppStateChange) name:kOnAppStateChanged object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeSyncData object:nil];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnDeviceStateChanged object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnAppStateChanged object:nil];
    
    if (getProgressTimer) {
        [getProgressTimer invalidate];
        getProgressTimer=nil;
    }
    [SVProgressHUD dismiss];
}

#pragma mark --UITableViewDelegate and UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.model.deviceType ==COOKFOOD_KETTLE) {
        if ([[self.model.State objectForKey:@"progress"]integerValue]==0x01) {
            return 3;
        } else {
            return 2;
        }
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"DeviceProgressCell";
    DeviceProgressCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (self.model.deviceType==CLOUD_COOKER) {
        //云炖锅
        cell=[self setCloudCookerCellDetailWithCell:cell Row:indexPath.row];
        if ([self.model.State[@"state"] isEqualToString:@"炖汤"]) {
            maxHours = @(24);
            minHours = @(0);
            minMinutes = @(1);
        }
    }else if (self.model.deviceType==WATER_COOKER || self.model.deviceType==WATER_COOKER_16AIG){
        //隔水炖 & 隔水炖16AIG
        cell=[self setWaterCookerCellDetailWithCell:cell Row:indexPath.row];
        if ([self.model.State[@"state"] isEqualToString:@"炖煮"]) {
            maxHours = @(24);
            minHours = @(0);
            minMinutes = @(1);
        }
    }else if (self.model.deviceType==COOKFOOD_KETTLE){
        //炒菜锅
        cell=[self setCookFoodCellDetailWithCell:cell Row:indexPath.row];
        if ([self.model.State[@"state"] isEqualToString:@"手动烹饪"]) {
            maxHours = @(12);
            minHours = @(0);
            minMinutes = @(1);
        }
    }else if (self.model.deviceType==ELECTRIC_COOKER){
        //电饭煲
        cell=[self setElectricCookerCellDetailWithCell:cell Row:indexPath.row];
        if ([self.model.State[@"state"] isEqualToString:@"煲汤"]) {
            maxHours = @(4);
            minHours = @(1);
            minMinutes = @(30);
        }
        
        if ([self.model.State[@"state"] isEqualToString:@"煮粥"]) {
            maxHours = @(2);
            minHours = @(0);
            minMinutes = @(50);
        }
        
        if ([self.model.State[@"state"] isEqualToString:@"蒸煮"]) {
            maxHours = @(2);
            minHours = @(0);
            minMinutes = @(45);
        }
        if ([self.model.State[@"state"] isEqualToString:@"营养保温"]) {
            maxHours = @(24);
            minHours = @(0);
            minMinutes = @(1);
        }
    }else if (self.model.deviceType==CLOUD_KETTLE){
        [self setCloudKettleCellDetailWithCell:cell Row:indexPath.row];
        
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    if (indexPath.row==2) {
        cell.lineLbl.hidden=YES;
    }else{
        cell.lineLbl.hidden=NO;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType==UITableViewCellAccessoryDisclosureIndicator) {
        timePicker =[[TimePickerView alloc]initWithTitle:@"烹饪时间" delegate:self];
        timePicker.timeDisplayIn24=YES;
        timePicker.isSetTime=YES;
        timePicker.pickerStyle=PickerStyle_setRunTime;
        
        timePicker.maxHours = maxHours;
        timePicker.minHours = minHours;
        timePicker.minMinutes = minMinutes;
        
        NSInteger selectHour=[cell.detailTextLabel.text substringToIndex:2].integerValue-minHours.intValue;
        NSInteger selectMin=[cell.detailTextLabel.text substringFromIndex:selectHour>9?4:3].integerValue;
        
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

#pragma mark UIActionSheetDelegate (TimePickerView)
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        //确定
        NSInteger hour=[timePicker.locatePicker selectedRowInComponent:0]+minHours.integerValue;
        NSInteger min;
        if (hour==minHours.integerValue) {
            min=[timePicker.locatePicker selectedRowInComponent:1]+minMinutes.integerValue;
        }else{
            min=[timePicker.locatePicker selectedRowInComponent:1];
        }
        [self.model.State setObject:hour<10?[NSString stringWithFormat:@"0%li",(long)hour]:[NSString stringWithFormat:@"%li",(long)hour] forKey:@"WorkHour"];
        [self.model.State setObject:min<10?[NSString stringWithFormat:@"0%li",(long)min]:[NSString stringWithFormat:@"%li",(long)min] forKey:@"WorkMin"];
        int percent = [[self.model.State objectForKey:@"percent"] intValue]-1;
        NSString *fire  = [NSString stringWithFormat:@"%d",percent];
        [self.model.State setObject:fire forKey:@"firetext"];
        [self resetControllTime];
    }
}

#pragma mark UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text.length>16||textField.text.length<1) {
        [self showAlertWithTitle:@"提示" Message:@"仅支持1-16个字符"];
    }
    return YES;
}

#pragma mark --NSNotification Methods
#pragma mark APP前后台切换
-(void)OnAppStateChange{
    if (appDelegate.isBackground) {
        if (getProgressTimer) {
            [getProgressTimer invalidate];
            getProgressTimer=nil;
        }
    }else{
        [self getDeviceProgress];
        if (!getProgressTimer) {
            getProgressTimer=[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(getDeviceProgress) userInfo:nil repeats:YES];
        }
    }
}

#pragma mark 键盘操作
- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    OkBtnEnabledAction.enabled = textField.text.length >= 1;
}

#pragma mark 设备连接
- (void)OnConnectDevice:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *Data=[Transform nsstringToHex:@"120000"];
    isResetTime=NO;
    //获取最新状态
    if (device.isWANOnline) {
        [[XLinkExportObject sharedObject]sendPipeData:device andPayload:Data];
    }else{
        [[XLinkExportObject sharedObject]sendLocalPipeData:device andPayload:Data];
    }
}
#pragma mark 设备接收信息
-(void)OnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    self.model.deviceName=[DeviceHelper getDeviceName:device];
    [NSUserDefaultInfos putKey:@"name" andValue:[self.model.State objectForKey:@"name"]];
    if ([[device getMacAddressSimple]isEqualToString:self.model.mac]) {
        NSData *recvData=[dict objectForKey:@"payload"];
        NSLog(@"OnPipeData = %s: %@", __func__, [recvData hexString]);
        ///如果是控制命令的返回就隐藏
        uint32_t cmd_len = (uint32_t)[recvData length];
        uint8_t cmd_data[cmd_len];
        memset(cmd_data, 0, cmd_len);
        [recvData getBytes:(void *)cmd_data length:cmd_len];
        
        if (cmd_data[0]==0x16&&self.model.role==0) {
            //重置设备返回命令
            [[ControllerHelper shareHelper]dismissProgressView];
            [self disbindingDevice];
            return;
        }
        if (cacheModel!=nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(resetControllTime) withObject:nil afterDelay:0.5f];
                });
            });
        }else{
            if (cmd_data[0]==0x14) {
                [[ControllerHelper shareHelper]dismissProgressView];
            }
            self.model.isOnline=YES;
            [[AutoLoginManager shareManager] getDeviceList];
            NSMutableDictionary *dic=[DeviceHelper getStateDicWithDevice:device Data:recvData];
        
            if (dic) {
                self.model.State=dic;
                if (![[dic objectForKey:@"state"]isEqualToString:@"空闲"]) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self updateUI];
                        });
                    });
                    
                }else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            if (!needPopToView) {
                                needPopToView=YES;
                            }else{
                                if (!self.navigationController.isMovingToParentViewController) {
                                    [[NSNotificationCenter defaultCenter]postNotificationName:kDeviceViewUpdateUI object:self.model];
                                    [[NSNotificationCenter defaultCenter]postNotificationName:@"DeviceFunctionViewUpdateUI" object:self.model];
                                    
                                    if (!self.navigationController.isMovingToParentViewController) {
                                        if ([[self.model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]||[stateLbl.text isEqualToString:@"偏好"]) {
                                            //如果是云菜谱或者偏好就连续返回两级
                                            NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
                                            if (index<2) {
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }else{
                                                DeviceFunctionViewController *functionVC=[self.navigationController.viewControllers objectAtIndex:index-2];
                                                [self.navigationController popToViewController:functionVC animated:YES];
                                            }
                                        }else{
                                            //转跳到设备控制界面
                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                dispatch_sync(dispatch_get_main_queue(), ^{
                                                    //推出self
                                                    if (_index==1) {
                                                        [self.navigationController popViewControllerAnimated:YES];
                                                    }else{
                                                    NSInteger count = self.navigationController.viewControllers.count;
                                                    if (![self.navigationController.viewControllers[count-2] isKindOfClass:[DeviceFunctionViewController class]]) {
                                                        //如果前一个VC不是DeviceFunctionViewController， 则插入DeviceFunctionViewController到前一个位置
                                                        DeviceFunctionViewController *functionVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DeviceFunctionViewController"];
                                                        functionVC.model = self.model;
                                                        NSMutableArray *copyVCs = self.navigationController.viewControllers.mutableCopy;
                                                        [copyVCs insertObject:functionVC atIndex:count-1];
                                                        self.navigationController.viewControllers = copyVCs;
                                                    }
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                    }
                                                });
                                            });
                                        }
                                    }
                                }
                            }
                        });
                    });
                }
            }
        }
    }
}

#pragma mark 设备状态变化
- (void)OnDeviceStateChanged:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    
    if ([[device getMacAddressSimple ]isEqualToString:self.model.mac]) {
        //当设备状态改变才更新界面
        if (device.isConnected) {
            self.model.isOnline=YES;
            [self.model.State setObject:@"在线" forKey:@"state"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // Do time-consuming task in background thread
                // Return back to main thread to update UI
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self updateUI];
                });
            });
        }else{
            self.model.isOnline=NO;
            [self.model.State setObject:@"离线" forKey:@"state"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //推出self
                    NSInteger count = self.navigationController.viewControllers.count;
                    if (![self.navigationController.viewControllers[count-2] isKindOfClass:[DeviceFunctionViewController class]]) {
                        //如果前一个VC不是DeviceFunctionViewController， 则插入DeviceFunctionViewController到前一个位置
                        DeviceFunctionViewController *functionVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DeviceFunctionViewController"];
                        functionVC.model = self.model;
                        NSMutableArray *copyVCs = self.navigationController.viewControllers.mutableCopy;
                        [copyVCs insertObject:functionVC atIndex:count-1];
                        self.navigationController.viewControllers = copyVCs;
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                });
            });
        }
    }
}

#pragma mark --Response Methods
#pragma mark 返回事件
-(void)leftButtonAction{
    NSArray *vcArray = self.navigationController.viewControllers;
    for(UIViewController *vc in vcArray){
        if ([vc isKindOfClass:[DeviceViewController class]]){
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

#pragma mark 导航栏更多事件
-(void)rightButtonAction{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *shareButtonTitle = NSLocalizedString(@"分享管理", nil);
    NSString *updateButtonTitle = NSLocalizedString(@"固件升级", nil);
    NSString *renameButtonTitle = NSLocalizedString(@"重命名", nil);
    NSString *deleteButtonTitle = NSLocalizedString(@"删除", nil);
    
    __block __typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:shareButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf performSegueWithIdentifier:@"toShareListView" sender:nil];
    }];
    
    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:updateButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UpgradeViewController *upgradeVC=[[UpgradeViewController alloc]initWithNibName:@"UpgradeViewController" bundle:nil];
        upgradeVC.deviceType=weakSelf.model.deviceType;
        upgradeVC.device=[[ControllerHelper shareHelper]getNeedControllDevice:weakSelf.model.mac];
        [weakSelf.navigationController pushViewController:upgradeVC animated:YES];
    }];
    
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:renameButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf showNameAlertController];
    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf showDeleteAlertController];
    }];
    
    [alertController addAction:renameAction];
    
    if (self.model.role ==0) {
        [alertController addAction:shareAction];
        [alertController addAction:updateAction];
    }
    
    [alertController addAction:cancelAction];
    
    if (self.model.deviceType==CLOUD_KETTLE) {
        NSString *smartButtonTitle = NSLocalizedString(@"智能设置", nil);
        NSString *planButtonTitle = NSLocalizedString(@"饮水计划", nil);
        UIAlertAction *smartAction = [UIAlertAction actionWithTitle:smartButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf performSegueWithIdentifier:@"toSmartSettingView" sender:nil];
        }];
        
        UIAlertAction *planAction = [UIAlertAction actionWithTitle:planButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf performSegueWithIdentifier:@"toDrinkPlanView" sender:nil];
        }];
        [alertController addAction:smartAction];
        [alertController addAction:planAction];
    }
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 跳转事件
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toShareListView"]){
        ShareListViewController *shareListVC=[segue destinationViewController];
        shareListVC.model=self.model;
        
    }else if ([segue.identifier isEqualToString:@"toSmartSettingView"]){
        SmartSettingViewController *smartVC=[segue destinationViewController];
        smartVC.model=self.model;
        
    }else if ([segue.identifier isEqualToString:@"toDrinkPlanView"]){
        DrinkPlanViewController *planVC=[segue destinationViewController];
        planVC.model=self.model;
    }
}

#pragma mark 取消操作
-(IBAction)cancelFunction:(id)sender{
    self.model.State=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"空闲",@"state", nil];
    isResetTime=NO;
    needPopToView=YES;
    [[ControllerHelper shareHelper]controllDevice:self.model];
}

#pragma mark --Custom Methods
#pragma mark 初始化界面
-(void)initDeviceProgressView{
    detailTB.layer.masksToBounds=YES;
    detailTB.layer.cornerRadius=10.0f;
    cancelBtn.layer.masksToBounds=YES;
    cancelBtn.layer.cornerRadius=20.0f;
    
    if (self.model.deviceType == COOKFOOD_KETTLE) {
        progressLbl.hidden = YES;
        progressView.hidden = YES;
        slider = [[LiuXSlider alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/320*22, 0,self.view.bounds.size.width/320*264, 40) titles:@[@"10％火力",@"20％火力",@"30％火力",@"40％火力",@"50％火力",@"60％火力",@"70％火力",@"80％火力",@"90％火力",@"100％火力"] firstAndLastTitles:@[@"10％",@"100％"]  defaultIndex:1 sliderImage:[UIImage imageNamed:@"ic_on"] bgImage:[UIImage imageNamed:@"bar_nor"] coverImage:[UIImage imageNamed:@"bar_hl"]];
        slider.rightImage.hidden = NO;
        slider.leftImage.hidden = NO;
        slider.leftLabel.hidden = YES;
        slider.rightLabel.hidden = YES;
        if (![[self.model.State objectForKey:@"state"]  isEqual:@"手动烹饪"]) {
            slider.userInteractionEnabled = NO;
        }
        [bgCookView addSubview:slider];
        
        __block DeviceProgressViewController *blockSelf = self;
        slider.block=^(int index){
            //火力值为index＋1
            if ([[blockSelf.model.State objectForKey:@"state"]  isEqual:@"手动烹饪"]) {
                NSLog(@"当前index==%d",index);
                if ([[blockSelf.model.State objectForKey:@"WorkHour"]isEqualToString:@"102"]&&[[blockSelf.model.State objectForKey:@"WorkMin"]isEqualToString:@"102"]) {
                    [blockSelf.model.State setObject:@"00" forKey:@"WorkHour"];
                    [blockSelf.model.State setObject:@"00" forKey:@"WorkMin"];
                }
                NSString *str = [[NSString alloc] initWithFormat:@"%d",index];
                [blockSelf.model.State setObject:str forKey:@"firetext"];
                [[ControllerHelper shareHelper]controllDevice:blockSelf.model];
            }
        };
    }else{
        progressView = [[YSProgressView alloc] initWithFrame:CGRectMake(0, 0, proBgView.frame.size.width, proBgView.frame.size.height)];
        [proBgView addSubview:progressView];
    }
}

#pragma mark 更新界面
-(void)updateUI{
    paomav.hidden = YES;
    stateLbl.textColor = [UIColor whiteColor];
    if (self.model.deviceType==CLOUD_COOKER) {
        //云炖锅
        [typeIV setImage:[UIImage imageNamed:@"设备控制云炖锅"]];
        stateLbl.text=[[self.model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]?[self.model.State objectForKey:@"name"]:[self.model.State objectForKey:@"state"];
        [onlineIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
        
        
        switch ([[self.model.State objectForKey:@"progress"] integerValue]) {
            case PRO_ORDER:
                [stateIV setImage:[UIImage imageNamed:@"云炖锅预约阶段"]];
                break;
            case PRO_WARMING:
                [stateIV setImage:[UIImage imageNamed:@"云炖锅升温阶段"]];
                break;
            case PRO_LITTLE_FIRE:
                [stateIV setImage:[UIImage imageNamed:@"云炖锅小火精炖阶段"]];
                break;
            case PRO_CONSTANT_TEM:
                [stateIV setImage:[UIImage imageNamed:@"云炖锅恒温精炖阶段"]];
                break;
            case PRO_BIG_FIRE:
                [stateIV setImage:[UIImage imageNamed:@"云炖锅大火快炖阶段"]];
                break;
            case PRO_LITTLE_FIR_SLOW:
                [stateIV setImage:[UIImage imageNamed:@"云炖锅小火慢熬阶段"]];
                break;
            case PRO_COOLING:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲降温阶段"]];
                break;
            case PRO_KEEP_TEM:
                [stateIV setImage:[UIImage imageNamed:@"云炖锅营养保温"]];
                break;
            default:
                break;
        }
        
    }else if (self.model.deviceType==WATER_COOKER || self.model.deviceType==WATER_COOKER_16AIG){
        //隔水炖
        if (self.model.deviceType==WATER_COOKER) {
            [typeIV setImage:[UIImage imageNamed:@"设备控制隔水炖"]];
        }else{
            [typeIV setImage:[UIImage imageNamed:@"geshuidun2_control"]];
        }
        stateLbl.text=[[self.model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]?[self.model.State objectForKey:@"name"]:[self.model.State objectForKey:@"state"];
        [onlineIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
        
        //因为每个设备的协议对阶段的命名都不一样，这里不做名字适配，用0x01判断。详细定义见协议
        switch ([[self.model.State objectForKey:@"progress"] integerValue]) {
            case 0x01:
                [stateIV setImage:[UIImage imageNamed:@"隔水炖预约阶段"]];
                break;
            case 0x02:
                [stateIV setImage:[UIImage imageNamed:@"隔水炖升温阶段"]];
                break;
            case 0x03:
                [stateIV setImage:[UIImage imageNamed:@"隔水炖小沸精炖阶段"]];
                break;
            case 0x05:
                [stateIV setImage:[UIImage imageNamed:@"隔水炖恒温精炖阶段"]];
                break;
            case 0x06:
                [stateIV setImage:[UIImage imageNamed:@"隔水炖沸腾快炖阶段"]];
                break;
            case 0x07:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲降温阶段"]];
                break;
            case 0x08:
                [stateIV setImage:[UIImage imageNamed:@"云炖锅营养保温"]];
                break;
            default:
                break;
        }
    }else if (self.model.deviceType==COOKFOOD_KETTLE){
        [typeIV setImage:[UIImage imageNamed:@"自动烹饪锅"]];
        if ([[self.model.State objectForKey:@"tem"] isEqualToString:@"偏好"]) {
            _workName.text = @"偏好";
        }else{
            if ([[self.model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]){
                _workName.text = @"云菜谱";
            }else{
                _workName.text = @"工作类型";
            }
        }
            if ([NSString isPureInt:[self.model.State objectForKey:@"state"]]) {
                
                if ([[self.model.State objectForKey:@"state"] isEqualToString:@"0"]){
                stateLbl.text=@"一键烹饪";
                }else{
                NSArray *foodArray = [[NSArray alloc] initWithObjects:@"三杯鸡",@"黄焖鸡",@"红烧鱼",@"红焖排骨",@"清炖鸡",@"老火汤",@"红烧肉",@"东坡肘子",@"口水鸡",@"滑香鸡",@"茄子煲",@"梅菜扣肉", nil];
                NSString *str = [self.model.State objectForKey:@"state"];
                stateLbl.text=foodArray[[str intValue]-2];
            }
        }else if([[self.model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]) {
            stateLbl.text =[self.model.State objectForKey:@"name"];
            if (stateLbl.text.length > 4) {
                paomav.hidden = NO;
                if (paoma == 1) {
                    [self pawLight];
                } else {
                    stateLbl.textColor = [UIColor clearColor];
                }
            }
            else{
                stateLbl.textColor = [UIColor whiteColor];
            }
        } else {
            stateLbl.text=[[self.model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]?[self.model.State objectForKey:@"name"]:[self.model.State objectForKey:@"state"];
            if (stateLbl.text.length > 4) {
                paomav.hidden = NO;
                if (paoma == 1) {
                    [self pawLight];
                    paoma = paoma +1;
                } else {
                    stateLbl.textColor = [UIColor clearColor];
                }
            } else{
                stateLbl.textColor = [UIColor whiteColor];
            }
        }
        switch ([[self.model.State objectForKey:@"progress"] integerValue]) {
            case 0x01:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲预约阶段"]];
                break;
            case 0x02:
                [stateIV setImage:[UIImage imageNamed:@"隔水炖升温阶段"]];
                break;
            case 0x03:
                [stateIV setImage:[UIImage imageNamed:@"隔水炖小沸精炖阶段"]];
                break;
            case 0x04:
                [stateIV setImage:[UIImage imageNamed:@"隔水炖恒温精炖阶段"]];
                break;
            case 0x05:
                [stateIV setImage:[UIImage imageNamed:@"隔水炖沸腾快炖阶段"]];
                break;
            case 0x06:
                [stateIV setImage:[UIImage imageNamed:@"云炖锅小火精炖阶段"]];
                break;
            case 0x07:
                [stateIV setImage:[UIImage imageNamed:@"隔水炖营养保温"]];
                break;
            default:
                break;
        }
    }else if (self.model.deviceType==ELECTRIC_COOKER){
        //电饭煲
        [typeIV setImage:[UIImage imageNamed:@"设备控制电饭煲"]];
        stateLbl.text=[[self.model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]?[self.model.State objectForKey:@"name"]:[self.model.State objectForKey:@"state"];
        [onlineIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
        
        //因为每个设备的协议对阶段的命名都不一样，这里不做名字适配，用0x01判断。详细定义见协议
        switch ([[self.model.State objectForKey:@"progress"] integerValue]) {
            case 0x01:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲预约阶段"]];
                break;
            case 0x02:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲小火吸水"]];
                break;
            case 0x03:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲大火加热"]];
                break;
            case 0x05:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲沸腾维持"]];
                break;
            case 0x06:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲焖饭"]];
                break;
            case 0x07:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲降温阶段"]];
                break;
            case 0x08:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲恒温精煮"]];
                break;
            case 0x09:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲恒温烘烤"]];
                break;
            case 0x0A:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲小火精熬"]];
                break;
            case 0x0B:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲小火精炖"]];
                break;
            case 0x0C:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲恒温炖煮"]];
                break;
            case 0x0D:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲恒温发酵"]];
                break;
            case 0x0E:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲小火蒸煮"]];
                break;
            case 0x0F:
                [stateIV setImage:[UIImage imageNamed:@"电饭煲营养保温"]];
                break;
            default:
                break;
        }
    }else if (self.model.deviceType==CLOUD_KETTLE){
        //私享壶
        [typeIV setImage:[UIImage imageNamed:@"云水壶"]];
        stateLbl.text =[self.model.State objectForKey:@"name"];
        stateLbl.text=[[self.model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]?[self.model.State objectForKey:@"name"]:[self.model.State objectForKey:@"state"];
        [onlineIV setImage:self.model.isOnline?[UIImage imageNamed:@"在线icon"]:[UIImage imageNamed:@"离线icon"] ];
        
        //因为每个设备的协议对阶段的命名都不一样，这里不做名字适配，用0x01判断。详细定义见协议
        switch ([[self.model.State objectForKey:@"progress"] integerValue]) {
            case 0x01:
                [stateIV setImage:[UIImage imageNamed:@"云水壶预约阶段"]];
                break;
            case 0x02:
                [stateIV setImage:[UIImage imageNamed:@"云水壶升温阶段"]];
                break;
            case 0x03:
                [stateIV setImage:[UIImage imageNamed:@"云水壶沸腾"]];
                break;
            case 0x04:
                [stateIV setImage:[UIImage imageNamed:@"云水壶除氯"]];
                break;
            case 0x05:
                [stateIV setImage:[UIImage imageNamed:@"云水壶大火"]];
                break;
            case 0x06:
                [stateIV setImage:[UIImage imageNamed:@"云水壶小火"]];
                break;
            case 0x07:
                [stateIV setImage:[UIImage imageNamed:@"云水壶恒温"]];
                break;
            case 0x08:
                [stateIV setImage:[UIImage imageNamed:@"云水壶保温"]];
                break;
            default:
                break;
        }
    }
    
    //用宽度计算百分比
    float value=progressView.frame.size.width*[[self.model.State objectForKey:@"percent"]floatValue]/100.00;
    progressView.progressValue=value;
    progressLbl.text=[NSString stringWithFormat:@"%@%%",[self.model.State objectForKey:@"percent"]?[self.model.State objectForKey:@"percent"]:@"--"];
    [detailTB reloadData];
    [self changeFire];
}

- (void)changeFire{
    fireNumber = [[self.model.State objectForKey:@"percent"] intValue];
    slider.pointX = fireNumber*(SCREEN_WIDTH/320)*26-(SCREEN_WIDTH/320)*26;
    slider.sectionIndex = fireNumber-1;

        if (fireNumber == 0 &&self.model.deviceType == COOKFOOD_KETTLE ) {
            
            bgCookView.hidden = YES;
            slider.hidden = YES;
        } else {
            slider.hidden = NO;
            bgCookView.hidden = NO;
            [slider refreshSlider];
        }
    [detailTB reloadData];
}

#pragma mark Cell显示
#pragma mark 炒菜锅
-(DeviceProgressCell *)setCookFoodCellDetailWithCell:(DeviceProgressCell *)cell Row:(NSInteger)row{
    if ([self.model.State[@"state"] isEqualToString:@"手动烹饪"]){
        switch (row) {
            case 0:
                cell.textLabel.text=[[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]?@"保温剩余时间":@"烹饪剩余时间";
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                if ((workhour==102&&workMin==102)||(!workhour&&!workMin)) {
                    //102显示--
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                }else{
                    if (![[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"云菜谱"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"偏好"]) {
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    }
                }
                break;
            case 1:
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getCookFoodProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                break;
                
            default:
                break;
        }
    }else{
        if ([[self.model.State objectForKey:@"progress"]integerValue]==0x01) {
            //预约阶段
            switch (row) {
                case 0:
                {
                    cell.textLabel.text=@"预约剩余时间";
                    int workhour=[[self.model.State objectForKey:@"orderHour"]intValue];
                    int workMin=[[self.model.State objectForKey:@"orderMin"]intValue];
                    [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                }
                    break;
                case 1:
                    if ([[self.model.State objectForKey:@"fire"] isEqualToString:@"2"]||[[self.model.State objectForKey:@"fire"] isEqualToString:@"F"]) {
                        cell.textLabel.text=@"烹饪时间";
                        
                    } else {
                        cell.textLabel.text=@"烹饪剩余时间";
                    }
                    int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                    int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                    [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    break;
                    
                case 2:
                    cell.textLabel.text=@"工作阶段";
                    cell.detailTextLabel.text=[DeviceHelper getCookFoodProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                    cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    break;
                    
                default:
                    break;
            }
        }
        else if ([[self.model.State objectForKey:@"progress"]integerValue]==0x07){
            //保温阶段
            switch (row) {
                case 0:
                    cell.textLabel.text=@"保温剩余时间";
                    
                    int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                    int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                    [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                    
                    break;
                case 1:
                    cell.textLabel.text=@"工作阶段";
                    cell.detailTextLabel.text=[DeviceHelper getCookFoodProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    break;
                    
                default:
                    break;
            }
        }else{
            //其他阶段
            {
                switch (row) {
                    case 0:
                        
                        if ([[self.model.State objectForKey:@"fire"] isEqualToString:@"2"]||[[self.model.State objectForKey:@"fire"] isEqualToString:@"F"]) {
                            
                            cell.textLabel.text = @"烹饪时间";
                        } else {
                            cell.textLabel.text=[[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]?@"保温剩余时间":@"烹饪剩余时间";
                            
                        }
                        int workhour=[[self.model.State objectForKey:@"WorkHour"] intValue];
                        int workMin=[[self.model.State objectForKey:@"WorkMin"] intValue];
                        [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                        
                        if ((workhour==102&&workMin==102)||(!workhour&&!workMin)) {
                            //102显示--
                            
                            [cell setAccessoryType:UITableViewCellAccessoryNone];
                        }else{
                            if (![[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"云菜谱"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"偏好"]) {
                                [cell setAccessoryType:UITableViewCellAccessoryNone];
                            }
                        }
                        break;
                    case 1:
                        cell.textLabel.text=@"工作阶段";
                        cell.detailTextLabel.text=[DeviceHelper getCookFoodProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                        cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                        [cell setAccessoryType:UITableViewCellAccessoryNone];
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
    return cell;
}

#pragma mark 云炖锅
-(DeviceProgressCell *)setCloudCookerCellDetailWithCell:(DeviceProgressCell *)cell Row:(NSInteger)row{
    if ([[self.model.State objectForKey:@"progress"]integerValue]==0x01) {
        //预约阶段
        switch (row) {
            case 0:
            {
                cell.textLabel.text=@"预约剩余时间";
                int workhour=[[self.model.State objectForKey:@"orderHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"orderMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                break;
            case 1:
            {
                cell.textLabel.text=[[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]?@"保温时间":@"烹饪剩余时间";
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                break;
            case 2:
            {
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getCloudCookerProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                break;
            default:
                break;
        }
    }else if ([[self.model.State objectForKey:@"progress"]integerValue]==0x09){
        //保温阶段
        switch (row) {
            case 0:
            {
                cell.textLabel.text=@"保温时间";
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
            }
                break;
            case 1:
            {
                cell.textLabel.text=@"锅内温度";
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ ℃",[self.model.State objectForKey:@"tem"]?[self.model.State objectForKey:@"tem"]:@"--"];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                }
                break;
            case 2:
            {
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getCloudCookerProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                break;
            
            default:
                break;
            }
    }else{
        switch (row) {
            case 0:
            {
                cell.textLabel.text=[[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]?@"保温时间":@"烹饪剩余时间";
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                if ((workhour==102&&workMin==102)||(!workhour&&!workMin)) {
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                }else{
                    if (![[self.model.State objectForKey:@"state"]isEqualToString:@"煮粥"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"云菜谱"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"偏好"]) {
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    }
                }
            }
                break;
            case 1:
            {
                cell.textLabel.text=@"锅内温度";
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ ℃",[self.model.State objectForKey:@"tem"]?[self.model.State objectForKey:@"tem"]:@"--"];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                break;
            case 2:
            {
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getCloudCookerProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                break;
            default:
                break;
        }
    }
    return cell;
}

#pragma mark 隔水炖 & 隔水炖16AIG
//设置隔水炖cell，除了保温阶段==0x08  其他与云炖锅一样，新写一个方法方便后期修改
-(DeviceProgressCell *)setWaterCookerCellDetailWithCell:(DeviceProgressCell *)cell Row:(NSInteger)row{
    if ([[self.model.State objectForKey:@"progress"]integerValue]==0x01) {
        //预约阶段
        switch (row) {
            case 0:
            {
                cell.textLabel.text=@"预约剩余时间";
                int workhour=[[self.model.State objectForKey:@"orderHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"orderMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                break;
            case 1:
            {
                cell.textLabel.text=[[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]?@"保温时间":@"烹饪剩余时间";
                
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                
                break;
            case 2:
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getWaterCookerProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                break;
                
            default:
                break;
        }
    }
    
    else if ([[self.model.State objectForKey:@"progress"]integerValue]==0x08){
        //保温阶段
        switch (row) {
            case 0:
                cell.textLabel.text=@"保温时间";
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                
                break;
            case 1:
            {
                
                cell.textLabel.text=@"锅内温度";
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ ℃",[self.model.State objectForKey:@"tem"]?[self.model.State objectForKey:@"tem"]:@"--"];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                
                
            } break;
            case 2:
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getWaterCookerProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                break;
                
            default:
                break;
        }
    }else{
        //其他阶段
        switch (row) {
            case 0:
                cell.textLabel.text=[[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]?@"保温时间":@"烹饪剩余时间";
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                if ((workhour==102&&workMin==102)||(!workhour&&!workMin)) {
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                }else{
                    if (![[self.model.State objectForKey:@"state"]isEqualToString:@"煮粥"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"云菜谱"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"偏好"]) {
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    }else{
                        [cell setAccessoryType:UITableViewCellAccessoryNone];
                    }
                }
                
                break;
            case 1:
            { cell.textLabel.text=@"锅内温度";
                
                
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ ℃",[self.model.State objectForKey:@"tem"]?[self.model.State objectForKey:@"tem"]:@"--"];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                
            } break;
            case 2:
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getWaterCookerProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                break;
                
            default:
                break;
        }
    }
    return cell;
}

#pragma mark 电饭煲
-(DeviceProgressCell *)setElectricCookerCellDetailWithCell:(DeviceProgressCell *)cell Row:(NSInteger)row{
    if ([[self.model.State objectForKey:@"progress"]integerValue]==0x01) {
        //预约阶段
        switch (row) {
            case 0:
            {
                cell.textLabel.text=@"预约剩余时间";
                int workhour=[[self.model.State objectForKey:@"orderHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"orderMin"]intValue];
                
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                break;
            case 1:
            {
                cell.textLabel.text=[[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]?@"保温时间":@"烹饪剩余时间";
                
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                break;
            case 2:
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getElectricCookerProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                break;
                
            default:
                break;
        }
    }
    else if ([[self.model.State objectForKey:@"progress"]integerValue]==0x0F){
        //保温阶段
        switch (row) {
            case 0:
                cell.textLabel.text=@"保温时间";
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                break;
            case 1:
            { cell.textLabel.text=@"锅内温度";
                
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ ℃",[self.model.State objectForKey:@"tem"]?[self.model.State objectForKey:@"tem"]:@"--"];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                
                
            } break;
            case 2:
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getElectricCookerProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                break;
                
            default:
                break;
        }
    }else{
        //其他阶段
        switch (row) {
            case 0:
                cell.textLabel.text=[[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]?@"保温时间":@"烹饪剩余时间";
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                if ((workhour==102&&workMin==102)||(!workhour&&!workMin)) {
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    
                }else{
                    if (![[self.model.State objectForKey:@"state"]isEqualToString:@"营养保温"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"云菜谱"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"热饭"]&&![[self.model.State objectForKey:@"state"]isEqualToString:@"偏好"]) {
                        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    }
                    
                }
                break;
            case 1:
            { cell.textLabel.text=@"锅内温度";
                
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ ℃",[self.model.State objectForKey:@"tem"]?[self.model.State objectForKey:@"tem"]:@"--"];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            } break;
            case 2:
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getElectricCookerProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                break;
                
            default:
                break;
        }
        
    }
    return cell;
    
}

#pragma mark 私享壶
-(DeviceProgressCell *)setCloudKettleCellDetailWithCell:(DeviceProgressCell *)cell Row:(NSInteger)row{
    if ([[self.model.State objectForKey:@"progress"]integerValue]==0x01) {
        //预约阶段
        switch (row) {
            case 0:
            {
                cell.textLabel.text=@"预约剩余时间";
                
                int workhour=[[self.model.State objectForKey:@"orderHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"orderMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
            }
                break;
            case 1:
            {
                cell.textLabel.text=@"煮水剩余时间";
                
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
                break;
            case 2:
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getCloudKettleProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                break;
                
            default:
                break;
        }
    }else{
        //其他阶段
        switch (row) {
            case 0:
                cell.textLabel.text=[[self.model.State objectForKey:@"state"]isEqualToString:@"保温"]||[[self.model.State objectForKey:@"progress"]integerValue]==0x08?@"保温时间":@"剩余时间";
                int workhour=[[self.model.State objectForKey:@"WorkHour"]intValue];
                int workMin=[[self.model.State objectForKey:@"WorkMin"]intValue];
                [self setCellTimeDetailTextLabel:cell.detailTextLabel hour:workhour minute:workMin];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                break;
            case 1:
            { cell.textLabel.text=@"壶内温度";
                
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ ℃",[self.model.State objectForKey:@"tem"]?[self.model.State objectForKey:@"tem"]:@"--"];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            } break;
            case 2:
                cell.textLabel.text=@"工作阶段";
                cell.detailTextLabel.text=[DeviceHelper getCloudKettleProgressStrWithProgress:[self.model.State objectForKey:@"progress"]];
                cell.detailTextLabel.textColor=[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                break;
                
            default:
                break;
        }
        
    }
    return cell;
}

#pragma mark 设置时间
- (void)setCellTimeDetailTextLabel:(UILabel *)label hour:(int)hour minute:(int)minute {
    NSMutableAttributedString *str;
    
    NSString *hourStr;
    NSString *minStr;
    if (hour==102 && minute==102) {
        hourStr = @"--";
        minStr  = @"--";
    } else {
        hourStr = [NSString stringWithFormat:@"%d", hour];
        minStr  = [NSString stringWithFormat:@"%d", minute];
    }
    NSString *displayStr = [NSString stringWithFormat:@"%@小时%@分钟", hourStr, minStr];
    
    str = [[NSMutableAttributedString alloc] initWithString:displayStr];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f] range:NSMakeRange(0,hourStr.length)];//设置部分文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255/255.0 green:131/255.0 blue:20/255.0 alpha:1.0f] range:NSMakeRange(hourStr.length+2,minStr.length)];//设置部分文字颜色
    label.attributedText = str;
}

#pragma mark 获得设备进度
-(void)getDeviceProgress{
    MyLog(@"获取设备进度 getDeviceProgress");
    
    [[ControllerHelper shareHelper] getDeviceState:self.model];
}

#pragma mark 重置时间
-(void)resetControllTime{
    isResetTime=NO;
    needPopToView=NO;
    [[ControllerHelper shareHelper]controllDevice:self.model];
    cacheModel=nil;
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
            [self showAlertWithTitle:@"提示" Message:@"仅支持1-16个字符"];
            
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
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceViewUpdateUI object:self.model];
            
            
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
        [self deleteDevice];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)deleteDevice{
    if (self.model.role==0&&self.model.isOnline) {
        [[ControllerHelper shareHelper]resteDevice:self.model];   //管理员先重置设备再解绑
        
    }else{
        [self disbindingDevice];
    }
}
#pragma mark 解绑设备
-(void)disbindingDevice{
    [SVProgressHUD show];
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    [HttpRequest unsubscribeDeviceWithUserID:[userDic objectForKey:@"user_id"] withAccessToken:[userDic objectForKey:@"access_token"] withDeviceID:[NSNumber numberWithInt:self.model.deviceID] didLoadData:^(id result, NSError *err) {
        if (err) {
            if (err.code==4001034) {
                //返回这个证明已经取消订阅了该设备
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnConnectDevice object:nil];
                        [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
                        [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
                        [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
                        [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnDeviceStateChanged object:nil];
                        
                        //更新UI，返回
                        [[AutoLoginManager shareManager] updateUIAfterDeleteDevice:self.model];
                        [self.navigationController popViewControllerAnimated:YES];
                        
                        
                        if (self.model.role==0) {
                            //管理员
                            [[ControllerHelper shareHelper]resteDevice:self.model];
                        }else{
                            [[ControllerHelper shareHelper] disconnectDevice:self.model];
                        }
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
                // Do time-consuming task in background thread
                // Return back to main thread to update UI
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnConnectDevice object:nil];
                    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
                    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
                    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
                    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnDeviceStateChanged object:nil];
                    
                    //更新UI，返回
                    [[AutoLoginManager shareManager] updateUIAfterDeleteDevice:self.model];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                    if (self.model.role==0) {
                        //管理员
                        [[ControllerHelper shareHelper] resteDevice:self.model];
                    }else{
                        [[ControllerHelper shareHelper] disconnectDevice:self.model];
                    }
                    //删除设备  
                    [DeviceHelper deleteDeviceFromLocal:self.model.mac];
                    
                });
            });
        }
    }];
}

#pragma mark 跑马灯
- (void)pawLight{
    paomav = [[LSPaoMaView alloc] initWithFrame:CGRectMake(0, 0, stateLbl.frame.size.width, stateLbl.frame.size.height) title:stateLbl.text];
    stateLbl.textColor = [UIColor clearColor];
    [stateLbl addSubview:paomav];
}

@end
