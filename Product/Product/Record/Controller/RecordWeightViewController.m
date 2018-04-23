//
//  RecordWeightViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecordWeightViewController.h"
#import "ScaleView.h"
#import "WeightLineChartView.h"
#import "TJYUserInfoViewController.h"
#import "ScaleViewController.h"
#import "ScaleHelper.h"
#import "ScalePersonInfoViewController.h"
#import "SVProgressHUD.h"


@interface RecordWeightViewController ()<ScaleViewDelegate,WeightLineDelegate>{
    
    UIView *bgView;
    UIButton *bodyFateBtn;
    UIButton *bodyWaterBun;
    UIButton *bodyMassBtn;
    UIButton *muscleRateBtn;
    UIButton *fatLevelBtn;
    UIButton *PorteinBtn;
    UIButton *baselBtn;
    UIButton *subFatRateBtn;
    
    UILabel *textLabel;
    UIButton *button;
    UILabel *conpareLabel;
    
    NSMutableArray *indexArray;
}
@property(nonatomic ,strong)UIScrollView      *rootScrollView;
@property(nonatomic ,strong)WeightLineChartView *lineWeightCharts;
@property(nonatomic ,strong)WeightLineChartView *lineBMICharts;
@property(nonatomic ,strong)WeightLineChartView *lineBodyFatCharts;
@property(nonatomic ,strong)WeightLineChartView *lineBodyWaterCharts;
@property(nonatomic ,strong)WeightLineChartView *lineBodyMassCharts;
@property(nonatomic ,strong)WeightLineChartView *lineMuscleRateCharts;
@property(nonatomic ,strong)WeightLineChartView *lineFatLevelCharts;
@property(nonatomic ,strong)WeightLineChartView *linePorteinCharts;
@property(nonatomic ,strong)WeightLineChartView *lineBaselCharts;
@property(nonatomic ,strong)WeightLineChartView *lineSubFatRateCharts;

@end

@implementation RecordWeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"体指标";
    self.rightImageName = @"添加";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    indexArray = [[NSMutableArray alloc] init];
    for (int i=0; i<10; i++) {
        [indexArray addObject:@"1"];
    }
    [self initWeightView];
    [self requestWeightData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-05" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-05" type:2];
#endif
}

