//
//  PreferenceTypeViewController.m
//  Product
//
//  Created by Xlink on 16/1/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "PreferenceTypeViewController.h"
#import "PreferenceDetailViewController.h"
#import "AppDelegate.h"
#import "ControllerHelper.h"

//手动重置弹框
#import "DeviceViewController.h"
#import "DeviceConnectStateCheckService.h"
#import "DeviceHelper.h"

@interface PreferenceTypeViewController ()<UIAlertViewDelegate>{
    NSArray *imageArr,*typeArr;
}

@end

@implementation PreferenceTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor bgColor_Gray];
    self.baseTitle=@"工作类型";
    
    if (self.model.deviceType==CLOUD_COOKER) {
        imageArr=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"偏好_炖汤"],[UIImage imageNamed:@"偏好_煮粥"],[UIImage imageNamed:@"偏好_保温"],nil] ;
        typeArr =[[NSArray alloc]initWithObjects:@"炖汤",@"煮粥",@"营养保温", nil];
    }else if (self.model.deviceType==WATER_COOKER){
        imageArr=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"偏好_蒸煮"],[UIImage imageNamed:@"偏好_保温"],nil] ;
        typeArr =[[NSArray alloc]initWithObjects:@"炖煮",@"营养保温", nil];
    }else if (self.model.deviceType==COOKFOOD_KETTLE){
        imageArr=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"三杯鸡"],[UIImage imageNamed:@"黄焖鸡"],[UIImage imageNamed:@"红烧鱼"],[UIImage imageNamed:@"红焖排骨"],[UIImage imageNamed:@"清炖鸡"],[UIImage imageNamed:@"老火汤"],[UIImage imageNamed:@"红烧肉"],[UIImage imageNamed:@"东坡肘子"],[UIImage imageNamed:@"口水鸡"],[UIImage imageNamed:@"滑香鸡"],[UIImage imageNamed:@"茄子煲"],[UIImage imageNamed:@"梅菜扣肉"],nil] ;
        typeArr =[[NSArray alloc]initWithObjects:@"三杯鸡",@"黄焖鸡", @"红烧鱼",@"红焖排骨",@"清炖鸡",@"老火汤",@"红烧肉",@"东坡肘子",@"口水鸡",@"滑香鸡",@"茄子煲",@"梅菜扣肉",nil];
    }else if (self.model.deviceType==CLOUD_KETTLE){
        imageArr=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"偏好_煮水"],[UIImage imageNamed:@"偏好_除氯"],[UIImage imageNamed:@"偏好_保温"],nil] ;
        typeArr =[[NSArray alloc]initWithObjects:@"煮水",@"煮水除氯",@"保温", nil];
    }
    else{
        imageArr=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"偏好_精华煮"],[UIImage imageNamed:@"偏好_超快煮"],[UIImage imageNamed:@"偏好_煮粥"],[UIImage imageNamed:@"偏好_蒸煮"],[UIImage imageNamed:@"偏好_热饭"],[UIImage imageNamed:@"偏好_保温"],[UIImage imageNamed:@"偏好_炖汤"],nil] ;
        typeArr =[[NSArray alloc]initWithObjects:@"精华煮",@"超快煮",@"煮粥",@"蒸煮",@"热饭",@"营养保温",@"煲汤", nil];
    }
    // Do any additional setup after loading the view.
}

#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return typeArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"WorkTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] ;
    }
    [cell.imageView setImage:[imageArr objectAtIndex:indexPath.row]];
    cell.textLabel.text=[typeArr objectAtIndex:indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toPreferenceDetailView"]) {
        PreferenceDetailViewController *detailVC=[segue destinationViewController];
        detailVC.selectedType=mainTB.indexPathForSelectedRow.row ;
        detailVC.model=self.model;
    }
}


@end
