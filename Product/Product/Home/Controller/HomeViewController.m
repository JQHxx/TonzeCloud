//
//  HomeViewController.m
//  Product
//
//  Created by vision on 17/4/13.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "HomeViewController.h"
#import "HerderClassifyButton.h"
#import "TJYFoodLibraryVC.h"
#import "TJYNutritionEncyclopediaVC.h"
#import "TJYHealthAssessmentVC.h"
#import "TJYMenuVC.h"
#import "TJYSportsRecommendationVC.h"
#import "TJYSportsRecommendationCell.h"
#import "TJYFoodRecommendMenuView.h"
#import "TJYFoodRecommendCell.h"
#import "TJYRecommendedDietVC.h"
#import "TJYBannerModel.h"
#import "TJYFoodDetailsVC.h"
#import "BasewebViewController.h"
#import "TJYHealthTargetModel.h"
#import "TJYFoodRecommendModel.h"
#import "TJYRecommendMotionModel.h"
#import "SDCycleScrollView.h"
#import "TJYFoodDetailsVC.h"
#import "TJYMenuDetailsVC.h"
#import "TJYRecommendView.h"
#import "TJYHealthGoalsTipView.h"
#import "TCUserTool.h"
#import "TCBannerModel.h"
#import "SSKeychain.h"
#import "UIViewController+Nav.h"
#import "HeziSDK.h"
#import "ActionSheetView.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>
#import "TJYArticleTableViewCell.h"
#import "DietIsRecommendedCell.h"
#import "TJYArticleTitleView.h"
#import "TJYEfficacyPickerView.h"
#import "TJYArticleclassModel.h"
#import "TargetModel.h"


@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource,TJYFoodRecommendMenuViewDelegate,SDCycleScrollViewDelegate,TCHwpopDelegate,HeziTriggerActivePageDelegate,DietIsRecommendedCellDelegate,TJYArticleMenuViewDelegate>
{
    NSInteger           _menuSelectIndex;       // 菜谱选中
    NSInteger           _articleSelectIndex;    // 文章选中
    NSArray             *_menuTitleArr;         // 菜谱推荐分类
    NSInteger           _articleListPage;       // 文章分页page
    NSMutableDictionary *_healthGoalsDic;
    TJYBannerModel      *announceBanner;
    BOOL                _isFirstPop;            // 公告栏第一次弹出
    NSString            *_healthTargetString;   // 功效类型
    BOOL                _isMenuReload;         // 推荐菜谱刷新
}
@property (nonatomic ,strong) UITableView *tableView;
/// 时间选择滑动框（早，中，晚）
@property (nonatomic ,strong) TJYFoodRecommendMenuView *menuView;
/// 营养百科菜单栏
@property (nonatomic ,strong)  TJYArticleTitleView *articlemenuView;
/// 营养百科导航栏停靠
@property (nonatomic ,strong)  TJYArticleTitleView *articleMenuNavView;
/// banner 视图
@property (nonatomic,strong)  SDCycleScrollView  *cycleScrollView;
/// banner数据数组
@property (nonatomic ,strong) NSMutableArray *bannersArray;
/// 食疗推荐模型
@property (nonatomic ,strong) TJYHealthTargetModel *healthTargetModel;
/// 推荐菜谱数据
@property (nonatomic ,strong) NSMutableArray *recommendDietData;
/// 推荐菜谱当前选中时间分组数据
@property (nonatomic ,strong) NSMutableArray *recommendDietDataSource;
/// 文章分类标题数据
@property (nonatomic ,strong) NSMutableArray *articleClassificationTitleArray;
/// 文章分类ID
@property (nonatomic ,strong) NSMutableArray *articleClassificationIdArray;
/// 文章列表数据
@property (nonatomic ,strong) NSMutableArray *articleListDateArray;
/// 健康目标标题数据
@property (nonatomic ,strong) NSMutableArray *healthGoalTitleArray;
/// 健康目标ID
@property (nonatomic ,strong) NSMutableArray *healthGoalIdArray;
/// 健康目标描述
@property (nonatomic ,strong) NSMutableArray *targetDescriptionArray;
/// 无数据视图
@property (nonatomic ,strong) BlankView *blankView;

@end

@implementation HomeViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setHealthTargetSuccess:) name:kSetTargetNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(announcementViewBackup) name:kLaunchAdClickNotify object:nil];
    
    if ([TJYHelper sharedTJYHelper].isReloadHome || [NSString isNeedLoadData]) {
        [self loadHomeVCData];
        [TJYHelper sharedTJYHelper].isReloadHome=NO;
    }
    
    if ([TJYHelper sharedTJYHelper].isShowAnnouce) {
        [self popAnnouncementView];
        [TJYHelper sharedTJYHelper].isShowAnnouce=NO;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004" type:1];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004" type:2];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"首页";
    self.isHiddenBackBtn=YES;
    _menuSelectIndex = 0;
    _articleSelectIndex = 0;
    _articleListPage = 1;
    _healthTargetModel = [[TJYHealthTargetModel alloc] init];
    
    [self initHomeVC];
    [self loadHomeVCData];
    [self requestAnnouncementData];
}
#pragma mark -- Refresh Data

- (void)loadNewData{
    
    _articleSelectIndex = 0;
    _articleListPage = 1;
    [self loadHomeVCData];
}
- (void)loadMoreArticleData{
    _articleListPage++;
    [self requestArticleList:_articleSelectIndex];
}
#pragma mark -- Build UI

- (void)initHomeVC{
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.articleMenuNavView];
}
#pragma mark -- tableHeaderView

