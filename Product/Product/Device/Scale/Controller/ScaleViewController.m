//
//  ScaleViewController.m
//  Product
//
//  Created by Feng on 16/2/27.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "ScaleViewController.h"
#import "QingNiuDevice.h"
#import "QingNiuSDK.h"
#import "QingNiuUser.h"
#import "ScalePersonInfoViewController.h"
#import "ScaleScoreView.h"
#import "ScaleCustomBtn.h"
#import "ScaleHelper.h"
#import "BodyTableViewCell.h"
#import "BodyHeaderView.h"
#import "BodySectionModel.h"
#import "ScaleHistoryViewController.h"
#import "OnlineServiceViewController.h"
#import "TJYFoodLibraryVC.h"
#import "ScaleBMIViewController.h"
#import "ScaleWeightViewController.h"
#import "HWPopTool.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>
#import "BLEDevice_DBController.h"

static NSString *kCellIdentfier = @"UITableViewCell";
static NSString *kHeaderIdentifier = @"HeaderView";

@interface ScaleViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,ScaleScoreDelegate>{
    UIImageView         *trendImageView;
    UILabel             *contentLabel;
    UIButton            *tipsBtn;
    
    ScaleCustomBtn      *bmiBtn;      //BMI
    ScaleCustomBtn      *weightBtn;   //体重
    
    NSArray             *images;
    NSArray             *titles;
    
    TJYUserModel        *userModel;
    QingNiuDevice       *connectedDevice;
    NSMutableArray      *bodyIndexArray;
    
    ScaleModel          *scale;
    UIImageView         *imgFoot;
    UIImageView         *subscribeAnimation;
    
    BOOL                isHasSaved;   //是否保存过数据

}

@property (nonatomic,strong)UIView          *topRemindView;
@property (nonatomic,strong)ScaleScoreView  *topScoreView;
@property (nonatomic,strong)UIView          *scaleWeightView;       //体重，BMI
@property (nonatomic,strong)UITableView     *bodyIndexTableView;    //其他体指标
@property (nonatomic,strong)UIView          *dietRemindView;        //营养改善建议

@end

@implementation ScaleViewController

#define Scale_NAME_PREFIX     @"智能健康体脂分析仪"

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"智能健康体脂分析仪";
    self.rightImageName=@"更多";
    
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    scale=[[ScaleModel alloc] init];
    bodyIndexArray=[[NSMutableArray alloc] init];
    
    
    images=@[@"ic_bodyfat",@"ic_water",@"ic_bone",@"ic_muscle",@"ic_visfat",@"ic_protein",@"ic_bmr",@"ic_subfat"];
    titles=@[@"体脂肪率",@"体水分率",@"骨量",@"骨骼肌率",@"内脏脂肪等级",@"蛋白质",@"基础代谢率",@"皮下脂肪率"];
    
    userModel=[TonzeHelpTool sharedTonzeHelpTool].user;
    
    [self initScaleView];
    [self initBodyIndexData];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.scaleModel) {
        TJYUserModel *user=[[TJYUserModel alloc] init];
        user.age=self.scaleModel.age;
        user.height=self.scaleModel.height;
        user.sex=self.scaleModel.sex;
        user.birthday = [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:self.scaleModel.birthday format:@"YYYY-MM-dd"];
        user.weight =[NSString stringWithFormat:@"%f",self.scaleModel.weight];
        [ScaleHelper sharedScaleHelper].scaleUser=user;
        
        double height=(double)[userModel.height integerValue]/100;   //身高
        double bmi=self.scaleModel.weight/(height*height);
        bmiBtn.valueDict=@{@"type":[NSNumber numberWithInteger:1],@"value":[NSString stringWithFormat:@"%.1f",bmi]};
        weightBtn.valueDict=@{@"type":[NSNumber numberWithInteger:2],@"value":[NSString stringWithFormat:@"%.2f",self.scaleModel.weight]};
        
        [self reloadViewWithScaleModel:self.scaleModel];
    }else{
        [ScaleHelper sharedScaleHelper].scaleUser=[TonzeHelpTool sharedTonzeHelpTool].user;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scanScaleDevice];
        });
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [QingNiuSDK stopBleScan];
    [QingNiuSDK cancelConnect:connectedDevice disconnectFailBlock:^(QingNiuDeviceDisconnectState qingNiuDeviceDisconnectState) {
        MyLog(@"断开连接失败 state:%ld",qingNiuDeviceDisconnectState);
    } disconnectSuccessBlock:^(QingNiuDeviceDisconnectState qingNiuDeviceDisconnectState) {
        MyLog(@"断开连接成功 state:%ld",qingNiuDeviceDisconnectState);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return bodyIndexArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BodySectionModel *sectionModel = bodyIndexArray[section];
    return sectionModel.isExpanded ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BodyTableViewCell *cell = [[BodyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentfier];
    
    BodySectionModel *sectionModel = bodyIndexArray[indexPath.section];
    ResultModel *model = sectionModel.resultModel;
    [cell bodyCellDisplayWithModel:model key:sectionModel.keyStr];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BodyHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderIdentifier];
    
    BodySectionModel *sectionModel = bodyIndexArray[section];
    view.sectionModel = sectionModel;
    if (![sectionModel.value isEqualToString:@"--"]) {
        view.expandCallback = ^(BOOL isExpanded) {
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                     withRowAnimation:UITableViewRowAnimationFade];
        };
    }
    return view;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BodySectionModel *sectionModel = bodyIndexArray[indexPath.section];
    ResultModel *model = sectionModel.resultModel;
    return [BodyTableViewCell bodyTableViewCellGetCellHeightWithModel:model];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

#pragma mark -- ScaleScoreDelegate
- (void)ScaleScoreView:(ScaleScoreView *)scaleScoreView{

    NSString *shareUrl=[NSString stringWithFormat:@"http://api-h.360tj.com/shared/fatWeigh/index.html?id=%ld&pid=%ld",(long)self.user_id,(long)self.record_id];
    NSArray* imageArray = @[[UIImage imageNamed:@"体脂称"]];
    if (imageArray) {
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"天际云体质健康分析仪，您的健康数据分析管理专家"
                                         images:imageArray
                                            url:[NSURL URLWithString:shareUrl]
                                          title:[NSString stringWithFormat:@"我的健康指数为:%ld",(long)self.shareScore]
                                           type:SSDKContentTypeAuto];
        [SSUIShareActionSheetStyle setActionSheetColor:kRGBColor(239, 239, 239)];
        [SSUIShareActionSheetStyle  setStatusBarStyle:UIStatusBarStyleLightContent];
        SSUIShareActionSheetController *sheet=[ShareSDK showShareActionSheet:self.view items:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
            switch (state) {
                case SSDKResponseStateSuccess:
                {
                    [self showAlertWithTitle:@"分享成功" Message:nil];
                    break;
                }
                case SSDKResponseStateFail:
                {
                    [self showAlertWithTitle:@"分享失败" Message:[NSString stringWithFormat:@"%@",error]];
                    break;
                }
                default:
                    break;
            }
        }
         ];
        [sheet.directSharePlatforms addObject:@(SSDKPlatformTypeSinaWeibo)];
    }
}

