//
//  TJYLaborViewController.m
//  Product
//
//  Created by vision on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYLaborViewController.h"
#import "TJYIntensityTableViewCell.h"
#import "TJYLaborModel.h"

@interface TJYLaborViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray   *workArray;
}

@property (nonatomic,strong)UITableView  *intensityTabView;

@end

@implementation TJYLaborViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"劳动强度";
    workArray =[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.intensityTabView];
    
    [self getLaborIntensityData];
    
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    TJYLaborModel *model=workArray[indexPath.row];
    [cell cellDisplayWithLabor:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TJYLaborModel *model=workArray[indexPath.row];
    [self.controllerDelegate laborVCDidSelectLabor:model.title];
    [self.navigationController popViewControllerAnimated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TJYLaborModel *labor=workArray[indexPath.row];
    return [TJYIntensityTableViewCell getCellHeightWithLabor:labor];
}

#pragma mark 获取劳动强度数据
-(void)getLaborIntensityData{
    NSArray *laborArr=[TJYHelper sharedTJYHelper].laborInstensityArr;
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for (NSDictionary *dict in laborArr) {
        TJYLaborModel *labor=[[TJYLaborModel alloc] init];
        [labor setValues:dict];
        if (!kIsEmptyString(self.laborIntensity)&&[self.laborIntensity isEqualToString:labor.title]) {
            labor.isSelected=[NSNumber numberWithBool:YES];
        }else{
            labor.isSelected=[NSNumber numberWithBool:NO];
        }
        [tempArr addObject:labor];
    }
    workArray=tempArr;
    [self.intensityTabView reloadData];
}

#pragma mark -- setters
-(UITableView *)intensityTabView{
    if (!_intensityTabView) {
        _intensityTabView=[[UITableView alloc] initWithFrame:CGRectMake(0, 74, kScreenWidth,kScreenHeight-74) style:UITableViewStylePlain];
        _intensityTabView.delegate=self;
        _intensityTabView.dataSource=self;
        _intensityTabView.showsVerticalScrollIndicator=NO;
        [_intensityTabView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    }
    return _intensityTabView;
}


@end
