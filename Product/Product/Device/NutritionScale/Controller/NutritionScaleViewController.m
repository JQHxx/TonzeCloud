//
//  NutritionScaleViewController.m
//  Product
//
//  Created by Wzy on 1/9/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "NutritionScaleViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "ShoppingCartTool.h"
#import "DiningDatePickerView.h"
#import "FoodSelectView.h"
#import "NutritionDetailView.h"
#import "FoodSelecedView.h"
#import "TJYFoodLibraryVC.h"
#import "TJYFoodListModel.h"
#import "iFreshSDK.h"
#import "iFreshModel.h"
#import "BLEDevice_DBController.h"
#import "UIView+Ext.h"
#import "TTTAttributedLabel.h"
#import "TJYHelper.h"
#import "BTManager.h"
#import "ZQSelectButton.h"
#import "TJYFoodDetailsModel.h"
#import "UnitSelectViewController.h"
#import "EstimateWeightViewController.h"
#import "TJYFoodDetailsVC.h"

#define NutritionScale_NAME_PREFIX     @"云智能营养秤"

@interface NutritionScaleViewController ()<BleReturnValueDelegate,UITextFieldDelegate>
{
    /**
     *  记录时间
     */
    NSString * strDineDate;
    
    /**
     *  选择食物
     */
    TJYFoodListModel * currentFood;

    /**
     *  是否不用断开连接
     */
    bool isNoDisConnect;
    
    /**
     *  当前单位
     */
    NSString * currentUnit;
}

/**
 *  背景
 */
@property (nonatomic,strong) UIImageView * imgBG;

/**
 *  操作视图
 */
@property (nonatomic,strong) UIView * viewAction;

/**
 *  连接状态
 */
@property (nonatomic,strong) UILabel * lblState;
/**
 *  是否已连接上
 */
@property (nonatomic,assign) BOOL isConnect;

/**
 *  内容
 */
@property (nonatomic,strong) TPKeyboardAvoidingScrollView * contentScroll;

/**
 *  选择食物
 */
@property (nonatomic,strong) UIButton * btnSelectFood;

/**
 *  食物重量
 */
@property (nonatomic,strong) UITextField * txtWeight;

/**
 *  lb单位页面
 */
@property (nonatomic,strong) UIView * viewLB;

/**
 *  食物重量(lb)
 */
@property (nonatomic,strong) UITextField * txtLBWeight;

/**
 *  食物重量(oz)
 */
@property (nonatomic,strong) UITextField * txtOZWeight;

/**
 *  单位
 */
@property (nonatomic,strong) UILabel * lblUnit;

/**
 *  称量提示
 */
@property (nonatomic,strong) UILabel * lblScaleTip;

/**
 *  去皮
 */
@property (nonatomic,strong) ZQSelectButton * btnPeeled;

/**
 *  归零
 */
@property (nonatomic,strong) ZQSelectButton * btnToZero;

/**
 *  选择用餐时间
 */
@property (nonatomic,strong) UIButton * btnDineDate;

/**
 *  已选食物
 */
@property (nonatomic,strong) UIButton * btnFood;

/**
 *  保存按钮
 */
@property (nonatomic,strong) UIButton * btnSave;

/**
 *  食物热量
 */
@property (nonatomic,strong) TTTAttributedLabel * lblKcal;

/**
 *  单位类型
 */
@property (nonatomic,strong) NSArray * arrayUnit;

/**
 *  加入餐盘的食物
 */
@property (nonatomic,strong) NSMutableArray * arraySelectFood;

/**
 *  加入餐盘的食物
 */
@property (nonatomic,strong) TJYFoodDetailsModel * currentFoodDetail;

/**
 *  单位转化
 */
@property (nonatomic,strong) iFreshModel * freshModel;



@end

@implementation NutritionScaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.baseTitle = NutritionScale_NAME_PREFIX;
    [self buildUI];
    [self startConnect];
    
    self.rightImageName=@"更多";


}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 退出断开连接
    if (isNoDisConnect) {
        return;
    }
    [self disConnect];
    // 设置长亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view endEditing:YES];
    isNoDisConnect = NO;
    // 关闭长亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)buildUI
{
    [self.view addSubview:self.contentScroll];
    [self.contentScroll addSubview:self.lblState];
    [self.contentScroll addSubview:self.imgBG];
    [self.contentScroll addSubview:self.viewAction];
    [self.contentScroll setContentSize:CGSizeMake(SCREEN_WIDTH, self.viewAction.bottom)];

    [self buildNutritionView];
    [self buildActionView];
    [self buildFootView];
}

/**
 *  营养秤视图
 */
-(void)buildNutritionView
{
    CGFloat scaleWidth = 238;
    CGFloat scaleHeight = 212;
    
    UIImageView * imgDial = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - scaleWidth)/2, 0, scaleWidth, scaleHeight)];
    imgDial.image = [UIImage imageNamed:@"dial.png"];
    [self.imgBG addSubview:imgDial];
    
    self.lblUnit.frame = CGRectMake(imgDial.left + (imgDial.width - 100.0f)/2 , 60.0f, 100.0f,30.0f);
    [self.imgBG addSubview:self.lblUnit];
    
    self.txtWeight.frame = CGRectMake(imgDial.left + (imgDial.width - 180.0f)/2, self.lblUnit.bottom , 180.0f, 50.0f);
    [self.imgBG addSubview:self.txtWeight];
    
    UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(self.txtWeight.left, self.txtWeight.bottom, self.txtWeight.width, 1.0f)];
    line.backgroundColor = UIColorHex(0xeeeeee);
    [self.imgBG addSubview:line];
    
    self.lblScaleTip.frame = CGRectMake(imgDial.left, self.txtWeight.bottom + 10.0f, imgDial.width, 20.0f);
    [self.imgBG addSubview:self.lblScaleTip];
    
    self.btnPeeled.frame = CGRectMake(imgDial.left + (imgDial.width - 47.0f*2)/3, imgDial.bottom - 50/2, 47.0f, 47.0f+25);
    [self.imgBG addSubview:self.btnPeeled];
    
    self.btnToZero.frame = CGRectMake(self.btnPeeled.right + (imgDial.width - 47.0f*2)/3, self.btnPeeled.top, self.btnPeeled.width, self.btnPeeled.height);
    [self.imgBG addSubview:self.btnToZero];
    
    self.btnSelectFood.frame = CGRectMake((SCREEN_WIDTH - 260)/2, self.imgBG.height - 20 -36, 260, 36);
    [self.btnSelectFood setImageEdgeInsets:UIEdgeInsetsMake(0, 260 - 20, 0, 0)];
    [self.imgBG addSubview:self.btnSelectFood];
    
    [self buildLBView];
}