#pragma mark -- Event response
#pragma mark 更多事件
-(void)rightButtonAction{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *recordButtonTitle = NSLocalizedString(@"历史记录", nil);
    NSString *userinfoButtonTitle = NSLocalizedString(@"个人资料", nil);
    NSString *serviceButtonTitle = NSLocalizedString(@"营养咨询", nil);
    NSString *deleteButtonTitle = NSLocalizedString(@"删除", nil);

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *recordAction = [UIAlertAction actionWithTitle:recordButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ScaleHistoryViewController *historyVC=[[ScaleHistoryViewController alloc] init];
        [weakSelf.navigationController pushViewController:historyVC animated:YES];
    }];

    UIAlertAction *userinfoAction = [UIAlertAction actionWithTitle:userinfoButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ScalePersonInfoViewController"];
        viewController.hidesBottomBarWhenPushed=YES;
        [weakSelf.navigationController pushViewController:viewController animated:YES];
    }];
    
    UIAlertAction *serviceAction= [UIAlertAction actionWithTitle:serviceButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        OnlineServiceViewController *onlineServiceVC=[[OnlineServiceViewController alloc] init];
        onlineServiceVC.isDietService=YES;
        [weakSelf.navigationController pushViewController:onlineServiceVC animated:YES];
    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [weakSelf showDeleteAlertController];
    }];
 
    
    //管理员才能显示
    [alertController addAction:recordAction];
    [alertController addAction:userinfoAction];
    [alertController addAction:serviceAction];
    BLEDeviceModel * tempModel = [[BLEDevice_DBController dbController] getBLEDevice:Scale_NAME_PREFIX];
    if (tempModel)
    {
        // 已经添加过设备，可删除
        [alertController addAction:deleteAction];
    }
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 弹出提示
-(void)popupTipsAction{
    [self popViewShow];
}

#pragma mark 关闭提示框
-(void)closeTipsViewAction{

    [[HWPopTool sharedInstance] closeAnimation:NO WithBlcok:^{
        
    }];
}

