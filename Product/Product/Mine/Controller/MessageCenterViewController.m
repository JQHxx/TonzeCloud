//
//  MessageCenterViewController.m
//  Product
//
//  Created by Xlink on 15/12/3.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "MessageCenterViewController.h"
#import "NotiCenterCell.h"
#import "DBManager.h"
#import "DeviceHelper.h"
#import "ShareModel.h"
#import "QRcodeTimeOutViewController.h"
#import "ConnectSuccessViewController.h"
#import "BlankView.h"
#import "TonzeHelpTool.h"

@interface MessageCenterViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray * notiArray;
    NSString       * _invite_code;
    NSNumber       * _deviceID;
}

@property (nonatomic,strong)UITableView *notiTableView;
@property (nonatomic,strong)BlankView   *blankView;

@end

@implementation MessageCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    
    switch (self.type) {
        case messageTypeDeviceWork:
            self.baseTitle = @"设备工作";
            break;
        case messageTypeDeviceShare:
            self.baseTitle = @"设备分享";
            break;
        case messageTypeMeasurementResult:
            self.baseTitle = @"测量结果";
            break;
        case messageTypeFaultMessage:
            self.baseTitle = @"故障消息";
            break;
            
        default:
            break;
    }
    notiArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.notiTableView];
    [self.notiTableView addSubview:self.blankView];
    self.blankView.hidden=YES;
    
    [self getMessageInfo];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
#if !DEBUG
    NSString *targetId=[TonzeHelpTool sharedTonzeHelpTool].messageTargetId;
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:targetId type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
#if !DEBUG
    NSString *targetId=[TonzeHelpTool sharedTonzeHelpTool].messageTargetId;
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:targetId type:2];
#endif
}


#pragma mark -- UITableViewDelegate and UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return notiArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"NotiCenterCell";
    NotiCenterCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[NotiCenterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NotiModel *model=notiArray[indexPath.row];
    [cell updateUI:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NotiModel *noti=[notiArray objectAtIndex:indexPath.row];
        NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    if ([noti.notiState isEqualToString:@"等待处理 >>"]) {
        _invite_code=noti.invite_code;
        if ([userDic objectForKey:@"user_id"]==noti.from_id) {
            [self showCancelShareActionSheet];
        }else{
            [self showActionSheetController];
        }
    }
}

#pragma mark --Private Methods
#pragma mark 获取消息
-(void)getMessageInfo{
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    if (self.type == messageTypeDeviceShare) {
        //获取分享列表
        kSelfWeak;
        [HttpRequest getShareListWithAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
            if (err) {
                [weakSelf showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakSelf handleArray:result];
                });
            }
        }];
    }else{
        //其它，不需要拉取订阅列表
        [self handleArray:@[]];
    }
}

