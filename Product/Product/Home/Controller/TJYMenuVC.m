//
//  TJYMenuVC.m
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYMenuVC.h"
#import "TJYMenuCell.h"
#import "TJYMenuDetailsVC.h"
#import "TJYSearchFoodVC.h"
#import "DOPDropDownMenu.h"
#import "TJYMenuListModel.h"
#import "TJYEquipmentModel.h"
#import "TJYMenuFilterView.h"
#import "TJYEffectModel.h"

@interface TJYMenuVC ()<UICollectionViewDelegate,UICollectionViewDataSource,DOPDropDownMenuDataSource,DOPDropDownMenuDelegate>{
    NSInteger _MenuType;/// 菜谱类型
    NSInteger _equipment;/// 设备标识
    NSInteger _heatType;/// 热量标识
    NSString * _effectType;/// 功效标识

    NSInteger _page;
    BOOL _isSetFlowLayout;/// 是否改变布局
    
    NSInteger _menuIndex;/// 菜谱序列
    NSInteger _deviceIndex;/// 设备序列
    NSMutableArray * _arrayEffectIndex;/// 功效序列

}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic ,strong) UICollectionViewFlowLayout *flowLayout;
/// 下拉菜谱数据
@property (nonatomic, strong) NSMutableArray *menuListArray;
/// 菜谱列表id
@property (nonatomic, strong) NSMutableArray *menuListIdArray;

/// 设备列表数据
@property (nonatomic, strong) NSMutableArray *equipmentListArray;
/// 设备列表id
@property (nonatomic, strong) NSMutableArray *equipmentIdArray;

/// 下拉热量数据
@property (nonatomic, strong) NSMutableArray *heatListArray;

/// 功效列表数据
@property (nonatomic, strong) NSMutableArray *effectListArray;
/// 功效列表id
@property (nonatomic, strong) NSMutableArray *effectIdArray;

@property (nonatomic ,strong) TJYMenuCell*menuCell;

@property (nonatomic ,strong) NSMutableArray *dataSource;
/// 下拉选择框
@property (nonatomic ,strong) DOPDropDownMenu *menu;
/// 无数据页面
@property (nonatomic ,strong) BlankView    *blankView;

@end

@implementation TJYMenuVC

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"菜谱";
    self.isHiddenNavBar = YES;
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self menuSetData];
    [self setNavigation];
    [self buildUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-03-01" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-03-01" type:2];
#endif
}