#pragma mark
-(void)gotoInfoAction:(ScaleCustomBtn *)sender{
    if (sender.tag==10) {
        if ((self.scaleModel&&self.scaleModel.bmi>0.0)||scale.bmi>0.0) {
            ScaleBMIViewController *scaleBmiVC=[[ScaleBMIViewController alloc] init];
            scaleBmiVC.scaleBMI=self.scaleModel?self.scaleModel.bmi:scale.bmi;
            [self.navigationController pushViewController:scaleBmiVC animated:YES];
        }
    }else{
        if ((self.scaleModel&&self.scaleModel.weight>0.0)||scale.weight>0.0) {
            ScaleWeightViewController *scaleWeightVC=[[ScaleWeightViewController alloc] init];
            scaleWeightVC.scaleWeight=self.scaleModel?self.scaleModel.weight:scale.weight;
            [self.navigationController pushViewController:scaleWeightVC animated:YES];
        }
    }
}

#pragma mark 查看食物库　
-(void)checkCutWeightDiet{
    TJYFoodLibraryVC *foodLibraryVC=[[TJYFoodLibraryVC alloc] init];
    foodLibraryVC.orderbyStr = @"fat";
    [self.navigationController pushViewController:foodLibraryVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 扫描设备
-(void)scanScaleDevice{
    MyLog(@"开始扫描");
    //扫描设备
    __weak typeof(self) weakSelf=self;
    [QingNiuSDK startBleScan:nil scanSuccessBlock:^(QingNiuDevice *qingNiuDevice) {
        MyLog(@"扫描到体质分析仪设备mac:%@",qingNiuDevice.macAddress);
        if (qingNiuDevice.macAddress) {
            [QingNiuSDK startBleScan:qingNiuDevice scanSuccessBlock:^(QingNiuDevice *qingNiuDevice) {
                [QingNiuSDK stopBleScan];
                connectedDevice = qingNiuDevice;
                [weakSelf connectScaleDevice:qingNiuDevice];
            } scanFailBlock:^(QingNiuScanDeviceFail qingNiuScanDeviceFail) {
                NSString *message=nil;
                if (qingNiuScanDeviceFail==QingNiuScanDeviceFailUnsupported) {
                    message=@"该设备不支持蓝牙4.0";
                }else if (qingNiuScanDeviceFail==QingNiuScanDeviceFailPoweredOff){
                    message=@"请打开蓝牙";
                }else{
                    message=@"扫描设备失败，请稍后再试";
                }
                MyLog(@"qingNiuScanDeviceFail:%@",message);
                [weakSelf.view makeToast:message duration:1.0 position:CSToastPositionCenter];
            }];
        }
    } scanFailBlock:^(QingNiuScanDeviceFail qingNiuScanDeviceFail) {
        NSString *message=nil;
        if (qingNiuScanDeviceFail==QingNiuScanDeviceFailUnsupported) {
            message=@"该设备不支持蓝牙4.0";
        }else if (qingNiuScanDeviceFail==QingNiuScanDeviceFailPoweredOff){
            message=@"请打开蓝牙";
        }else{
            message=@"扫描设备失败，请稍后再试";
        }
        MyLog(@"qingNiuScanDeviceFail:%@",message);
        [weakSelf.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
}

-(void)connectScaleDevice:(QingNiuDevice *)device{
    MyLog(@"连接设备");
    
    imgFoot.hidden = YES;
    if (!isHasSaved) {   //未保存过数据（第一次测量）
        self.topRemindView.hidden=NO;
        self.topScoreView.hidden=YES;
        [subscribeAnimation startAnimating];
    }
    
    NSString *userID=[NSUserDefaultInfos getValueforKey:USER_ID];
    CGFloat height=[userModel.height floatValue];
    int gender=userModel.sex==1?1:0;
    
    __weak typeof(self) weakSelf=self;
    QingNiuUser *qnUser=[[QingNiuUser alloc] initUserWithUserId:userID andHeight:height andGender:gender andBirthday:userModel.birthday];
    MyLog(@"qnUser--userID:%@,height:%.1f,gender:%ld,birthdar:%@",qnUser.userId,qnUser.height,(long)gender,qnUser.birthday);
    [QingNiuSDK connectDevice:device user:qnUser connectSuccessBlock:^(NSMutableDictionary *deviceData, QingNiuDeviceConnectState qingNiuDeviceConnectState) {
        MyLog(@"获取数据：%@ ,state:%ld",deviceData,(long)qingNiuDeviceConnectState);
        if (kIsDictionary(deviceData)&&deviceData.count>0) {
            if (scale.weight>0.0) {
                weakSelf.topRemindView.hidden=NO;
                weakSelf.topScoreView.hidden=YES;
                [subscribeAnimation startAnimating];
                
                bmiBtn.valueDict=@{@"title":@"BMI",@"value":@"--"};
                NSString *weightStr=[NSString stringWithFormat:@"%.2f",scale.weight];
                weightBtn.valueDict=@{@"title":@"体重",@"value":weightStr};
                [weakSelf initBodyIndexData];
                // 连接成功，添加到设备列表
                [weakSelf addToDeviceList];
            }
            [weakSelf getDeviceMeseaureData:deviceData withState:qingNiuDeviceConnectState];
        }else{
            [weakSelf connectScaleDevice:connectedDevice];
        }
        
    } connectFailBlock:^(QingNiuDeviceConnectState qingNiuDeviceConnectState) {
        MyLog(@"qingNiuDeviceConnectState:%ld",(long)qingNiuDeviceConnectState);
    }];
}

#pragma mark 获取设备测量数据
-(void)getDeviceMeseaureData:(NSDictionary *)deviceData withState:(QingNiuDeviceConnectState)state{
    [scale setValues:deviceData];
    scale.body_fat_percentage=[[deviceData valueForKey:@"bodyfat"] doubleValue];
    scale.body_water_rate=[[deviceData valueForKey:@"water"] doubleValue];
    scale.bone_mass=[[deviceData valueForKey:@"bone"] doubleValue];
    scale.skeletal_muscle_rate=[[deviceData valueForKey:@"muscle"] doubleValue];
    scale.visceral_fat_level=[[deviceData valueForKey:@"visfat"] integerValue];
    scale.basal_metabolic_rate=[[deviceData valueForKey:@"bmr"] doubleValue];
    scale.subcutaneous_fat_rate=[[deviceData valueForKey:@"subfat"] doubleValue];
    
    weightBtn.valueDict=@{@"type":[NSNumber numberWithInteger:2],@"value":[NSString stringWithFormat:@"%.2f",scale.weight]};
    bmiBtn.valueDict=@{@"type":[NSNumber numberWithInteger:1],@"value":[NSString stringWithFormat:@"%.1f",scale.bmi]};
    
    if (state>=6) {
        
        [self reloadViewWithScaleModel:scale];
    }
}

-(void)reloadViewWithScaleModel:(ScaleModel *)model{
    NSInteger score=0;
    if (model.body_fat_percentage>0.0) {
        [subscribeAnimation stopAnimating];
        self.topScoreView.hidden=NO;
        self.topRemindView.hidden=YES;
        if (self.scaleModel) {
            weightBtn.valueDict=@{@"type":[NSNumber numberWithInteger:2],@"value":[NSString stringWithFormat:@"%.2f",model.weight]};
            bmiBtn.valueDict=@{@"type":[NSNumber numberWithInteger:1],@"value":[NSString stringWithFormat:@"%.1f",model.bmi]};
        }
        score=60+model.skeletal_muscle_rate-model.body_fat_percentage+0.5;  //评分  60+骨骼肌率-体脂肪
        if (score>100) {
            score = 100;
        }
        self.topScoreView.bodyScore=score;
        
        // 体脂肪率
        NSString *resultStr=[[ScaleHelper sharedScaleHelper] getBodyFatStandardWithBodyfat:model.body_fat_percentage];
        BodySectionModel *bodyfatModel=[[BodySectionModel alloc] init];
        bodyfatModel.sectionTitle=titles[0];
        bodyfatModel.imageName=images[0];
        bodyfatModel.value=[NSString stringWithFormat:@"%.1f%%",model.body_fat_percentage];
        bodyfatModel.keyStr=@"bodyfat";
        bodyfatModel.standard=resultStr;
        
        ResultModel *bodyfatResult=[[ResultModel alloc] init];
        bodyfatResult.value=[NSString stringWithFormat:@"%.1f",model.body_fat_percentage];
        bodyfatResult.resultText=[[ScaleHelper sharedScaleHelper] getStandardContentWithResult:resultStr key:@"bodyfat"];
        bodyfatModel.resultModel=bodyfatResult;
        [bodyIndexArray replaceObjectAtIndex:0 withObject:bodyfatModel];
        
        if ([resultStr isEqualToString:@"偏高"]||[resultStr isEqualToString:@"严重偏高"]) {
            self.bodyIndexTableView.tableFooterView=self.dietRemindView;
        }
        
        //体水分率
        NSString *resultStr2=[[ScaleHelper sharedScaleHelper] getWaterStandardWithWater:model.body_water_rate];
        BodySectionModel *waterModel=[[BodySectionModel alloc] init];
        waterModel.sectionTitle=titles[1];
        waterModel.imageName=images[1];
        waterModel.value=[NSString stringWithFormat:@"%.1f%%",model.body_water_rate];
        waterModel.keyStr=@"water";
        waterModel.standard=resultStr2;
        
        ResultModel *waterResult=[[ResultModel alloc] init];
        waterResult.value=[NSString stringWithFormat:@"%.1f",model.body_water_rate];
        waterResult.resultText=[[ScaleHelper sharedScaleHelper] getStandardContentWithResult:resultStr2 key:@"water"];
        waterModel.resultModel=waterResult;
        [bodyIndexArray replaceObjectAtIndex:1 withObject:waterModel];
        
        //骨量
        NSString *resultStr3=[[ScaleHelper sharedScaleHelper] getBoneStandardWithBone:model.bone_mass];
        BodySectionModel *boneModel=[[BodySectionModel alloc] init];
        boneModel.sectionTitle=titles[2];
        boneModel.imageName=images[2];
        boneModel.value=[NSString stringWithFormat:@"%.1f",model.bone_mass];
        boneModel.keyStr=@"bone";
        boneModel.standard=resultStr3;
        
        ResultModel *boneResult=[[ResultModel alloc] init];
        boneResult.value=[NSString stringWithFormat:@"%.1f",model.bone_mass];
        boneResult.resultText=[[ScaleHelper sharedScaleHelper] getStandardContentWithResult:resultStr3 key:@"bone"];
        boneModel.resultModel=boneResult;
        [bodyIndexArray replaceObjectAtIndex:2 withObject:boneModel];
        
        //骨骼肌率
        NSString *resultStr4=[[ScaleHelper sharedScaleHelper] getMuscleStandardWithMuscle:model.skeletal_muscle_rate];
        BodySectionModel *muscleModel=[[BodySectionModel alloc] init];
        muscleModel.sectionTitle=titles[3];
        muscleModel.imageName=images[3];
        muscleModel.value=[NSString stringWithFormat:@"%.1f%%",model.skeletal_muscle_rate];
        muscleModel.keyStr=@"muscle";
        muscleModel.standard=resultStr4;
        
        ResultModel *muscleResult=[[ResultModel alloc] init];
        muscleResult.value=[NSString stringWithFormat:@"%.1f",model.skeletal_muscle_rate];
        muscleResult.resultText=[[ScaleHelper sharedScaleHelper] getStandardContentWithResult:resultStr4 key:@"muscle"];
        muscleModel.resultModel=muscleResult;
        [bodyIndexArray replaceObjectAtIndex:3 withObject:muscleModel];
        
        //蛋白质
        NSString *resultStr5=[[ScaleHelper sharedScaleHelper] getProteinStandardWithProtein:model.protein];
        BodySectionModel *proteinModel=[[BodySectionModel alloc] init];
        proteinModel.sectionTitle=titles[5];
        proteinModel.imageName=images[5];
        proteinModel.value=[NSString stringWithFormat:@"%.1f%%",model.protein];
        proteinModel.keyStr=@"protein";
        proteinModel.standard=resultStr5;
        
        ResultModel *proteinResult=[[ResultModel alloc] init];
        proteinResult.value=[NSString stringWithFormat:@"%.1f",model.protein];
        proteinResult.resultText=[[ScaleHelper sharedScaleHelper] getStandardContentWithResult:resultStr5 key:@"protein"];
        proteinModel.resultModel=proteinResult;
        [bodyIndexArray replaceObjectAtIndex:5 withObject:proteinModel];
        
        //内脏脂肪等级
        NSString *resultStr6=[[ScaleHelper sharedScaleHelper] getVisfatStandardWithVisfat:model.visceral_fat_level];
        BodySectionModel *visfatModel=[[BodySectionModel alloc] init];
        visfatModel.sectionTitle=titles[4];
        visfatModel.imageName=images[4];
        visfatModel.value=[NSString stringWithFormat:@"%ld",(long)model.visceral_fat_level];
        visfatModel.keyStr=@"visfat";
        visfatModel.standard=resultStr6;
        
        ResultModel *visfatResult=[[ResultModel alloc] init];
        visfatResult.value=[NSString stringWithFormat:@"%ld",(long)model.visceral_fat_level];
        visfatResult.resultText=[[ScaleHelper sharedScaleHelper] getStandardContentWithResult:resultStr6 key:@"visfat"];
        visfatModel.resultModel=visfatResult;
        [bodyIndexArray replaceObjectAtIndex:4 withObject:visfatModel];
        
        //基础代谢量
        NSString *resultStr7=[[ScaleHelper sharedScaleHelper] getBmrStandardWithBmr:model.basal_metabolic_rate];
        BodySectionModel *bmrModel=[[BodySectionModel alloc] init];
        bmrModel.sectionTitle=titles[6];
        bmrModel.imageName=images[6];
        bmrModel.value=[NSString stringWithFormat:@"%.1fkcal",model.basal_metabolic_rate];
        bmrModel.keyStr=@"bmr";
        bmrModel.standard=resultStr7;
        
        ResultModel *bmrResult=[[ResultModel alloc] init];
        bmrResult.value=[NSString stringWithFormat:@"%.1f",model.basal_metabolic_rate];
        bmrResult.resultText=[[ScaleHelper sharedScaleHelper] getStandardContentWithResult:resultStr7 key:@"bmr"];
        bmrModel.resultModel=bmrResult;
        [bodyIndexArray replaceObjectAtIndex:6 withObject:bmrModel];
        
        //皮下脂肪率
        NSString *resultStr8=[[ScaleHelper sharedScaleHelper] getSubfatStandardWithSubfat:model.subcutaneous_fat_rate];
        BodySectionModel *subfatModel=[[BodySectionModel alloc] init];
        subfatModel.sectionTitle=titles[7];
        subfatModel.imageName=images[7];
        subfatModel.value=[NSString stringWithFormat:@"%.1f%%",model.subcutaneous_fat_rate];
        subfatModel.keyStr=@"subfat";
        subfatModel.standard=resultStr8;
        
        ResultModel *subfatResult=[[ResultModel alloc] init];
        subfatResult.value=[NSString stringWithFormat:@"%.1f",model.subcutaneous_fat_rate];
        subfatResult.resultText=[[ScaleHelper sharedScaleHelper] getStandardContentWithResult:resultStr8 key:@"subfat"];
        subfatModel.resultModel=subfatResult;
        [bodyIndexArray replaceObjectAtIndex:7 withObject:subfatModel];
    }
    
    [self.bodyIndexTableView reloadData];
    

    //同步数据到后台
    if (!self.scaleModel) {
        TJYUserModel *user=[ScaleHelper sharedScaleHelper].scaleUser;
        NSInteger birthdayS = [[TJYHelper sharedTJYHelper] timeSwitchTimestamp:user.birthday format:@"yyyy-MM-dd"];
        NSString *body=[NSString stringWithFormat:@"score=%ld&bmi=%.1f&weight=%.2f&body_fat_percentage=%.1f&body_water_rate=%.1f&bone_mass=%.1f&skeletal_muscle_rate=%.1f&visceral_fat_level=%ld&basal_metabolic_rate=%.1f&subcutaneous_fat_rate=%.1f&protein=%.1f&way=2&doSubmit=1&height=%@&sex=%ld&birthday=%ld",(long)score,model.bmi,model.weight,model.body_fat_percentage,model.body_water_rate,model.bone_mass,model.skeletal_muscle_rate,(long)model.visceral_fat_level,model.basal_metabolic_rate,model.subcutaneous_fat_rate,model.protein,user.height,(long)user.sex,(long)birthdayS];
        kSelfWeak;
        [[NetworkTool sharedNetworkTool] postMethodWithURL:kWeightRecordAdd body:body success:^(id json) {
            NSArray *array = [json objectForKey:@"result"];
            NSDictionary *dict = array[0];
            weakSelf.user_id = [[dict objectForKey:@"user_id"] integerValue];
            weakSelf.record_id = [[dict objectForKey:@"constitution_analyzer_id"] integerValue];
            weakSelf.shareScore = score;
            
            scale=[[ScaleModel alloc] init];
            isHasSaved=YES;
            
            [weakSelf.view makeToast:@"您的体指标数据已保存" duration:1.0 position:CSToastPositionCenter];
            [weakSelf connectScaleDevice:connectedDevice];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:@"您的体指标数据保存失败" duration:1.0 position:CSToastPositionCenter];
        }];
    }

}

#pragma mark 初始化界面
-(void)initScaleView{
    [self.view addSubview:self.topRemindView];
    [self.view addSubview:self.topScoreView];
    self.topScoreView.hidden=YES;
    [self.view addSubview:self.bodyIndexTableView];
    self.bodyIndexTableView.tableHeaderView=self.scaleWeightView;
}

#pragma mark -- Setters
#pragma mark 测量提示视图
-(UIView *)topRemindView{
    if (!_topRemindView) {
        _topRemindView=[[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth,130)];
        _topRemindView.backgroundColor=[UIColor whiteColor];
        
        subscribeAnimation = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-140)/2, 15, 140, 60)];
        subscribeAnimation.animationImages = [[NSArray alloc]initWithObjects:[UIImage imageNamed:@"tzy_lian_img01"],[UIImage imageNamed:@"tzy_lian_img02"],[UIImage imageNamed:@"tzy_lian_img03"],[UIImage imageNamed:@"tzy_lian_img04"],[UIImage imageNamed:@"tzy_lian_img03"],[UIImage imageNamed:@"tzy_lian_img02"],[UIImage imageNamed:@"tzy_lian_img01"], nil];
        subscribeAnimation.animationDuration=1.0f;
        [_topRemindView addSubview:subscribeAnimation];
        
        imgFoot = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-140)/2, 15, 140, 60)];
        imgFoot.image = [UIImage imageNamed:@"img_foot"];
        [_topRemindView addSubview:imgFoot];
        
        tipsBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, 10, 30, 30)];
        [tipsBtn setImage:[UIImage imageNamed:@"ic_tzy_tips"] forState:UIControlStateNormal];
        [tipsBtn addTarget:self action:@selector(popupTipsAction) forControlEvents:UIControlEventTouchUpInside];
        [_topRemindView addSubview:tipsBtn];
        
        contentLabel=InsertLabel(_topRemindView, CGRectMake(20, 95, kScreenWidth-40, 20), NSTextAlignmentCenter, @"请光脚站在秤上", [UIFont systemFontOfSize:14], [UIColor blackColor], NO);
        
    }
    return _topRemindView;
}

