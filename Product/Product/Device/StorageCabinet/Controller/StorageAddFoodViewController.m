//
//  StorageAddFoodViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StorageAddFoodViewController.h"
#import "FoodWeightScaleView.h"
#import "DataPickerView.h"
#import "StorageDeviceHelper.h"

@interface StorageAddFoodViewController ()<UITableViewDelegate,UITableViewDataSource,FoodWeightScaleViewDelegate,UITextFieldDelegate,DatePickerViewDelegate>{
    UIAlertAction *OkBtnEnabledAction;
    
}
@property(nonatomic, strong)UITableView *addFoodTableView;
@end

@implementation StorageAddFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.foodModel?@"编辑食材":@"存入食材";
    
    self.foodModel=self.foodModel?self.foodModel:[[StorageModel alloc] init];
    
    self.view.backgroundColor =[UIColor bgColor_Gray];
    
    [self.view addSubview:self.addFoodTableView];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kAllHeight-49, kScreenWidth, 49)];
    saveButton.backgroundColor = [UIColor colorWithHexString:@"#ffbe23"];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveStorageFoodAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
    
}
#pragma mark --UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row==0) {
        cell.textLabel.text = @"食材名称";
        cell.detailTextLabel.text = kIsEmptyString(self.foodModel.item_name)?@"请输入名称":self.foodModel.item_name;
    }else if (indexPath.row==1){
        cell.textLabel.text = @" 重量";
        cell.detailTextLabel.text = self.foodModel.weight==0?@"请选择重量":[NSString stringWithFormat:@"%ldg",(long)self.foodModel.weight];
    }else{
        cell.textLabel.text = @"过期日期";
        if (self.foodModel.overdue_time>0) {
            NSString *expiredTime=[[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",self.foodModel.overdue_time] format:@"yyyy-MM-dd"];
            cell.detailTextLabel.text = expiredTime;
        }else{
            cell.detailTextLabel.text = @"请选择日期";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        [self changeFoodName];
    }else if (indexPath.row==1){
        NSInteger weight=self.foodModel.weight>0?self.foodModel.weight:0;
        FoodWeightScaleView *scaleView=[[FoodWeightScaleView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 300) weight:weight];
        scaleView.foodWeightScaleDelegate=self;
        [scaleView foodWeightScaleViewShowInView:self.view];
    }else{
        NSString *nowDateStr=[[TJYHelper sharedTJYHelper] getCurrentDate];
        NSString *currentDateStr=nil;
        if (self.foodModel.overdue_time>0) {
            NSString *expiredTime=[[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",(long)self.foodModel.overdue_time] format:@"yyyy-MM-dd"];
            currentDateStr=expiredTime;
        }else{
            currentDateStr=nowDateStr;
        }
        
        DataPickerView *datePickerView=[[DataPickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) value:currentDateStr dateType:DateTypeDate pickerType:DatePickerViewTypeFuture title:@""];
        datePickerView.pickerDelegate=self;
        [datePickerView datePickerViewShowInView:self.view];
    }
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark --FoodWeightScaleViewDelegate
- (void)foodWeightScaleView:(FoodWeightScaleView *)scale weight:(NSInteger)weight{
    self.foodModel.weight = weight;
    [self.addFoodTableView reloadData];
}
#pragma mark TCDatePickerViewDelegate
-(void)datePickerView:(DataPickerView *)pickerView didSelectDate:(NSString *)dateStr{
    self.foodModel.overdue_time = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:dateStr format:@"yyyy-MM-dd"];
    [self.addFoodTableView reloadData];
}


#pragma mark -- Event response
#pragma mark -- 保存
- (void)saveStorageFoodAction{
    if (kIsEmptyString(self.foodModel.item_name)) {
        [self.view makeToast:@"食材名称不能为空" duration:1.0 position:CSToastPositionCenter];
    }else if (self.foodModel.weight==0){
        [self.view makeToast:@"食材重量不能为0" duration:1.0 position:CSToastPositionCenter];
    }else if (self.foodModel.overdue_time==0){
        [self.view makeToast:@"食材过期日期不能为空" duration:1.0 position:CSToastPositionCenter];
    }else{
        __weak typeof(self) weakSelf=self;
        NSString *body=nil;
        NSString *urlStr=nil;
        int deviceId=[StorageDeviceHelper sharedStorageDeviceHelper].device_id;
        if (self.storageType==0) {
            body=[NSString stringWithFormat:@"device_id=%d&overdue_time=%ld&weight=%ld&item_name=%@&doSubmit=1",deviceId,(long)self.foodModel.overdue_time,(long)self.foodModel.weight,self.foodModel.item_name];
            urlStr=kAddStorageFood;
        }else{
            body=[NSString stringWithFormat:@"device_id=%d&overdue_time=%ld&weight=%ld&item_name=%@&locker_ingredient_id=%ld&doSubmit=1",deviceId,(long)self.foodModel.overdue_time,(long)self.foodModel.weight,self.foodModel.item_name,(long)self.foodModel.locker_ingredient_id];
            urlStr=kUpdateStorageFood;
        }
        [[NetworkTool sharedNetworkTool] postMethodWithURL:urlStr body:body success:^(id json) {
            [StorageDeviceHelper sharedStorageDeviceHelper].isStorageFoodRefresh=YES;
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:@"" duration:1.0 position:CSToastPositionCenter];
        }];
    }
}

#pragma mark -- Private Methods
#pragma mark 修改名称
-(void)changeFoodName{
    NSString *title = NSLocalizedString(@"食材名称", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"请输入食材名称"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        textField.delegate=self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    
    __weak typeof(self) weakSelf =self;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController.textFields.firstObject resignFirstResponder];
        alertController.textFields.firstObject.text = [alertController.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (alertController.textFields.firstObject.text.length>10||alertController.textFields.firstObject.text.length<1) {
            [weakSelf showAlertWithTitle:@"提示" Message:@"食材名称仅支持1-10个字"];
        }else{
            weakSelf.foodModel.item_name =alertController.textFields.firstObject.text;
            [weakSelf.addFoodTableView reloadData];
        }
    }];
    otherAction.enabled = NO;
    OkBtnEnabledAction = otherAction;//定义一个全局变量来存储
    [alertController addAction:otherAction];
    alertController.view.layer.cornerRadius = 20;
    alertController.view.layer.masksToBounds = YES;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark --NSNotification
- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    OkBtnEnabledAction.enabled = textField.text.length >= 1;
}

#pragma mark -- setters
- (UITableView *)addFoodTableView{
    if (_addFoodTableView==nil) {
        _addFoodTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationHeight+20, kScreenWidth, kBodyHeight-49) style:UITableViewStylePlain];
        _addFoodTableView.backgroundColor = [UIColor bgColor_Gray];
        _addFoodTableView.delegate  =self;
        _addFoodTableView.dataSource = self;
        [_addFoodTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    }
    return _addFoodTableView;
}



@end
