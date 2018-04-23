//
//  PreferenceViewController.m
//  Product
//
//  Created by Xlink on 16/1/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "PreferenceViewController.h"
#import "PreferenceTypeViewController.h"
#import "PreferenceCloudMenuViewController.h"
#import "ControllerHelper.h"
#import "Transform.h"
#import "StartFunctionView.h"
#import "TimePickerView.h"
#import "DeviceHelper.h"
#import "DeviceProgressViewController.h"
#import "UIImageView+WebCache.h"
#import "RecommendFoodCell.h"
#import "Product-Swift.h"
#import "SVProgressHUD.h"
#import "TJYMenuListModel.h"


@interface PreferenceViewController ()<StartFunctionDelegate>{
    PreferenceModel *preferenceModel;
    StartFunctionView  *startFuncView;
    TimePickerView *timePicker;
    
    
}

@end

@implementation PreferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    self.baseTitle=@"偏好";
    self.rightImageName=@"添加";
    
    
    startFuncView=[[StartFunctionView alloc] initWithNibName:@"StartFunctionView" bundle:nil];
    preferenceModel=[[PreferenceModel alloc]init];
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeSyncData object:nil];
    
    if (!preferenceModel.preferenceName) {
        //获取最新偏好命令
        [[ControllerHelper shareHelper] getCurrentPreference:self.model];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnDeviceStateChanged object:nil];
    
    [SVProgressHUD dismiss];
}

-(void)updateUI:(PreferenceModel *)pModel{
    preferenceModel=pModel;
    [self getCloudMenuDetail:preferenceModel.preferenceName];
}

#pragma mark 获取云菜谱的图片和介绍
-(void)getCloudMenuDetail:(NSString *)name{
    MyLog(@"菜谱名称：%@",name);
    
    NSInteger equip=[self getEquipmentWithProductID:self.model.productID];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *urlStr = [NSString stringWithFormat:@"type=1&page_num=1&page_size=100&equipment=%ld",(long)equip];
    
    [[NetworkTool sharedNetworkTool]postMethodWithURL:kMenuList body:urlStr success:^(id json) {
        NSMutableArray *resultArr = [json objectForKey:@"result"];
        for (int i=0; i<resultArr.count; i++) {
            TJYMenuListModel *menuListModel = [TJYMenuListModel new];
            [menuListModel setValues:resultArr[i]];
            [dataArray addObject:menuListModel];
        }
        if (dataArray.count>0) {
            for (int i=0; i<dataArray.count; i++) {
                TJYMenuListModel *menuListModel = dataArray[i];
                if ([menuListModel.name isEqualToString:name]) {
                    preferenceModel.preferenceImgURL=menuListModel.image_id_cover;
                    preferenceModel.preferenceId = [NSString stringWithFormat:@"%ld",(long)menuListModel.cook_id];
                    preferenceModel.preferenceDetail=menuListModel.abstract;
                }
            }
        }
        [mainTB performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    } failure:^(NSString *errorStr) {
        
    }];
}


#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return preferenceModel.preferenceName.length>0?1:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    
    if (preferenceModel.preferenceType==TYPE_WORKTYPE) {
        CellIdentifier=@"WorkTypeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] ;
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.imageView.image=[self getWorkTypeImg];
        cell.textLabel.text=preferenceModel.preferenceName;
        if ([preferenceModel.preferenceHour isEqualToString:@"--"] && [preferenceModel.preferenceMin isEqualToString:@"--"]) {
            cell.detailTextLabel.text = @"";
        }else if([preferenceModel.preferenceName isEqualToString:@"茄子煲"]){
           cell.detailTextLabel.text = @"";
        } else {
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@小时%@分",preferenceModel.preferenceHour,preferenceModel.preferenceMin];
        }
        return cell;
        
    }else{
        static NSString *CellIdentifier = @"RecommendFoodCell";
        RecommendFoodCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.titleLbl.text=preferenceModel.preferenceName;
        cell.detailLbl.text=preferenceModel.preferenceDetail;
        if (!kIsEmptyString(preferenceModel.preferenceImgURL)) {
            [cell.foodIV sd_setImageWithURL:[NSURL URLWithString:preferenceModel.preferenceImgURL]  placeholderImage:[UIImage imageNamed:@"菜谱默认图.png"]];
            
        }
        cell.lineLbl.hidden=YES;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    startFuncView.canSetWorkTime=NO;
    startFuncView.delegate=self;
    [startFuncView showInView:self.view];
}

#pragma mark startFuntionViewDelegate
-(void)startFunction:(id)sender{
    
    [self.model.State setObject:@"偏好" forKey:@"state"];
    [self.model.State setObject:@"00" forKey:@"orderHour"];
    [self.model.State setObject:@"00" forKey:@"orderMin"];
    
    [[ControllerHelper shareHelper]controllDevice:self.model];
    
}

-(void)selectTime:(id)sender{
    
}

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

#pragma mark TimePicker Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (timePicker.isOrderType) {
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
            
            [self.model.State setObject:@"偏好" forKey:@"state"];
            [self.model.State setObject:hour<10?[NSString stringWithFormat:@"0%li",(long)hour]:[NSString stringWithFormat:@"%li",(long)hour] forKey:@"orderHour"];
            [self.model.State setObject:min<10?[NSString stringWithFormat:@"0%li",(long)min]:[NSString stringWithFormat:@"%li",(long)min] forKey:@"orderMin"];
            if (self.model.deviceType ==COOKFOOD_KETTLE) {
                if (hour < 12) {
                    [[ControllerHelper shareHelper]controllDevice:self.model];
                }else{
                    [self showAlertWithTitle:@"提示" Message:@"最大预约时间为12小时"];
                }
            }else{
                [[ControllerHelper shareHelper]controllDevice:self.model];
            }
        }
        
    }
}

