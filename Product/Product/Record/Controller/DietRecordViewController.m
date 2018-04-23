//
//  DietRecordViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DietRecordViewController.h"
#import "AddFoodViewController.h"
#import "FoodDingButton.h"
#import "DietAddFoodTableViewCell.h"
#import "TimePickerView.h"
#import "DataPickerView.h"
#import "FoodAddTool.h"
#import "FoodAddModel.h"
#import "BlankView.h"

@interface DietRecordViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,DatePickerViewDelegate>{
    NSArray               *periodArray;
    NSMutableArray        *foodListArray;
    
    TimePickerView        *pickerView;
    NSString              *dietDateStr;
    NSString              *dietTypeStr;
    
    BOOL            isBoolBack;             //是否确定返回
}

@property (nonatomic,strong)UILabel          *colaryLabel;
@property (nonatomic,strong)FoodDingButton   *diningTimeButton;
@property (nonatomic,strong)FoodDingButton   *diningTypeButton;
@property (nonatomic,strong)UIView           *foodHeadView;
@property (nonatomic,strong)UITableView      *foodTableView;
@property (nonatomic,strong)BlankView        *blankView;
@property (nonatomic,strong)UIButton         *saveFoodButton;

@end


@implementation DietRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"记录饮食";
    self.rightImageName = self.foodRecordModel?@"ic_n_del":nil;
    self.view.backgroundColor=[UIColor bgColor_Gray];
    periodArray=@[@"早餐",@"午餐",@"晚餐",@"加餐"];
    foodListArray=[[NSMutableArray alloc] init];
    isBoolBack = NO;
    dietDateStr=nil;
    dietTypeStr=nil;
    
    [self loadDietRecordData];  //加载饮食记录数据

    [self.view addSubview:self.colaryLabel];
    [self.view addSubview:self.diningTimeButton];
    [self.view addSubview:self.diningTypeButton];
    [self.view addSubview:self.foodHeadView];
    [self.view addSubview:self.foodTableView];
    [self.view addSubview:self.blankView];
    self.blankView.hidden=foodListArray.count>0;
    [self.view addSubview:self.saveFoodButton];
    
    [self getDietRecordData];  //计算热量
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([TJYHelper sharedTJYHelper].isAddFood) {
        [self addFoodReloadAction];
        [TJYHelper sharedTJYHelper].isAddFood=NO;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-01-03" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-01-03" type:2];
#endif
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return foodListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"DietAddFoodTableViewCell";
    DietAddFoodTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"DietAddFoodTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    FoodAddModel *food=foodListArray[indexPath.row];
    [cell cellFoodDisplayWith:food];
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{

        return UITableViewCellEditingStyleDelete;
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    if (editingStyle==UITableViewCellEditingStyleDelete) {
        FoodAddModel *food=foodListArray[indexPath.row];
        [foodListArray removeObjectAtIndex:indexPath.row];
        [[FoodAddTool sharedFoodAddTool] deleteFood:food];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self getDietRecordData];
        }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark -- Custom Delegate
#pragma mark  UIActionSheetDelegate (TimePickerView)
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        isBoolBack = YES;
        if (pickerView.pickerStyle==PickerStyle_DietTime) {
            NSInteger index=[pickerView.locatePicker selectedRowInComponent:0];
            dietTypeStr=[periodArray objectAtIndex:index];
            self.diningTypeButton.valueString=dietTypeStr;
        }
    }
}

