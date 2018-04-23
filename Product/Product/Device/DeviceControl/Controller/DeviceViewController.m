//
//  DeviceViewController.m
//  Product
//
//  Created by Xlink on 15/12/1.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "DeviceViewController.h"
#import "MainDeviceListCell.h"
#import "DeviceModel.h"
#import "DeviceFunctionViewController.h"
#import "DeviceProgressViewController.h"
#import "MainScaleListCell.h"
#import "ScaleViewController.h"
#import "Product-swift.h"
#import "AutoLoginManager.h"
#import "AddDeviceTypeViewController.h"
#import "HorizontalFlowLayout.h"
#import "DeviceCollectionViewCell.h"
#import "ScaleViewController.h"
#import "ScalePersonInfoViewController.h"
#import "DeviceGuideViewController.h"
#import "DeviceConnectStateCheckService.h"
#import "MineSceneViewController.h"
#import "StorageCabinetViewController.h"
#import "YBPopupMenu.h"
#import "NutritionScaleViewController.h"
#import "BLEDevice_DBController.h"
#import "NewPagedFlowView.h"
#import "PGIndexBannerSubiew.h"
#import "MYCoreTextLabel.h"

@interface DeviceViewController ()<YBPopupMenuDelegate,NewPagedFlowViewDelegate,NewPagedFlowViewDataSource,MYCoreTextLabelDelegate>{
    UICollectionView *deviceCollectionView;
    UILabel          *deviceNameLabel;

    
    NSMutableArray   *deviceModelArr;//云端列表，显示列表
    NSArray          *recommandDeviceArray;
    UIButton         *rightBtn;
    UILabel          *deviceLabel;
    
    DeviceModel      *selDeviceModel;
    
    
}
@property (nonatomic,strong)NSArray * arrayLocalDevice;

@property (nonatomic,strong)UIView           *recommandDeviceView;
/// 图片轮播
@property (nonatomic ,strong) NewPagedFlowView *pagedFlowView;
@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"设备";

    self.isHiddenBackBtn=YES;
    self.view.backgroundColor = [UIColor bgColor_Gray];

    recommandDeviceArray=[TJYHelper sharedTJYHelper].recommandDeviceArr;
    deviceModelArr=[[NSMutableArray alloc] init];
 
    [self initDeviceMainView];
    
    if ([AutoLoginManager shareManager].hasLogin&&kIsLogined) {
        [[AutoLoginManager shareManager] startAutoLogin];
    }
    [self getDeviceInfo];
    [self getArrayLocalDeviceInfo];

}

-(NSArray *)arrayLocalDevice
{
    if (_arrayLocalDevice == nil) {
        _arrayLocalDevice = [[NSArray alloc] init];
    }
    return _arrayLocalDevice;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceInfo) name:kDeviceViewUpdateUI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceInfo) name:kOnManagerDeviceStateChange object:nil];

    if ([TJYHelper sharedTJYHelper].isReloadDeviceList) {
        [[AutoLoginManager shareManager] startAutoLogin];
        [self getDeviceInfo];
        [TJYHelper sharedTJYHelper].isReloadDeviceList=NO;
    }
    
    /**
     *  更新用户本地设备
     */
    if ([TJYHelper sharedTJYHelper].isReloadLocalDevice) {
        [self getArrayLocalDeviceInfo];
        [TJYHelper sharedTJYHelper].isReloadLocalDevice=NO;
    }
    
    [[AutoLoginManager shareManager] addNoti];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006" type:2];
#endif
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeviceViewUpdateUI object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnManagerDeviceStateChange object:nil];
    
    [[AutoLoginManager shareManager] removeNoti];
}

