//
//  ScalePersonInfoViewController.m
//  Product
//
//  Created by Feng on 16/2/27.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "ScalePersonInfoViewController.h"
#import "TimePickerView.h"
#import "ScaleViewController.h"
#import "DataPickerView.h"

@interface ScalePersonInfoViewController ()<DatePickerViewDelegate>{
    TimePickerView    *Picker;
    
    TJYUserModel      *userModel;
}

@end

@implementation ScalePersonInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"设置个人信息";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    userModel=[TonzeHelpTool sharedTonzeHelpTool].user;
    
    [self initScalePersonInfoView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


-(IBAction)selectAge:(id)sender{
    
    NSString *currentDateStr=kIsEmptyString(userModel.birthday)?@"1990-01-01":userModel.birthday;
    DataPickerView *datePickerView=[[DataPickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) value:currentDateStr dateType:DateTypeDate pickerType:DatePickerViewTypeBirthday title:@"出生日期"];
    datePickerView.pickerDelegate=self;
    [datePickerView datePickerViewShowInView:self.view];
}

-(IBAction)selectHeight:(id)sender{
    Picker =[[TimePickerView alloc]initWithTitle:@"身高" delegate:self];
    Picker.pickerStyle=PickerStyle_Height;
    NSInteger aHeight = [userModel.height integerValue];
    if (aHeight < 30) {
        aHeight = 160;
    }
    [Picker.locatePicker selectRow:aHeight-30 inComponent:0 animated:YES];
    [Picker showInView:self.view];
    [Picker pickerView:Picker.locatePicker didSelectRow:aHeight-30 inComponent:0];
}

-(IBAction)selectSex:(id)sender{
    Picker =[[TimePickerView alloc] initWithTitle:@"性别" delegate:self];
    Picker.pickerStyle=PickerStyle_Sex;
    [Picker.locatePicker selectRow:0 inComponent:0 animated:YES];
    [Picker showInView:self.view];
    [Picker pickerView:Picker.locatePicker didSelectRow:0 inComponent:0];}

#pragma mark TimePicker Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
         if (Picker.pickerStyle==PickerStyle_Height){
            userModel.height=[NSString stringWithFormat:@"%li",(long)[Picker.locatePicker selectedRowInComponent:0]+30];
             heightValueLbl.text=[NSString stringWithFormat:@"%@",userModel.height];
        }else if (Picker.pickerStyle==PickerStyle_Sex){
            userModel.sex=[Picker.locatePicker selectedRowInComponent:0]+1;
            sexValueLbl.text=userModel.sex==1?@"男":@"女";
        }
    }
}

#pragma mark DatePickerViewDelegate
-(void)datePickerView:(DatePickerView *)pickerView didSelectDate:(NSString *)dateStr{
    ageValueLbl.text=dateStr;
    userModel.birthday=dateStr;
}

-(IBAction)setComplete:(id)sender{
    __weak typeof(self) weakSelf=self;
    NSString *body=[NSString stringWithFormat:@"sex=%ld&height=%@&birthday=%@&doSubmit=1",(long)userModel.sex,userModel.height,userModel.birthday];
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kSetUserInfo body:body success:^(id json) {
        
        NSInteger age=[[TonzeHelpTool sharedTonzeHelpTool] getPersonAgeWithBirthdayString:userModel.birthday];
        [NSUserDefaultInfos putKey:USER_AGE andValue:[NSString stringWithFormat:@"%ld",(long)age]];
        [NSUserDefaultInfos putKey:USER_HEIGHT andValue:userModel.height];
        [NSUserDefaultInfos putKey:USER_SEX andValue:sexValueLbl.text];
        [TonzeHelpTool sharedTonzeHelpTool].user=userModel;
        
        BOOL isHasScaleVc=NO;
        for (UIViewController *controller in weakSelf.navigationController.viewControllers) {
            if ([controller isKindOfClass:[ScaleViewController class]]) {
                isHasScaleVc=YES;
            }
        }
        if (isHasScaleVc) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            ScaleViewController *scaleVC=[[ScaleViewController alloc] init];
            [weakSelf.navigationController pushViewController:scaleVC animated:YES];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
    
}

- (void)saveFaild{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithTitle:@"提示" Message:@"保存失败"];
    });
}


#pragma mark 初始化界面
-(void)initScalePersonInfoView{
    completeBtn.layer.masksToBounds=YES;
    completeBtn.layer.cornerRadius=20.0f;
    
    if (userModel.sex<1||userModel.sex>2) {
       sexValueLbl.text=@"请选择性别";
    }else{
       sexValueLbl.text=userModel.sex==1?@"男":@"女";
    }
    heightValueLbl.text=[userModel.height integerValue]>30?[NSString stringWithFormat:@"%@cm",userModel.height]:@"请选择身高";
    ageValueLbl.text=kIsEmptyString(userModel.birthday)?@"请选择出生日期":userModel.birthday;
}




@end