#pragma mark DatePickerViewDelegate
-(void)datePickerView:(DataPickerView *)pickerView didSelectDate:(NSString *)dateStr{
    isBoolBack  = YES;
    dietDateStr=dateStr;
    self.diningTimeButton.valueString=dietDateStr;
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSArray *foodsArr=self.foodRecordModel.item;
        NSString *body=[NSString stringWithFormat:@"diet_record_id=%@",[foodsArr[0] objectForKey:@"diet_record_id"]];
        [[NetworkTool sharedNetworkTool] postMethodWithURL:kDietRecordDelete body:body success:^(id json) {
            [TJYHelper sharedTJYHelper].isDietReload=YES;
            [TJYHelper sharedTJYHelper].isHistoryDietReload=YES;
            [TJYHelper sharedTJYHelper].isRecordDietReload=YES;
            [self.navigationController popViewControllerAnimated:YES];

        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
#pragma mark -- Event response
#pragma mark 用餐时间
-(void)addDiningTimeAction:(FoodDingButton *)button{
    DataPickerView *datePickerView=[[DataPickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) value:dietDateStr dateType:DateTypeDate pickerType:DatePickerViewTypeNormal title:@""];
    datePickerView.pickerDelegate=self;
    [datePickerView datePickerViewShowInView:self.view];
}
#pragma mark 用餐类别
-(void)addDiningTypeAction:(FoodDingButton *)button{
    pickerView=[[TimePickerView alloc] initWithTitle:@"" delegate:self];
    pickerView.pickerStyle=PickerStyle_DietTime;
    pickerView.valuesArray=periodArray;
    NSUInteger index=[periodArray indexOfObject:dietTypeStr];
    [pickerView.locatePicker selectRow:index inComponent:0 animated:YES];
    [pickerView showInView:self.view];
}
#pragma mark 添加食物
-(void)addFoodAction:(UIButton *)sender{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-05"];
#endif
    AddFoodViewController *addFoodVC=[[AddFoodViewController alloc] init];
    [self.navigationController pushViewController:addFoodVC animated:YES];
}
#pragma mark 保存食物记录
-(void)saveDietDataAction:(UIButton *)sender{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-06"];
#endif
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for (FoodAddModel *model in foodListArray) {
        if (model.type==1||model.type==3) {  //添加食物
               if (self.foodRecordModel) {  //更新饮食记录
                   NSDictionary *dict=[[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:model.id],model.weight,[NSNumber numberWithInteger:model.energykcal],@"1"] forKeys:@[@"item_id",@"item_weight",@"item_calories",@"type"]];
                   [tempArr addObject:dict];
               }else{
                   NSDictionary *dict=[[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:model.id],model.weight,[NSNumber numberWithInteger:model.energykcal*[model.weight doubleValue]/100],@"1"] forKeys:@[@"item_id",@"item_weight",@"item_calories",@"type"]];
                   [tempArr addObject:dict];
               }
        }else{
            if (self.foodRecordModel) {
//                更新饮食记录
                    NSDictionary *dict=[[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:model.cook_id],model.weight,[NSNumber numberWithInteger:model.calories_pre100],@"2"] forKeys:@[@"item_id",@"item_weight",@"item_calories",@"type"]];
                    [tempArr addObject:dict];
                }else{
                    NSDictionary *dict=[[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:model.cook_id],model.weight,[NSNumber numberWithInteger:model.calories_pre100*[model.weight doubleValue]/100],@"2"] forKeys:@[@"item_id",@"item_weight",@"item_calories",@"type"]];
                    [tempArr addObject:dict];
            }

        }
    }
            NSString *jsonStr=[[NetworkTool sharedNetworkTool] getValueWithParams:tempArr]; //数组转json
            NSInteger timeSp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:dietDateStr format:@"yyyy-MM-dd"];
            NSString *period=[[TJYHelper sharedTJYHelper] getDietPeriodEnNameWithPeriod:dietTypeStr];
            
            NSString *body=nil;
            NSString *url=nil;
        
        
            if (tempArr.count>0) {
                
                if (self.foodRecordModel) {  //更新饮食记录
                    NSArray *dietRecordIDArray = _foodRecordModel.item;
                    NSString *diet_record_id = [dietRecordIDArray[0] objectForKey:@"diet_record_id"];
                    body=[NSString stringWithFormat:@"doSubmit=1&time_slot=%@&feeding_time=%ld&item=%@&diet_record_id=%@",period,(long)timeSp,jsonStr,diet_record_id];
                    url=kDietRecordUpdate;
                }else{  //添加饮食记录
                    body=[NSString stringWithFormat:@"doSubmit=1&time_slot=%@&feeding_time=%ld&item=%@",period,(long)timeSp,jsonStr];
                    url=kDietRecordAdd;
                }
                kSelfWeak;
                [[NetworkTool sharedNetworkTool] postMethodWithURL:url body:body success:^(id json) {
                    [TJYHelper sharedTJYHelper].isDietReload=YES;
                    [TJYHelper sharedTJYHelper].isRecordDietReload=YES;
                    if (self.foodRecordModel) {
                        [TJYHelper sharedTJYHelper].isHistoryDietReload=YES;
                    }
                    
                    [[FoodAddTool sharedFoodAddTool] removeAllFood];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
                
            } else {
                [self.view makeToast:@"请添加食物" duration:1.0 position:CSToastPositionCenter];
                
            }
}
#pragma mark -- Private Methods
#pragma mark 加载饮食记录
-(void)loadDietRecordData{
    if (self.foodRecordModel) {
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        NSArray *list=self.foodRecordModel.item;
            for (NSInteger i=0; i<list.count; i++) {
                NSDictionary *dict=list[i];
                if ([[dict objectForKey:@"type"] integerValue]==1) {
                    FoodAddModel *model=[[FoodAddModel alloc] init];
                    model.type = [dict[@"type"] integerValue];
                    model.id=[dict[@"item_id"] integerValue];
                    model.image_url=dict[@"image_url"];
                    model.name=dict[@"item_name"];
                    model.energykcal=[dict[@"item_calories"] integerValue];
                    model.calories_pre100 =[dict[@"item_calorie"] integerValue];
                    model.weight=[NSNumber numberWithInteger:[dict[@"item_weight"] integerValue]];
                    model.isSelected=[NSNumber numberWithBool:YES];
                    [tempArr addObject:model];

                } else {
                    FoodAddModel *model=[[FoodAddModel alloc] init];
                    model.type = [dict[@"type"] integerValue];
                    model.cook_id=[dict[@"item_id"] integerValue];
                    model.image_id_cover=dict[@"image_url"];
                    model.name=dict[@"item_name"];
                    model.energykcal=[dict[@"item_calorie"] integerValue];
                    model.calories_pre100=[dict[@"item_calories"] integerValue];
                    model.weight=[NSNumber numberWithInteger:[dict[@"item_weight"] integerValue]];
                    model.isSelected=[NSNumber numberWithBool:YES];
                    [tempArr addObject:model];
                }
            }
        [FoodAddTool sharedFoodAddTool].selectFoodArray=tempArr;
        foodListArray=tempArr;
    }
}
#pragma mark 返回按钮事件
-(void)leftButtonAction{
    if (isBoolBack == YES) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确认放弃此次记录编辑" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[FoodAddTool sharedFoodAddTool] removeAllFood];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        [[FoodAddTool sharedFoodAddTool] removeAllFood];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark 删除
-(void)rightButtonAction{
    if (self.foodRecordModel) {
#if !DEBUG
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-01-04"];
#endif
        
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"确认删除所有记录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}
-(void)addFoodReloadAction{
    NSMutableArray *foodArr=[FoodAddTool sharedFoodAddTool].selectFoodArray;
    
    NSMutableArray *foodIds=[[NSMutableArray alloc] init];
    
    for (FoodAddModel *model in foodListArray) {
        [foodIds addObject:[NSNumber numberWithInteger: model.id]];
    }
    for (FoodAddModel *model in foodListArray) {
        [foodIds addObject:[NSNumber numberWithInteger: model.cook_id]];
    }
    for (NSInteger i=0; i<foodArr.count; i++) {
        FoodAddModel *foodModel=foodArr[i];
        if (foodModel.type==1||foodModel.type==3) {
            if ([foodIds containsObject:[NSNumber numberWithInteger:foodModel.id]]) {
                [foodListArray replaceObjectAtIndex:i withObject:foodModel];
            }else{
                [foodListArray addObject:foodModel];
            }
        }else{
            if ([foodIds containsObject:[NSNumber numberWithInteger:foodModel.cook_id]]) {
                [foodListArray replaceObjectAtIndex:i withObject:foodModel];
            }else{
                [foodListArray addObject:foodModel];
            }

        }
    }
    isBoolBack = YES;
    [self.foodTableView reloadData];
    
    [self getDietRecordData];
    self.blankView.hidden=foodListArray.count>0;
    
}

#pragma mark 计算能量值
-(void)getDietRecordData{
    NSInteger totalColaries=0;
    if (foodListArray.count>0) {
        for (FoodAddModel *model in foodListArray) {
            if (model.type==YES) {
                if ([TJYHelper sharedTJYHelper].isHistoryDiet == YES) {
                    totalColaries+=model.energykcal;
                }else{
                    totalColaries+=model.energykcal*[model.weight doubleValue]/100;
                }
            } else {
                if ([TJYHelper sharedTJYHelper].isHistoryDiet == YES) {
                    totalColaries+=model.calories_pre100;
                }else{
                    totalColaries+=model.calories_pre100*[model.weight doubleValue]/100;
                }
            }
        }
    }
    
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld 千卡",(long)totalColaries]];
    [attributeStr addAttributes:@{NSForegroundColorAttributeName:kRGBColor(244, 182, 123),NSFontAttributeName:[UIFont systemFontOfSize:25]} range:NSMakeRange(0, attributeStr.length-2)];
    self.colaryLabel.attributedText=attributeStr;
}

#pragma mark -- Getters and Setters
#pragma mark 能量值
-(UILabel *)colaryLabel{
    if (_colaryLabel==nil) {
        _colaryLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 60)];
        _colaryLabel.backgroundColor=[UIColor whiteColor];
        _colaryLabel.textColor=[UIColor blackColor];
        _colaryLabel.font=[UIFont systemFontOfSize:13.0f];
        _colaryLabel.textAlignment=NSTextAlignmentCenter;
        _colaryLabel.text=self.foodRecordModel?[NSString stringWithFormat:@"%ld",(long)self.foodRecordModel.all_calories_record]:@"0";
    }
    return _colaryLabel;
}

#pragma mark  用餐日期
-(FoodDingButton *)diningTimeButton{
    if (_diningTimeButton==nil) {
        _diningTimeButton=[[FoodDingButton alloc] initWithFrame:CGRectMake(0, self.colaryLabel.bottom+10, kScreenWidth, 50) title:@"用餐日期"];
        [_diningTimeButton addTarget:self action:@selector(addDiningTimeAction:) forControlEvents:UIControlEventTouchUpInside];
        NSString *dietDate=[[TJYHelper sharedTJYHelper] getCurrentDate];
        if (self.foodRecordModel) {
            dietDateStr=[[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:self.foodRecordModel.feeding_time format:@"yyyy-MM-dd"];
        }
        dietDateStr=kIsEmptyString(dietDateStr)?dietDate:dietDateStr;
        _diningTimeButton.valueString=dietDateStr;
    }
    return _diningTimeButton;
}

#pragma mark 用餐类别
-(FoodDingButton *)diningTypeButton{
    if (_diningTypeButton==nil) {
        _diningTypeButton=[[FoodDingButton alloc] initWithFrame:CGRectMake(0, self.diningTimeButton.bottom, kScreenWidth, 50) title:@"用餐类别"];
        [_diningTypeButton addTarget:self action:@selector(addDiningTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *dietPeriod=[[TJYHelper sharedTJYHelper] getDietPeriodOfCurrentTime];
        if (self.foodRecordModel) {
            dietTypeStr=[[TJYHelper sharedTJYHelper] getDietPeriodChNameWithPeriod:self.foodRecordModel.time_slot];
        }
        dietTypeStr=kIsEmptyString(dietTypeStr)?dietPeriod:dietTypeStr;
        _diningTypeButton.valueString=dietTypeStr;
        
        UILabel *lineLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        lineLabel.backgroundColor=kLineColor;
        [_diningTypeButton addSubview:lineLabel];
    }
    return _diningTypeButton;
}

#pragma mark 添加食物
-(UIView *)foodHeadView{
    if (_foodHeadView==nil) {
        _foodHeadView=[[UIView alloc] initWithFrame:CGRectMake(0, self.diningTypeButton.bottom+10, kScreenWidth, 50)];
        _foodHeadView.backgroundColor=[UIColor whiteColor];
        
        UIButton *addBtn=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2, 5, 120, 40)];
        [addBtn setTitle:@"+添加食物" forState:UIControlStateNormal];
        [addBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addFoodAction:) forControlEvents:UIControlEventTouchUpInside];
        [_foodHeadView addSubview:addBtn];
    

        UILabel *lineLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 49, kScreenWidth, 1)];
        lineLabel.backgroundColor=kLineColor;
        [_foodHeadView addSubview:lineLabel];
    }
    return _foodHeadView;
}

#pragma mark 食物列表
-(UITableView *)foodTableView{
    if (_foodTableView==nil) {
        _foodTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, self.foodHeadView.bottom, kScreenWidth, kScreenHeight-self.foodHeadView.bottom-50) style:UITableViewStylePlain];
        _foodTableView.delegate=self;
        _foodTableView.dataSource=self;
        _foodTableView.showsVerticalScrollIndicator=NO;
        _foodTableView.backgroundColor=[UIColor whiteColor];
        _foodTableView.tableFooterView=[[UIView alloc] init];
    }
    return _foodTableView;
}

#pragma mark 尚未添加食物
-(UIView *)blankView{
    if (_blankView==nil) {
        _blankView=[[BlankView alloc] initWithFrame:CGRectMake(0, self.foodHeadView.bottom+10, kScreenWidth, 200) img:@"img_tips_no" text:@"尚未添加食物"];
    }
    return _blankView;
}

#pragma mark 保存
-(UIButton *)saveFoodButton{
    if (_saveFoodButton==nil) {
        _saveFoodButton=[[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        [_saveFoodButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveFoodButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveFoodButton.backgroundColor=kSystemColor;
        [_saveFoodButton addTarget:self action:@selector(saveDietDataAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveFoodButton;
}



@end