/**
 *  切换Lb单位
 */
-(void)buildLBView
{
    self.viewLB = [[UIView alloc] initWithFrame:CGRectMake(self.txtWeight.left, self.txtWeight.top, self.txtWeight.width, self.txtWeight.height)];
    self.viewLB.hidden = YES;
    [self.imgBG addSubview:self.viewLB];
    
    CGFloat width = (self.viewLB.width - 10)/2;
    
    self.txtLBWeight.frame = CGRectMake(0.0, 0.0, width, self.viewLB.height);
    [self.viewLB addSubview:self.txtLBWeight];
    
    UILabel * lblColon = [[UILabel alloc] initWithFrame:CGRectMake(width, 0.0, 10, self.viewLB.height)];
    lblColon.text = @":";
    lblColon.textAlignment = NSTextAlignmentCenter;
    lblColon.textColor = [UIColor whiteColor];
    lblColon.font = [UIFont systemFontOfSize:40];
    [self.viewLB addSubview:lblColon];
    
    self.txtOZWeight.frame = CGRectMake(lblColon.right, 0.0, width, self.viewLB.height);
    [self.viewLB addSubview:self.txtOZWeight];
}

/**
 *  操作视图
 */
-(void)buildActionView
{
    UILabel * lblDate = [[UILabel alloc] initWithFrame:CGRectMake(20.0f,0.0f, 100.0f, 48.0f)];
    lblDate.text = @"用餐时间：";
    lblDate.font = [UIFont systemFontOfSize:15];
    lblDate.textColor = UIColorHex(0x313131);
    [self.viewAction addSubview:lblDate];
    
    self.btnDineDate.frame = CGRectMake(lblDate.right, 0, SCREEN_WIDTH - lblDate.right, 48.0f);
    [self.btnDineDate setImageEdgeInsets:UIEdgeInsetsMake(0, self.btnDineDate.width - 20, 0, 0)];
    [self.viewAction addSubview:self.btnDineDate];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.btnDineDate.bottom, SCREEN_WIDTH, 1.0f)];
    line.backgroundColor = UIColorHex(0xeeeeee);
    [self.viewAction addSubview:line];
    
    UIView * downline = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.viewAction.height-1, SCREEN_WIDTH, 1.0f)];
    downline.backgroundColor = UIColorHex(0xeeeeee);
    [self.viewAction addSubview:downline];
    
    CGFloat margin = (SCREEN_WIDTH - 160)/4;
    ZQSelectButton * btnNutrition = [ZQSelectButton buttonWithType:UIButtonTypeCustom];
    btnNutrition.frame = CGRectMake(margin, self.btnDineDate.bottom + 15, 80, 50 + 25.0f);
    btnNutrition.titleHeight = 20;
    btnNutrition.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [btnNutrition setTitleColor:UIColorHex(0x313131) forState:UIControlStateNormal];
    [btnNutrition setTitle:@"营养含量" forState:UIControlStateNormal];
    [btnNutrition setImage:[UIImage imageNamed:@"nutrition_content.png"] forState:UIControlStateNormal];
    [btnNutrition addTarget:self action:@selector(onBtnNutrition:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewAction addSubview:btnNutrition];
    
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(btnNutrition.right + margin, self.btnDineDate.bottom + (self.viewAction.height - 48 - 60)/2,2,60.0f)];
    line1.backgroundColor = UIColorHex(0xeeeeee);
    [self.viewAction addSubview:line1];
    
    ZQSelectButton * btnAddFood = [ZQSelectButton buttonWithType:UIButtonTypeCustom];
    btnAddFood.frame = CGRectMake(btnNutrition.right + margin * 2, btnNutrition.top, btnNutrition.width, btnNutrition.height);
    btnAddFood.titleHeight = 20;
    btnAddFood.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [btnAddFood setTitleColor:UIColorHex(0x313131) forState:UIControlStateNormal];
    [btnAddFood setTitle:@"加入餐盘" forState:UIControlStateNormal];
    [btnAddFood setImage:[UIImage imageNamed:@"add_plant.png"] forState:UIControlStateNormal];
    [btnAddFood addTarget:self action:@selector(onBtnAddFood:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewAction addSubview:btnAddFood];
}


/**
 *  底部视图
 */
-(void)buildFootView
{
    UIView * footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.contentScroll.bottom, SCREEN_WIDTH, 48.0f)];
    [self.view addSubview:footView];
    
    self.btnFood.frame = CGRectMake(20.0f, 0.0f,footView.height, footView.height);
    [footView addSubview:self.btnFood];
    
    self.lblKcal.frame = CGRectMake(self.btnFood.right + 10.0f, 0.0f, SCREEN_WIDTH - self.btnFood.width - 40 - 96, footView.height);
    [footView addSubview:self.lblKcal];
    
    self.btnSave.frame = CGRectMake(footView.width - 96, self.lblKcal.top, 96, footView.height);
    [footView addSubview:self.btnSave];
}