#pragma mark--TableView  Delegate and Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    if (section == 0)
    {
        count =  deviceModelArr.count;
    }
    else if (section == 1)
    {
        count =  self.arrayLocalDevice.count;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceModel *model;
    
    if (indexPath.section == 0) {
        model=[deviceModelArr objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1)
    {
        model = (BLEDeviceModel *)self.arrayLocalDevice[indexPath.row];
    }
    switch (model.deviceType) {
        case DeviceTypeScale:     //秤
        case DeviceTypeThermometer: //体温计
        case DeviceTypeBPMeter: //血压计
        case DeviceTypeNutritionScale: //营养秤
        {
            BLEDeviceModel *meterDevice = (BLEDeviceModel *)model;
            static NSString *CellIdentifier = @"MainScaleListCell";
            MainScaleListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.deviceTypeIV.image = [meterDevice tableViewIconImage];
            cell.deviceNameLbl.text = meterDevice.deviceName;
            
            cell.deviceUUIDLbl.text = meterDevice.BLEMacAddress;
            if (indexPath.row==deviceModelArr.count-1 && self.arrayLocalDevice.count == 0) {
                cell.lineLbl.hidden=YES;
            }else{
                cell.lineLbl.hidden=NO;
            }
            return cell;
        }
        default:
        {
            static NSString *CellIdentifier = @"MainDeviceListCell";
            MainDeviceListCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.deviceTypeIV.image = [model tableViewIconImage];
            cell.deviceNameLbl.text = model.deviceName;
            if (model.isOnline) {
                [cell.deviceStateIV setImage:[UIImage imageNamed:@"在线icon"]];
                cell.deviceStateLbl.text=@"设备在线";
            }else{
                [cell.deviceStateIV setImage:[UIImage imageNamed:@"离线icon"]];
                cell.deviceStateLbl.text=@"设备离线";
            }
            [cell.deviceNameLbl sizeToFit];
            
            cell.deviceStateIV.frame = CGRectMake(CGRectGetMaxX(cell.deviceNameLbl.frame), cell.deviceStateIV.frame.origin.y, cell.deviceStateIV.frame.size.width, cell.deviceStateIV.frame.size.height);
            if (model.deviceType == COOKFOOD_KETTLE) {
                if ([NSString isPureInt:[model.State objectForKey:@"state"]]) {
                    if ([[model.State objectForKey:@"state"] isEqualToString:@"0"]){
                        cell.deviceProgressLbl.text=@"一键烹饪";
                    }else {
                        NSArray *foodArray = [[NSArray alloc] initWithObjects:@"三杯鸡",@"黄焖鸡",@"红烧鱼",@"红焖排骨",@"清炖鸡",@"老火汤",@"红烧肉",@"东坡肘子",@"口水鸡",@"滑香鸡",@"茄子煲",@"梅菜扣肉", nil];
                        NSString *str =[model.State objectForKey:@"state"];
                        cell.deviceProgressLbl.text=foodArray[[str intValue]-2];
                    }
                }else{
                    cell.deviceProgressLbl.text=[[model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]?[model.State objectForKey:@"name"]:[model.State objectForKey:@"state"];
                }
            } else {
                cell.deviceProgressLbl.text=[[model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]?[model.State objectForKey:@"name"]:[model.State objectForKey:@"state"];
                
            }
            //根据title的文字长度确认状态deviceStateIV的位置
            [cell.deviceNameLbl setNumberOfLines:0];  //必须是这组值
//            cell.deviceNameLbl.backgroundColor = [UIColor blueColor];
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],};
        
            CGSize textSize = [cell.deviceNameLbl.text boundingRectWithSize:CGSizeMake(130, 100) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;;
            cell.deviceNameLbl.frame = CGRectMake(cell.deviceNameLbl.frame.origin.x, cell.deviceNameLbl.frame.origin.y, textSize.width, textSize.height);
            cell.deviceStateIV.frame=CGRectMake(cell.deviceNameLbl.frame.origin.x+cell.deviceNameLbl.frame.size.width+5, cell.deviceNameLbl.top - 2, cell.deviceStateIV.frame.size.width, cell.deviceStateIV.frame.size.height);
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            if (indexPath.row==deviceModelArr.count-1 && self.arrayLocalDevice.count == 0) {
                cell.lineLbl.hidden=YES;
            }else{
                cell.lineLbl.hidden=NO;
            }
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceModel *model;
    
    if (indexPath.section == 0) {
        model=[deviceModelArr objectAtIndex:indexPath.row];
        NSString *aName=[NSUserDefaultInfos getValueforKey:[model.mac stringByAppendingString:@"name"]];
        model.deviceName=kIsEmptyString(aName)?model.deviceName:aName;
        selDeviceModel=model;
    }
    else if (indexPath.section == 1)
    {
        model = (BLEDeviceModel *)self.arrayLocalDevice[indexPath.row];
    }
    
    if (kIsLogined&&[AutoLoginManager shareManager].hasLogin) {
        switch (model.deviceType) {
            case DeviceTypeScale:
            {
                [self performSegueWithIdentifier:@"ToScaleView" sender:nil];
            }
                break;
            case DeviceTypeBPMeter:
            {
                [self performSegueWithIdentifier:@"showBPMeter" sender:model];
            }
                break;
            case DeviceTypeThermometer:
            {
                [self performSegueWithIdentifier:@"showThermometer" sender:model];
            }
                break;
            case DeviceTypeCaninets:
            {
                StorageCabinetViewController *storageCabinetsVC=[[StorageCabinetViewController alloc] init];
                storageCabinetsVC.hidesBottomBarWhenPushed=YES;
                storageCabinetsVC.storageDevice=model;
                [self.navigationController pushViewController:storageCabinetsVC animated:YES];
            }
                break;
            case DeviceTypeNutritionScale:
            {
                /**
                 营养秤
                 */
                NutritionScaleViewController * nutritionScaleVC = [[NutritionScaleViewController alloc] init];
                nutritionScaleVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:nutritionScaleVC animated:YES];
            }
                break;
            default:
            {
                if ([[model.State objectForKey:@"state"]isEqualToString:@"在线"]||[[model.State objectForKey:@"state"]isEqualToString:@"离线"]||[[model.State objectForKey:@"state"]isEqualToString:@"空闲"]) {
                    [self performSegueWithIdentifier:@"toFunctionView" sender:nil];
                }else{
                    [self performSegueWithIdentifier:@"toProgressView" sender:nil];
                }
                break;
            }
        }
    }else{
        [self pushToFastLogin];
    }
}
#pragma mark ====== NewPagedFlowViewDelegate =======

- (CGSize)sizeForPageInFlowView:(NewPagedFlowView *)flowView{
    return CGSizeMake(kScreenWidth/3, kScreenWidth/3);
}
- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex {
    MyLog(@"点击了第%ld张图",(long)subIndex + 1);
    DeviceGuideViewController *deviceGuideVC=[[DeviceGuideViewController alloc] init];
    deviceGuideVC.deviceDict=recommandDeviceArray[subIndex];
    deviceGuideVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:deviceGuideVC animated:YES];
}
#pragma mark ====== NewPagedFlowViewDataSource =======

- (NSInteger)numberOfPagesInFlowView:(NewPagedFlowView *)flowView {
    return recommandDeviceArray.count;
}
- (UIView *)flowView:(NewPagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    
    PGIndexBannerSubiew *bannerView = (PGIndexBannerSubiew *)[flowView dequeueReusableCell];
    if (!bannerView) {
        bannerView = [[PGIndexBannerSubiew alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth * 9 / 16)];
        bannerView.tag = index;
    }
        //在这里下载网络图片
    NSDictionary *dict=recommandDeviceArray[index];
    bannerView.mainImageView.image = [UIImage imageNamed:dict[@"image"]];
    bannerView.contentView.backgroundColor = [UIColor clearColor];
    return bannerView;
}
- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(NewPagedFlowView *)flowView {
    deviceNameLabel.text=recommandDeviceArray[pageNumber][@"name"];

}

#pragma mark - YBPopupMenuDelegate
- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu
{
    if(kIsLogined&&[AutoLoginManager shareManager].hasLogin){
        if (index== 0) {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-03"];
#endif
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AddDeviceTypeViewController"];
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-04"];
#endif
            MineSceneViewController *mineSceneVC = [[MineSceneViewController alloc] init];
            mineSceneVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mineSceneVC animated:YES];
        }
    }else{
        [self pushToFastLogin];
    }
}
#pragma mark -- MYCoreTextLabelDelegate
- (void)linkText:(NSString *)clickString type:(MYLinkType)linkType tag:(NSInteger)tag{
     if(kIsLogined&&[AutoLoginManager shareManager].hasLogin){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AddDeviceTypeViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
     }else{
         [self pushToFastLogin];
     }
}
#pragma mark --跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toFunctionView"]) {
        DeviceFunctionViewController *functionVC=[segue destinationViewController];
        functionVC.model=selDeviceModel;
    }else if ([segue.identifier isEqualToString:@"toProgressView"]) {
        DeviceProgressViewController *progressVC=[segue destinationViewController];
        progressVC.model=selDeviceModel;
    }else if ([segue.identifier isEqualToString:@"showBPMeter"]) {
        BPMeterViewController *vc = [segue destinationViewController];
        vc.bpmeterDevice = (BPMeterModel *)sender;
    }else if ([segue.identifier isEqualToString:@"showThermometer"]) {
        ThermometerViewController *vc = [segue destinationViewController];
        vc.tempDevice = (ThermometerModel *)sender;
    }
}