#pragma mark 测量分数视图
-(ScaleScoreView *)topScoreView{
    if (!_topScoreView) {
        _topScoreView=[[ScaleScoreView alloc] initWithFrame:CGRectMake(0,64, kScreenWidth, 130)];
        _topScoreView.ScaleScoreDelegate = self;
    }
    return _topScoreView;
}

#pragma mark 体重、BMI
-(UIView *)scaleWeightView{
    if (_scaleWeightView ==nil) {
        _scaleWeightView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 90)];
        
        //BMI
        bmiBtn=[[ScaleCustomBtn alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/2-1, 85) dict:@{@"title":@"BMI",@"value":@"--"}];
        [bmiBtn addTarget:self action:@selector(gotoInfoAction:) forControlEvents:UIControlEventTouchUpInside];
        bmiBtn.tag=10;
        [_scaleWeightView addSubview:bmiBtn];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-1, 5, 1, 80)];
        line.backgroundColor=kLineColor;
        [_scaleWeightView addSubview:line];
        
        //体重
        weightBtn=[[ScaleCustomBtn alloc] initWithFrame:CGRectMake(kScreenWidth/2, 0, kScreenWidth/2, 85) dict:@{@"title":@"体重",@"value":@"0.00kg"}];
        weightBtn.tag=11;
        [weightBtn addTarget:self action:@selector(gotoInfoAction:) forControlEvents:UIControlEventTouchUpInside];
        [_scaleWeightView addSubview:weightBtn];
        
    }
    return _scaleWeightView;
}