-(TPKeyboardAvoidingScrollView *)contentScroll
{
    if (_contentScroll == nil)
    {
        _contentScroll = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0,64, SCREEN_WIDTH,SCREEN_HEIGHT - 64.0f - 48.0f)];
        _contentScroll.backgroundColor = UIColorHex(0xfefcec);
        _contentScroll.bounces = NO;
    }
    return _contentScroll;
}

-(UIImageView *)imgBG
{
    if (_imgBG == nil)
    {
        _imgBG = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, self.lblState.bottom, SCREEN_WIDTH, 333)];
        [_imgBG setImage:[UIImage imageNamed:@"background_new.png"]];
        _imgBG.userInteractionEnabled = YES;
    }
    return _imgBG;
}

-(UIView *)viewAction
{
    if (_viewAction == nil)
    {
        _viewAction = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.imgBG.bottom, SCREEN_WIDTH, 155.0f)];
        _viewAction.backgroundColor = [UIColor whiteColor];
    }
    return _viewAction;
}

-(UILabel *)lblState
{
    if (_lblState == nil)
    {
        _lblState = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, 48.0f)];
        _lblState.textColor = UIColorHex(0xfd832b);
        _lblState.textAlignment = NSTextAlignmentCenter;
        _lblState.font = [UIFont systemFontOfSize:16];
        _lblState.backgroundColor = UIColorHex(0xfefcec);
        if([BTManager isBLEEnable])
        {
            _lblState.text = @"正在连接营养秤";
        }
        else
        {
            _lblState.text = @"蓝牙未开启";
        }
    }
    
    return _lblState;
}