- (UIView *)tableHeaderView{
    
    UIView  *headerView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 135*kScreenWidth/320 + 94 + 10)];
    headerView.backgroundColor = kBackgroundColor;
    /* 广告循环*/
    [headerView addSubview:self.cycleScrollView];
    /* 栏目菜单按钮 */
    NSArray *titleArry = @[@"食物库",@"菜谱",@"营养日记",@"健康评估"];
    NSArray *titleImg = @[@"h_ic_food",@"h_ic_caipu",@"h_ic_diary",@"h_ic_test"];
    for (NSInteger  i = 0; i < titleArry.count; i++) {
        HerderClassifyButton *classifyBtn = [[HerderClassifyButton alloc]initWithFrame:CGRectMake(i * (kScreenWidth/4), _cycleScrollView.bottom , kScreenWidth/4, 94)];
        [classifyBtn setImage:[UIImage imageNamed:titleImg[i]] forState:UIControlStateNormal];
        [classifyBtn setTitle:titleArry[i] forState:UIControlStateNormal];
        [classifyBtn addTarget:self action:@selector(classifyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        classifyBtn.tag = 1000 + i;
        [headerView addSubview:classifyBtn];
    }
    CALayer *len = [[CALayer alloc]init];
    len.frame = CGRectMake(0, headerView.height - 10, kScreenWidth, 10);
    len.backgroundColor = kBackgroundColor.CGColor;
    [headerView.layer addSublayer:len];
    
    return headerView;
}
#pragma mark ====== tableFooterView =======

- (UIView *)tableFooterView{
    
    UIView *tableFooteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    [tableFooteView addSubview:self.blankView];
    return tableFooteView;
}

#pragma mark -- request Data

- (void)loadHomeVCData{
    
    if (_isMenuReload) {
        [self.recommendDietData removeAllObjects];
    }else{
        [self.bannersArray removeAllObjects];
        [self.recommendDietData removeAllObjects];
        [self.articleClassificationTitleArray removeAllObjects];
    }
    
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postMethodWithURL:kHomeIndex body:nil success:^(id json) {
        [weakSelf.tableView.mj_header endRefreshing];
        
        NSDictionary *dic = [json objectForKey:@"result"];
        if (!_isMenuReload) {
            /** banner  **/
            id bannerList = [dic objectForKey:@"banner_list"];
            if ((kIsArray(bannerList)&&[(NSArray *)bannerList count]>0)||(kIsDictionary(bannerList)&&[(NSDictionary *)bannerList count]>0)) {
                if (!kIsEmptyObject(bannerList)) {
                    NSArray *bannerListArr = [dic objectForKey:@"banner_list"];
                    if (kIsArray(bannerListArr) && bannerListArr.count > 0) {
                        [weakSelf loadBannerArray:bannerListArr];
                    }
                }
            }
            /** 推荐食谱 **/
            id recommendDiet = [dic objectForKey:@"recommend_diet"];
            if ((kIsArray(recommendDiet)&&[(NSArray *)recommendDiet count]>0)||(kIsDictionary(recommendDiet)&&[(NSDictionary *)recommendDiet count]>0)) {
                if (!kIsEmptyObject(recommendDiet)) {
                    NSDictionary *recommendDietDic = [dic objectForKey:@"recommend_diet"];
                    if (kIsDictionary(recommendDietDic)&&recommendDietDic.count>0) {
                        [weakSelf loadrecommendDietDic:recommendDietDic];
                    }
                }
            }
            /** 默认健康目标 **/
            NSDictionary *healthTargetDic = [dic objectForKey:@"health_target"];
            if (kIsDictionary(healthTargetDic)) {
                _healthTargetString = [healthTargetDic objectForKey:@"target_name"];
            }
            
            /**  健康目标列表  **/
            NSArray *targetListArray =[dic objectForKey:@"target_list"];
            [weakSelf.healthGoalTitleArray removeAllObjects];
            [weakSelf.healthGoalIdArray removeAllObjects];
            [weakSelf.targetDescriptionArray removeAllObjects];
            if (kIsArray(targetListArray)&&targetListArray.count>0) {
                for (NSDictionary *dict in targetListArray) {
                    TargetModel *targetModel=[[TargetModel alloc] init];
                    [targetModel setValues:dict];
                    [weakSelf.healthGoalTitleArray  addObject:targetModel.target_name];
                    [weakSelf.healthGoalIdArray addObject:[NSNumber numberWithInteger:targetModel.target_id]];
                    [weakSelf.targetDescriptionArray addObject:targetModel.brief];
                }
            }
            
            /**  文章分类列表  **/
            NSArray *articleListArray = [dic objectForKey:@"article_list"];
            if (kIsArray(articleListArray) && articleListArray.count > 0) {
                for (NSDictionary * dic in articleListArray) {
                    TJYArticleclassModel *articleclassModelmodel = [TJYArticleclassModel new];
                    [articleclassModelmodel setValues:dic];
                    [weakSelf.articleClassificationTitleArray addObject:articleclassModelmodel.name];
                    [weakSelf.articleClassificationIdArray  addObject:articleclassModelmodel.article_classification_id];
                }
                _articleSelectIndex = 0;
                weakSelf.articleMenuNavView.articleMenusArray = [NSMutableArray arrayWithArray:weakSelf.articleClassificationTitleArray];
                weakSelf.articlemenuView.articleMenusArray = [NSMutableArray arrayWithArray:weakSelf.articleClassificationTitleArray];
                [weakSelf requestArticleList:_articleSelectIndex];    // 请求文章列表数据
            }
            
            [_tableView reloadData];
        }else{
           
            /** 推荐食谱 **/
            id recommendDiet = [dic objectForKey:@"recommend_diet"];
            if ((kIsArray(recommendDiet)&&[(NSArray *)recommendDiet count]>0)||(kIsDictionary(recommendDiet)&&[(NSDictionary *)recommendDiet count]>0)) {
                if (!kIsEmptyObject(recommendDiet)) {
                    NSDictionary *recommendDietDic = [dic objectForKey:@"recommend_diet"];
                    if (kIsDictionary(recommendDietDic)&&recommendDietDic.count>0) {
                        [weakSelf loadrecommendDietDic:recommendDietDic];
                    }
                }
            }
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark --- load BannerList Data

- (void)loadBannerArray:(NSArray *)bannerArr{
    
    NSMutableArray *bannerTempArr=[[NSMutableArray alloc] init];
    NSMutableArray *bannersImgArr = [NSMutableArray array];
    for (NSDictionary *dict in bannerArr) {
        TJYBannerModel *bannerModel=[[TJYBannerModel alloc] init];
        [bannerModel setValues:dict];
        bannerModel.id=[[dict valueForKey:@"banner_id"] integerValue];
        [bannerTempArr addObject:bannerModel];
        [bannersImgArr addObject:bannerModel.image_url];
    }
    self.bannersArray = bannerTempArr;
    self.cycleScrollView.imageURLStringsGroup =bannersImgArr;
}
#pragma mark -- load recommend_diet  Data

- (void)loadrecommendDietDic:(NSDictionary *)recommendDietDic{
    //  早上
    NSMutableArray *morningArr = [recommendDietDic objectForKey:@"breakfast"];
    NSMutableArray *morningData = [NSMutableArray array];
    if (morningArr.count > 0 && kIsArray(morningArr)) {
        for (NSDictionary *dic in morningArr) {
            TJYFoodRecommendModel *recommendModel = [TJYFoodRecommendModel new];
            [recommendModel  setValues:dic];
            [morningData  addObject:recommendModel];
        }
        [self.recommendDietData addObject:morningData];
    }else{
        if (kIsArray(morningArr)) {
            [self.recommendDietData addObject:morningArr];
        }
    }
    //  中午
    NSMutableArray *lunchArr = [recommendDietDic objectForKey:@"lunch"];
    NSMutableArray *lunchData = [NSMutableArray array];
    if (lunchArr.count > 0 && kIsArray(lunchArr)) {
        for (NSDictionary *dic in lunchArr) {
            TJYFoodRecommendModel *recommendModel = [TJYFoodRecommendModel new];
            [recommendModel  setValues:dic];
            [lunchData  addObject:recommendModel];
        }
        [self.recommendDietData addObject:lunchData];
    }else{
        if (kIsArray(lunchArr)) {
            [self.recommendDietData addObject:lunchArr];
        }
    }
    //  晚饭
    NSMutableArray *dinnerArr = [recommendDietDic objectForKey:@"dinner"];
    NSMutableArray *dinnerData = [NSMutableArray array];
    if (dinnerArr.count > 0 && kIsArray(dinnerArr)) {
        for (NSDictionary *dic in dinnerArr) {
            TJYFoodRecommendModel *recommendModel = [TJYFoodRecommendModel new];
            [recommendModel  setValues:dic];
            [dinnerData  addObject:recommendModel];
        }
        [self.recommendDietData addObject:dinnerData];
    }else{
        if (kIsArray(dinnerArr)) {
            [self.recommendDietData addObject:dinnerArr];
        }
    }
    //  加餐
    NSMutableArray *snackArr = [recommendDietDic objectForKey:@"supper"];
    NSMutableArray *snackData = [NSMutableArray array];
    if (snackArr.count > 0 && kIsArray(snackArr)) {
        for (NSDictionary *dic in snackArr) {
            TJYFoodRecommendModel *recommendModel  = [TJYFoodRecommendModel new];
            [recommendModel  setValues:dic];
            [snackData  addObject:recommendModel];
        }
        [self.recommendDietData addObject:snackData];
    }else{
        if (kIsArray(snackArr)) {
            [self.recommendDietData addObject:snackArr];
        }
    }
    /* 默认为早餐 */
    if (self.recommendDietData.count > 0) {
        if (kIsArray(self.recommendDietData[_menuSelectIndex])) {
            self.recommendDietDataSource = self.recommendDietData[_menuSelectIndex];
        }
    }
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    if (!_isMenuReload) {
        [self changeMenuItem];
    }
     _isMenuReload = NO;
}
#pragma mark ====== Event Response =======

#pragma mark ------ 推荐用餐时间判断  -------

- (NSInteger)getMenuTimeSelectIndex{
    
    NSInteger index;
    if ([[TJYHelper sharedTJYHelper]judgeTimeByStartAndEnd:@"00:00" withExpireTime:@"08:59"]) {
        index = 0;
    }else if ([[TJYHelper sharedTJYHelper]judgeTimeByStartAndEnd:@"09:00" withExpireTime:@"10:59"]){
        index = 3;
    }else if ([[TJYHelper sharedTJYHelper]judgeTimeByStartAndEnd:@"11:00" withExpireTime:@"13:59"]){
        index = 1;
    }else if ([[TJYHelper sharedTJYHelper]judgeTimeByStartAndEnd:@"14:00" withExpireTime:@"16:59"]){
        index = 3;
    }else if ([[TJYHelper sharedTJYHelper]judgeTimeByStartAndEnd:@"17:00" withExpireTime:@"19:59"]){
        index = 2;
    }else if ([[TJYHelper sharedTJYHelper]judgeTimeByStartAndEnd:@"20:00" withExpireTime:@"23:59"]){
        index = 3;
    }
    return index;
}
-(void)changeMenuItem{
    
    _menuSelectIndex = [self getMenuTimeSelectIndex];
    UIButton *btn;
    for (UIView  *view in _menuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_menuSelectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [_menuView changeViewWithButton:btn];
}

#pragma mark ====== 文章搜索 =======

- (void)knowledgeSearchAction{
    
    TJYSearchFoodVC *search =[[TJYSearchFoodVC alloc]init];
    search.searchType = KnowledgeSearchType;
    [self push:search];
}
#pragma mark ====== 健康目标 =======

- (void)changeEfficacyAction{
    
    if (kIsLogined) {
        if (_healthGoalTitleArray.count > 0) {
            NSArray *effectDescriptionArray = self.targetDescriptionArray;
            kSelfWeak;
            TJYEfficacyPickerView *efficacyPickerView = [TJYEfficacyPickerView efficacyPickerViewBlockWithTitle:_healthGoalTitleArray andHeadTitle:@"选择三餐功效" Andcall:^(TJYEfficacyPickerView *pickerView, NSString *choiceString,NSInteger targetId) {
                
                [weakSelf confirmSetHealthTargetWithTargetId:targetId];
                [pickerView dismissPicker];
            }];
            efficacyPickerView.effectDescriptionArray = effectDescriptionArray;
            efficacyPickerView.effectIdArray = self.healthGoalIdArray;
            efficacyPickerView.selectTextStr = _healthTargetString;
            [efficacyPickerView show];
        }else{
            [self getHealthTargetData];
        }
    }else{
        [self pushToFastLogin];
    }
}
#pragma mark ====== 设定健康目标 =======

-(void)confirmSetHealthTargetWithTargetId:(NSInteger)targetId{

    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-06-02"];

    NSString *body =[NSString stringWithFormat:@"target_id=%ld&doSubmit=1",(long)targetId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kSetUserInfo body:body success:^(id json) {
        [TJYHelper sharedTJYHelper].isSetUserInfoSuccess=YES;
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            TJYUserModel *userModel=[[TJYUserModel alloc] init];
            [userModel setValues:result];
            [TonzeHelpTool sharedTonzeHelpTool].user=userModel;
        }
        [weakSelf loadHomeVCData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark ====== 获取健康目标数据 =======
-(void)getHealthTargetData{

    [self.healthGoalTitleArray removeAllObjects];
    [self.healthGoalIdArray removeAllObjects];
    [self.targetDescriptionArray removeAllObjects];
    
    kSelfWeak;
    NSString *body=[NSString stringWithFormat:@"page_size=100&page_num=1"];
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kGetHealthTargetList body:body success:^(id json) {
        NSArray *result=[json objectForKey:@"result"];
        if (kIsArray(result)&&result.count>0) {
            for (NSDictionary *dict in result) {
                TargetModel *targetModel=[[TargetModel alloc] init];
                [targetModel setValues:dict];
                targetModel.isDefault=[dict[@"default"] boolValue];
                
                [weakSelf.healthGoalTitleArray  addObject:targetModel.target_name];
                [weakSelf.healthGoalIdArray addObject:[NSNumber numberWithInteger:targetModel.target_id]];
                [weakSelf.targetDescriptionArray addObject:targetModel.brief];
            }
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark --- 请求文章列表数据

- (void)requestArticleList:(NSInteger)index{
    
    NSString *urlString = nil;
    NSString *classificationId = [NSString stringWithFormat:@"%@",_articleClassificationIdArray[index]];
    urlString = [NSString stringWithFormat:@"page_num=%ld&page_size=20&classification_id=%@",(long)_articleListPage,classificationId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kArticleList body:urlString success:^(id json) {
        NSDictionary *pager=[json objectForKey:@"pager"];
        if (kIsDictionary(pager)) {
            NSInteger totalValues=[[pager valueForKey:@"total"] integerValue];
            weakSelf.tableView.mj_footer.hidden=(totalValues-_articleListPage*20)<=0;
        }
        NSArray *dataArray = [json objectForKey:@"result"];
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        if (dataArray.count>0 && kIsArray(dataArray)) {
            weakSelf.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
            for (int i=0; i<dataArray.count; i++) {
                TJYArticleModel *articleModel=[[TJYArticleModel alloc] init];
                [articleModel setValues:dataArray[i]];
                [tempArr addObject:articleModel];
            }
            if (_articleListPage == 1) {
                weakSelf.articleListDateArray = [[NSMutableArray alloc] init];
                weakSelf.articleListDateArray = tempArr;
            }else{
                [weakSelf.articleListDateArray addObjectsFromArray:tempArr];
            }
        } else {
            weakSelf.tableView.mj_footer.hidden=YES;
            weakSelf.tableView.mj_header.hidden = YES;
            tempArr = [[NSMutableArray alloc] init];
            weakSelf.tableView.tableFooterView = _articleListDateArray.count > 0 ? [[UIView alloc]initWithFrame:CGRectZero] : [weakSelf tableFooterView];
        }
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.tableView reloadData];

    } failure:^(NSString *errorStr) {
        weakSelf.tableView.tableFooterView = [weakSelf tableFooterView];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.articleListDateArray removeAllObjects];
        
        [weakSelf.tableView reloadData];
    }];
}
#pragma mark ====== 刷新菜谱 =======

- (void)reloadMenuAction{
    
    _isMenuReload = YES;
    [self loadHomeVCData];
}
#pragma mark -- SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    
    TJYBannerModel *banner=self.bannersArray[index];
    
    NSString *uuid = [[TJYHelper sharedTJYHelper] deviceUUID];
    NSString *body = [NSString stringWithFormat:@"doSubmit=1&type=1&imsi=%@&type_id=%ld",uuid,(long)banner.id];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kBannarStatistics body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        
    }];
    
    NSString *targetId=[NSString stringWithFormat:@"004-01-%ld",(long)index];
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:targetId];
    
    [self showActivityDetailForChooseBanner:banner isAnnounce:NO];
}
#pragma mark -- NSNotification

-(void)announcementViewBackup{
    [TJYHelper sharedTJYHelper].isShowAnnouce=YES;
    [[HWPopTool sharedInstance] closeAnimation:NO WithBlcok:^{
        
    }];
}
#pragma mark -- TJYFoodRecommendMenuViewDelegate

-(void)foodMenuView:(TJYFoodRecommendMenuView *)menuView Index:(NSInteger)index
{
    _menuSelectIndex = index;
    if (kIsArray(self.recommendDietData) && self.recommendDietData.count > 0) {
        if (kIsArray(self.recommendDietData[_menuSelectIndex]) && self.recommendDietData.count > 0) {
            self.recommendDietDataSource =  self.recommendDietData[_menuSelectIndex];
            
            NSArray *arr=@[@"早餐",@"午餐",@"晚餐",@"加餐"];
            NSString *targetId=[NSString stringWithFormat:@"004-07-01-%@",arr[_menuSelectIndex]];
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:targetId];
        }
    }
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark ====== TJYMenuViewDelegate =======
#pragma mark ====== 文章分类代理 =======

- (void)articleTitleMenuView:(TJYArticleTitleView *)menuView actionWithIndex:(NSInteger)index{

    _articleListPage = 1;
    _articleSelectIndex = index;
    
    UIButton *btn;
    for (UIView  *view in _articlemenuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_articleSelectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    
    UIButton *btns;
    for (UIView  *view in _articleMenuNavView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_articleSelectIndex+100)) {
                btns = (UIButton*)menuview;
            }
        }
    }
    [_articleMenuNavView changeBtnLineWithButton:btns];
    [_articlemenuView changeBtnLineWithButton:btn];

    [self requestArticleList:index];
}
#pragma mark -- UITableViewDelegate && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
        {
            return 1;
        }
            break;
        case 1:
        {
            return self.articleListDateArray.count;
        }
            break;
        default:
            break;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            return (kScreenWidth - 30)/3;
        }
            break;
        case 1:
        {
            return 100 * kScreenWidth/320;
        }
            break;
        default:
            break;
    }
    return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return 44.0f;
    }else{
        return 44 + 45;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        return 44 + 33 + 10;
    }else{
        return 0.01f;
    }
}
/* 分组头部视图 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *tableHeaderView =InsertView(nil, CGRectMake(0, 0, kScreenWidth, 44), [UIColor whiteColor]);
    
    // -- 用餐推荐
    NSArray *titleArray = @[@"h_title_01",@"h_title_02"];
    
    UIImageView *titleImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, (44 - 34/2)/2 , 142/2, 34/2)];
    titleImgView.image = [UIImage imageNamed:titleArray[section]];
    [tableHeaderView addSubview:titleImgView];
    
    switch (section) {
        case 0:
        {   // 用餐时间
            UILabel *mealTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(titleImgView.right + 8,(tableHeaderView.height - 20)/2 , 100, 20)];
            mealTimeLab.textColor = UIColorHex(0x666666);
            mealTimeLab.font = kFontSize(15);
            mealTimeLab.text = _menuTitleArr[_menuSelectIndex];
            [tableHeaderView addSubview:mealTimeLab];
            
             // 健康目标
            CGSize  efficacyTypeSize = [_healthTargetString boundingRectWithSize:CGSizeMake(200, 30) withTextFont:kFontSize(18)];
            UILabel *healthGoalLab = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - efficacyTypeSize.width - 30, (tableHeaderView.height - 40)/2 , efficacyTypeSize.width, 40)];
            healthGoalLab.textColor = UIColorHex(0xff9100);
            healthGoalLab.font = kFontSize(15);
            healthGoalLab.text = kIsLogined ? _healthTargetString : @"通用";
            [tableHeaderView addSubview:healthGoalLab];
            
            UIButton *efficacyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            efficacyBtn.frame = CGRectMake(kScreenWidth -  140 ,(tableHeaderView.height - 40)/2 , 140, 40);
            efficacyBtn.backgroundColor = [UIColor clearColor];
            [efficacyBtn addTarget:self action:@selector(changeEfficacyAction) forControlEvents:UIControlEventTouchUpInside];
            [tableHeaderView addSubview:efficacyBtn];
            
            UIImageView *arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 30, (tableHeaderView.height - 15)/2, 15, 15)];
            arrowImg.image = [UIImage imageNamed:@"ic_pub_arrow_nor"];
            [tableHeaderView addSubview:arrowImg];
        }
            break;
        case 1:
        {
            tableHeaderView.frame = CGRectMake(0, 0, kScreenWidth, 44 + 45);
            // 文章搜索
            CALayer *searchBgView = [[CALayer alloc]init];
            searchBgView.frame = CGRectMake(kScreenWidth - 70, (44 - 30)/2 , 60, 30);
            searchBgView.backgroundColor = UIColorHex(0xEFEFF4).CGColor;
            searchBgView.masksToBounds = YES;
            searchBgView.cornerRadius = 16;
            [tableHeaderView.layer addSublayer:searchBgView];
            
            UIImageView *searchImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 40, (44 - 20)/2, 20, 20)];
            searchImg.image = [UIImage imageNamed:@"pub_H_ic_search"];
            [tableHeaderView addSubview:searchImg];
       
            UIButton *searchArticleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            searchArticleBtn.frame = CGRectMake(kScreenWidth - 110 , 0, 100 , 44);
            searchArticleBtn.backgroundColor = [UIColor clearColor];
            [searchArticleBtn addTarget:self action:@selector(knowledgeSearchAction) forControlEvents:UIControlEventTouchUpInside];
            [tableHeaderView addSubview:searchArticleBtn];
            
            [tableHeaderView addSubview:self.articlemenuView];
        }
            break;
        default:
            break;
    }
    return  tableHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        UIView  *tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44 + 33 + 10)];
        tableFooterView.backgroundColor = [UIColor whiteColor];
        
        [tableFooterView addSubview:self.menuView];
        
        UIButton *reloadMenuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        reloadMenuBtn.frame = CGRectMake(0, 44, kScreenWidth, 33);
        [reloadMenuBtn setTitle:@"换一批" forState:UIControlStateNormal];
        [reloadMenuBtn setTitleColor:UIColorHex(0x999999) forState:UIControlStateNormal];
        [reloadMenuBtn setImage:[UIImage imageNamed:@"pub_h_ic_re"] forState:UIControlStateNormal];
        reloadMenuBtn.titleLabel.font = kFontSize(13);
        [reloadMenuBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:6];
        [reloadMenuBtn addTarget:self action:@selector(reloadMenuAction) forControlEvents:UIControlEventTouchUpInside];
        [tableFooterView addSubview:reloadMenuBtn];
        
        CALayer *len = [[CALayer alloc]init];
        len.frame = CGRectMake(0, tableFooterView.height - 10, kScreenWidth, 10);
        len.backgroundColor = kBackgroundColor.CGColor;
        [tableFooterView.layer addSublayer:len];
        
        return tableFooterView;
    }else{
        return nil;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static  NSString *dietIsRecommendedIdentifier = @"dietIsRecommendedIdentifier";
    static  NSString *articleTableViewCellIdentifier = @"articleTableViewCellIdentifier";
    switch (indexPath.section) {
        case 0:
        {
            DietIsRecommendedCell *dietIsRecommendedCell = [[DietIsRecommendedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dietIsRecommendedIdentifier];
            dietIsRecommendedCell.recommendDietData = self.recommendDietDataSource;
            dietIsRecommendedCell.delegate = self;
            return dietIsRecommendedCell;
        }
            break;
        case 1:
        {
            TJYArticleTableViewCell *articleTableViewCell = [tableView dequeueReusableCellWithIdentifier:articleTableViewCellIdentifier];
            if (!articleTableViewCell) {
                articleTableViewCell = [[TJYArticleTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:articleTableViewCellIdentifier];
            }
            if (self.articleListDateArray.count > 0) {
                TJYArticleModel *article = self.articleListDateArray[indexPath.row];
                [articleTableViewCell cellDisplayWithModel:article type:1 searchText:@""];
            }
            articleTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return articleTableViewCell;
        }
            break;
        default:
            break;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-07-03"];
    if (self.articleListDateArray.count > 0 && indexPath.section == 1) {
        TJYArticleModel *articleModel = self.articleListDateArray[indexPath.row];
        
        [TonzeHelpTool sharedTonzeHelpTool].viewType=WebViewTypeArticle;
        [TonzeHelpTool sharedTonzeHelpTool].article_id=articleModel.article_management_id;
        BasewebViewController *webVC=[[BasewebViewController alloc] init];
        webVC.titleText=@"文章详情";
        webVC.titleName = articleModel.title;
        NSString *url = [NSString stringWithFormat:@"%@",kHostURL];
        url = [url stringByReplacingOccurrencesOfString:@"/%@" withString:@""];
        webVC.urlStr=[NSString stringWithFormat:@"%@/article/%ld",url,(long)articleModel.article_management_id];
        webVC.hidesBottomBarWhenPushed=YES;
        webVC.articleId = articleModel.article_management_id;
        webVC.isWebUrl = NO;
        webVC.isCollect = articleModel.is_collection;
        webVC.imageUrl = articleModel.image_url;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}
#pragma -mark 控制隐藏显示文章标题

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat  offsetY = 135*kScreenWidth/320 + 94 + 10 + 44 +    (kScreenWidth - 50)/3  + 44 + 33 + 10 + 44 ;
    
    if (self.articleMenuNavView.hidden == NO) {
        if (scrollView.contentOffset.y < offsetY) {
            self.articleMenuNavView.hidden = YES;
        }
    } else {
        if (scrollView.contentOffset.y > offsetY) {
            self.articleMenuNavView.hidden = NO;
        }
    }
}
#pragma mark 分享
-(void)heziTrigger:(HeziTrigger *)heziSDK share:(HeziShareModel *)shareContent activePage:(UIView *)activePage{
    MyLog(@"title:%@,content:%@,imageUrl:%@,linkUrl:%@,callbackUrl:%@",shareContent.title,shareContent.content,shareContent.imgUrl,shareContent.linkUrl,shareContent.callBackUrl);
    
    NSArray *titlearr = @[@"微信好友",@"微信朋友圈",@"QQ",@"QQ空间",@"新浪微博",@""];
    NSArray *imageArr = @[@"ic_pub_share_wx",@"ic_pub_share_pyq",@"ic_pub_share_qq",@"ic_pub_share_qzone",@"ic_pub_share_wb",@""];
    ActionSheetView *actionsheet = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"测试" and:ShowTypeIsShareStyle];
    [actionsheet setBtnClick:^(NSInteger btnTag) {
        
        //可选 生成深度链接 第一个参数表示活动原始分享链接 scheme 表示为 app 设置的 url scheme, customerParams表示用户的自定义参数
        NSString *deepUrl = [[HeziSDKManager sharedInstance] buildDeepLinkWithUrl:shareContent.linkUrl  scheme:@"TangShi://" customeParams:@{@"banner":@"share"}];
        
        MyLog(@"深度链接:%@",deepUrl);
        //分享成功后 调用统计分享成功,并且给分享者增加次数
        [[HeziSDKManager sharedInstance] statisticsShareCallBack:shareContent.callBackUrl linkUrl:deepUrl];
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:shareContent.content
                                         images:[NSURL URLWithString:shareContent.imgUrl]
                                            url:[NSURL URLWithString:deepUrl]
                                          title:shareContent.title
                                           type:SSDKContentTypeAuto];
        
        if (btnTag==0) {
            [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
            
        }else if (btnTag==1){
            [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
            
        }else if (btnTag==2){
            [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
            
        }else if(btnTag==3){
            [ShareSDK share:SSDKPlatformSubTypeQZone parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
            
        }else{
            [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@%@",shareContent.title,
                                                     [NSURL URLWithString:shareContent.linkUrl]]
                                             images:shareContent.imgUrl
                                                url:[NSURL URLWithString:shareContent.linkUrl]
                                              title:shareContent.title
                                               type:SSDKContentTypeAuto];
            [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                [self shareSuccessorError:state];
            }];
        }
        [shareParams SSDKEnableUseClientShare];
        
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];
}
#pragma mark -- Event Response
#pragma mark  分享成功／失败／取消
- (void)shareSuccessorError:(NSInteger)index{
    if (index==1) {
        [[[UIApplication sharedApplication]keyWindow] makeToast:@"分享成功" duration:1.0 position:CSToastPositionCenter];
    }else if (index==2){
        [[[UIApplication sharedApplication]keyWindow] makeToast:@"分享失败" duration:1.0 position:CSToastPositionCenter];
    }else if(index==3){
        [[[UIApplication sharedApplication]keyWindow] makeToast:@"分享取消" duration:1.0 position:CSToastPositionCenter];
    }
}
#pragma mark ======  文章滑动事件 =======

-(void)swipArticleTableView:(UISwipeGestureRecognizer *)gesture{

    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        _articleSelectIndex++;
        if (_articleSelectIndex>_articleClassificationTitleArray.count-1) {
            _articleSelectIndex=_articleClassificationTitleArray.count;
            return;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        _articleSelectIndex--;
        if (_articleSelectIndex<0) {
            _articleSelectIndex=0;
            return;
        }
    }
    UIButton *btn;
    for (UIView  *view in _articlemenuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_articleSelectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    
    UIButton *btns;
    for (UIView  *view in _articleMenuNavView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_articleSelectIndex+100)) {
                btns = (UIButton*)menuview;
            }
        }
    }
    
    [_articlemenuView changeFoodViewWithButton:btn];
    [_articleMenuNavView changeFoodViewWithButton:btns];
}
#pragma mark ====== DietIsRecommendedCellDelegate =======
#pragma mark --------  菜谱滑动事件  --------
- (void)swipMealTime:(UISwipeGestureRecognizer *)gesture{
    
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        _menuSelectIndex++;
        if (_menuSelectIndex>_menuTitleArr.count-1) {
            _menuSelectIndex=_menuTitleArr.count;
            return;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        _menuSelectIndex--;
        if (_menuSelectIndex<0) {
            _menuSelectIndex=0;
            return;
        }
    }
    UIButton *btn;
    for (UIView  *view in _menuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == (long)_menuSelectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [_menuView changeViewWithButton:btn];
}
#pragma mark -----  菜谱点击 --------

- (void)menuClickIndexRow:(NSInteger)row{
    
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-07-03"];
    
    if (self.recommendDietDataSource.count == 3) {
        TJYFoodRecommendModel *recommendModel = [[TJYFoodRecommendModel alloc]init];
        recommendModel = self.recommendDietDataSource[row - 1000];
        switch (recommendModel.type) {
            case 1:
            {
                TJYFoodDetailsVC *foodDetailsVC = [TJYFoodDetailsVC new];
                foodDetailsVC.food_id = recommendModel.food_id;
                [self push:foodDetailsVC];
            }break;
            case 2:
            {
                TJYMenuDetailsVC *menuDetailsVC = [TJYMenuDetailsVC new];
                menuDetailsVC.menuid = recommendModel.food_id;
                [self push:menuDetailsVC];
            }break;
            default:
                break;
        }
    }
}
#pragma mark -- Action
#pragma mark 设置健康目标成功
-(void)setHealthTargetSuccess:(NSNotification *)notify{
    NSDictionary *userInfo=notify.userInfo;
    NSString *targetName=[userInfo valueForKey:@"name"];
    NSString *message=[NSString stringWithFormat:@"%@健康目标设置成功",targetName];
    [self.view makeToast:message duration:2.0 position:CSToastPositionBottom];
}

/*  分类事件点击响应 */
- (void)classifyBtnClick:(UIButton *)btn{
    switch (btn.tag) {
        case 1000:{//食材库
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-02"];
#endif
            TJYFoodLibraryVC *foodLibraryVC = [[TJYFoodLibraryVC alloc] init];
            foodLibraryVC.orderbyStr = @"id";
            foodLibraryVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:foodLibraryVC animated:YES];
        }break;
        case 1001:{// 菜谱
            
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-03"];
            [self push:[TJYMenuVC new]];
        }break;
        case 1002:{// 营养日记
            //#if !DEBUG
            //            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-04"];
            //#endif
            //            [self push:[TJYNutritionEncyclopediaVC new]];
            BasewebViewController *baseWebVC = [[BasewebViewController alloc] init];
            baseWebVC.type = BaseWebViewTypeADiary;
            baseWebVC.urlStr =[NSString stringWithFormat:@"%@?time=%@",kHostADiaryURL,[[TJYHelper sharedTJYHelper] getNowTimeTimestamp]];
            baseWebVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:baseWebVC animated:YES];
        }break;
        case 1003:{// 健康评估
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-05"];
            
            if (kIsLogined) {
                [self push:[TJYHealthAssessmentVC new]];
            }else{
                [self pushToFastLogin];
            }
        }break;
        default:
            break;
    }
}
#pragma mark 加载公告信息

