//
//  SetViewController.m
//  Product
//
//  Created by vision on 17/4/18.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SetViewController.h"
#import "OnlineServiceViewController.h"
#import "AboutUsViewController.h"
#import "FeedbackViewController.h"
#import "TonzeHelpTool.h"
#import "DeviceConnectStateCheckService.h"
#import "DeviceStateListener.h"


@interface SetViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    NSArray          *itemsArray;
    double           cachSize;
    NSInteger        status;
}

@property(nonatomic,strong)UITableView *setTableView;
@property (nonatomic,strong)UIButton    *loginOutBtn;

@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"设置";
    
    itemsArray=@[@[@"清除缓存"],@[@"在线客服",@"意见反馈",@"评价一下",@"关于我们"]];
    cachSize=[[TonzeHelpTool sharedTonzeHelpTool] getCachFileSize];
    
    [self.view addSubview:self.setTableView];
    BOOL isLogining=kIsLogined;
    if (isLogining) {
        [self.setTableView addSubview:self.loginOutBtn];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-05-01" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-05-01" type:2];
#endif
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return itemsArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [itemsArray[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.text=itemsArray[indexPath.section][indexPath.row];
    if (indexPath.section==0) {
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%.2fMB",cachSize];
    }else{
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认要清除缓存吗？" message:[NSString stringWithFormat:@"%.2fMB",cachSize] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }else{
        if (indexPath.row==0) {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-05-03"];
#endif
            OnlineServiceViewController *onlineServiceVC=[[OnlineServiceViewController alloc] init];
            [self.navigationController pushViewController:onlineServiceVC animated:YES];
        }else if (indexPath.row==1){
            if(kIsLogined){
#if !DEBUG
                [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-05-04"];
#endif
                FeedbackViewController *feedBackVC=[[FeedbackViewController alloc] init];
                [self.navigationController pushViewController:feedBackVC animated:YES];
            }else{
                [self pushToFastLogin];
            }
        }else if (indexPath.row==2){
            NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",@"1126623839"];
            NSURL * url = [NSURL URLWithString:str];
            if ([[UIApplication sharedApplication] canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url];
            }else{
                MyLog(@"can not open");
            }
        }else if (indexPath.row==3){
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-05-06"];
#endif
            AboutUsViewController *aboutUsVC=[[AboutUsViewController alloc] init];
            [self.navigationController pushViewController:aboutUsVC animated:YES];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

#pragma mark -- UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
#if !DEBUG
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-05-02"];
#endif
        
        [self clearCachFile];
    }
}

#pragma mark -- private Methods
#pragma mark  清理缓存
- (void)clearCachFile{
    NSString * cachPath = [ NSSearchPathForDirectoriesInDomains ( NSCachesDirectory , NSUserDomainMask , YES ) firstObject ];
    NSArray * files = [[ NSFileManager defaultManager ] subpathsAtPath :cachPath];
    NSLog ( @"cachpath = %@" , cachPath);
    for ( NSString * p in files) {
        NSError * error = nil ;
        NSString * path = [cachPath stringByAppendingPathComponent :p];
        if ([[ NSFileManager defaultManager ] fileExistsAtPath :path]) {
            [[ NSFileManager defaultManager ] removeItemAtPath :path error :&error];
        }
    }
    [ self performSelectorOnMainThread : @selector (clearCachSuccess) withObject : nil waitUntilDone : YES ];
}

-(void)clearCachSuccess{
    [self.view makeToast:@"清除缓存成功" duration:1.0 position:CSToastPositionCenter];
    cachSize=0;
    [self.setTableView reloadData];
}

#pragma mark -- Event Response
-(void)loginOutAction{
    kSelfWeak;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"您确定要退出登录吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
#if !DEBUG
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-05-12"];
#endif
        [[NetworkTool sharedNetworkTool] postMethodWithURL:kLoginOutAPI body:@"" success:^(id json) {
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserKey];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserToken];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserSecret];
            
            [NSUserDefaultInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:NO]];
            [TJYHelper sharedTJYHelper].isLoginSuccess=YES;
    
            [[AutoLoginManager shareManager] clearAllUserData];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
            
        } failure:^(NSString *errorStr) {
            status = [[NSUserDefaultInfos getValueforKey:@"status"] integerValue];
            if (status == 10001) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserKey];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserToken];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserSecret];
                
                [NSUserDefaultInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:NO]];
                [TJYHelper sharedTJYHelper].isLoginSuccess=YES;
                
                [[AutoLoginManager shareManager] clearAllUserData];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- Setters
#pragma mark 设置
-(UITableView *)setTableView{
    if (!_setTableView) {
        _setTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight) style:UITableViewStyleGrouped];
        _setTableView.backgroundColor=[UIColor bgColor_Gray];
        _setTableView.dataSource=self;
        _setTableView.delegate=self;
    }
    return _setTableView;
}

-(UIButton *)loginOutBtn{
    if (!_loginOutBtn) {
        _loginOutBtn=[[UIButton alloc] initWithFrame:CGRectMake(20, self.setTableView.bottom-60-64, kScreenWidth-40, 40)];
        _loginOutBtn.layer.cornerRadius=5.0;
        _loginOutBtn.backgroundColor=kSystemColor;
        [_loginOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        [_loginOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginOutBtn addTarget:self action:@selector(loginOutAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginOutBtn;
}

@end
