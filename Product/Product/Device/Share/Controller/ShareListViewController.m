//
//  ShareListViewController.m
//  Product
//
//  Created by Feng on 16/2/3.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "ShareListViewController.h"
#import "ShareFromQRcodeViewController.h"
#import "ShareFromAccountViewController.h"
#import "ShareModel.h"
#import "AppDelegate.h"
#import "ShareListCell.h"
#import "Transform.h"

//手动重置弹框
#import "DeviceViewController.h"
#import "DeviceConnectStateCheckService.h"
#import "DeviceHelper.h"

@interface ShareListViewController ()<UIAlertViewDelegate>{
    NSMutableArray *shareListArr;
    
    AppDelegate *appDelegate;
}

@end

@implementation ShareListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"分享管理";
    self.rightImageName=@"添加";
    
    shareListArr=[[NSMutableArray alloc]init];
    withoutShareView.hidden=YES;
    
    appDelegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getShareList];
}

#pragma mark--Private Methods
#pragma mark 获取分享列表
-(void)getShareList{
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    //获取用户的分享列表
    [HttpRequest getShareListWithAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (err) {
                    if (err.code==4031003) {
                        [appDelegate updateAccessToken];
                    }
                    [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
                }else{
                    [shareListArr removeAllObjects];
                    NSMutableArray *shareArr=[[NSMutableArray alloc]init];
                    
                    //筛选是用户已经分享出去的和self.model.deviceID相同的设备
                    for (NSDictionary *tem in result) {
                        if ([[tem objectForKey:@"device_id"]integerValue]==self.model.deviceID&&[[userDic objectForKey:@"user_id"] integerValue]==[[tem objectForKey:@"from_id"]integerValue]) {
                            ShareModel *model = [[ShareModel alloc] init];
                            [model setValuesForKeysWithDictionary:tem];
                            model.to_id = tem[@"user_id"];
                            model.create_date=[Transform timeSPToTime:[tem objectForKey:@"gen_date"]];
                            model.user_nickname=tem[@"nick_name"];
                            
                            if ([model.state isEqualToString:@"accept"]) {
                                NSArray *copyShareArr = [NSArray arrayWithArray:shareArr];
                                for (ShareModel *model in copyShareArr) {
                                    if (model.to_id==tem[@"user_id"] ){
                                        [shareArr removeObject:model];
                                    }
                                }
                                [shareArr addObject:model];
                            }
                        }
                        if ([[userDic objectForKey:@"user_id"] integerValue]!=[[tem objectForKey:@"from_id"]integerValue]) {
                            //删除无用记录
                            [HttpRequest delShareRecordWithInviteCode:[tem objectForKey:@"invite_code"] withAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                                
                            }];
                        }
                    }
                    
                    //获取该设备的订阅用户列表
                    [HttpRequest getDeviceUserListWithUserID:[userDic objectForKey:@"user_id"] withDeviceID:[NSNumber numberWithInt:self.model.deviceID] withAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            if (err) {
                                if (err.code==4031003) {
                                    [appDelegate updateAccessToken];
                                }
                                [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
                            }else{
                                NSArray *listArr=[result objectForKey:@"list"];
                                //连续用两个接口，因为最后只需要获取管理员分享出去的，该设备的订阅用户列表，而且还需要获取分享邀请码，用于取消分享
                                for (NSDictionary *dic in listArr) {
                                    for (ShareModel *model in shareArr) {
                                        if (model.user_id == dic[@"user_id"]) {
                                            model.user_nickname=dic[@"nickname"];
                                            [shareListArr addObject:model];
                                        }
                                    }
                                }
                                [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
                                [shareListTB reloadData];
                            }
                        });
                    }];
                }
            });
        });
    }];
}

-(void)updateUI{
    if (shareListArr.count==0) {
        withoutShareView.hidden=NO;
        shareListTB.hidden=YES;
    }else{
        withoutShareView.hidden=YES;
        shareListTB.hidden=NO;
    }
}

#pragma mark --Response Methods
#pragma mark 添加分享
-(void)rightButtonAction{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *QRcodeButtonTitle = NSLocalizedString(@"二维码分享", nil);
    NSString *accountButtonTitle = NSLocalizedString(@"ID分享", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *QRcodeAction = [UIAlertAction actionWithTitle:QRcodeButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"toQRcodeView" sender:nil];
    }];
    UIAlertAction *accountAction = [UIAlertAction actionWithTitle:accountButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"toAccountView" sender:nil];
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:QRcodeAction];
    [alertController addAction:accountAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toQRcodeView"]) {
        ShareFromQRcodeViewController *QRcodeVC=segue.destinationViewController;
        QRcodeVC.model=self.model;
    }else if ([segue.identifier isEqualToString:@"toAccountView"]){
        ShareFromAccountViewController *accountVC=segue.destinationViewController;
        accountVC.model=self.model;
    }
}

#pragma mark　--UITableViewDelegate and UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return shareListArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"ShareListCell";
    ShareListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ShareModel *model=[shareListArr objectAtIndex:indexPath.row];
    cell.titleLbl.text=[NSString stringWithFormat:@"%@",model.to_id];
    cell.nameLbl.text=model.user_nickname;
    cell.timeLbl.text=model.create_date;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showDelectAlertController:indexPath];
}

-(void)showDelectAlertController:(NSIndexPath *)indexPath{
    NSString *title = NSLocalizedString(@"删除提示", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    
    __weak ShareModel *model = [shareListArr objectAtIndex:indexPath.row];
    NSString *text=[NSString stringWithFormat:@"确定取消%@共享当前设备？",model.to_id];
    NSString *okButtonTitle = NSLocalizedString(@"删除", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
    }];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [HttpRequest cancelShareDeviceWithAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] withInviteCode:model.invite_code didLoadData:^(id result, NSError *err) {
                if (err) {
                    if (err.code==4031003) {
                        [appDelegate updateAccessToken];
                    }
                    [weakSelf showDoneAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
                } else {
                    [shareListArr removeObject:model];
                    [shareListTB performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                }
       }];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    alertController.view.layer.cornerRadius = 20;
    alertController.view.layer.masksToBounds = YES;
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)showDoneAlertWithTitle:(NSString *)title Message:(NSString *)message {
    NSString *otherButtonTitle = NSLocalizedString(@"好的", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
    }];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}





@end