#pragma mark -- Custom Delegate
#pragma mark  ScaleViewDelegate
-(void)scaleView:(ScaleView *)scaleView weight:(NSString *)weight{
    TJYUserModel *userModel=[TonzeHelpTool sharedTonzeHelpTool].user;
    NSInteger age=[[TonzeHelpTool sharedTonzeHelpTool] getPersonAgeWithBirthdayString:userModel.birthday];
    
    if (userModel.sex<1||userModel.sex>2||[userModel.height integerValue]<50||age<10) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ScalePersonInfoViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
        
    }else{
        kSelfWeak;
        [[NetworkTool sharedNetworkTool] postMethodWithURL:kSetUserInfo body:@"doSubmit=0" success:^(id json) {
            NSDictionary *result = [json objectForKey:@"result"];
            if (kIsDictionary(result)) {
                NSString *height = [result objectForKey:@"height"];
                NSInteger sex = [[result objectForKey:@"sex"] integerValue];
                NSInteger birthday = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:[result objectForKey:@"birthday"] format:@"yyyy-MM-dd"];

                NSString *weightAll = [weight substringToIndex:weight.length-2];
                

                NSString *body = [NSString stringWithFormat:@"weight=%@&bmi=%.1f&height=%@&sex=%ld&birthday=%ld&doSubmit=1&way=1",weightAll,[weight floatValue]/([height floatValue]*[height floatValue])*10000,height,sex,birthday];
                [[NetworkTool sharedNetworkTool] postMethodWithURL:kWeightRecordAdd body:body success:^(id json) {
                    
                    [TJYHelper sharedTJYHelper].isReloadUserInfo=YES;
                    [TJYHelper sharedTJYHelper].isWeightReload=YES;
                    [weakSelf requestWeightData];
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
                
            }
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
#pragma mark  WeightLineChartView
- (void)weightLineChartView:(WeightLineChartView *)ChartView type:(NSInteger)type{
    
    NSInteger index = [indexArray[type-1] integerValue];
    index++;
    [indexArray replaceObjectAtIndex:type-1 withObject:[NSString stringWithFormat:@"%ld",index]];
        [ self requestWeightdata:type];
}
- (void)weightrightLineChartView:(WeightLineChartView *)ChartView type:(NSInteger)type{
    
    NSInteger index = [indexArray[type-1] integerValue];
    index--;
    [indexArray replaceObjectAtIndex:type-1 withObject:[NSString stringWithFormat:@"%ld",index]];
    [ self requestWeightdata:type];
}
#pragma mark -- 跳转体质健康分析仪
- (void)scaleView:(ScaleView *)scaleView{
    TJYUserModel *userModel=[TonzeHelpTool sharedTonzeHelpTool].user;
    NSInteger age=[[TonzeHelpTool sharedTonzeHelpTool] getPersonAgeWithBirthdayString:userModel.birthday];
    
    if (userModel.sex<1||userModel.sex>2||[userModel.height integerValue]<50||age<10) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ScalePersonInfoViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
        
    }else{
        ScaleViewController *scaleVC=[[ScaleViewController alloc] init];
        [self.navigationController pushViewController:scaleVC animated:YES];
    }
}
#pragma mark -- Event response
#pragma mark -- 添加体重
- (void)rightButtonAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-05-01"];
#endif
    ScaleView *scaleView=[[ScaleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300)];
    scaleView.scaleDelegate=self;
    [scaleView scaleViewShowInView:self.view];
    
}
#pragma mark -- 获取数据
- (void)requestWeightData{
    NSMutableArray *pageArray = [[NSMutableArray alloc] init];
    for (int i=0; i<20; i++) {
        [pageArray addObject:@"0"];
    }
    NSArray *array =pageArray;
    NSMutableArray *weightArray = [NSMutableArray arrayWithArray:array];
    NSMutableArray *BMIArray =  [NSMutableArray arrayWithArray:array];
    NSMutableArray *fatArray =   [NSMutableArray arrayWithArray:array];
    NSMutableArray *waterArray =   [NSMutableArray arrayWithArray:array];
    NSMutableArray *massArray =   [NSMutableArray arrayWithArray:array];
    NSMutableArray *muscleRateArray =   [NSMutableArray arrayWithArray:array];
    NSMutableArray *fatLeavlArraay =   [NSMutableArray arrayWithArray:array];
    NSMutableArray *porteinArray =   [NSMutableArray arrayWithArray:array];
    NSMutableArray *baselArray =   [NSMutableArray arrayWithArray:array];
    NSMutableArray *subFatRateArray =   [NSMutableArray arrayWithArray:array];
    
    NSString *nowData = [[TJYHelper sharedTJYHelper] getLastWeekDateWithDays:-1];
    NSString *sexData = [[TJYHelper sharedTJYHelper] getLastWeekDateWithDays:-20+1];
    NSInteger nowdata = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:nowData format:@"yyyy-MM-dd"];
    NSInteger sexdata = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:sexData format:@"yyyy-MM-dd"];
    
    NSString *body = [NSString stringWithFormat:@"page_num=0&page_size=0&start_time=%ld&end_time=%ld&type=1",sexdata,nowdata];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kWeightRecordList body:body success:^(id json) {
        NSDictionary *weightDict= [json objectForKey:@"result"];
        NSMutableArray *timedataArray = [[NSMutableArray alloc] init];
        if (kIsDictionary(weightDict)) {
            NSArray *timeArray = [weightDict allKeys];
            if (timeArray.count>0) {
                timedataArray =[[TJYHelper sharedTJYHelper] loadMaxTime:timeArray];
                NSArray *dataArray = [[TJYHelper sharedTJYHelper] getStringDateFromTodayWithDays:20];
                
                
                for (int i=0; i<timeArray.count; i++) {
                    for (int j=0; j<dataArray.count; j++) {
                        NSString *timeString = [timeArray[i] substringFromIndex:5];
                        if ([timeString isEqualToString:dataArray[j]]) {
                            NSDictionary *dict = [weightDict objectForKey:timeArray[i]][0];
                            NSLog(@"--------%ld",weightArray.count);
                            [weightArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"weight"]];
                            [BMIArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"bmi"]];
                            [fatArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"body_fat_percentage"]];
                            [waterArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"body_water_rate"]];
                            [massArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"bone_mass"]];
                            [muscleRateArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"skeletal_muscle_rate"]];
                            [fatLeavlArraay replaceObjectAtIndex:j withObject:[dict objectForKey:@"visceral_fat_level"]];
                            [porteinArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"protein"]];
                            [baselArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"basal_metabolic_rate"]];
                            [subFatRateArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"subcutaneous_fat_rate"]];
                        }
                    }
                }
            }
        }
        TJYUserModel *userModel=[TonzeHelpTool sharedTonzeHelpTool].user;
        NSInteger age=[[TJYHelper sharedTJYHelper] getCurrentAgeWithBornDate:userModel.birthday];

        if (!(userModel.sex<1||userModel.sex>2||[userModel.height integerValue]<50||age<10)) {
            textLabel.hidden = YES;
            button.hidden = YES;
            if (timedataArray.count>0) {
                conpareLabel.hidden = NO;
                NSArray *dataArray = [weightDict objectForKey:timedataArray[0]];
                NSDictionary *dataDic = dataArray[0];
                double weight=[[dataDic objectForKey:@"weight"] doubleValue];
                
                NSString *weightStr = [[ScaleHelper sharedScaleHelper] getWeightStandardWithWeight:weight];
                NSString *idealWeight = [[ScaleHelper sharedScaleHelper] getStandardContentWithResult:weightStr key:@"weight"];
                
                NSMutableParagraphStyle *paraStyle=[[NSMutableParagraphStyle alloc] init];
                paraStyle.alignment=NSTextAlignmentLeft;
                paraStyle.headIndent=0.0f;
                paraStyle.lineSpacing=2.0f;//行间距
                conpareLabel.text = idealWeight;
                NSAttributedString *attrText=[[NSAttributedString alloc] initWithString:conpareLabel.text attributes:@{NSParagraphStyleAttributeName:paraStyle}];
                conpareLabel.attributedText=attrText;
                
                CGFloat contentHeight=[conpareLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:conpareLabel.font,NSFontAttributeName,nil] context:nil].size.height;
                bgView.frame = CGRectMake(0, 0, kScreenWidth, contentHeight+30);
                conpareLabel.frame = CGRectMake(10, 10, kScreenWidth-20, contentHeight+10);
                weakSelf.lineWeightCharts.frame = CGRectMake(0, bgView.bottom+10, kScreenWidth, 220);
                weakSelf.lineBMICharts.frame = CGRectMake(0,  weakSelf.lineWeightCharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineBodyFatCharts.frame = CGRectMake(0,  weakSelf.lineBMICharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineBodyWaterCharts.frame = CGRectMake(0, weakSelf.lineBodyFatCharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineBodyMassCharts.frame = CGRectMake(0, weakSelf.lineBodyWaterCharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineMuscleRateCharts.frame = CGRectMake(0,  weakSelf.lineBodyMassCharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineFatLevelCharts.frame = CGRectMake(0, weakSelf.lineMuscleRateCharts.bottom+10, kScreenWidth, 220);
                weakSelf.linePorteinCharts.frame = CGRectMake(0, weakSelf.lineFatLevelCharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineBaselCharts.frame = CGRectMake(0, weakSelf.linePorteinCharts.bottom+10, kScreenWidth, 220); 
                weakSelf.lineSubFatRateCharts.frame = CGRectMake(0,  weakSelf.lineBaselCharts.bottom+10, kScreenWidth, 220);
            } else {
                conpareLabel.hidden =YES;
                textLabel.hidden = NO;
                button.hidden = NO;
                weakSelf.lineWeightCharts.frame = CGRectMake(0, 0, kScreenWidth, 220);
                weakSelf.lineBMICharts.frame = CGRectMake(0,  weakSelf.lineWeightCharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineBodyFatCharts.frame = CGRectMake(0,  weakSelf.lineBMICharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineBodyWaterCharts.frame = CGRectMake(0, weakSelf.lineBodyFatCharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineBodyMassCharts.frame = CGRectMake(0, weakSelf.lineBodyWaterCharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineMuscleRateCharts.frame = CGRectMake(0,  weakSelf.lineBodyMassCharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineFatLevelCharts.frame = CGRectMake(0, weakSelf.lineMuscleRateCharts.bottom+10, kScreenWidth, 220);
                weakSelf.linePorteinCharts.frame = CGRectMake(0, weakSelf.lineFatLevelCharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineBaselCharts.frame = CGRectMake(0, weakSelf.linePorteinCharts.bottom+10, kScreenWidth, 220);
                weakSelf.lineSubFatRateCharts.frame = CGRectMake(0,  weakSelf.lineBaselCharts.bottom+10, kScreenWidth, 220);
            }
        }
        weakSelf.lineWeightCharts.page = 1;
        weakSelf.lineBMICharts.page = 1;
        weakSelf.lineBodyFatCharts.page = 1;
        weakSelf.lineBodyWaterCharts.page = 1;
        weakSelf.lineBodyMassCharts.page = 1;
        weakSelf.lineMuscleRateCharts.page = 1;
        weakSelf.lineFatLevelCharts.page = 1;
        weakSelf.linePorteinCharts.page = 1;
        weakSelf.lineBaselCharts.page = 1;
        weakSelf.lineSubFatRateCharts.page = 1;
        
        weakSelf.lineWeightCharts.dataArray = weightArray;
        weakSelf.lineBMICharts.dataArray = BMIArray;
        weakSelf.lineBodyFatCharts.dataArray = fatArray;
        weakSelf.lineBodyWaterCharts.dataArray = waterArray;
        weakSelf.lineBodyMassCharts.dataArray = massArray;
        weakSelf.lineMuscleRateCharts.dataArray = muscleRateArray;
        weakSelf.lineFatLevelCharts.dataArray = fatLeavlArraay;
        weakSelf.linePorteinCharts.dataArray = porteinArray;
        weakSelf.lineBaselCharts.dataArray = baselArray;
        weakSelf.lineSubFatRateCharts.dataArray = subFatRateArray;
        
        for (int i=0; i<subFatRateArray.count; i++) {
            if ([subFatRateArray[i] integerValue]!=0) {
                bodyFateBtn.hidden=YES;
                bodyMassBtn.hidden=YES;
                bodyWaterBun.hidden=YES;
                baselBtn.hidden=YES;
                fatLevelBtn.hidden=YES;
                subFatRateBtn.hidden=YES;
                muscleRateBtn.hidden=YES;
                PorteinBtn.hidden=YES;
            }
        }
        
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
    
}
- (void)requestWeightdata:(NSInteger)type{
    
    NSString *nowData = [[TJYHelper sharedTJYHelper] getLastWeekDateWithDays:([indexArray[type-1] integerValue]-1)*20-1];
    NSString *sexData = [[TJYHelper sharedTJYHelper] getLastWeekDateWithDays:[indexArray[type-1] integerValue]*20-1];
    NSInteger nowdata = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:nowData format:@"yyyy-MM-dd"];
    NSInteger sexdata = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:sexData format:@"yyyy-MM-dd"];
    
    NSString *body = [NSString stringWithFormat:@"page_num=0&page_size=0&start_time=%ld&end_time=%ld&type=1",sexdata,nowdata];
    kSelfWeak;
    [SVProgressHUD show];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kWeightRecordList body:body success:^(id json) {
        NSDictionary *weightDict= [json objectForKey:@"result"];
        if (kIsDictionary(weightDict)) {
            NSArray *timeArray = [weightDict allKeys];
            if (timeArray.count>0) {
                NSArray *dataArray = [[TJYHelper sharedTJYHelper] getStringDateFromTodayWithDays:20*[indexArray[type-1] integerValue]];
                
                NSMutableArray *pageArray = [[NSMutableArray alloc] init];
                for (int i=0; i<20; i++) {
                    [pageArray addObject:@"0"];
                }
                NSArray *array =pageArray;
                NSMutableArray *weightArray = [NSMutableArray arrayWithArray:array];
                NSMutableArray *BMIArray =  [NSMutableArray arrayWithArray:array];
                NSMutableArray *fatArray =   [NSMutableArray arrayWithArray:array];
                NSMutableArray *waterArray =   [NSMutableArray arrayWithArray:array];
                NSMutableArray *massArray =   [NSMutableArray arrayWithArray:array];
                NSMutableArray *muscleRateArray =   [NSMutableArray arrayWithArray:array];
                NSMutableArray *fatLeavlArraay =   [NSMutableArray arrayWithArray:array];
                NSMutableArray *porteinArray =   [NSMutableArray arrayWithArray:array];
                NSMutableArray *baselArray =   [NSMutableArray arrayWithArray:array];
                NSMutableArray *subFatRateArray =   [NSMutableArray arrayWithArray:array];
                
                for (int i=0; i<timeArray.count; i++) {
                    for (int j=0; j<20; j++) {
                        NSString *timeString = [timeArray[i] substringFromIndex:5];
                        if ([timeString isEqualToString:dataArray[j]]) {
                            NSDictionary *dict = [weightDict objectForKey:timeArray[i]][0];
                            NSLog(@"--------%ld",weightArray.count);
                            
                            [weightArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"weight"]];
                            [BMIArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"bmi"]];
                            [fatArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"body_fat_percentage"]];
                            [waterArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"body_water_rate"]];
                            [massArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"bone_mass"]];
                            [muscleRateArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"skeletal_muscle_rate"]];
                            [fatLeavlArraay replaceObjectAtIndex:j withObject:[dict objectForKey:@"visceral_fat_level"]];
                            [porteinArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"protein"]];
                            [baselArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"basal_metabolic_rate"]];
                            [subFatRateArray replaceObjectAtIndex:j withObject:[dict objectForKey:@"subcutaneous_fat_rate"]];
                        }
                    }
                }
                if (type==1) {
                    weakSelf.lineWeightCharts.page = [indexArray[type-1] integerValue];
                    weakSelf.lineWeightCharts.dataArray = weightArray;
                    
                }else if (type==2){
                    weakSelf.lineBMICharts.page = [indexArray[type-1] integerValue];
                    weakSelf.lineBMICharts.dataArray = BMIArray;
                    
                }else if (type==3){
                    weakSelf.lineBodyFatCharts.page = [indexArray[type-1] integerValue];
                    weakSelf.lineBodyFatCharts.dataArray = fatArray;
                    
                }else if (type==4){
                    weakSelf.lineBodyWaterCharts.page = [indexArray[type-1] integerValue];
                    weakSelf.lineBodyWaterCharts.dataArray = waterArray;
                    
                }else if (type==5){
                    weakSelf.lineBodyMassCharts.page = [indexArray[type-1] integerValue];
                    weakSelf.lineBodyMassCharts.dataArray = massArray;
                    
                }else if (type==6){
                    weakSelf.lineMuscleRateCharts.page = [indexArray[type-1] integerValue];
                    weakSelf.lineMuscleRateCharts.dataArray = muscleRateArray;
                    
                }else if (type==7){
                    weakSelf.lineFatLevelCharts.page = [indexArray[type-1] integerValue];
                    weakSelf.lineFatLevelCharts.dataArray = fatLeavlArraay;
                    
                }else if (type==8){
                    weakSelf.linePorteinCharts.page = [indexArray[type-1] integerValue];
                    weakSelf.linePorteinCharts.dataArray = porteinArray;
                    
                }else if (type==9){
                    weakSelf.lineBaselCharts.page = [indexArray[type-1] integerValue];
                    weakSelf.lineBaselCharts.dataArray = subFatRateArray;
                    
                } else {
                    weakSelf.lineSubFatRateCharts.page = [indexArray[type-1] integerValue];
                    weakSelf.lineSubFatRateCharts.dataArray = weightArray;
                    
                }

            }   
        }
        [SVProgressHUD dismiss];

    } failure:^(NSString *errorStr) {
        [SVProgressHUD dismiss];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
    
}

#pragma mark -- 完善个人资料
- (void)usetButton{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ScalePersonInfoViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}
#pragma mark -- 跳转体质健康分析仪
- (void)nextAddDevice:(UIButton *)sender{
#if !DEBUG
    NSArray *arr=@[@"体脂肪率",@"体水分率",@"骨量",@"骨骼肌率",@"内脏脂肪等级",@"蛋白质",@"基础代谢率",@"皮下脂肪率"];
    NSString *targetId=[NSString stringWithFormat:@"005-05-04-%@",arr[sender.tag]];
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"005-05-04"];
#endif
    TJYUserModel *userModel=[TonzeHelpTool sharedTonzeHelpTool].user;
    NSInteger age=[[TonzeHelpTool sharedTonzeHelpTool] getPersonAgeWithBirthdayString:userModel.birthday];
    
    if (userModel.sex<1||userModel.sex>2||[userModel.height integerValue]<50||age<10) {

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ScalePersonInfoViewController"];
        [self.navigationController pushViewController:viewController animated:YES];

    }else{
        ScaleViewController *scaleVC=[[ScaleViewController alloc] init];
        [self.navigationController pushViewController:scaleVC animated:YES];
    }
}
#pragma mark -- 初始化界面
- (void)initWeightView{
    
    self.rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0,64, kScreenWidth, kAllHeight-64)];
    self.rootScrollView.showsVerticalScrollIndicator=NO;
    self.rootScrollView.backgroundColor=[UIColor bgColor_Gray];
    [self.view addSubview:self.rootScrollView];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 58)];
    bgView.backgroundColor = [UIColor colorWithHexString:@"0xfefcec"];
    [self.rootScrollView addSubview:bgView];
    
    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 125, 20)];
    textLabel.text = @"获取参考标准需先";
    textLabel.font = [UIFont systemFontOfSize:15];
    [bgView addSubview:textLabel];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(textLabel.right, 20, 70, 20)];
    [button setTitle:@"完善资料" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor colorWithHexString:@"0xfd832b"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(usetButton) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:button];
    
    conpareLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, kScreenWidth-30, 40)];
    conpareLabel.numberOfLines = 0;
    conpareLabel.hidden = YES;
    conpareLabel.font = [UIFont systemFontOfSize:13];
    [bgView addSubview:conpareLabel];
    
    [self.rootScrollView addSubview:self.lineWeightCharts];
    [self.rootScrollView addSubview:self.lineBMICharts];
    [self.rootScrollView addSubview:self.lineBodyFatCharts];
    [self.rootScrollView addSubview:self.lineBodyWaterCharts];
    [self.rootScrollView addSubview:self.lineBodyMassCharts];
    [self.rootScrollView addSubview:self.lineMuscleRateCharts];
    [self.rootScrollView addSubview:self.lineFatLevelCharts];
    [self.rootScrollView addSubview:self.linePorteinCharts];
    [self.rootScrollView addSubview:self.lineBaselCharts];
    [self.rootScrollView addSubview:self.lineSubFatRateCharts];
    
    self.rootScrollView.contentSize = CGSizeMake(0, self.lineSubFatRateCharts.bottom);
}
#pragma mark -- setters
#pragma mark -- 体重
- (WeightLineChartView *)lineWeightCharts{
    if (_lineWeightCharts == nil) {
        _lineWeightCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, bgView.bottom+10, kScreenWidth, 220) maxY:200 title:@"体重(kg)"];
        _lineWeightCharts.type = 1;
        _lineWeightCharts.weightLineDelegate = self;
    }
    return _lineWeightCharts;
}
#pragma mark -- BMI
- (WeightLineChartView *)lineBMICharts{
    if (_lineBMICharts == nil) {
        _lineBMICharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, _lineWeightCharts.bottom+10, kScreenWidth, 220) maxY:60 title:@"BMI"];
        _lineBMICharts.type = 2;
        _lineBMICharts.weightLineDelegate = self;

    }
    return _lineBMICharts;
}
#pragma mark -- 体脂肪率
- (WeightLineChartView *)lineBodyFatCharts{
    if (_lineBodyFatCharts == nil) {
        _lineBodyFatCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, _lineBMICharts.bottom+10, kScreenWidth, 220) maxY:50 title:@"体脂肪率"]
        ;
        _lineBodyFatCharts.type = 3;
        _lineBodyFatCharts.weightLineDelegate = self;
        bodyFateBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _lineBodyFatCharts.width, _lineBodyFatCharts.height)];
        [bodyFateBtn addTarget:self action:@selector(nextAddDevice:) forControlEvents:UIControlEventTouchUpInside];
        bodyFateBtn.backgroundColor = [UIColor grayColor];
        [bodyFateBtn setImage:[UIImage imageNamed:@"pub_ic_lock"] forState:UIControlStateNormal];
        bodyFateBtn.alpha = 0.5;
        bodyFateBtn.tag=0;
        [_lineBodyFatCharts addSubview:bodyFateBtn];
    }
    return _lineBodyFatCharts;
}
#pragma mark -- 体水分率
- (WeightLineChartView *)lineBodyWaterCharts{
    if (_lineBodyWaterCharts == nil) {
        _lineBodyWaterCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, _lineBodyFatCharts.bottom+10, kScreenWidth, 220) maxY:100 title:@"体水分率"];
        _lineBodyWaterCharts.weightLineDelegate = self;
        _lineBodyWaterCharts.type = 4;
        bodyWaterBun = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _lineBodyFatCharts.width, _lineBodyFatCharts.height)];
        [bodyWaterBun addTarget:self action:@selector(nextAddDevice:) forControlEvents:UIControlEventTouchUpInside];
        bodyWaterBun.backgroundColor = [UIColor grayColor];
        [bodyWaterBun setImage:[UIImage imageNamed:@"pub_ic_lock"] forState:UIControlStateNormal];
        bodyWaterBun.alpha = 0.5;
        bodyFateBtn.tag=1;
        [_lineBodyWaterCharts addSubview:bodyWaterBun];
    }
    return _lineBodyWaterCharts;
}
#pragma mark -- 骨量
- (WeightLineChartView *)lineBodyMassCharts{
    if (_lineBodyMassCharts == nil) {
        _lineBodyMassCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, _lineBodyWaterCharts.bottom+10, kScreenWidth, 220) maxY:10 title:@"骨量"];
        _lineBodyMassCharts.weightLineDelegate = self;
        _lineBodyMassCharts.type = 5;
        bodyMassBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _lineBodyFatCharts.width, _lineBodyFatCharts.height)];
        [bodyMassBtn addTarget:self action:@selector(nextAddDevice:) forControlEvents:UIControlEventTouchUpInside];
        bodyMassBtn.backgroundColor = [UIColor grayColor];
        [bodyMassBtn setImage:[UIImage imageNamed:@"pub_ic_lock"] forState:UIControlStateNormal];
        bodyMassBtn.alpha = 0.5;
        bodyFateBtn.tag=2;
        [_lineBodyMassCharts addSubview:bodyMassBtn];
    }
    return _lineBodyMassCharts;
}
#pragma mark -- 骨骼肌率
- (WeightLineChartView *)lineMuscleRateCharts{
    if (_lineMuscleRateCharts == nil) {
        _lineMuscleRateCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, _lineBodyMassCharts.bottom+10, kScreenWidth, 220) maxY:100 title:@"骨骼肌率"];
        _lineMuscleRateCharts.weightLineDelegate = self;
        _lineMuscleRateCharts.type = 6;
        muscleRateBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _lineBodyFatCharts.width, _lineBodyFatCharts.height)];
        [muscleRateBtn addTarget:self action:@selector(nextAddDevice:) forControlEvents:UIControlEventTouchUpInside];
        muscleRateBtn.backgroundColor = [UIColor grayColor];
        [muscleRateBtn setImage:[UIImage imageNamed:@"pub_ic_lock"] forState:UIControlStateNormal];
        muscleRateBtn.alpha = 0.5;
        bodyFateBtn.tag=3;
        [_lineMuscleRateCharts addSubview:muscleRateBtn];
    }
    return _lineMuscleRateCharts;
}
#pragma mark -- 内脏脂肪等级
- (WeightLineChartView *)lineFatLevelCharts{
    if (_lineFatLevelCharts == nil) {
        _lineFatLevelCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, _lineMuscleRateCharts.bottom+10, kScreenWidth, 220) maxY:50 title:@"内脏脂肪等级"];
        _lineFatLevelCharts.weightLineDelegate = self;
        _lineFatLevelCharts.type = 7;
        fatLevelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _lineBodyFatCharts.width, _lineBodyFatCharts.height)];
        [fatLevelBtn addTarget:self action:@selector(nextAddDevice:) forControlEvents:UIControlEventTouchUpInside];
        fatLevelBtn.backgroundColor = [UIColor grayColor];
        [fatLevelBtn setImage:[UIImage imageNamed:@"pub_ic_lock"] forState:UIControlStateNormal];
        fatLevelBtn.alpha = 0.5;
        bodyFateBtn.tag=4;
        [_lineFatLevelCharts addSubview:fatLevelBtn];
    }
    return _lineFatLevelCharts;
}
#pragma mark -- 蛋白质
- (WeightLineChartView *)linePorteinCharts{
    if (_linePorteinCharts == nil) {
        _linePorteinCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, _lineFatLevelCharts.bottom+10, kScreenWidth, 220) maxY:50 title:@"蛋白质"];
        _linePorteinCharts.weightLineDelegate = self;
        _linePorteinCharts.type = 8;
        PorteinBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _lineBodyFatCharts.width, _lineBodyFatCharts.height)];
        [PorteinBtn addTarget:self action:@selector(nextAddDevice:) forControlEvents:UIControlEventTouchUpInside];
        PorteinBtn.backgroundColor = [UIColor grayColor];
        [PorteinBtn setImage:[UIImage imageNamed:@"pub_ic_lock"] forState:UIControlStateNormal];
        PorteinBtn.alpha = 0.5;
        bodyFateBtn.tag=5;
        [_linePorteinCharts addSubview:PorteinBtn];
    }
    return _linePorteinCharts;
}
#pragma mark -- 基础代谢率
- (WeightLineChartView *)lineBaselCharts{
    if (_lineBaselCharts == nil) {
        _lineBaselCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, _linePorteinCharts.bottom+10, kScreenWidth, 220) maxY:3000 title:@"基础代谢率"];
        _lineBaselCharts.weightLineDelegate = self;
        _lineBaselCharts.type = 9;
        baselBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _lineBodyFatCharts.width, _lineBodyFatCharts.height)];
        [baselBtn addTarget:self action:@selector(nextAddDevice:) forControlEvents:UIControlEventTouchUpInside];
        baselBtn.backgroundColor = [UIColor grayColor];
        [baselBtn setImage:[UIImage imageNamed:@"pub_ic_lock"] forState:UIControlStateNormal];
        baselBtn.alpha = 0.5;
        bodyFateBtn.tag=6;
        [_lineBaselCharts addSubview:baselBtn];
    }
    return _lineBaselCharts;
}
#pragma mark -- 皮下脂肪率
- (WeightLineChartView *)lineSubFatRateCharts{
    if (_lineSubFatRateCharts == nil) {
        _lineSubFatRateCharts = [[WeightLineChartView alloc] initWithFrame:CGRectMake(0, _lineBaselCharts.bottom+10, kScreenWidth, 220) maxY:50 title:@"皮下脂肪率"];
        _lineSubFatRateCharts.weightLineDelegate = self;
        _lineSubFatRateCharts.type = 10;
        subFatRateBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _lineBodyFatCharts.width, _lineBodyFatCharts.height)];
        [subFatRateBtn addTarget:self action:@selector(nextAddDevice:) forControlEvents:UIControlEventTouchUpInside];
        subFatRateBtn.backgroundColor = [UIColor grayColor];
        [subFatRateBtn setImage:[UIImage imageNamed:@"pub_ic_lock"] forState:UIControlStateNormal];
        subFatRateBtn.alpha = 0.5;
        bodyFateBtn.tag=7;
        [_lineSubFatRateCharts addSubview:subFatRateBtn];
    }
    return _lineSubFatRateCharts;
}
@end
