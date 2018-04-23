//
//  AddSportViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddSportViewController.h"
#import "SportViewController.h"
#import "TimePickerView.h"
#import "DataPickerView.h"
#import "TonzeHelpTool.h"

@interface AddSportViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,SportsViewControllerDelegate,DatePickerViewDelegate>{
    
    NSArray         *personInfoArray;
    NSDictionary    *sportTypeDict;        //运动类型
    NSInteger       minute;                //运动时长
    NSString        *sportbeginTime;       //运动开始时间
    NSInteger       consumeColaries;       //消耗能量
    
    
    TimePickerView   *Picker;               //运动时长选择器
    DataPickerView   *datePickerView;       //开始时间选择
    
    UITextView      *remarkTextView;
    UILabel         *promptLabel;
    UILabel         *countLabel;
    
    BOOL            isBoolBack;             //是否确定返回
}
@property (nonatomic,strong)UITableView *sportTableView;

@end

@implementation AddSportViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"记录运动";
    self.rightImageName = self.sportModel?@"ic_n_del":nil;

    self.view.backgroundColor = [UIColor bgColor_Gray];
    isBoolBack=NO;
    
    personInfoArray=@[@"运动类型",@"运动时长",@"运动开始时间"];
    sportTypeDict=[[NSDictionary alloc] init];
    minute=0;
    consumeColaries=0;
    sportbeginTime=[[TJYHelper sharedTJYHelper] getCurrentDateTime];
    
    [self initsportView];
    [self initSportsRecordData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    if ([TonzeHelpTool sharedTonzeHelpTool].isAddSport) {
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-03-02" type:1];
    }else{
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-03-06" type:1];
    }
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    if ([TonzeHelpTool sharedTonzeHelpTool].isAddSport) {
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-03-02" type:2];
    }else{
        [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-03-06" type:2];
    }
#endif
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0?3:1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=personInfoArray[indexPath.row];
        if (indexPath.row==0) {
            NSString *name = sportTypeDict[@"name"];
            NSString *sportType= name.length>0?name:self.sportModel.motion_type_name;
            cell.detailTextLabel.text=kIsEmptyString(sportType)?@"请选择运动类型":sportType;
        }else if(indexPath.row==1){
            cell.detailTextLabel.text=minute==0?@"请选择运动时长":[NSString stringWithFormat:@"%ld分钟",(long)minute];
        }else{
            cell.detailTextLabel.text=sportbeginTime;
        }
    }else {
        cell.textLabel.text=@"消耗热量";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%ld千卡",(long)consumeColaries>0?consumeColaries:[self.sportModel.calorie integerValue]];
        if ([self.sportModel.calorie integerValue]==0&&consumeColaries==0) {
            cell.detailTextLabel.text = @"--千卡";
        }
        if (consumeColaries==0) {
            consumeColaries =[self.sportModel.calorie integerValue];
        }
    }
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        if (indexPath.row == 0) {
            SportViewController *sportsVC = [[SportViewController alloc] init];
            if (self.sportModel) {
                sportsVC.motion_record_id = self.sportModel.motion_record_id;
            }
            sportsVC.controllerDelegate = self;
            [self.navigationController pushViewController:sportsVC animated:YES];
        }else if(indexPath.row ==1){
            Picker =[[TimePickerView alloc]initWithTitle:@"运动时长" delegate:self];
            Picker.pickerStyle=PickerStyle_sportTime;
            minute = minute < 1? 30:minute;
            [Picker.locatePicker selectRow:minute-1 inComponent:0 animated:YES];
            [Picker showInView:self.view];
            [Picker pickerView:Picker.locatePicker didSelectRow:minute-1 inComponent:0];
            
        }else{
            datePickerView=[[DataPickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) value:sportbeginTime dateType:DateTypeDateTime pickerType:DatePickerViewTypeNormal title:@""];
            datePickerView.pickerDelegate=self;
            [datePickerView datePickerViewShowInView:self.view];
        }
    }
 }
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return section==0?20:0.1;
}
#pragma mark -- CustomDelegate
#pragma mark DatePickerViewDelegate
-(void)datePickerView:(DataPickerView *)pickerView didSelectDate:(NSString *)dateStr{
    sportbeginTime=dateStr;
    isBoolBack=YES;
    [_sportTableView reloadData];
}
#pragma mark  SportsViewControllerDelegate
-(void)sportsViewControllerDidSelectDict:(NSDictionary *)dict{
    sportTypeDict=dict;
    isBoolBack=YES;
    NSInteger calory=[sportTypeDict[@"calory"] integerValue];
    if (self.sportModel) {
        NSInteger calory=[self.sportModel.calorie_type integerValue];
        consumeColaries =minute*calory/30;
    } else {
        consumeColaries =minute*calory/30;
    }
    [self.sportTableView reloadData];
}
#pragma mark TimePickerViewDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (Picker.pickerStyle==PickerStyle_sportTime) {
            isBoolBack=YES;
            minute=[Picker.locatePicker selectedRowInComponent:0]+1;
            if (self.sportModel) {
                NSInteger calory=[self.sportModel.calorie_type integerValue];
                consumeColaries =minute*calory/30;
            } else {
                NSInteger calory=[sportTypeDict[@"calory"] integerValue];
                consumeColaries =minute*calory/30;
            }

            [_sportTableView reloadData];
        }
    }
}
#pragma mark--UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView{
    isBoolBack=YES;
    NSString *tString = [NSString stringWithFormat:@"%lu/100",(unsigned long)textView.text.length];
    countLabel.text = tString;
}