#pragma mark 体指标视图
-(UITableView *)bodyIndexTableView{
    if (!_bodyIndexTableView) {
        _bodyIndexTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, self.topScoreView.bottom+10, kScreenWidth, kBodyHeight-self.topScoreView.bottom+55) style:UITableViewStyleGrouped];
        _bodyIndexTableView.delegate=self;
        _bodyIndexTableView.dataSource=self;
        _bodyIndexTableView.backgroundColor=[UIColor bgColor_Gray];
        _bodyIndexTableView.showsVerticalScrollIndicator=NO;
        [_bodyIndexTableView registerClass:[BodyHeaderView class] forHeaderFooterViewReuseIdentifier:kHeaderIdentifier];
    }
    return _bodyIndexTableView;
}

#pragma mark 营养改善建议
-(UIView *)dietRemindView{
    if (!_dietRemindView) {
        _dietRemindView=[[UIView alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 80)];
        _dietRemindView.backgroundColor=[UIColor whiteColor];
        
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth-20, 30)];
        lab.text=@"营养改善建议";
        lab.font=[UIFont systemFontOfSize:16];
        lab.textColor=[UIColor lightGrayColor];
        [_dietRemindView addSubview:lab];
        
        UILabel *line1=[[UILabel alloc] initWithFrame:CGRectMake(0, lab.bottom, kScreenWidth, 1)];
        line1.backgroundColor=kLineColor;
        [_dietRemindView addSubview:line1];
        
        UIImageView *dietImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, line1.bottom+5, 40, 40)];
        dietImageView.image=[UIImage imageNamed:@"ic_tzy_lowzf"];
        [_dietRemindView addSubview:dietImageView];
        
        UILabel *dietlbl=[[UILabel alloc] initWithFrame:CGRectMake(dietImageView.right+10, line1.bottom+10, 200, 30)];
        dietlbl.text=@"建议食用低脂肪的食物.";
        dietlbl.font=[UIFont systemFontOfSize:14];
        [_dietRemindView addSubview:dietlbl];
        
        UIButton *checkBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-80, line1.bottom+10, 70, 30)];
        [checkBtn setTitle:@"查看" forState:UIControlStateNormal];
        [checkBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
        checkBtn.layer.cornerRadius=5;
        checkBtn.layer.borderWidth=1.0;
        checkBtn.layer.borderColor=kSystemColor.CGColor;
        checkBtn.clipsToBounds=YES;
        [checkBtn addTarget:self action:@selector(checkCutWeightDiet) forControlEvents:UIControlEventTouchUpInside];
        checkBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        [_dietRemindView addSubview:checkBtn];
        
        UILabel *line2=[[UILabel alloc] initWithFrame:CGRectMake(0, dietImageView.bottom+5, kScreenWidth, 1)];
        line2.backgroundColor=kLineColor;
        [_dietRemindView addSubview:line2];
        
    }
    return _dietRemindView;
}