#pragma mark 处理本地的消息通知和获取回来的分享列表
-(void)handleArray:(NSArray *)arr{
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    notiArray=[[NSMutableArray alloc] initWithArray:[[DBManager shareManager] readAllNoti]];
    
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NotiModel *model=[[NotiModel alloc]init];
        model.from_id=[obj objectForKey:@"from_id"];
        model.invite_code = [obj objectForKey:@"invite_code"];
        NSInteger userID=[[userDic objectForKey:@"user_id"] integerValue];
        NSInteger fromID=[[obj objectForKey:@"from_id"] integerValue];
        
        if (userID==fromID) {
            NSString *deviceType=[DeviceHelper getDeviceTypeFromDeviceID:[obj objectForKey:@"device_id"]];
            model.deviceName=@"您";
            NSInteger user_id = [obj[@"user_id"] integerValue];
            if (user_id!=0) {
                model.deviceName=[NSString stringWithFormat:@"您向%@分享了%@",[obj objectForKey:@"to_name"]?[obj objectForKey:@"to_name"]:@"**",deviceType?deviceType:@"设备"];
            }else{
                model.deviceName=[NSString stringWithFormat:@"二维码分享了%@",deviceType?deviceType:@"设备"];
            }
            model.time=[Transform timeSPToTime:[obj objectForKey:@"gen_date"]];
            model.notiType=[NSString stringWithFormat:@"%i",AUTH_DEVICE];
            
            
            if ([[obj objectForKey:@"state"]isEqualToString:@"pending"]) {
                //等待处理
                model.notiState=@"等待处理 >>";
            }else if([[obj objectForKey:@"state"] isEqualToString:@"accept"]){
                model.notiState=@"已分享";
            }else if([[obj objectForKey:@"state"] isEqualToString:@"deny"]){
                model.notiState=@"已拒绝";
            }else if([[obj objectForKey:@"state"] isEqualToString:@"cancel"]){
                model.notiState=@"已取消";
            }else if([[obj objectForKey:@"state"] isEqualToString:@"overtime"]){
                model.notiState=@"已失效";
            }
            [notiArray addObject:model];
        }else{
            //别人分享给我的
            NSString *deviceType=[DeviceHelper getDeviceTypeFromDeviceID:[obj objectForKey:@"device_id"]];
            model.deviceName=[NSString stringWithFormat:@"%@向您分享了%@",[obj objectForKey:@"from_name"]?[obj objectForKey:@"from_name"]:@"**",deviceType?deviceType:@"设备"];
            model.time=[Transform timeSPToTime:[obj objectForKey:@"gen_date"]];
            model.notiType=[NSString stringWithFormat:@"%i",AUTH_DEVICE];
            
            
            if ([[obj objectForKey:@"state"]isEqualToString:@"pending"]) {
                model.notiState=@"等待处理 >>";
            }else if([[obj objectForKey:@"state"] isEqualToString:@"accept"]){
                model.notiState=@"已分享";
            }else if([[obj objectForKey:@"state"] isEqualToString:@"deny"]){
                model.notiState=@"已拒绝";
            }else if([[obj objectForKey:@"state"] isEqualToString:@"cancel"]){
                model.notiState=@"已取消";
            }else if([[obj objectForKey:@"state"] isEqualToString:@"overtime"]){
                model.notiState=@"已过期";
            }
            [notiArray addObject:model];
        }
    }];
    
    //排序
    [notiArray sortUsingComparator:^NSComparisonResult(NotiModel  *obj1, NotiModel  *obj2) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeInterval interval1=[[formatter dateFromString:obj1.time] timeIntervalSince1970];
        ;
        NSTimeInterval interval2=[[formatter dateFromString:obj2.time] timeIntervalSince1970];
        ;
        return interval1<interval2;
    }];
    
    //根据消息类型显示数据
    NSMutableArray *tem = [NSMutableArray array];
    if (self.type == messageTypeDeviceWork) {
        //设备工作
        for (NotiModel *model in notiArray) {
            if (model.notiType.intValue == 1) {
                [tem addObject:model];
            }
        }
    }else if (self.type == messageTypeFaultMessage){
        //故障消息
        for (NotiModel *model in notiArray) {
            if (model.notiType.intValue == 2) {
                [tem addObject:model];
            }
        }
    }else if (self.type == messageTypeDeviceShare){
        //设备分享
        for (NotiModel *model in notiArray) {
            if (model.notiType.intValue == 0 || model.notiType.intValue == 3) {
                [tem addObject:model];
            }
        }
    }
    
    notiArray = [NSMutableArray arrayWithArray:tem];
    
    self.blankView.hidden=notiArray.count>0;
    [self.notiTableView reloadData];
    
}