#pragma mark 根据类型获取图片
-(UIImage *)getWorkTypeImg{
    if ([preferenceModel.preferenceName isEqualToString:@"炖汤"]||[preferenceModel.preferenceName isEqualToString:@"煲汤"]) {
        return [UIImage imageNamed:@"偏好_炖汤"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"保温"]||[preferenceModel.preferenceName isEqualToString:@"营养保温"]){
        return [UIImage imageNamed:@"偏好_保温"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"热饭"]){
        return [UIImage imageNamed:@"偏好_热饭"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"煮粥"]){
        return [UIImage imageNamed:@"偏好_煮粥"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"精华煮"]){
        return [UIImage imageNamed:@"偏好_精华煮"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"炖煮"]||[preferenceModel.preferenceName isEqualToString:@"蒸煮"]){
        return [UIImage imageNamed:@"偏好_蒸煮"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"超快煮"]){
        return [UIImage imageNamed:@"偏好_超快煮"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"煮水"]){
        return [UIImage imageNamed:@"偏好_煮水"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"煮水除氯"]){
        return [UIImage imageNamed:@"偏好_除氯"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"三杯鸡"]){
        return [UIImage imageNamed:@"三杯鸡"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"黄焖鸡"]){
        return [UIImage imageNamed:@"黄焖鸡"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"红烧鱼"]){
        return [UIImage imageNamed:@"红烧鱼"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"红焖排骨"]){
        return [UIImage imageNamed:@"红焖排骨"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"清炖鸡"]){
        return [UIImage imageNamed:@"清炖鸡"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"老火汤"]){
        return [UIImage imageNamed:@"老火汤"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"红烧肉"]){
        return [UIImage imageNamed:@"红烧肉"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"东坡肘子"]){
        return [UIImage imageNamed:@"东坡肘子"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"口水鸡"]){
        return [UIImage imageNamed:@"口水鸡"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"滑香鸡"]){
        return [UIImage imageNamed:@"滑香鸡"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"茄子煲"]){
        return [UIImage imageNamed:@"茄子煲"];
    }else if ([preferenceModel.preferenceName isEqualToString:@"梅菜扣肉"]){
        return [UIImage imageNamed:@"梅菜扣肉"];
    }
    
    return nil;
}

-(void)rightButtonAction{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *cloudMenuButtonTitle = NSLocalizedString(@"云菜谱", nil);
    NSString *workTypeButtonTitle = NSLocalizedString(@"工作类型", nil);

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    UIAlertAction *cloudMenuAction = [UIAlertAction actionWithTitle:cloudMenuButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"toCloudMenuView" sender:nil];
    }];
    
    UIAlertAction *workTypeAction = [UIAlertAction actionWithTitle:workTypeButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"toSelectTypeView" sender:nil];
    }];
    [alertController addAction:cloudMenuAction];
    [alertController addAction:workTypeAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}




#pragma mark Device Delegate
-(void)OnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    [NSUserDefaultInfos putKey:@"name" andValue:[self.model.State objectForKey:@"name"]];
    uint32_t cmd_len = (uint32_t)[recvData length];
    uint8_t cmd_data[cmd_len];
    memset(cmd_data, 0, cmd_len);
    [recvData getBytes:(void *)cmd_data length:cmd_len];
    
    MyLog(@"获取设备偏好设置数据--PrefrenceViewController:%@",[recvData hexString]);
    
    if ([[device getMacAddressSimple]isEqualToString:self.model.mac]) {
        
        if ((cmd_data[0]==0x11&&cmd_data[3]==0x05)||(cmd_data[0]==0x11&&cmd_data[3]==0x10)) {
            //获取偏好信息的返回
            [self performSelectorOnMainThread:@selector(getPreferenceInfo:) withObject:recvData waitUntilDone:YES];
        }else if (cmd_data[0]==0x14){
            //设置偏好返回
            NSMutableDictionary *dic=[DeviceHelper getStateDicWithDevice:device Data:recvData];
            if (dic) {
                self.model.State=dic;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // Do time-consuming task in background thread
                    // Return back to main thread to update UI
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        
                        //获取偏好状态命令返回
                        [[ControllerHelper shareHelper]dismissProgressView];
                        
                        [self performSegueWithIdentifier:@"toProgressView" sender:nil];
                    });
                });
            }
        }
    }
}