#pragma mark 弹出提示视图
- (void)popViewShow {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.layer.cornerRadius = 5;
    contentView.backgroundColor =[UIColor bgColor_Gray];
    
    CGFloat viewWidth=SCREEN_WIDTH-60;
    
    UILabel *titlelbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, viewWidth, 30)];
    titlelbl.text = @"温馨提示";
    titlelbl.textAlignment = NSTextAlignmentCenter;
    titlelbl.font = [UIFont systemFontOfSize:18];
    [contentView addSubview:titlelbl];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, titlelbl.bottom+10,viewWidth, viewWidth*226/540)];
    imgView.image = [UIImage imageNamed:@"img_foot"];
    [contentView addSubview:imgView];
    
    UILabel  *contLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contLabel.font = [UIFont systemFontOfSize:14];
    contLabel.textColor = [UIColor blackColor];
    [contLabel setNumberOfLines:0];
    NSString *dataStr = @"1 请将设备放置于光滑平坦的地面上，并光脚测量。\n\n2 体内装有心脏起搏器，人工肺，佩戴型心电仪等医疗器械者，禁止使用该产品。\n\n3 儿童、青少年、孕妇，80岁以上的老人等特殊人群，建议仅将测量值做参考。";
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:dataStr];
    [attributeStr setAttributes:@{NSKernAttributeName:@1.2} range:NSMakeRange(0, dataStr.length)];
    contLabel.attributedText=attributeStr;
    
    CGSize labelsizes = [dataStr boundingRectWithSize:CGSizeMake(viewWidth-30, CGFLOAT_MAX) withTextFont:[UIFont systemFontOfSize:14]];
    [contLabel setFrame:CGRectMake(15,imgView.bottom+10, viewWidth-30, labelsizes.height+10)];
    [contentView addSubview:contLabel];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,contLabel.bottom+10, viewWidth, 1)];
    lineLabel.backgroundColor = kLineColor;
    [contentView addSubview:lineLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,lineLabel.bottom+5,viewWidth, 40)];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:20];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeTipsViewAction) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:button];
    
    contentView.frame=CGRectMake(0, 0, viewWidth, button.bottom+10);
    
    [HWPopTool sharedInstance].shadeBackgroundType = ShadeBackgroundTypeSolid;
    [HWPopTool sharedInstance].closeButtonType = ButtonPositionTypeNone;
    [[HWPopTool sharedInstance] showWithPresentView:contentView animated:YES];
    
}

