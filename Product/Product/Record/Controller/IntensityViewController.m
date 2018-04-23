//
//  IntensityViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "IntensityViewController.h"
#import "IntensityTableViewCell.h"
#import "LaborModel.h"

@interface IntensityViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray   *workArray;
    UITableView      *intensityTabView;
}
@end

@implementation IntensityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"劳动强度";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    workArray =[[NSMutableArray alloc] init];
    
    [self initIntensityView];
    [self getLaborIntensityData];
    
}
#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return workArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCIntensityTableViewCell";
    IntensityTableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell = [[IntensityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LaborModel *model=workArray[indexPath.row];
    [cell cellDisplayWithLabor:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LaborModel *model=workArray[indexPath.row];
    [self.controllerDelegate intensityViewControllerDidSelectLaborIntensity:model.title];
    [self.navigationController popViewControllerAnimated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    LaborModel *labor=workArray[indexPath.row];
    return [IntensityTableViewCell getCellHeightWithLabor:labor];
}

#pragma mark 获取劳动强度数据
-(void)getLaborIntensityData{
    NSArray *laborArr=[TJYHelper sharedTJYHelper].laborInstensityArr;
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for (NSDictionary *dict in laborArr) {
        LaborModel *labor=[[LaborModel alloc] init];
        [labor setValues:dict];
        if ([self.laborIntensity isEqualToString:labor.title]) {
            labor.isSelected=[NSNumber numberWithBool:YES];
        }else{
            labor.isSelected=[NSNumber numberWithBool:NO];
        }
        [tempArr addObject:labor];
    }
    workArray=tempArr;
    [intensityTabView reloadData];
}

#pragma mark--初始化界面
- (void)initIntensityView{
    intensityTabView=[[UITableView alloc] initWithFrame:CGRectMake(0, 74, kScreenWidth,kScreenHeight-74) style:UITableViewStylePlain];
    intensityTabView.delegate=self;
    intensityTabView.dataSource=self;
    intensityTabView.showsVerticalScrollIndicator=NO;
    [intensityTabView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:intensityTabView];
}

@end