-(void)getPreferenceInfo:(NSData *)data{
    
    uint32_t cmd_len = (uint32_t)[data length];
    uint8_t cmd_data[cmd_len];
    memset(cmd_data, 0, cmd_len);
    [data getBytes:(void *)cmd_data length:cmd_len];
    
    //获取偏好状态命令返回
    [[ControllerHelper shareHelper]dismissProgressView];
    
    NSString *PreferenceInfo=@"";
    NSString *strHour=@"";
    NSString *strMin=@"";
    int TypeIdentifier=cmd_data[4];   // @
    int secondIdentifier=cmd_data[5]; // |
    
    if ([[NSString stringWithFormat:@"%C",(unichar)TypeIdentifier] isEqualToString:@"@"]&&[[NSString stringWithFormat:@"%C",(unichar)secondIdentifier] isEqualToString:@"|"]) {
        //工作类型
        
        BOOL gotName = false;//如果已经获取了名字，则取一位accii码转化
        for (int i=6;i<24;i++) {
            if ((([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+3]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+6]] isEqualToString:@"|"])||([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+2]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+5]] isEqualToString:@"|"])||([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+3]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+5]] isEqualToString:@"|"])||([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+2]] isEqualToString:@"|"]&&[[NSString stringWithFormat:@"%C",(unichar)cmd_data[i+4]] isEqualToString:@"|"]))&&cmd_data[i+1]!=0xa5) {
                
                //判断是否已经获取了名字
                gotName=true;
            }
            
            if ([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"\0"]) {
                break;
            }
            
            if (gotName==true) {
                
                int acciiCode=cmd_data[i];
                PreferenceInfo=[PreferenceInfo stringByAppendingString:[NSString stringWithFormat:@"%C",(unichar)acciiCode]];
            }else {
                int acciiCode=cmd_data[i]*pow(16, 2)+cmd_data[i+1];
                i++;
                PreferenceInfo=[PreferenceInfo stringByAppendingString:[NSString stringWithFormat:@"%C",(unichar)acciiCode]];
            }
            
            
        }
        
        
        NSArray *infoArr=[PreferenceInfo componentsSeparatedByString:@"|"];
        if (infoArr.count>2) {
            preferenceModel.preferenceType=TYPE_WORKTYPE;
            preferenceModel.preferenceName=infoArr[0];
            if (self.model.deviceType == COOKFOOD_KETTLE) {
                
                strHour =[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%d",cmd_data[25]]];
                strMin =[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%d",cmd_data[26]]];;
                
                preferenceModel.preferenceHour=[NSString stringWithFormat:@"%@",strHour];
                preferenceModel.preferenceMin=[NSString stringWithFormat:@"%@",strMin];
            } else {
                if (([Transform unsignedLongFrom:infoArr[1] scale:16]==153&&[Transform unsignedLongFrom:infoArr[2] scale:16]==153)||([Transform unsignedLongFrom:infoArr[1] scale:16]==0&&[Transform unsignedLongFrom:infoArr[2] scale:16]==0)) {
                    preferenceModel.preferenceHour=@"--";
                    preferenceModel.preferenceMin=@"--";
                }else{
                    preferenceModel.preferenceHour=[NSString stringWithFormat:@"%@",infoArr[1]];
                    preferenceModel.preferenceMin=[NSString stringWithFormat:@"%@",infoArr[2]];
                }
            }
            [mainTB performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }else {
        //云菜谱
        for (int i=4;i<23;i++) {
            if ([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"\0"]) {
                break;
            }
            int acciiCode=cmd_data[i]*pow(16, 2)+cmd_data[i+1];
            i++;
            PreferenceInfo=[PreferenceInfo stringByAppendingString:[NSString stringWithFormat:@"%C",(unichar)acciiCode]];
        }
        preferenceModel.preferenceType=TYPE_CLOUD_MENU;
        preferenceModel.preferenceName=PreferenceInfo;
        [self getCloudMenuDetail:preferenceModel.preferenceName];
    }
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toSelectTypeView"]) {
        PreferenceTypeViewController *typeView=[segue destinationViewController];
        typeView.model=self.model;
    }else if ([segue.identifier isEqualToString:@"toCloudMenuView"]){
        PreferenceCloudMenuViewController *cloudMenuVC=[segue destinationViewController];
        cloudMenuVC.model=self.model;
    }else if ([segue.identifier isEqualToString:@"toProgressView"]){
        DeviceProgressViewController *progressVC=[segue destinationViewController];
        progressVC.model=self.model;
    }
}


-(NSInteger)getEquipmentWithProductID:(NSString *)productID{
    NSInteger equip=0;
    if ([productID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]) {
        equip=1;
    }else if ([productID isEqualToString:CLOUD_KETTLE_PRODUCT_ID]){
        equip=2;
    }else if ([productID isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]){
        equip=3;
    }else if ([productID isEqualToString:CLOUD_COOKER_PRODUCT_ID]){
        equip=4;
    }else if ([productID isEqualToString:WATER_COOKER_PRODUCT_ID]){
        equip=5;
    }
    return equip;
}


@end