#pragma mark 选择接受或拒绝分享
-(void)showActionSheetController{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *acceptButtonTitle = NSLocalizedString(@"接受分享", nil);
    NSString *refuseButtonTitle = NSLocalizedString(@"拒绝分享", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:acceptButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSelectorOnMainThread:@selector(acceptShare) withObject:nil waitUntilDone:NO];
    }];
    UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:refuseButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSelectorOnMainThread:@selector(refuseShare) withObject:nil waitUntilDone:NO];
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:acceptAction];
    [alertController addAction:refuseAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 取消分享
-(void)showCancelShareActionSheet{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *cancelShareButtonTitle = NSLocalizedString(@"取消分享", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *cancelShareAction = [UIAlertAction actionWithTitle:cancelShareButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSelectorOnMainThread:@selector(cancelShare) withObject:nil waitUntilDone:NO];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:cancelShareAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 取消分享
-(void)cancelShare{
    [HttpRequest cancelShareDeviceWithAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] withInviteCode:_invite_code didLoadData:^(id result, NSError *err) {
        if (err) {
            [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark 拒绝分享
-(void)refuseShare{
    __weak typeof(self) weakSelf = self;
    [HttpRequest denyShareWithInviteCode:_invite_code withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        if (!err) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
            
        }else{
            [weakSelf showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        }
    }];
}

#pragma mark 接受分享
-(void)acceptShare{
    //接受分享
    [HttpRequest acceptShareWithInviteCode:_invite_code withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        
        if (!err) {
            __weak typeof(self) weakSelf = self;
             [HttpRequest getDeviceListWithUserID:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"user_id"] withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] withVersion:@(0) didLoadData:^(id result, NSError *err) {
                if (!err) {
                    NSDictionary *dic = (NSDictionary *)result;
                    [weakSelf addDevice:dic];
                } else {
                    [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
                }
            }];
        }else{
            QRcodeTimeOutViewController *view = [[QRcodeTimeOutViewController alloc] init];
            [self.navigationController pushViewController:view animated:YES];
        }
    }];
}

#pragma mark 添加分享设备
- (void)addDevice:(NSDictionary *)dic{
    [HttpRequest getShareListWithAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        if (!err) {
            NSArray *tem = (NSArray *)result;
            for (NSDictionary *newsDict in tem) {
                ShareModel *model = [[ShareModel alloc] init];
                [model setValuesForKeysWithDictionary:newsDict];
                model.to_id = newsDict[@"user_id"];
                if ([model.invite_code isEqualToString:_invite_code]) {
                    _deviceID = model.device_id;
                    
                    for (NSDictionary *deviceDic in dic[@"list"]) {
                        if ([@([deviceDic[@"id"] intValue]) isEqualToNumber:_deviceID]) {
                            DeviceEntity *newDevice = [[DeviceEntity alloc] initWithMac:deviceDic[@"mac"] andProductID:deviceDic[@"product_id"]];
                            newDevice.deviceID = [deviceDic[@"id"] intValue];
                            newDevice.accessKey = deviceDic[@"access_key"];
                            [self performSelectorOnMainThread:@selector(pushToSuccess:) withObject:newDevice waitUntilDone:YES];
                        }
                    }
                     break;
                }
            }
        }else{
            [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        }
    }];
}

- (void)pushToSuccess:(DeviceEntity *)device{
    ConnectSuccessViewController *view = [[ConnectSuccessViewController alloc] init];
    view.device = device;
    [DeviceHelper saveDeviceToLocal:device];
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark -- Setters
#pragma mark 消息中心
-(UITableView *)notiTableView{
    if (_notiTableView==nil) {
        _notiTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight) style:UITableViewStylePlain];
        _notiTableView.dataSource=self;
        _notiTableView.delegate=self;
        _notiTableView.backgroundColor=[UIColor bgColor_Gray];
        _notiTableView.tableFooterView=[[UIView alloc] init];
        _notiTableView.showsVerticalScrollIndicator=NO;
    }
    return _notiTableView;
}

#pragma mark 暂无数据
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView=[[BlankView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kBodyHeight) img:@"暂无数据" text:@"暂无数据"];
    }
    return _blankView;
}

@end