#pragma mark --Custom Methods
-(void)getAddDeviceListAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-01-02"];
#endif
    
    [YBPopupMenu showRelyOnView:rightBtn titles:@[@"添加设备",@"添加场景"] icons:nil menuWidth:120 otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.priorityDirection = YBPopupMenuPriorityDirectionTop;
        popupMenu.borderWidth = 0.5;
        popupMenu.borderColor = UIColorHex(0xeeeeeee);
        popupMenu.delegate = self;
        popupMenu.textColor = UIColorHex(0x626262);
        popupMenu.fontSize = 14;
    }];
}

#pragma mark 刷新设备列表
-(void)loadNewDeviceData{
    [[AutoLoginManager shareManager] getDeviceList];
    [DeviceTB.mj_header endRefreshing];
}

#pragma mark 获取设备列表信息
-(void)getDeviceInfo{
    
    deviceModelArr=[AutoLoginManager shareManager].deviceModelArr;
    MyLog(@"device--count:%ld",deviceModelArr.count);
    
    kSelfWeak;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [DeviceTB reloadData];
            if (deviceModelArr.count>0 || self.arrayLocalDevice.count >0) {
                DeviceTB.hidden=NO;
                weakSelf.recommandDeviceView.hidden=YES;
            }else{
                DeviceTB.hidden=YES;
                weakSelf.recommandDeviceView.hidden=NO;
            }
        });
    });
}

