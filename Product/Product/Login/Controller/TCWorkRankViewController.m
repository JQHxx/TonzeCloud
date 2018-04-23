//
//  TCWorkRankViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCWorkRankViewController.h"
#import "TJYIntensityTableViewCell.h"
#import "AppDelegate.h"
#import "TCUserTool.h"
#import "TJYLaborModel.h"

@interface TCWorkRankViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray      *workArray;
    UITableView         *intensityTabView;
    
    TJYLaborModel        *selLabor;
}
@end

@implementation TCWorkRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"劳动强度";
    
    workArray=[[NSMutableArray alloc] init];
    selLabor=[[TJYLaborModel alloc] init];

    [self initWorkRankView];
    [self loadLaborData];
}


#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return workArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCIntensityTableViewCell";
    TJYIntensityTableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell = [[TJYIntensityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    TJYLaborModel *labor=workArray[indexPath.row];
    [cell cellDisplayWithLabor:labor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selLabor=workArray[indexPath.row];
    for (TJYLaborModel *model in workArray) {
        if ([model.title isEqualToString:selLabor.title]) {
            model.isSelected=[NSNumber numberWithBool:YES];
        }else{
            model.isSelected=[NSNumber numberWithBool:NO];
        }
    }
    [intensityTabView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TJYLaborModel *labor=workArray[indexPath.row];
    return [TJYIntensityTableViewCell getCellHeightWithLabor:labor];
}

#pragma mark -- Event Response
#pragma mark 设置个人信息完成
-(void)toCompleteAction{
    double weightDouble=[[[TCUserTool sharedTCUserTool].userDict objectForKey:@"weight"] doubleValue]+0.01;
    
    NSString  *body=[NSString stringWithFormat:@"sex=%@&birthday=%@&height=%@&weight=%.1f&labour_intensity=%@&doSubmit=1",
          [[TCUserTool sharedTCUserTool].userDict objectForKey:@"sex"],
          [[TCUserTool sharedTCUserTool].userDict objectForKey:@"birthday"],
          [[TCUserTool sharedTCUserTool].userDict objectForKey:@"height"],
          weightDouble,selLabor.title];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kSetUserInfo body:body success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            TJYUserModel *userModel=[[TJYUserModel alloc] init];
            [userModel setValues:result];
            [TonzeHelpTool sharedTonzeHelpTool].user=userModel;
        }
        [TJYHelper sharedTJYHelper].isSetUserInfoSuccess=YES;
        [[TonzeHelpTool sharedTonzeHelpTool] calculateDailyEnergyWithHeight: [[[TCUserTool sharedTCUserTool].userDict objectForKey:@"height"] integerValue] weight:[[[TCUserTool sharedTCUserTool].userDict objectForKey:@"weight"] doubleValue]+0.01 labor:[[TCUserTool sharedTCUserTool].userDict objectForKey:@"labor"]];
        
        if ([TJYHelper sharedTJYHelper].isRootWindowIn) {
            AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            appDelegate.window.rootViewController=[storyboard instantiateInitialViewController];
            [TJYHelper sharedTJYHelper].isRootWindowIn=NO;
        }else{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark --Private methods
#pragma mark -- 初始化界面
- (void)initWorkRankView{
    intensityTabView=[[UITableView alloc] initWithFrame:CGRectMake(0, 74, kScreenWidth,kScreenHeight-74) style:UITableViewStylePlain];
    intensityTabView.delegate=self;
    intensityTabView.dataSource=self;
    intensityTabView.showsVerticalScrollIndicator=NO;
    [intensityTabView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:intensityTabView];

    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, kScreenHeight-60, 150, 40)];
    [nextButton setTitle:@"完成" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor colorWithHexString:@"0xff9d38"] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){255.0/256, 157.0/256, 56.0/256,1 });
    [nextButton.layer setBorderColor:colorref];//边框颜色
    [nextButton addTarget:self action:@selector(toCompleteAction) forControlEvents:UIControlEventTouchUpInside];
    nextButton.layer.cornerRadius = 5;
    nextButton.layer.borderWidth = 1;
    [self.view addSubview:nextButton];

}

#pragma mark 加载劳动强度
-(void)loadLaborData{
    NSArray *laborArr=[TJYHelper sharedTJYHelper].laborInstensityArr;
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for (NSDictionary *dict in laborArr) {
        TJYLaborModel  *labor=[[TJYLaborModel alloc] init];
        [labor setValues:dict];
        labor.isSelected=[NSNumber numberWithBool:NO];
        [tempArr addObject:labor];
    }
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    for (int i=0; i<tempArr.count; i++) {
        TJYLaborModel  *labor = tempArr[i];
        if (i==1) {
            labor.isSelected = [NSNumber numberWithBool:YES];
        }
        [dataArr addObject:labor];
    }
    workArray=dataArr;
    selLabor=workArray[1];
    [intensityTabView reloadData];
}

@end
