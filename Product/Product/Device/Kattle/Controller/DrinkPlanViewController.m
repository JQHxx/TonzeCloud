//
//  DrinkPlanViewController.m
//  Product
//
//  Created by Feng on 16/3/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DrinkPlanViewController.h"
#import "YTKKeyValueStore.h"
#import "Transform.h"
#import "DrinkRemindViewController.h"
#import "GraphViewController.h"
#import "DeviceHelper.h"

//手动重置弹框
#import "DeviceViewController.h"
#import "DeviceConnectStateCheckService.h"

@interface DrinkPlanViewController ()<UITextFieldDelegate,UIAlertViewDelegate>{
    YTKKeyValueStore *YTKHelper;
    
     UIAlertAction *OkBtnEnabledAction;
    
     NSMutableArray *recordArr;
    
    int drankWater;// 已喝的水量
}

@end

@implementation DrinkPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"饮水计划";
    self.rightImageName=@"设置icon";
    
    if (!YTKHelper) {
        YTKHelper = [[YTKKeyValueStore alloc] initDBWithName:@"TJProduct.db"];
    }
    
    [self getAllRecord];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getAllRecord) name:@"Drink_Plan_Reload_TB" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"Drink_Plan_Reload_TB" object:nil];
}

-(void)rightButtonAction{
    DrinkRemindViewController *drinkVC=[DrinkRemindViewController instantiateOfStoryboard];
    drinkVC.model=self.model;
    [self.navigationController pushViewController:drinkVC animated:YES];
}


-(IBAction)addRecord:(id)sender{
    NSString *title = NSLocalizedString(@"喝水量", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"200 ml"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setReturnKeyType:UIReturnKeyDone];
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
        if (alertController.textFields.firstObject.text.length>6||alertController.textFields.firstObject.text.length<1) {
            [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:YES];
        }else{
            [self insertRecord:[NSString stringWithFormat:@"%@ml",alertController.textFields.firstObject.text]];
            [self getAllRecord];
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

#pragma mark UI
-(void)updateDrankView{
    
    int totalValue=[NSUserDefaultInfos getIntValueforKey:DRINK_VALUE];
    if (totalValue==0) {
        [NSUserDefaultInfos putInt:DRINK_VALUE andValue:1600];
        totalValue=1600;
    }
    totalLbl.text=[NSString stringWithFormat:@"%dml",1600];
    drankLbl.text=[NSString stringWithFormat:@"已喝%dml",drankWater];
    int percent=drankWater*100/totalValue;
    if (percent<=0) {
        drinkIV.image=[UIImage imageNamed:@"水杯0"];
    }
    else if (percent>=0&&percent<10){
        drinkIV.image=[UIImage imageNamed:@"水杯10"];
    }else if (percent>=10&&percent<20){
       drinkIV.image=[UIImage imageNamed:@"水杯20"];
    }else if (percent>=20&&percent<30){
        drinkIV.image=[UIImage imageNamed:@"水杯30"];
    }else if (percent>=30&&percent<40){
        drinkIV.image=[UIImage imageNamed:@"水杯40"];
    }else if (percent>=40&&percent<50){
        drinkIV.image=[UIImage imageNamed:@"水杯50"];
    }else if (percent>=50&&percent<60){
        drinkIV.image=[UIImage imageNamed:@"水杯60"];
    }else if (percent>=60&&percent<70){
        drinkIV.image=[UIImage imageNamed:@"水杯70"];
    }else if (percent>=70&&percent<80){
        drinkIV.image=[UIImage imageNamed:@"水杯80"];
    }else if (percent>=80&&percent<90){
        drinkIV.image=[UIImage imageNamed:@"水杯90"];
    }else{
       drinkIV.image=[UIImage imageNamed:@"水杯100"];
    }
    
}

- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    OkBtnEnabledAction.enabled = textField.text.length >= 1;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.text.length>6||textField.text.length<1) {
        
        [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.7f];
        
    }
    return YES;
}

-(void)showAlert{
    [self showAlertWithTitle:@"提示" Message:@"仅支持1-6个字符"];
}