-(void)getArrayLocalDeviceInfo
{
    self.arrayLocalDevice = [[BLEDevice_DBController dbController] getAllBLEDevice];
    kSelfWeak;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [DeviceTB reloadData];
            if (deviceModelArr.count>0 || self.arrayLocalDevice.count >0) {
                DeviceTB.hidden=NO;
                weakSelf.recommandDeviceView.hidden=YES;
            }else{
                DeviceTB.hidden=YES;
                weakSelf.recommandDeviceView.hidden=NO;
            }
        });
    });
}

#pragma mark 初始化界面
-(void)initDeviceMainView{
    rightBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, 20, 30, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"ic_top_add"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(getAddDeviceListAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    DeviceTB.tableFooterView=[[UIView alloc] init];
    DeviceTB.bounces=YES;
    
    //  下拉加载最新
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDeviceData)];
    header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
    DeviceTB.mj_header=header;
    
    [rootScrollView addSubview:self.recommandDeviceView];
    self.recommandDeviceView.hidden=YES;
}

#pragma mark 推荐设备
-(UIView *)recommandDeviceView{
    if (!_recommandDeviceView) {
        _recommandDeviceView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kRootViewHeight-kTabbarHeight)];
        
        
        UIImageView *bgImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth/3+80)];
        bgImageView.image=[UIImage imageNamed:@"equ_bg"];
        [_recommandDeviceView addSubview:bgImageView];
        
        [_recommandDeviceView addSubview:self.pagedFlowView];
        
        //设备名称
        deviceNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, self.pagedFlowView.bottom, kScreenWidth, 40)];
        deviceNameLabel.textAlignment=NSTextAlignmentCenter;
        deviceNameLabel.textColor=[UIColor whiteColor];
        deviceNameLabel.backgroundColor = [UIColor clearColor];
        deviceNameLabel.font=[UIFont systemFontOfSize:18];
         deviceNameLabel.text = @"云智能隔水炖16AIG";
        [bgImageView addSubview:deviceNameLabel];
        
        UIImageView  *blankImgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-70)/2, bgImageView.bottom+(_recommandDeviceView.height-bgImageView.height)/2-65, 70, 70)];
        blankImgView.image=[UIImage imageNamed:@"ic_s_equip_none"];
        [_recommandDeviceView addSubview:blankImgView];
        
        
        MYCoreTextLabel *addLab = [[MYCoreTextLabel alloc] initWithFrame:CGRectMake(30, blankImgView.bottom+7, kScreenWidth-60, 30)];
        addLab.lineSpacing = 1.5;
        addLab.wordSpacing = 0.5;
        //设置普通文本的属性
        addLab.textFont = [UIFont systemFontOfSize:13.f];   //设置普通内容文字大小
        addLab.textColor = [UIColor colorWithHexString:@"#959595"];   // 设置普通内容文字颜色
        addLab.delegate = self;   //设置代理 , 用于监听点击事件 以及接收点击内容等
        //设置关键字的属性
        addLab.customLinkFont = [UIFont systemFontOfSize:13];
        addLab.customLinkColor = [UIColor colorWithHexString:@"#ff9d38"];  //设置关键字颜色
        addLab.customLinkBackColor = [UIColor colorWithHexString:@"#ff9d38"];  //设置关键字高亮背景色
        
        [addLab setText:@"期待添加您的第一款设备" customLinks:@[@"添加"] keywords:@[]];
        CGSize size = [addLab sizeThatFits:CGSizeMake(kScreenWidth, [UIScreen mainScreen].bounds.size.height)];
        addLab.frame =CGRectMake((kScreenWidth-size.width)/2, blankImgView.bottom+7, size.width, 30);
        [_recommandDeviceView addSubview:addLab];

        [self.pagedFlowView reloadData];
    }
    return _recommandDeviceView;
}

#pragma mark ====== 图片轮播 =======
- (NewPagedFlowView *)pagedFlowView{
    if (!_pagedFlowView) {
        _pagedFlowView = [[NewPagedFlowView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,kScreenWidth/3+20)];
        _pagedFlowView.delegate = self;
        _pagedFlowView.dataSource = self;
        _pagedFlowView.backgroundColor = [UIColor clearColor];
        _pagedFlowView.minimumPageAlpha = 0.01;
        _pagedFlowView.isCarousel = YES;
        _pagedFlowView.leftRightMargin = 38;
        _pagedFlowView.topBottomMargin = 38;
        _pagedFlowView.autoTime = 4.0f;
        _pagedFlowView.orientation = NewPagedFlowViewOrientationHorizontal;
        _pagedFlowView.isOpenAutoScroll = YES;
    }
    return _pagedFlowView;
}
#pragma mark ====== dealloc =======

- (void)dealloc{
    // 不停止退出登录会闪退
    [self.pagedFlowView stopTimer];
}
@end
