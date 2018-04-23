//
//  AddRemindViewController.m
//  Product
//
//  Created by Feng on 16/3/22.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "AddRemindViewController.h"
#import "YTKKeyValueStore.h"
#import "TimePickerView.h"
#import "Transform.h"
#import "DrinkRemindViewController.h"
#import "DeviceHelper.h"

@interface AddRemindViewController ()<UITextFieldDelegate,UIAlertViewDelegate>{
    YTKKeyValueStore * YTKHelper;
    TimePickerView   * pickerView;
    UIAlertAction    * OkBtnEnabledAction;
    
}

@end

@implementation AddRemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!YTKHelper) {
        YTKHelper = [[YTKKeyValueStore alloc] initDBWithName:@"TJProduct.db"];
    }
    
    if (self.isUpdateRemind) {
        //编辑页面
        self.baseTitle=@"编辑提醒";
        
        timeValueLbl .text=[self.remindDic objectForKey:@"time"];
        valueValueLbl.text=[self.remindDic objectForKey:@"value"];
    }else{
      self.baseTitle=@"添加提醒";
    }
    self.rigthTitleName=@"完成";
    
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
}


-(void)rightButtonAction{
    if ([self checkTime]) {
        [self showAlertWithTitle:@"提示" Message:@"该时间点已设置饮水计划，无需重复！"];
    }else{
        if (self.isUpdateRemind) {
            [self updateRemind];
        }
        else{
            [self insertRemind];
        }
    }
}

- (BOOL)checkTime{
    BOOL hasSame = NO;
    for (NSDictionary *oldDict in self.remindDics) {
        if ([oldDict[@"time"] isEqualToString:timeValueLbl.text]) {
            hasSame = YES;
            break;
        }
    }
    return hasSame;
}

#pragma mark Database
#pragma mark 插入数据库
-(void)insertRemind{
    NSString *currentDate=[NSUserDefaultInfos getCurrentDate];
    NSString *currentUser=[NSUserDefaultInfos getValueforKey:USER_ID];
    NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:currentDate,@"date",timeValueLbl.text,@"time",valueValueLbl.text,@"value",@"0",@"isOn",self.model.mac,@"deviceid",currentUser,@"userid", nil];
    NSDictionary *insertDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data", nil];
    [YTKHelper insertDataWithJSON:[Transform DataToJsonString:insertDic]];
    NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
    DrinkRemindViewController *remindVC=[self.navigationController.viewControllers objectAtIndex:index-1];
    [remindVC updateUIafterAddRemind];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 更新数据库
-(void)updateRemind{
    //数据库
    NSDictionary *dataDic=[[NSDictionary alloc]initWithObjectsAndKeys:timeValueLbl.text,@"time",valueValueLbl.text,@"value",self.model.mac,@"deviceid", nil];
    //查询条件
    NSDictionary *queryDic=@{@"deviceid":@{@"$in":@[[NSString stringWithFormat:@"%@",self.model.mac]]},@"id":@{@"$in":@[[self.remindDic objectForKey:@"id"]]}};
    NSDictionary *sqlDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data",queryDic,@"query", nil];
    [YTKHelper updateData:[Transform DataToJsonString:sqlDic]];
    NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
    DrinkRemindViewController *remindVC=[self.navigationController.viewControllers objectAtIndex:index-1];
    [remindVC updateUIafterAddRemind];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)selectTime:(id)sender{
    pickerView=[[TimePickerView alloc]initWithTitle:@"饮水时间" delegate:self];
    pickerView.timeDisplayIn24=YES;
    pickerView.isOrderType=YES;
    pickerView.isSetTime=YES;
    pickerView.pickerStyle=PickerStyle_Time;

    NSInteger hour=[timeValueLbl.text substringToIndex:2].integerValue;
    NSInteger min=[timeValueLbl.text substringFromIndex:3].integerValue;
    
    [pickerView.locatePicker selectRow:hour inComponent:0 animated:NO];
    [pickerView.locatePicker selectRow:min/5 inComponent:1 animated:NO];
    [pickerView showInView:self.view];
    [pickerView pickerView:pickerView.locatePicker didSelectRow:hour inComponent:0];
    [pickerView pickerView:pickerView.locatePicker didSelectRow:min/5 inComponent:1];
}


-(IBAction)selectValue:(id)sender{
    NSString *title = NSLocalizedString(@"喝水量", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"300 ml"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField becomeFirstResponder];
        textField.delegate=self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (alertController.textFields.firstObject.text.length>6||alertController.textFields.firstObject.text.length<1) {
            [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.7f];
        }else{
            valueValueLbl.text=[NSString stringWithFormat:@"%@ml",alertController.textFields.firstObject.text];
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


#pragma mark PickerViewDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSInteger hour=[pickerView.locatePicker selectedRowInComponent:0];
        NSInteger min=[pickerView.locatePicker selectedRowInComponent:1]*5;
        
        timeValueLbl.text=[NSString stringWithFormat:@"%@:%@",hour<10?[NSString stringWithFormat:@"0%li",(long)hour]:[NSString stringWithFormat:@"%li",(long)hour],min<10?[NSString stringWithFormat:@"0%li",(long)min]:[NSString stringWithFormat:@"%li",(long)min]];
    }
}


@end