#pragma mark  体指标数据
-(void)initBodyIndexData{
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for (NSInteger i=0; i<titles.count; i++) {
        BodySectionModel *model=[[BodySectionModel alloc] init];
        model.imageName=images[i];
        model.sectionTitle=titles[i];
        model.value=@"--";
        [tempArr addObject:model];
    }
    bodyIndexArray=tempArr;
    [self.bodyIndexTableView reloadData];
    
}
#pragma mark  添加设备到设备列表
/**
 *  添加设备到设备列表
 */
-(void)addToDeviceList
{
    BLEDeviceModel * tempModel = [[BLEDevice_DBController dbController] getBLEDevice:Scale_NAME_PREFIX];
    if (tempModel)
    {
        // 设备已经添加了
        return;
    }
    
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:Scale_NAME_PREFIX,@"name", nil];
    BLEDeviceModel * device = [[BLEDeviceModel alloc] initWithDictionary:dic deviceType:DeviceTypeScale];
    [[BLEDevice_DBController dbController] insertBLEDevice:device];
    
    // 更新设备列表
    [TJYHelper sharedTJYHelper].isReloadLocalDevice=YES;
}


#pragma mark  删除设备

/**
 *  删除提示
 */
-(void)showDeleteAlertController
{
    NSString *otherButtonTitle = NSLocalizedString(@"确定", nil);
    NSString *title = NSLocalizedString(@"提示", nil);
    NSString *message = NSLocalizedString(@"确定要删除当前设备？", nil);
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf deleteDevice];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 *  删除数据
 */
-(void)deleteDevice
{
    [[BLEDevice_DBController dbController] deleteBLEDevice:Scale_NAME_PREFIX];
    [self.navigationController popViewControllerAnimated:YES];
    // 更新设备列表
    [TJYHelper sharedTJYHelper].isReloadLocalDevice=YES;
}
@end