-(UIButton *)btnSelectFood
{
    if (_btnSelectFood == nil)
    {
        _btnSelectFood = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSelectFood setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 20)];
        [_btnSelectFood setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSelectFood setBackgroundImage:[UIImage imageNamed:@"select_food.png"] forState:UIControlStateNormal];
        [_btnSelectFood setImage:[UIImage imageNamed:@"more_food.png"] forState:UIControlStateNormal];
        [_btnSelectFood setTitle:@"请选择食物" forState:UIControlStateNormal];
        [_btnSelectFood addTarget:self action:@selector(onBtnSelectFood:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSelectFood;
}

-(UITextField *)txtWeight
{
    if (_txtWeight == nil) {
        _txtWeight = [[UITextField alloc] init];
        _txtWeight.textAlignment = NSTextAlignmentCenter;
        _txtWeight.keyboardType = UIKeyboardTypeDecimalPad;
        _txtWeight.font = [UIFont systemFontOfSize:40];
        _txtWeight.textColor = [UIColor whiteColor];
        _txtWeight.text = @"0";
        _txtWeight.placeholder = @"0";
        [_txtWeight addTarget:self  action:@selector(weightChanged:)  forControlEvents:UIControlEventEditingChanged];
    }
    return _txtWeight;
}

-(UITextField *)txtLBWeight
{
    if (_txtLBWeight == nil) {
        _txtLBWeight = [[UITextField alloc] init];
        _txtLBWeight.textAlignment = NSTextAlignmentCenter;
        _txtLBWeight.keyboardType = UIKeyboardTypeDecimalPad;
        _txtLBWeight.font = [UIFont systemFontOfSize:34];
        _txtLBWeight.textColor = [UIColor whiteColor];
        _txtLBWeight.text = @"0";
        _txtLBWeight.placeholder = @"0";
        _txtLBWeight.adjustsFontSizeToFitWidth = YES;
        _txtLBWeight.minimumFontSize = 28.0f;
        [_txtLBWeight addTarget:self  action:@selector(weightChanged:)  forControlEvents:UIControlEventEditingChanged];
    }
    return _txtLBWeight;
}

-(UITextField *)txtOZWeight
{
    if (_txtOZWeight == nil) {
        _txtOZWeight = [[UITextField alloc] init];
        _txtOZWeight.textAlignment = NSTextAlignmentCenter;
        _txtOZWeight.keyboardType = UIKeyboardTypeDecimalPad;
        _txtOZWeight.font = [UIFont systemFontOfSize:34];
        _txtOZWeight.textColor = [UIColor whiteColor];
        _txtOZWeight.text = @"0.00";
        _txtOZWeight.placeholder = @"0.00";
        _txtOZWeight.adjustsFontSizeToFitWidth = YES;
        _txtOZWeight.minimumFontSize = 28.0f;
        
        [_txtOZWeight addTarget:self  action:@selector(weightChanged:)  forControlEvents:UIControlEventEditingChanged];
    }
    return _txtOZWeight;
}

-(UILabel *)lblUnit
{
    if (_lblUnit == nil)
    {
        _lblUnit = [[UILabel alloc] init];
        _lblUnit.text = @"重量（g）";
        currentUnit = @"g";
        _lblUnit.font = [UIFont systemFontOfSize:18];
        _lblUnit.textColor = [UIColor whiteColor];
        _lblUnit.textAlignment = NSTextAlignmentCenter;
    }
    return _lblUnit;
}

-(UILabel *)lblScaleTip
{
    if (_lblScaleTip == nil)
    {
        _lblScaleTip = [[UILabel alloc] init];
        _lblScaleTip.text = @"可手动输入重量";
        _lblScaleTip.textColor = [UIColor whiteColor];
        _lblScaleTip.backgroundColor = [UIColor clearColor];
        _lblScaleTip.textAlignment = NSTextAlignmentCenter;
    }
    return _lblScaleTip;
}

-(UIButton *)btnPeeled
{
    if (_btnPeeled == nil)
    {
        _btnPeeled = [ZQSelectButton buttonWithType:UIButtonTypeCustom];
        _btnPeeled.titleHeight = 25;
        //[_btnPeeled setImage:[UIImage imageNamed:@"minus_plant.png"] forState:UIControlStateNormal];
        _btnPeeled.userInteractionEnabled = NO;
        [_btnPeeled setImage:[UIImage imageNamed:@"noBtnPeel.png"] forState:UIControlStateNormal];
        [_btnPeeled setImage:[UIImage imageNamed:@"btnPeel.png"] forState:UIControlStateHighlighted];
        [_btnPeeled setImage:[UIImage imageNamed:@"btnPeel.png"] forState:UIControlStateSelected];
        [_btnPeeled setTitle:@"去皮" forState:UIControlStateNormal];
        [_btnPeeled addTarget:self action:@selector(onBtnPeeled:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnPeeled;
}

-(UIButton *)btnToZero
{
    if (_btnToZero == nil)
    {
        _btnToZero = [ZQSelectButton buttonWithType:UIButtonTypeCustom];
        _btnToZero.titleHeight = 25;
        //[_btnToZero setImage:[UIImage imageNamed:@"rebirth.png"] forState:UIControlStateNormal];
        _btnToZero.userInteractionEnabled = NO;
        [_btnToZero setImage:[UIImage imageNamed:@"noBtnZero.png"] forState:UIControlStateNormal];
        [_btnToZero setImage:[UIImage imageNamed:@"btnZero.png"] forState:UIControlStateHighlighted];
        [_btnToZero setImage:[UIImage imageNamed:@"btnZero.png"] forState:UIControlStateSelected];

        [_btnToZero setTitle:@"归零" forState:UIControlStateNormal];
        [_btnToZero addTarget:self action:@selector(onBtnToZero:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnToZero;
}

-(UIButton *)btnDineDate
{
    if (_btnDineDate == nil)
    {
        _btnDineDate = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_btnDineDate addTarget:self action:@selector(onbtnDineDate:) forControlEvents:UIControlEventTouchUpInside];
        [_btnDineDate setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_btnDineDate setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 26)];
        NSString * currentDate =[[TJYHelper sharedTJYHelper] getCurrentDate];
        NSString * dietPeriod=[[TJYHelper sharedTJYHelper] getDietPeriodOfCurrentTime];
        strDineDate = [currentDate stringByAppendingFormat:@" %@",dietPeriod];
        [_btnDineDate setTitle:strDineDate forState:UIControlStateNormal];
        [_btnDineDate setTitleColor:UIColorHex(0x959595) forState:UIControlStateNormal];
        [_btnDineDate setImage:[UIImage imageNamed:@"when_eat.png"] forState:UIControlStateNormal];
        
    }
    return _btnDineDate;
}

-(UIButton *)btnFood
{
    if (_btnFood == nil)
    {
        _btnFood = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnFood.enabled = NO;
        [_btnFood setImage:[UIImage imageNamed:@"my-dinner.png"] forState:UIControlStateNormal];
        [_btnFood addTarget:self action:@selector(onBtnFood:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnFood;
}

-(UILabel *)lblKcal
{
    if (_lblKcal == nil)
    {
        _lblKcal = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _lblKcal.textColor = UIColorHex(0x959595);
        _lblKcal.font = [UIFont systemFontOfSize:15];
    }
    return _lblKcal;
}

-(UIButton *)btnSave
{
    if (_btnSave == nil){
        self.btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSave.backgroundColor = UIColorHex(0xf9c150);
        [_btnSave setTitle:@"保存" forState:UIControlStateNormal];
        [_btnSave addTarget:self action:@selector(onBtnSave:) forControlEvents:UIControlEventTouchUpInside];
        _btnSave.enabled = NO;
    }
    return _btnSave;
}

-(NSArray *)arrayUnit
{
    if(_arrayUnit == nil)
    {
        _arrayUnit = [NSArray arrayWithObjects:@"g",@"ml",@"lb",@"oz", nil];
    }
    return _arrayUnit;
}

-(NSMutableArray *)arraySelectFood
{
    if (_arraySelectFood == nil)
    {
        _arraySelectFood = [[NSMutableArray alloc] init];
    }
    return _arraySelectFood;
}

-(iFreshModel *)freshModel
{
    if(_freshModel == nil)
    {
        _freshModel = [[iFreshModel alloc] init];
    }
    
    return _freshModel;
}

#pragma mark -
#pragma mark ==== Action ====
#pragma mark -

/**
 *  开始连接
 */
-(void)startConnect
{
    [[iFreshSDK shareManager] setbleReturnValueDelegate:self];
    [[iFreshSDK shareManager] bleDoScan];
}

/**
 *  断开连接
 */
-(void)disConnect
{
    if ([iFreshSDK shareManager].isBle_Link == YES) {
        
        [[iFreshSDK shareManager] closeBleAndDisconnect];
    }
    else
    {
        [[iFreshSDK shareManager] stopBleScan];
    }
}

/**
 *  重新连接
 */
-(void)reConnect
{
    if ([iFreshSDK shareManager].isBle_Link == NO)
    {
        [[iFreshSDK shareManager] bleDoScan];
    }
}

/**
 *  添加设备到设备列表
 */
-(void)addToDeviceList
{
    BLEDeviceModel * tempModel = [[BLEDevice_DBController dbController] getBLEDevice:NutritionScale_NAME_PREFIX];
    if (tempModel)
    {
        // 设备已经添加了
        return;
    }
    
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:NutritionScale_NAME_PREFIX,@"name", nil];
    BLEDeviceModel * device = [[BLEDeviceModel alloc] initWithDictionary:dic deviceType:DeviceTypeNutritionScale];
    [[BLEDevice_DBController dbController] insertBLEDevice:device];

    // 更新设备列表
    [TJYHelper sharedTJYHelper].isReloadLocalDevice=YES;
}


/**
 *  更新状态
 */
-(void)updateConnectState:(BOOL)isConnect
{
    self.isConnect = isConnect;
    if (self.isConnect)
    {
        self.lblScaleTip.text = @"请将食物放置秤上";
        self.btnPeeled.userInteractionEnabled = YES;
        self.imgBG.frame = CGRectMake(self.imgBG.left, self.imgBG.top - self.lblState.height, self.imgBG.width, self.imgBG.height);
        self.viewAction.frame = CGRectMake(self.viewAction.left, self.viewAction.top - self.lblState.height, self.viewAction.width, self.viewAction.height);
        self.lblState.frame = CGRectZero;
    }
    else
    {
        self.lblScaleTip.text = @"可手动输入重量";
        self.btnPeeled.userInteractionEnabled = NO;
        if (self.lblState.height !=0)
        {
            return;
        }
        self.lblState.frame = CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, 48.0f);
        self.imgBG.frame = CGRectMake(self.imgBG.left, self.lblState.bottom, self.imgBG.width, self.imgBG.height);
        self.viewAction.frame = CGRectMake(self.viewAction.left, self.imgBG.bottom, self.viewAction.width, self.viewAction.height);
    }
}

-(void)weightChanged:(UITextField *)textField
{
    if (![currentUnit isEqualToString:@"lb"])
    {
        if ([textField.text isEqualToString:@"0"] ||
            [textField.text isEqualToString:@"0.00"])
        {
            self.btnToZero.userInteractionEnabled = NO;
        }
        else
        {
            self.btnToZero.userInteractionEnabled = YES;
        }
    }
    else
    {
        if ([self.txtLBWeight.text isEqualToString:@"0"] &&
            ([self.txtOZWeight.text isEqualToString:@"0"] ||
             [self.txtOZWeight.text isEqualToString:@"0.00"]))
        {
            self.btnToZero.userInteractionEnabled = NO;
        }
        else
        {
            self.btnToZero.userInteractionEnabled = YES;
        }
    }

    
//    // 已经选择了食物，把重量保存起来
//    if (currentFood) {
//        if (![textField.text isEqualToString:@""]) {
//            currentFood.weight = [textField.text floatValue];
//            [self unitConversion:textField.text];
//        }
//    }
}

/**
 *  更新选择食物
 */
-(void)updateDeleteFood:(TJYFoodListModel *)model isDeleteAll:(BOOL)isDeleteAll
{
    if (isDeleteAll)
    {
        // 删除全部
        [self.arraySelectFood removeAllObjects];
    }
    else
    {
        // 删除
        [self.arraySelectFood removeObject:model];
    }
    
    [self updateFoodCount];
}

-(void)updateModifyFood:(TJYFoodListModel *)food
{
    for (TJYFoodListModel * model in self.arraySelectFood) {
        if (model.id == food.id) {
            
        }
    }
    [self updateFoodCount];
}

/**
 *  更新食物名
 */
-(void)updateSelectFood:(TJYFoodListModel *)model
{
    currentFood = model;
//    currentFood.weight = [self.txtWeight.text floatValue];
//    [self unitConversion:self.txtWeight.text];
    [self.btnSelectFood setTitle:model.name forState:UIControlStateNormal];
    self.currentFoodDetail = nil;
    
    [self requestFoodDetail];
}

/**
 *  请求食物详情
 */
-(void)requestFoodDetail
{
    NSString *urlString = [NSString stringWithFormat:@"id=%ld",(long)currentFood.id];

    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postMethodWithURL:kFoodDetail body:urlString success:^(id json) {
        NSDictionary *dic = [json objectForKey:@"result"];
        if (kIsDictionary(dic)) {
            weakSelf.currentFoodDetail = [TJYFoodDetailsModel new];
            [weakSelf.currentFoodDetail setValues:dic];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

/**
 *  更新选择食物数量
 */
-(void)updateFoodCount
{
    if (self.arraySelectFood.count != 0)
    {
        [self.btnFood addBadgeTip:[NSString stringWithFormat:@"%i",(int)self.arraySelectFood.count]];
        self.btnFood.enabled = YES;
        self.btnSave.enabled = YES;
        
        CGFloat totalKcal = 0;
        for (TJYFoodListModel * model in self.arraySelectFood)
        {
            totalKcal = totalKcal + model.totalkcal;
        }
        NSString * strTotalKcal = [NSString stringWithFormat:@"%.0f",totalKcal];
        [self.lblKcal setText:[NSString stringWithFormat:@"共%@千卡",strTotalKcal]afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName
                                            value:(id)UIColorHex(0xff9d38).CGColor
                                            range:NSMakeRange(1, strTotalKcal.length)];
            return mutableAttributedString;
        }];
    }
    else
    {
        [self.btnFood removeBadgeTips];
        self.lblKcal.text = @"";
        self.btnFood.enabled = NO;
        self.btnSave.enabled = NO;
    }
}

/**
 *  处理选择食物，计算出总热量
 */
-(void)handleAddToFood
{
    bool isExist = NO;

    CGFloat proportion = currentFood.weight / 100.0f;
    CGFloat energykcal = proportion * currentFood.energykcal;
    currentFood.totalkcal = energykcal;
    
    for (TJYFoodListModel * model in self.arraySelectFood)
    {
        if (model.id == currentFood.id) {
            isExist = YES;
           
            model.weight = model.weight + currentFood.weight;
            model.totalkcal = model.totalkcal + currentFood.totalkcal;
            break;
        }
    }
    
    if(!isExist)
    {
        [self.arraySelectFood addObject:[currentFood copy]];
    }
}

/**
 *  更新用餐时间
 */
-(void)updateDineDate:(NSString *)strDate
{
    strDineDate = strDate;
    [self.btnDineDate setTitle:strDate forState:UIControlStateNormal];
}

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
    [[BLEDevice_DBController dbController] deleteBLEDevice:NutritionScale_NAME_PREFIX];
    [self.navigationController popViewControllerAnimated:YES];
    // 更新设备列表
    [TJYHelper sharedTJYHelper].isReloadLocalDevice=YES;

}

/**
 *  计算营养成分|加入餐盘，把单位转化为g
 */
-(void)unitConversion
{
    if ([currentUnit isEqualToString:@"g"] ||
        [currentUnit isEqualToString:@"ml"])
    {
        currentFood.weight = [self.txtWeight.text floatValue];
    }
    else if ([currentUnit isEqualToString:@"lb"])
    {
        NSString * strLB = [self.freshModel lbTog:self.txtLBWeight.text];
        NSString * strOZ = [self.freshModel ozTog:self.txtOZWeight.text];
        currentFood.weight  = [strLB floatValue] + [strOZ floatValue];
    }
    else if ([currentUnit isEqualToString:@"oz"])
    {
        currentFood.weight = [[self.freshModel ozTog:self.txtWeight.text] floatValue];
    }
    
    self.currentFoodDetail.weight = currentFood.weight;
}

/**
 *  单位切换，切换视图
 */
-(void)setViewUnit:(NSString *)strUnit
{
    // 切换视图
    if ([strUnit isEqualToString:@"lb"])
    {
        self.viewLB.hidden = NO;
        self.txtWeight.hidden = YES;
    }
    else
    {
        self.viewLB.hidden = YES;
        self.txtWeight.hidden = NO;
    }
    
    if (self.isConnect)
    {
        if([strUnit isEqualToString:@"g"])
        {
            [[iFreshSDK shareManager] insertTheUnit:UNIT_g];
        }
        else if ([strUnit isEqualToString:@"ml"])
        {
            [[iFreshSDK shareManager] insertTheUnit:UNIT_ml];
        }
        else if ([strUnit isEqualToString:@"lb"])
        {
            [[iFreshSDK shareManager] insertTheUnit:UNIT_lb];
        }
        else if ([strUnit isEqualToString:@"oz"])
        {
            [[iFreshSDK shareManager] insertTheUnit:UNIT_oz];
        }
    }
    
    // 数据转换
    NSString * strTemp = @"";

    if ([currentUnit isEqualToString:@"g"] ||
        [currentUnit isEqualToString:@"ml"])
    {
        if([strUnit isEqualToString:@"lb"])
        {
            strTemp = [self.freshModel gTolb:self.txtWeight.text];
            if ([strTemp containsString:@":"]) {
                NSArray * array = [strTemp componentsSeparatedByString:@":"];
                self.txtLBWeight.text = array[0];
                CGFloat oz = [array[1] floatValue];
                self.txtOZWeight.text = [NSString stringWithFormat:@"%.2f",oz];
            }
        }
        else if ([strUnit isEqualToString:@"oz"])
        {
            CGFloat oz = [[self.freshModel gTooz:self.txtWeight.text] floatValue];
            self.txtWeight.text = [NSString stringWithFormat:@"%.2f",oz];
        }
    }
    else if ([currentUnit isEqualToString:@"lb"])
    {
        if([strUnit isEqualToString:@"g"] ||
           [strUnit isEqualToString:@"ml"])
        {
            strTemp = [self.freshModel lbTog:self.txtLBWeight.text];
            NSString * strOZ = [self.freshModel ozTog:self.txtOZWeight.text];
            NSInteger num = [strTemp floatValue] + [strOZ floatValue];
            self.txtWeight.text = [NSString stringWithFormat:@"%ld",(long)num];;
        }
        else if ([strUnit isEqualToString:@"oz"])
        {
            strTemp = [self.freshModel lbTog:self.txtLBWeight.text];
            NSString * strOZ = [self.freshModel ozTog:self.txtOZWeight.text];
            NSInteger num = [strTemp floatValue] + [strOZ floatValue];
            CGFloat oz = [[self.freshModel gTooz:[NSString stringWithFormat:@"%ld",(long)num]] floatValue];
            self.txtWeight.text = [NSString stringWithFormat:@"%.2f",oz];
        }
    }
    else if ([currentUnit isEqualToString:@"oz"])
    {
        if([strUnit isEqualToString:@"g"] ||
           [strUnit isEqualToString:@"ml"])
        {
            self.txtWeight.text = [self.freshModel ozTog:self.txtWeight.text];
        }
        else if ([strUnit isEqualToString:@"lb"])
        {
            strTemp = [self.freshModel ozTog:self.txtWeight.text];
            strTemp = [self.freshModel gTolb:strTemp];
            if ([strTemp containsString:@":"]) {
                NSArray * array = [strTemp componentsSeparatedByString:@":"];
                self.txtLBWeight.text = array[0];
                CGFloat oz = [array[1] floatValue];
                self.txtOZWeight.text = [NSString stringWithFormat:@"%.2f",oz];
            }
        }
        }
    
    
    currentUnit = strUnit;
    self.lblUnit.text = [NSString stringWithFormat:@"重量(%@)",currentUnit];

}

#pragma mark -
#pragma mark ==== BleReturnValueDelegate ====
#pragma mark -

/**
 *  返回链接状态
 */
- (void)bleStatusupdate:(GN_BleStatus)bleStatus {
    
    if ( bleStatus == bleOpen  ||
        bleStatus == bleBreak)
    {
        [self updateConnectState:NO];
        self.lblState.hidden = NO;
        if([BTManager isBLEEnable])
        {
            self.lblState.text = @"正在连接营养秤";
        }
        else
        {
            self.lblState.text = @"蓝牙未开启";
        }
    }
    else if (bleStatus == bleOff)
    {
        [self updateConnectState:NO];
        self.lblState.hidden = NO;
        self.lblState.text = @"蓝牙未开启";
    }
    else if (bleStatus == bleConnect)
    {
        self.lblState.text = @"蓝牙已连接";
        [self addToDeviceList];
        
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5),dispatch_get_main_queue(), ^(){
            weakSelf.lblState.hidden = YES;
            [weakSelf updateConnectState:YES];
        });
    }
}

/**
 *  返回称量重量
 */
- (void)bleReturnValueModel:(iFreshModel *)globalBLEmodel
{
    MyLog(@"unit:%@,weight:%@",currentUnit,globalBLEmodel.value);
    
    if([currentUnit isEqualToString:@"lb"])
    { 
        if ([globalBLEmodel.value containsString:@":"]) {
            NSArray * array = [globalBLEmodel.value componentsSeparatedByString:@":"];
            self.txtLBWeight.text = array[0];
            self.txtOZWeight.text = array[1];
        }
    }
    else
    {
        self.txtWeight.text = globalBLEmodel.value;
    }
    [self weightChanged:self.txtWeight];
}

/**
 *  返回称量的单位
 */
- (void)changeUnitWithBle:(GN_UnitEnum)unitChange
{
    NSString * strUnit = @"";
    if (unitChange == UNIT_g)
    {
        strUnit = self.arrayUnit[0];
    }
    else if (unitChange == UNIT_ml)
    {
        strUnit = self.arrayUnit[1];
    }
    else if (unitChange == UNIT_lb)
    {
        strUnit = self.arrayUnit[2];
    }
    else if (unitChange == UNIT_oz)
    {
        strUnit = self.arrayUnit[3];
    }
    
    // 切换视图
    if ([strUnit isEqualToString:@"lb"])
    {
        self.viewLB.hidden = NO;
        self.txtWeight.hidden = YES;
    }
    else
    {
        self.viewLB.hidden = YES;
        self.txtWeight.hidden = NO;
    }
    
    currentUnit = strUnit;
    self.lblUnit.text = [NSString stringWithFormat:@"重量(%@)",currentUnit];}

#pragma mark -
#pragma mark ==== onBtnAction ====
#pragma mark -

/**
 *  选择食物
 */
-(void)onBtnSelectFood:(id)sender
{
    [self.view endEditing:YES];

    isNoDisConnect = YES;
    TJYFoodLibraryVC * foodLibraryVC = [[TJYFoodLibraryVC alloc] init];
    foodLibraryVC.orderbyStr = @"id";
    foodLibraryVC.isFromNutritionScale = YES;
    foodLibraryVC.strTitle = currentFood != nil ? currentFood.name : @"选择食物";
    foodLibraryVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:foodLibraryVC animated:YES];
    
    __weak typeof(self) weakSelf = self;
    foodLibraryVC.selectBlock = ^(TJYFoodListModel * model){
        [weakSelf updateSelectFood:model];
    };
}

/**
 *  去皮
 */
-(void)onBtnPeeled:(id)sender
{
    [self.view endEditing:YES];

    if (self.isConnect) {
        [[iFreshSDK shareManager] zeroWriteBle];
    }
}

/**
 *  归零
 */
-(void)onBtnToZero:(id)sender
{
    [self.view endEditing:YES];

    if ([currentUnit isEqualToString:@"lb"])
    {
        if (kIsEmptyString(self.txtLBWeight.text) ||
            kIsEmptyString(self.txtOZWeight.text)){
            return;
        }

        if ([self.txtLBWeight.text isEqualToString:@"0"] &&
            ([self.txtOZWeight.text isEqualToString:@"0.00"] ||
            [self.txtOZWeight.text isEqualToString:@"0"]))
        {
            return;
        }
        
        self.txtLBWeight.text = @"0";
        self.txtOZWeight.text = @"0.00";
        [self weightChanged:self.txtWeight];
    }
    else
    {
        if ([self.txtWeight.text isEqualToString:@"0"] ||
            [self.txtWeight.text isEqualToString:@"0.00"])
        {
            return;
        }
        if (![currentUnit isEqualToString:@"oz"])
        {
            self.txtWeight.text = @"0";
        }
        else
        {
            self.txtWeight.text = @"0.00";
        }
        
        [self weightChanged:self.txtWeight];
    }
    
    // 归零为了快一点获取到更新值，结果太快了，延迟2s
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*1.5),dispatch_get_main_queue(), ^(){
        if (self.isConnect)
        {
            if([currentUnit isEqualToString:@"g"])
            {
                [[iFreshSDK shareManager] insertTheUnit:UNIT_g];
            }
            else if ([currentUnit isEqualToString:@"ml"])
            {
                [[iFreshSDK shareManager] insertTheUnit:UNIT_ml];
            }
            else if ([currentUnit isEqualToString:@"lb"])
            {
                [[iFreshSDK shareManager] insertTheUnit:UNIT_lb];
            }
            else if ([currentUnit isEqualToString:@"oz"])
            {
                [[iFreshSDK shareManager] insertTheUnit:UNIT_oz];
            }
        }
    });

}

/**
 *  选择用餐时间
 */
-(void)onbtnDineDate:(id)sender
{
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    DiningDatePickerView  * datePickerView=[[DiningDatePickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) value:strDineDate title:@"" dateBlock:^(NSString *strDate) {
        [weakSelf updateDineDate:strDate];
    }];
    [datePickerView datePickerViewShowInView:self.view];
}

/**
 *  营养含量
 */
-(void)onBtnNutrition:(id)sender
{
    [self.view endEditing:YES];
    if(currentFood == nil)
    {
        [self.view makeToast:@"请先选择食物" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    [self unitConversion];
    NutritionDetailView * nutritionView = [[NutritionDetailView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [nutritionView nutritionDetailShowInView:self.view];
    [nutritionView renderNutritionDetail:self.currentFoodDetail];
}

/**
 *  加入餐盘
 */
-(void)onBtnAddFood:(id)sender
{
    [self.view endEditing:YES];
    [self unitConversion];
    if(currentFood == nil)
    {
        [self.view makeToast:@"请先选择食物" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    if (currentFood.weight <= 0) {
        [self.view makeToast:@"食物重量为0，不可加入餐盘" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    UIButton * btn = (UIButton *)sender;
    CGRect rc = [self.view convertRect:btn.frame fromView:self.viewAction];
    CGPoint startPoint = CGPointMake(rc.origin.x + btn.width/2,rc.origin.y + btn.height/2);
    CGPoint endPoint = CGPointMake(self.btnFood.center.x, self.btnFood.top + self.btnFood.superview.top);
    __weak typeof(self) weakSelf = self;
    [ShoppingCartTool addToShoppingCartWithGoodsImage:[UIImage imageNamed:@"green_food.png"] startPoint:startPoint endPoint:endPoint completion:^(BOOL finished) {
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        scaleAnimation.toValue = [NSNumber numberWithFloat:0.7];
        scaleAnimation.duration = 0.1;
        scaleAnimation.repeatCount = 2; // 颤抖两次
        scaleAnimation.autoreverses = YES;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [weakSelf.btnFood.layer addAnimation:scaleAnimation forKey:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleAddToFood];
            [weakSelf updateFoodCount];
        });
    }];
}

/**
 *  食物
 */
-(void)onBtnFood:(id)sender
{
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    FoodSelecedView * foodSelectedView = [[FoodSelecedView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [foodSelectedView foodSelecedShowInView:self.view withArray:self.arraySelectFood foodSelecedBlock:^(TJYFoodListModel *food, BOOL isDeleteAll) {
        [weakSelf updateDeleteFood:food isDeleteAll:isDeleteAll];
    }];
    foodSelectedView.modifyBlock = ^(TJYFoodListModel * model){
        [weakSelf updateModifyFood:model];
    };
    foodSelectedView.selectToBlock = ^(FoodSelectToType type,FoodAddModel * model){
      
        if (type == FoodSelectToTypeDetail) {
            // 详情
            [weakSelf goToFoodDetail:model];
        }
        else if(type == FoodSelectToTypeEstimate){
            // 估算
            [weakSelf goToEstimateVc];
        }
    };
}

/**
 *  保存
 */
-(void)onBtnSave:(id)sender
{
    [self.view endEditing:YES];
    if(self.arraySelectFood.count == 0)
    {
        return;
    }
    

    NSMutableArray * tempArr=[[NSMutableArray alloc] init];
    for (TJYFoodListModel * model in self.arraySelectFood) {
 
        NSDictionary *dict=[[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:model.id],[NSNumber numberWithInteger:model.weight],[NSNumber numberWithInteger:model.totalkcal],@"1"] forKeys:@[@"item_id",@"item_weight",@"item_calories",@"type"]];
        [tempArr addObject:dict];
        
    }
    NSString * strDate;
    NSString * strdietType;
    if (![strDineDate isEqualToString:@""])
    {
        NSArray * array = [strDineDate componentsSeparatedByString:@" "];
        strDate = array[0];
        strdietType = array[1];
    }
    NSString *jsonStr=[[NetworkTool sharedNetworkTool] getValueWithParams:tempArr]; //数组转json
    NSInteger timeSp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:strDate format:@"yyyy-MM-dd"];
    NSString *period=[[TJYHelper sharedTJYHelper] getDietPeriodEnNameWithPeriod:strdietType];

    NSString *body=nil;
    NSString *url=nil;
    
    
    if (tempArr.count>0) {
 
        body=[NSString stringWithFormat:@"doSubmit=1&time_slot=%@&feeding_time=%ld&item=%@",period,(long)timeSp,jsonStr];
        url=kDietRecordAdd;
        kSelfWeak;
        [[NetworkTool sharedNetworkTool] postMethodWithURL:url body:body success:^(id json) {
            [TJYHelper sharedTJYHelper].isDietReload=YES;
            [TJYHelper sharedTJYHelper].isRecordDietReload=YES;
            
            [weakSelf.view makeToast:@"餐盘保存成功" duration:1.0 position:CSToastPositionCenter];
            [weakSelf updateDeleteFood:nil isDeleteAll:YES];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
        
    } else {
        [self.view makeToast:@"请添加食物" duration:1.0 position:CSToastPositionCenter];
        
    }
}

-(void)rightButtonAction
{
    [self.view endEditing:YES];
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *deleteButtonTitle = NSLocalizedString(@"删除", nil);
    NSString *unitButtonTitle = NSLocalizedString(@"计量单位", nil);

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [weakSelf showDeleteAlertController];
    }];
    
    UIAlertAction * unitAction = [UIAlertAction actionWithTitle:unitButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [weakSelf goToUnitVc];
    }];
    
    [alertController addAction:unitAction];
    BLEDeviceModel * tempModel = [[BLEDevice_DBController dbController] getBLEDevice:NutritionScale_NAME_PREFIX];
    if (tempModel)
    {
        // 已经添加过设备，可删除
        [alertController addAction:deleteAction];
    }
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark -
#pragma mark ==== 页面跳转 ====
#pragma mark -

// 跳转选择单位
-(void)goToUnitVc
{
    isNoDisConnect = YES;
    __weak typeof(self) weakSekf = self;
    UnitSelectViewController * vc = [[UnitSelectViewController alloc] init];
    vc.strUnit = currentUnit;
    [self.navigationController pushViewController:vc animated:YES];
    vc.unitSelcetBlock = ^(NSString * strUnit){
        [weakSekf setViewUnit:strUnit];
    };
}

/**
 *   跳转估算页面
 */
-(void)goToEstimateVc
{
    isNoDisConnect = YES;
    EstimateWeightViewController *estimateWeightVC = [[EstimateWeightViewController alloc] init];
    [self.navigationController pushViewController:estimateWeightVC animated:YES];
}

/**
 *   跳转食物详情页面
 */
-(void)goToFoodDetail:(FoodAddModel *)model
{
    isNoDisConnect = YES;
    TJYFoodDetailsVC *foodDetailsVC = [TJYFoodDetailsVC  new];
    foodDetailsVC.food_id = model.id;
    [self push:foodDetailsVC];
}



@end