- (void)requestAnnouncementData{
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kAdIndexUrl body:@"type=3" success:^(id json) {
        NSDictionary *dict=[json objectForKey:@"result"];
        if(kIsDictionary(dict)&&dict.count>0){
            announceBanner=[[TJYBannerModel alloc] init];
            [announceBanner setValues:dict];
            
            NSString *currentDateStr=[[TJYHelper sharedTJYHelper] getCurrentDate];
            NSInteger popNum= [[NSUserDefaultInfos getValueforKey:currentDateStr] integerValue];
            MyLog(@"弹出公告栏次数：%ld",(long)popNum);
            if ([announceBanner.num integerValue]>popNum) {
                if (!_isFirstPop) {
                    popNum++;
                    [NSUserDefaultInfos putKey:currentDateStr andValue:[NSNumber numberWithInteger:popNum]];
                }
                [weakSelf popAnnouncementView];
            }
        }
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark  HeziTriggerActivePageDelegate
#pragma mark 活动页将要打开，返回NO会拦截。
- (BOOL)heziTriggerWillOpenActivePage:(HeziTrigger *)heziSDK activityURL:(NSString *)url {
    MyLog(@"%s", __FUNCTION__);
    return YES;
}

#pragma mark 活动页已经打开
- (void)heziTriggerDidOpenActivePage:(HeziTrigger *)heziSDK {
    MyLog(@"%s", __FUNCTION__);
}

#pragma mark 活动页已经关闭
- (void)heziTriggerDidCloseActivePage:(HeziTrigger *)heziSDK {
    //注意,默认情况下触发的图标点击后不会关闭,需要开发者调用 dismiss 方法
    [heziSDK dismiss];
    MyLog(@"%s", __FUNCTION__);
}

#pragma mark 触发失败
- (void)heziTirgger:(HeziTrigger *)trigger triggerError:(NSError *)error {
    MyLog(@"%s", __FUNCTION__);
}

#pragma mark 弹出公告
- (void)popAnnouncementView{
    
    UIView *contentView=[[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor=[UIColor whiteColor];
    contentView.layer.cornerRadius=5;
    contentView.clipsToBounds=YES;
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-80, kScreenWidth-80)];
    [imgView sd_setImageWithURL:[NSURL URLWithString:announceBanner.image_url] placeholderImage:[UIImage imageNamed:@""]];
    [contentView addSubview:imgView];
    
    UILabel *contentLbl=[[UILabel alloc] initWithFrame:CGRectZero];
    contentLbl.textColor=[UIColor grayColor];
    contentLbl.textAlignment=NSTextAlignmentCenter;
    contentLbl.numberOfLines=0;
    contentLbl.text=announceBanner.desc_info;
    CGFloat contentH=[contentLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth-110, kRootViewHeight) withTextFont:contentLbl.font].height;
    contentLbl.frame=CGRectMake(15, imgView.bottom+10, kScreenWidth-110, contentH);
    [contentView addSubview:contentLbl];
    
    UIButton  *detailBtn=[[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-80-150)/2, contentLbl.bottom+20, 150, 35)];
    [detailBtn setTitle:announceBanner.btn_name forState:UIControlStateNormal];
    [detailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    detailBtn.backgroundColor=kSystemColor;
    [detailBtn addTarget:self action:@selector(getMoreAnnounceDetail:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:detailBtn];
    
    contentView.frame=CGRectMake(0, 0, kScreenWidth-80, detailBtn.bottom+30);
    
    [HWPopTool sharedInstance].shadeBackgroundType = ShadeBackgroundTypeSolid;
    [HWPopTool sharedInstance].closeButtonType = ButtonPositionTypeBottom;
    [[HWPopTool sharedInstance] showWithPresentView:contentView animated:YES];
}
#pragma mark 公告详情
- (void)getMoreAnnounceDetail:(UIButton *)sender{
    
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:[NSString stringWithFormat:@"004-09-02:%ld",(long)announceBanner.id]];
    
    NSString *uuid = [[TJYHelper sharedTJYHelper] deviceUUID];
    NSString *body = [NSString stringWithFormat:@"doSubmit=1&type=4&imsi=%@&type_id=%ld",uuid,(long)announceBanner.id];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kBannarStatistics body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        
    }];
    
    [[HWPopTool sharedInstance] closeAnimation:YES WithBlcok:^{
        [self showActivityDetailForChooseBanner:announceBanner isAnnounce:YES];
    }];
}
#pragma mark 选择活动对应事件
-(void)showActivityDetailForChooseBanner:(TJYBannerModel *)banner isAnnounce:(BOOL)isAnnounce{
    BOOL isNeedLogin=[banner.login_limit boolValue];
    BOOL flag=NO;
    if (isNeedLogin&&isAnnounce) {
        flag=kIsLogined;
    }else{
        flag=YES;
    }
    
    if (flag) {
        switch (banner.type) {
            case 1: //url外部跳转
            {
                NSString *tmall_url=banner.info;
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[tmall_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
                break;
            case 2: //文章
            {
                [TonzeHelpTool sharedTonzeHelpTool].viewType=WebViewTypeArticle;
                NSString *url = [NSString stringWithFormat:@"%@",kHostURL];
                url = [url stringByReplacingOccurrencesOfString:@"/%@" withString:@""];
                NSString *urlString = [NSString stringWithFormat:@"%@/article/%@",url,banner.info];
                BasewebViewController *webVC=[[BasewebViewController alloc] init];
                webVC.articleId = [banner.info integerValue];
                webVC.titleText=@"文章详情";
                webVC.isWebUrl = NO;
                webVC.imageUrl = banner.image_url;
                webVC.urlStr=urlString;
                webVC.titleName = banner.name;
                webVC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:webVC animated:YES];
            }break;
            case 3: //食物
            {
                TJYFoodDetailsVC *foodDetailVC=[[TJYFoodDetailsVC alloc] init];
                foodDetailVC.food_id=[banner.info integerValue];
                foodDetailVC.is_collection = banner.is_collection;
                foodDetailVC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:foodDetailVC animated:YES];
            }break;
            case 5: //活动盒子
            {
                NSString *phone=[NSUserDefaultInfos getValueforKey:kUserPhone];
                NSDictionary *userInfo=@{@"username":phone,@"mobile":phone};
                [HeziTrigger trigger:banner.info userInfo:userInfo showIconInView:self.view rootController:self delegate:self];
                
            }
                break;
            case 6: //url内部链接
            {
                [TonzeHelpTool sharedTonzeHelpTool].viewType=WebViewTypeOther;
                BasewebViewController *webVC=[[BasewebViewController alloc] init];
                webVC.titleText=banner.name;
                webVC.isWebUrl = YES;
                webVC.urlStr=banner.info;
                webVC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:webVC animated:YES];
            }
                break;
            default:
                break;
        }
    }else{
        [self pushToFastLogin];
    }
}
#pragma mark -- Getter--
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth,kBodyHeight - kTabbarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [self tableHeaderView];
        _tableView.backgroundColor = kBackgroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _tableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreArticleData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _tableView.mj_footer = footer;
        footer.hidden = YES;
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_tableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_tableView addGestureRecognizer:swipGestureRight];
    }
    return _tableView;
}
/* 分类菜单 */
-(TJYFoodRecommendMenuView *)menuView{
    if (_menuView==nil) {
        _menuView=[[TJYFoodRecommendMenuView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        _menuView.delegate = self;
        _menuTitleArr= @[@"早餐",@"午餐",@"晚餐",@"加餐"];
        _menuView.menusArray = [NSMutableArray arrayWithArray:_menuTitleArr];
        _menuView.backgroundColor = [UIColor whiteColor];
    }
    return _menuView;
}
- (TJYArticleTitleView *)articlemenuView{
    if (!_articlemenuView) {
        _articlemenuView = [[TJYArticleTitleView alloc]initWithFrame:CGRectMake(0, 44, kScreenWidth, 45)];
        _articlemenuView.delegate = self;
    }
    return _articlemenuView;
}
- (TJYArticleTitleView *)articleMenuNavView{
    if (!_articleMenuNavView) {
        _articleMenuNavView = [[TJYArticleTitleView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 45)];
        _articleMenuNavView.delegate = self;
        _articleMenuNavView.hidden = YES;
        _articleMenuNavView.backgroundColor = [UIColor whiteColor];
    }
    return _articleMenuNavView;
}
/* Banner视图 */
-(SDCycleScrollView *)cycleScrollView{
    if (_cycleScrollView==nil) {
        _cycleScrollView=[SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, 135*kScreenWidth/320) delegate:self placeholderImage:[UIImage imageNamed:@"banner_nor"]];
        _cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
        _cycleScrollView.autoScrollTimeInterval = 4;
        _cycleScrollView.currentPageDotColor = kSystemColor; // 自定义分页控件小圆标颜色
        _cycleScrollView.pageDotColor=[UIColor whiteColor];
    }
    return _cycleScrollView;
}
- (BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) img:@"img_tips_no" text:@"暂无数据"];
        _blankView.backgroundColor = [UIColor bgColor_Gray];
    }
    return _blankView;
}

