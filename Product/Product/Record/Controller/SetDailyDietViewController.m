//
//  SetDailyDietViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SetDailyDietViewController.h"
#import "TimePickerView.h"
#import "IntensityViewController.h"
#import "TJYUserModel.h"

@interface SetDailyDietViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,IntensityDelegate>{
    
    TimePickerView  *pickerView;              //选择器

    NSArray         *personInfoArray;
    NSInteger       heigh;                   //身高
    double          weight;                  //体重
    NSString        *laborIntensityString;   //劳动强度
    NSArray         *laborArray;             //劳动类型列表
    
    TJYUserModel     *userModel;

}


@property (nonatomic,strong)UITableView *infoTableView;

@end

@implementation SetDailyDietViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"设置每日饮食目标";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    personInfoArray=@[@"身高",@"体重",@"劳动强度"];
    laborArray=@[@"休息状态",@"轻体力劳动",@"中体力劳动",@"重体力劳动"];
    userModel = [[TJYUserModel alloc] init];

    [self initDailyTargetView];
    [self getUserInfoData];
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return personInfoArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.text=personInfoArray[indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:14.0f];
    cell.detailTextLabel.font=[UIFont systemFontOfSize:13.0f];
    if (indexPath.row==0) {
        cell.detailTextLabel.text=heigh==0?@"请选择身高":[NSString stringWithFormat:@"%ldcm",(long)heigh];
    }else if(indexPath.row==1){
        cell.detailTextLabel.text=weight>0.1?[NSString stringWithFormat:@"%.1fkg",weight]:@"请选择体重";
    }else{
        cell.detailTextLabel.text=kIsEmptyString(laborIntensityString)?@"请选择劳动强度":laborIntensityString;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==2) {
        IntensityViewController *intensityVC=[[IntensityViewController alloc] init];
        intensityVC.controllerDelegate=self;
        intensityVC.laborIntensity=laborIntensityString;
        [self.navigationController pushViewController:intensityVC animated:YES];
    }else{
        if (indexPath.row==0) {
            heigh = heigh < 30 ? 160:heigh;
            pickerView =[[TimePickerView alloc] initWithTitle:@"身高" delegate:self];
            pickerView.pickerStyle=PickerStyle_Height;
            [pickerView.locatePicker selectRow:heigh-30 inComponent:0 animated:YES];
            [pickerView showInView:self.view];
            [pickerView pickerView:pickerView.locatePicker didSelectRow:heigh-30 inComponent:0];
        }else if(indexPath.row==1){
            NSInteger rowValue=0;
            NSInteger rowValue2=0;
            if (weight<10.0) {
                rowValue=60;
                rowValue2=0;
            }else{
                rowValue=(NSInteger)weight;
                rowValue2=(weight+0.01-rowValue)*10;
            }
            pickerView =[[TimePickerView alloc] initWithTitle:@"体重" delegate:self];
            pickerView.pickerStyle=PickerStyle_Weight;
            [pickerView.locatePicker selectRow:rowValue-1 inComponent:0 animated:YES];
            [pickerView.locatePicker selectRow:rowValue2 inComponent:2 animated:YES];
            [pickerView showInView:self.view];
            [pickerView pickerView:pickerView.locatePicker didSelectRow:rowValue-1 inComponent:0];
            [pickerView pickerView:pickerView.locatePicker didSelectRow:rowValue2 inComponent:2];
            
        }
    }
}
#pragma mark -- UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (pickerView.pickerStyle==PickerStyle_Height) {
            heigh=[pickerView.locatePicker selectedRowInComponent:0]+30;
        }else if (pickerView.pickerStyle==PickerStyle_Weight){
            NSInteger row1=[pickerView.locatePicker selectedRowInComponent:0]+1;
            NSInteger row2=[pickerView.locatePicker selectedRowInComponent:2];
            weight=row1+row2/10.0;
        }
        [self.infoTableView reloadData];
    }
}
#pragma mark -- Custom Delegate
-(void)intensityViewControllerDidSelectLaborIntensity:(NSString *)selectLabor{
    laborIntensityString=selectLabor;
    [self.infoTableView reloadData];
}

#pragma mark -- Event Response
#pragma mark 计算能量
-(void)calculateEnergy:(UIButton *)sender{
    if (heigh<50) {
        [self.view makeToast:@"请选择身高" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (weight<10.0) {
        [self.view makeToast:@"请选择体重" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(laborIntensityString)||[laborIntensityString isEqualToString:@"请选择劳动强度"]) {
        [self.view makeToast:@"请选择劳动强度" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    NSString *body = [NSString stringWithFormat:@"height=%ld&weight=%f&labour_intensity=%@&doSubmit=1",(long)heigh,weight,laborIntensityString];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kSetUserInfo body:body success:^(id json) {
        
        [[TonzeHelpTool sharedTonzeHelpTool] calculateDailyEnergyWithHeight:heigh weight:weight labor:laborIntensityString];
        [TJYHelper sharedTJYHelper].isReloadUserInfo=YES;
        [TJYHelper sharedTJYHelper].isSetDietTarget=YES;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        
    }];

}

#pragma mark -- Pravite Methods
#pragma mark 获取个人信息
-(void)getUserInfoData{
    
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kGetUserInfo body:@"" success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            [userModel setValues:result];
            
            heigh=[userModel.height integerValue];
            weight=[userModel.weight doubleValue];
            laborIntensityString=userModel.labour_intensity;
            
            [self.infoTableView reloadData];
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter]; }];
}
#pragma mark 初始化界面
-(void)initDailyTargetView{
    [self.view addSubview:self.infoTableView];
    
    UILabel *descLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, self.infoTableView.bottom+20, kScreenWidth-20, 25)];
    descLabel.text=@"系统将根据您填写的信息计算饮食标准";
    descLabel.textAlignment=NSTextAlignmentCenter;
    descLabel.font=[UIFont systemFontOfSize:12.0f];
    descLabel.textColor=[UIColor lightGrayColor];
    [self.view addSubview:descLabel];
    
    UIButton *calculateButton=[[UIButton alloc] initWithFrame:CGRectMake(20, descLabel.bottom+5, kScreenWidth-40, 40)];
    [calculateButton setBackgroundColor:kSystemColor];
    calculateButton.layer.cornerRadius=3.0;
    calculateButton.clipsToBounds=YES;
    calculateButton.titleLabel.font=[UIFont systemFontOfSize:17.0f];
    [calculateButton setTitle:@"计算" forState:UIControlStateNormal];
    [calculateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [calculateButton addTarget:self action:@selector(calculateEnergy:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:calculateButton];
}

#pragma mark -- Getters and Setters
#pragma mark 个人数据
-(UITableView *)infoTableView{
    if (_infoTableView==nil) {
        _infoTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 69, kScreenWidth, 132) style:UITableViewStylePlain];
        _infoTableView.delegate=self;
        _infoTableView.dataSource=self;
        _infoTableView.showsVerticalScrollIndicator=NO;
        _infoTableView.tableFooterView=[[UIView alloc] init];
    }
    return _infoTableView;
}


@end