- (void)textViewDidChange:(UITextView *)textView{
    isBoolBack=YES;
    if ([textView.text length]!= 0) {
        promptLabel.hidden = YES;
    }else{
        promptLabel.hidden = NO;
        NSString *tString = [NSString stringWithFormat:@"%lu/100",(unsigned long)textView.text.length];
        countLabel.text = tString;
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (textView==remarkTextView) {
        
        if ([textView.text length]+text.length>100) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSString *body=[NSString stringWithFormat:@"motion_record_id=%ld",(long)self.sportModel.motion_record_id];
        kSelfWeak;
        [[NetworkTool sharedNetworkTool] postMethodWithURL:kSportRecordDelete body:body success:^(id json) {
            [TJYHelper sharedTJYHelper].isSportsReload=YES;
            [TJYHelper sharedTJYHelper].isSportsHistoryReload=YES;
            [TJYHelper sharedTJYHelper].isSportsRecordReload=YES;

            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
#pragma mark -- Event response
#pragma mark -- 保存
-(void)preserveAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-03-05"];
#endif
    NSInteger beginTime=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:sportbeginTime format:@"yyyy-MM-dd HH:mm"];
    NSString *body=nil;
    NSString *url=nil;
    if (self.sportModel) {
        body=[NSString stringWithFormat:@"doSubmit=1&motion_bigin_time=%ld&motion_type=%@&motion_time=%ld&calorie=%ld&remark=%@&motion_record_id=%ld",(long)beginTime,sportTypeDict[@"sportid"],(long)minute,(long)consumeColaries,remarkTextView.text,(long)self.sportModel.motion_record_id];
        url=kSportRecordUpdate;
    }else{
        body=[NSString stringWithFormat:@"doSubmit=1&motion_bigin_time=%ld&motion_type=%@&motion_time=%ld&calorie=%ld&remark=%@",(long)beginTime,sportTypeDict[@"sportid"],(long)minute,(long)consumeColaries,remarkTextView.text];
        url=kSportRecordAdd;
    }
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:url body:body success:^(id json) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
        [TJYHelper sharedTJYHelper].isSportsReload=YES;
        [TJYHelper sharedTJYHelper].isSportsRecordReload=YES;
        if (self.sportModel) {
            [TJYHelper sharedTJYHelper].isSportsHistoryReload=YES;
        }

    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];


}
#pragma mark -- 返回按钮事件
-(void)leftButtonAction{
    if (isBoolBack == YES) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确认放弃此次记录编辑" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark 删除
-(void)rightButtonAction{
    if (self.sportModel) {
#if !DEBUG
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-03-04"];
#endif
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"确认删除记录?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}
#pragma mark -- 完成
- (void)resignKeyboard{
    [self.view endEditing:YES];
}

#pragma mark -- toolbar
- (void)initToolBarTextView{
    
    //定义一个toolBar
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 35)];
    topView.backgroundColor = [UIColor whiteColor];
    //设置style
    [topView setBarStyle:UIBarStyleDefault];
    //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
    UIBarButtonItem * button1 =[[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * button2 = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //定义完成按钮
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(resignKeyboard)];
    //在toolBar上加上这些按钮
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    [topView setItems:buttonsArray];
    [remarkTextView setInputAccessoryView:topView];
}
#pragma mark -- Pravite Methods
#pragma mark 初始化运动记录
-(void)initSportsRecordData{
    if (self.sportModel) {

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[NSString stringWithFormat:@"%ld",self.sportModel.motion_type] forKey:@"sportid"];
        sportTypeDict=dict;
        
        minute=[self.sportModel.motion_time integerValue];
        sportbeginTime=[[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:self.sportModel.motion_bigin_time format:@"yyyy-MM-dd HH:mm"];
        NSInteger calory=[sportTypeDict[@"calory"] integerValue];
        consumeColaries =minute*calory/60;
        [self.sportTableView reloadData];
        
        remarkTextView.text=self.sportModel.remark;
        NSString *tString = [NSString stringWithFormat:@"%lu/100",(unsigned long)remarkTextView.text.length];
        countLabel.text = tString;
        promptLabel.hidden=remarkTextView.text.length>0;
    }
}
#pragma mark -- 初始化界面
- (void)initsportView{
    [self.view addSubview:self.sportTableView];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,  _sportTableView.bottom+30, kScreenWidth, 120)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    remarkTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, _sportTableView.bottom+30, kScreenWidth-30, 120)];
    remarkTextView.delegate = self;
    remarkTextView.backgroundColor = [UIColor whiteColor];
    remarkTextView.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:remarkTextView];
    [self initToolBarTextView];
    
    promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, remarkTextView.top+7, 200, 20)];
    promptLabel.text = @"请填写备注（选填）";
    promptLabel.font = [UIFont systemFontOfSize:15];
    promptLabel.textColor = [UIColor grayColor];
    [self.view addSubview:promptLabel];
    
    countLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100, remarkTextView.bottom-30, 80, 20)];
    countLabel.text = @"0/100";
    countLabel.textColor = [UIColor grayColor];
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:countLabel];
    
    UIButton *preserveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
    preserveButton.backgroundColor = kSystemColor;
    [preserveButton setTitle:@"保存" forState:UIControlStateNormal];
    [preserveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [preserveButton addTarget:self action:@selector(preserveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:preserveButton];
}

#pragma mark -- Getters and Setters
#pragma mark -- 个人数据
-(UITableView *)sportTableView{
    if (_sportTableView==nil) {
        _sportTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64+5, kScreenWidth, 220) style:UITableViewStylePlain];
        _sportTableView.delegate=self;
        _sportTableView.dataSource=self;
        _sportTableView.showsVerticalScrollIndicator=NO;
        _sportTableView.tableFooterView=[[UIView alloc] init];
        _sportTableView.scrollEnabled =NO; //设置tableview 不能滚动
        
    }
    return _sportTableView;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