- (NSMutableArray *)bannersArray {
    if (!_bannersArray) {
        _bannersArray = [NSMutableArray array];
    }
    return _bannersArray;
}

-(NSMutableArray *)recommendDietData
{
    if (!_recommendDietData) {
        _recommendDietData = [NSMutableArray array];
    }
    return _recommendDietData;
}
- (NSMutableArray *)recommendDietDataSource{
    if (!_recommendDietDataSource) {
        _recommendDietDataSource = [NSMutableArray array];
    }
    return _recommendDietDataSource;
}
- (NSMutableArray *)articleClassificationIdArray{
    if (!_articleClassificationIdArray) {
        _articleClassificationIdArray = [NSMutableArray array];
    }
    return _articleClassificationIdArray;
}
- (NSMutableArray *)articleClassificationTitleArray{
    if (!_articleClassificationTitleArray) {
        _articleClassificationTitleArray = [NSMutableArray array];
    }
    return _articleClassificationTitleArray;
}
- (NSMutableArray *)healthGoalTitleArray{
    if (!_healthGoalTitleArray) {
        _healthGoalTitleArray = [NSMutableArray array];
    }
    return _healthGoalTitleArray;
}
- (NSMutableArray *)healthGoalIdArray{
    if (!_healthGoalIdArray) {
        _healthGoalIdArray = [NSMutableArray array];
    }
    return _healthGoalIdArray;
}
- (NSMutableArray *)targetDescriptionArray{
    if (!_targetDescriptionArray) {
        _targetDescriptionArray = [NSMutableArray array];
    }
    return _targetDescriptionArray;
}
- (NSMutableArray *)articleListDateArray{
    if (!_articleListDateArray) {
        _articleListDateArray = [NSMutableArray array];
    }
    return _articleListDateArray;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSetTargetNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLaunchAdClickNotify object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