#pragma mark Database
#pragma mark 插入饮水量
-(void)insertRecord:(NSString *)value{
    NSString *currentDate=[NSUserDefaultInfos getCurrentDate];
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    
    NSNumber *userid=[userDic objectForKey:@"user_id"];
    
    //获取年份
    NSNumber *year=[NSNumber numberWithInteger:[[currentDate substringToIndex:4] integerValue]];
    NSNumber *month=[NSNumber numberWithInteger:[[currentDate substringWithRange:NSMakeRange(5, 2)] integerValue]];
    NSNumber *day=[NSNumber numberWithInteger:[[currentDate substringWithRange:NSMakeRange(8, 2)] integerValue]];
    NSString *time=[currentDate substringFromIndex:11];
    
    //时间戳
    NSNumber *timeSP=[NSNumber numberWithInteger:[[NSUserDefaultInfos getTimeSP] integerValue]];
    
    NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:year,@"year",month,@"month",day,@"day",time,@"time",currentDate,@"date",[NSNumber numberWithFloat:value.floatValue],@"value",self.model.mac,@"deviceid",timeSP,@"timeSP",userid,@"user_id", nil];
    NSDictionary *insertDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_PLAN_TABLE,@"table",dataDic,@"data", nil];
    
    [YTKHelper insertDataWithJSON:[Transform DataToJsonString:insertDic]];
}

#pragma mark 获取所有记录
-(void)getAllRecord{
    recordArr=[[NSMutableArray alloc]init];
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    NSNumber *userid=[userDic objectForKey:@"user_id"];
    NSDictionary *orderDic=[[NSDictionary alloc]initWithObjectsAndKeys:@"desc",@"date", nil];
    NSDictionary *queryDic=@{@"deviceid":@{@"$in":@[self.model.mac]},@"user_id":@{@"$in":@[userid]}};
    NSDictionary *sqlDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_PLAN_TABLE,@"table",orderDic,@"order",queryDic,@"query", nil];
    NSDictionary *resultDic=[YTKHelper queryDataWithJSON:[Transform DataToJsonString:sqlDic]];
    NSArray *allArr=[resultDic objectForKey:@"list"];
    NSString *today=[[NSUserDefaultInfos getCurrentDate ]substringToIndex:10];
    drankWater=0;
    
    //按时间分组
    for (int i=0; i<allArr.count; i++) {
        NSDictionary *dataDic=[allArr objectAtIndex:i];
        //计算今天的喝水量
        if ([[[dataDic objectForKey:@"date"] substringToIndex:10] isEqualToString:today]) {
            drankWater+=[[dataDic objectForKey:@"value"]intValue];
        }
        
        //处理tableView
        if (i==0) {
            NSMutableArray *valueArr=[[NSMutableArray alloc]init];
            [valueArr addObject:dataDic];
            NSDictionary *valueDic=[[NSDictionary alloc]initWithObjectsAndKeys:[[dataDic objectForKey:@"date"] substringToIndex:10],@"date",valueArr,@"data", nil];
            [recordArr addObject:valueDic];
        }else {
            if ([[[dataDic objectForKey:@"date"] substringToIndex:10] isEqualToString:[[[recordArr lastObject]objectForKey:@"date"] substringToIndex:10]]) {
                [[[recordArr lastObject] objectForKey:@"data"] addObject:dataDic];
            }else{
                NSMutableArray *valueArr=[[NSMutableArray alloc]init];
                [valueArr addObject:dataDic];
                NSDictionary *valueDic=[[NSDictionary alloc]initWithObjectsAndKeys:[[dataDic objectForKey:@"date"] substringToIndex:10],@"date",valueArr,@"data", nil];
                [recordArr addObject:valueDic];
            }
        }
    }
    //更新UI
    [self performSelectorOnMainThread:@selector(updateDrankView) withObject:nil waitUntilDone:NO];
    [recordTB performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return recordArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[recordArr objectAtIndex:section] objectForKey:@"data"] count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 下面这几行代码是用来设置cell的上下行线的位置
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    //控制分割线不缩进
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UITableViewHeaderFooterView *view=[[UITableViewHeaderFooterView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 2, 130 , 26)];
    imageView.image=[UIImage imageNamed:@"日期背景"];
    
    
    UILabel *dateLbl=[[UILabel alloc]initWithFrame:CGRectMake(15, 2, 105, 26)];
    dateLbl.textColor=[UIColor whiteColor];
    dateLbl.font=[UIFont systemFontOfSize:17];
    dateLbl.text=[[[recordArr objectAtIndex:section] objectForKey:@"date"] substringToIndex:10];
    [view addSubview:imageView];
    [view addSubview:dateLbl];
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"PlanCell";
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSDictionary *dic=[[[recordArr objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row];
    cell.textLabel.text=[[dic objectForKey:@"date"]substringWithRange:NSMakeRange(11, 5)];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"喝了%.0fml",[[dic objectForKey:@"value"]floatValue]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toRemindView"]) {
        DrinkRemindViewController *remindVC=[segue destinationViewController];
        remindVC.model=self.model;
    }else if ([segue.identifier isEqualToString:@"toGraphView"]){
        GraphViewController *graphVC=[segue destinationViewController];
        graphVC.model=self.model;
    }
}
@end