#pragma mark -- setNavigation
/** 导航栏 **/
- (void)setNavigation{
    UIView *navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    navigationView.backgroundColor  = kSystemColor;
    [self.view addSubview:navigationView];
    
    UIButton *backBtn = InsertButtonWithType(navigationView, CGRectMake(5, 22, 40, 40), 1000, self, @selector(leftButtonAction), UIButtonTypeCustom);
    [backBtn setImage:[UIImage drawImageWithName:@"back.png" size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
    
    UIButton *serarchBtn =  InsertButtonWithType(navigationView, CGRectMake(kScreenWidth - 50, 22 , 40, 40), 1000, self, @selector(rightButClick:), UIButtonTypeCustom);
    [serarchBtn setImage:[UIImage imageNamed:@"ic_top_search"] forState:UIControlStateNormal];
    
    UIButton *setBtn = InsertButtonWithType(navigationView, CGRectMake(kScreenWidth - 90, 22 , 40, 40), 1001, self, @selector(rightButClick:), UIButtonTypeCustom);
    [setBtn setImage:[UIImage imageNamed:@"ic_top_list"] forState:UIControlStateNormal];
    [setBtn setImage:[UIImage imageNamed:@"ic_top_card"] forState:UIControlStateSelected];
    
    InsertLabel(navigationView, CGRectMake((SCREEN_WIDTH-150)/2, 20, 150, 44), NSTextAlignmentCenter, @"菜谱", kFontSize(18), [UIColor whiteColor], NO);
}
#pragma mark -- Build UI
- (void)buildUI{
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.menu];

    kSelfWeak;
    // 处理筛选点击
    self.menu.handleTag = 1;
    self.menu.dropDownMenuBlock = ^(){
        [weakSelf onBtnFilter:nil];
    };
}
#pragma mark -- Request Data
- (void)menuSetData{
    NSArray *menuArray = @[@"云菜谱", @"普通菜谱"];
    self.menuListArray = [NSMutableArray arrayWithArray:menuArray];
    self.menuListIdArray = [NSMutableArray arrayWithObjects:@"1",@"2",nil];
    self.heatListArray = [NSMutableArray arrayWithObjects:@"默认",@"热量由低到高",@"热量由高到低", nil];

    _page = 1;
    _isSetFlowLayout = NO;
    _MenuType = 0;
    _equipment = 0;
    
    _menuIndex = -1;
    _deviceIndex = -1;
    _effectType = @"";
    _arrayEffectIndex = [NSMutableArray array];
    
    // 获取设备
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] getMethodWithURL:KEquipment isLoading:YES success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        
        if (resultArray.count > 0 && kIsArray(resultArray)) {
            for (NSDictionary *dic in resultArray) {
                TJYEquipmentModel *equipmentModel = [TJYEquipmentModel  new];
                [equipmentModel setValues:dic];
                [weakSelf.equipmentIdArray addObject:equipmentModel.id];
                [weakSelf.equipmentListArray addObject:equipmentModel.name];
            }
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
    
    // 获取功效
    [[NetworkTool sharedNetworkTool] getMethodWithURL:KEffect isLoading:YES success:^(id json) {
        NSArray *resultArray = [json objectForKey:@"result"];
        
        if (resultArray.count > 0 && kIsArray(resultArray)) {
            for (NSDictionary *dic in resultArray) {
                TJYEffectModel * model = [TJYEffectModel  new];
                [model setValues:dic];
                [weakSelf.effectIdArray addObject:model.effect_id];
                [weakSelf.effectListArray addObject:model.name];
            }
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
    
    [self menuRequestData];
}
- (void)menuRequestData{
    NSString *urlStr = [NSString stringWithFormat:@"type=%ld&page_num=%ld&page_size=20&equipment=%ld&order=%ld&effect=%@",(long)_MenuType,(long)_page,(long)_equipment,(long)_heatType,_effectType];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postMethodWithURL:kMenuList body:urlStr success:^(id json) {
        NSMutableArray *resultArr = [json objectForKey:@"result"];
        NSInteger totalNumber = [[json objectForKey:@"total_num"] integerValue];
        weakSelf.collectionView.mj_footer.hidden=(totalNumber-_page*20)<=0;
        NSMutableArray *dataArr = [NSMutableArray array];
        if (resultArr.count > 0 && kIsArray(dataArr)) {
            weakSelf.blankView.hidden = YES;
            for (NSDictionary *dic  in resultArr) {
                TJYMenuListModel *menuListModel = [TJYMenuListModel new];
                [menuListModel setValues:dic];
                [dataArr addObject:menuListModel];
            }
            if (_page==1) {
                [weakSelf.dataSource removeAllObjects];
                [weakSelf.dataSource addObjectsFromArray:dataArr];
                weakSelf.blankView.hidden = resultArr.count > 0;
                weakSelf.collectionView.mj_footer.hidden=resultArr.count<20;
            }else{
                [weakSelf.dataSource addObjectsFromArray:dataArr];
            }
        }else{
            // 上拉无数据直接隐藏上拉刷新
            if (_page == 1) {
                [weakSelf.dataSource removeAllObjects];
                weakSelf.blankView.hidden = resultArr.count > 0;
            }
            weakSelf.collectionView.mj_footer.hidden=YES;
        }
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer endRefreshing];
        [weakSelf.collectionView reloadData];
    } failure:^(NSString *errorStr) {
        weakSelf.blankView.hidden = NO;
        weakSelf.collectionView.mj_footer.hidden = YES;
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.collectionView.mj_footer endRefreshing];
        [weakSelf.collectionView reloadData];
//        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- loadMoreFoodData  with loadNewFoodData
/// - 加载更多
- (void)loadMoreFoodData{
    _page++;
    [self menuRequestData];
}
/// 加载最新
- (void)loadNewFoodData{
    _page = 1;
    [self menuRequestData];
}
#pragma mark 头部显示的内容

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *ReusableView  = [collectionView dequeueReusableSupplementaryViewOfKind:
                                               UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
    return ReusableView ;
}
#pragma mark - UICollectionView delegate dataSource
#pragma mark 定义展示的UICollectionViewCell的个数

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
#pragma mark 每个UICollectionView展示的内容

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    _menuCell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    TJYMenuListModel *menuListModel = self.dataSource[indexPath.row];
    [_menuCell cellInitWithMenuListModel:menuListModel];
    
    if (_isSetFlowLayout) {
        [_menuCell UpdateLineFrame];
    }else{
        [_menuCell updataWaterfallsFlowFrame];
    }
    [_menuCell sizeToFit];
    
    return _menuCell;
}
#pragma mark -- item 点击

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TJYMenuDetailsVC *menuDetailsVC = [TJYMenuDetailsVC new];
    kSelfWeak;
    menuDetailsVC.likeClickBlock= ^(BOOL isLike){
            NSMutableArray *arr = [NSMutableArray array];
            for (NSInteger i = 0; i < weakSelf.dataSource.count ; i++) {
                TJYMenuListModel *model = weakSelf.dataSource[i];
                if (i == indexPath.row) {
                    if (isLike) {
                        model.like_number = model.like_number + 1;
                    }else{
                        model.like_number = model.like_number - 1;
                    }
                }
                [arr addObject:model];
            }
            weakSelf.dataSource = arr;
            [weakSelf.collectionView reloadData];
    };
    TJYMenuListModel *menuListModel = _dataSource[indexPath.row];
    menuDetailsVC.menuid = menuListModel.cook_id;
    menuDetailsVC.is_Yun = menuListModel.is_yun;
    [self push:menuDetailsVC];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSInteger i = 0; i < _dataSource.count ; i++) {
        TJYMenuListModel *model = _dataSource[i];
        if (i == indexPath.row) {
            model.reading_number = model.reading_number + 1;
        }
        [arr addObject:model];
    }
    _dataSource = arr;
    [_collectionView reloadData];
}
#pragma mark -- DOPDropDownMenuDataSource,DOPDropDownMenuDelegate

- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu{
    return 2;
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column{
    if (column == 0) {
        return _heatListArray.count;
    }else {
        return 1;
    }
}
- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath{
    if (indexPath.column == 0) {
        return _heatListArray[indexPath.row];
    } else {
        return @"筛选";
    }
}
- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfItemsInRow:(NSInteger)row column:(NSInteger)column{
    return 0;
}
- (NSString *)menu:(DOPDropDownMenu *)menu titleForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath{
    return nil;
}
- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath{
    
    switch (indexPath.column) {
        case 0:
        {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-03-02"];
#endif
            if (_heatType!= indexPath.row) {
                _page = 1;
            }
            _heatType = indexPath.row;
            [_dataSource removeAllObjects];
            [self menuRequestData];
        }break;
        case 1:
        {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-03-03"];
#endif
            _equipment = indexPath.row;
            _page = 1;
            [_dataSource removeAllObjects];
            [self menuRequestData];
        }
        default:
            break;
    }
}

#pragma mark -- rightBtn Action

- (void)rightButClick:(UIButton *)btn{
    btn.selected=!btn.selected;
    
    switch (btn.tag) {
        case 1000:
        { // 跳转到搜索
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-03-05"];
#endif
            [TonzeHelpTool sharedTonzeHelpTool].searchType=MenuSearchType;
            TJYSearchFoodVC *search = [TJYSearchFoodVC new];
            search.searchType = MenuSearchType;
            [self push:search];
        }break;
        case 1001:
        {// 改变布局
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-03-04"];
#endif
            if (!_isSetFlowLayout) {
                _flowLayout.itemSize = CGSizeMake(kScreenWidth, 90 * kScreenWidth/320);
                _flowLayout.minimumInteritemSpacing = 0;
                _flowLayout.minimumLineSpacing = 0;
                _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);//上左下右
                [_collectionView reloadData];
            }else{
                _flowLayout.itemSize = CGSizeMake((kScreenWidth-27)/2, 120 * kScreenWidth/320 + 70);
                _flowLayout.minimumLineSpacing = 9;//定义横向的间距
                _flowLayout.minimumInteritemSpacing = 9;
                _flowLayout.sectionInset = UIEdgeInsetsMake(9, 9, 9, 9);//上左下右
                [_collectionView reloadData];
            }
            _isSetFlowLayout = !_isSetFlowLayout;
            
        }break;
        default:
            break;
    }
}

-(void)onBtnFilter:(id)sender
{

    kSelfWeak;
    TJYMenuFilterView * view = [[TJYMenuFilterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [view showMenuFilterView:self.view withDeviceArray:self.equipmentListArray withEffectArray:self.effectListArray];
    view.fillerBlock = ^(NSInteger menuIndex,NSInteger deviceIndex,NSMutableArray * arrayEffectIndex){
        // 处理筛选
        _menuIndex = menuIndex;
        _deviceIndex = deviceIndex;
        _MenuType = menuIndex != -1 ? [weakSelf.menuListIdArray[menuIndex] integerValue] : 0;
        if (_menuIndex==0) {
            _equipment = deviceIndex != -1 ? [weakSelf.equipmentIdArray[deviceIndex] integerValue] : 0;
        } else {
            _equipment = 0;
        }
        _arrayEffectIndex = arrayEffectIndex;
        [weakSelf handleEffectIndex];
        _page = 1;
        [weakSelf menuRequestData];
    };
    
    view.menuIndex = _menuIndex;
    view.deviceIndex = _deviceIndex;
    view.arrayEffectIndex = _arrayEffectIndex;
}

/**
 *  处理功效的id
 */
-(void)handleEffectIndex
{
    _effectType = @"";
    NSMutableArray * arrayId = [NSMutableArray array];
    for (int i = 0; i < _arrayEffectIndex.count; i++) {
        NSString * index = _arrayEffectIndex[i];
        
        NSString * effectId = self.effectIdArray[[index integerValue]];
        
        [arrayId addObject:effectId];
    }
    if ([arrayId count]!=0) {
        _effectType = [[NetworkTool sharedNetworkTool] getValueWithParams:arrayId];
    }
}

#pragma mark - 创建collectionView并设置代理

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64 +44, kScreenWidth, kBodyHeight - 44) collectionViewLayout:_flowLayout];
        //定义大小
        _flowLayout.itemSize = CGSizeMake((kScreenWidth-27)/2, 120 * kScreenWidth/320 + 70);
        //定义横向的间距
        _flowLayout.minimumLineSpacing = 9;
        //纵向的间距
        _flowLayout.minimumInteritemSpacing = 9;
        //定义每个的边距
        _flowLayout.sectionInset = UIEdgeInsetsMake(9, 9, 9, 9);//上左下右
        //注册cell和ReusableView（相当于头部）
        [_collectionView registerClass:[TJYMenuCell class] forCellWithReuseIdentifier:@"cell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];
        //设置代理
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        //背景颜色
        _collectionView.backgroundColor = UIColorHex(0xF5F9FA);
        //自适应大小
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewFoodData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _collectionView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreFoodData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _collectionView.mj_footer = footer;
        footer.hidden = YES;
        [_collectionView addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return _collectionView;
}

- (DOPDropDownMenu *)menu{
    if (!_menu) {
        _menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 64) andHeight:44];
        _menu.width = SCREEN_WIDTH;
        _menu.delegate = self;
        _menu.indicatorColor = kSystemColor;
        _menu.textColor = UIColorHex(0x666666);
        _menu.textSelectedColor = kSystemColor;
        _menu.separatorColor = UIColorHex(0xd1d1d1);
        _menu.fontSize = 16;
        _menu.dataSource = self;
    }
    return _menu;
}
- (BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 +44) img:@"img_tips_no" text:@"暂无相关菜谱"];
    }
    return _blankView;
}
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (NSMutableArray *)equipmentListArray{
    if (!_equipmentListArray) {
        _equipmentListArray = [NSMutableArray array];
    }
    return _equipmentListArray;
}
- (NSMutableArray *)menuListArray
{
    if (!_menuListArray) {
        _menuListArray = [NSMutableArray array];
    }
    return _menuListArray;
}
- (NSMutableArray *)equipmentIdArray
{
    if (!_equipmentIdArray) {
        _equipmentIdArray = [NSMutableArray array];
    }
    return _equipmentIdArray;
}

- (NSMutableArray *)effectListArray
{
    if (!_effectListArray) {
        _effectListArray = [NSMutableArray array];
    }
    return _effectListArray;
}

- (NSMutableArray *)effectIdArray
{
    if (!_effectIdArray) {
        _effectIdArray = [NSMutableArray array];
    }
    return _effectIdArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
