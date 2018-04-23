//
//  TJEfficacyAndClassificationVC.m
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYFoodDetailsVC.h"
#import "TJEfficacyAndClassificationCell.h"
#import "TJYRelatedRecipesCell.h"
#import "TJYNutrientContentCell.h"
#import "TJYFoodNutritionVC.h"
#import "TJYFoodDetailsModel.h"
#import "TJYMenuListModel.h"
#import "TJYCommentsCell.h"
#import "TJYMenuDetailsVC.h"
#import "TJYFoodEffectCell.h"

@interface TJYFoodDetailsVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UIImageView *_foodImg;   /// 食物图片
    UILabel *_foodname;      /// 食材名称
    UILabel *_energykcalLabel;/// 能量
    CGFloat  _efficacyDescriptionArrayHight;    /// 功效说明文本高度
    BOOL  _isCollection;    /// 是否收藏
    NSInteger _page;        /// 页数记录
    NSString *_sectionTitleStr;
}
@property (nonatomic, strong) UITableView *tableView;
/// 元素类型
@property (nonatomic ,strong) NSArray *ingredientArray;
/// 元素数据
@property (nonatomic, strong) NSMutableArray *contentArray;

@property (nonatomic ,strong) TJYFoodDetailsModel *foodDetailsModel ;
/// 菜谱数据
@property (nonatomic, strong) NSMutableArray *menuListdataArr;
/// 功效说明
@property (nonatomic ,strong) NSArray *efficacyDescriptionArray;
/// 功效名称
@property (nonatomic ,strong) NSArray *effectNameArray;

@end

@implementation TJYFoodDetailsVC

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"食物详情";
    
    [self setFoodDetailUI];
    [self requestFoodDetailData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:[NSString stringWithFormat:@"004-02-05-%02ld",(long)self.food_id] type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:[NSString stringWithFormat:@"004-02-05-%02ld",(long)self.food_id] type:2];
#endif
}


#pragma mark -- Build UI

- (void)setFoodDetailUI{
    [self.view addSubview:self.tableView];
    if (_isCollection) {
        self.rightImageName = @"ic_top_collect_on";
    }else{
        self.rightImageName = @"ic_top_collect_un";
    }
}
#pragma mark -- request Data
/** 食物详情 **/
- (void)requestFoodDetailData{
    _page = 1;
    _menuListdataArr = [NSMutableArray array];
    _contentArray = [NSMutableArray array];
    _effectNameArray = [NSMutableArray array];
    _efficacyDescriptionArray = [NSMutableArray array];
    _ingredientArray = @[@"热量",@"碳水化合物",@"脂肪",@"蛋白质"];
    NSString *urlString = [NSString stringWithFormat:@"id=%ld",(long)_food_id];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postMethodWithURL:kFoodDetail body:urlString success:^(id json) {
        NSDictionary *dic = [json objectForKey:@"result"];
        if (kIsDictionary(dic)) {
            // 功效数据
            _effectNameArray = [dic objectForKey:@"effect_name"];
            _efficacyDescriptionArray = [dic objectForKey:@"efficacy_description"];
            
            weakSelf.foodDetailsModel= [TJYFoodDetailsModel new];
            [weakSelf.foodDetailsModel setValues:dic];
            
            [_foodImg sd_setImageWithURL:[NSURL URLWithString:_foodDetailsModel.image_url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
            _foodname.text = _foodDetailsModel.name;
            NSString *str = [NSString stringWithFormat:@"%ld千卡/100克",(long)_foodDetailsModel.energykcal];
            NSAttributedString *text = [NSString ql_changeRangeText:str noRangeInedex:7 changeColor:kSystemColor];
            _energykcalLabel.attributedText =text;
            
            [_contentArray addObject:[self string:weakSelf.foodDetailsModel.energykcal unit:@"千卡"]];
            [_contentArray addObject:[self string:weakSelf.foodDetailsModel.carbohydrate unit:@"克"]];
            [_contentArray addObject:[self string:weakSelf.foodDetailsModel.fat unit:@"克"]];
            [_contentArray addObject:[self string:weakSelf.foodDetailsModel.protein unit:@"克"]];
            _isCollection = weakSelf.foodDetailsModel.is_collection;
            
            if (_isCollection) {
                weakSelf.rightImageName = @"ic_top_collect_on";
            }else{
                weakSelf.rightImageName = @"ic_top_collect_un";
            }
        }
        [self requestMenuListData];
        [weakSelf.tableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
/***  请求关联菜谱数据 ***/
- (void)requestMenuListData{
    
    NSString *urlStr = [NSString stringWithFormat:@"page_num=%ld&page_size=20&ingredient=%ld",(long)_page,(long)_food_id];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postMethodWithURL:kMenuList body:urlStr success:^(id json) {
        NSMutableArray *resultArr = [json objectForKey:@"result"];
        NSInteger totalNumber = [[json objectForKey:@"total_num"] integerValue];
        weakSelf.tableView.mj_footer.hidden=(totalNumber-_page*20)<=0;
        
        NSMutableArray *dataArr = [NSMutableArray array];
        if (resultArr.count > 0) {
            for (NSDictionary *dic  in resultArr) {
                TJYMenuListModel *menuListModel = [TJYMenuListModel new];
                [menuListModel setValues:dic];
                [dataArr addObject:menuListModel];
            }
            if (_page==1) {
                [weakSelf.menuListdataArr removeAllObjects];
                [weakSelf.menuListdataArr addObjectsFromArray:dataArr];
                
            }else{
                [weakSelf.menuListdataArr addObjectsFromArray:dataArr];
            }
        }else{
            // 上拉无数据直接隐藏上拉刷新
            if (_page == 1) {
                [weakSelf.menuListdataArr removeAllObjects];
            }
            weakSelf.tableView.mj_footer.hidden=YES;
        }
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.tableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.tableView reloadData];
//        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 上拉加载数据
- (void)loadMoreFoodData{
    _page ++;
    [self requestMenuListData];
}
#pragma mark -- 拼接字符串
- (NSString *)string:(NSInteger)intvalue unit:(NSString *)unit{
    NSString *string = [[NSString alloc] init];
    string = intvalue==0?[NSString stringWithFormat:@"--%@",unit]:[NSString stringWithFormat:@"%ld%@",(long)intvalue,unit];
    return string;
}
#pragma mark -- tableHeaderView

- (UIView *)tableHeaderView{
    UIView *hearderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    hearderView.backgroundColor =[UIColor whiteColor];
    _foodImg = InsertImageView(hearderView, CGRectMake(15, 10, 40, 40), [UIImage imageNamed:@""]);
    _foodname =  InsertLabel(hearderView, CGRectMake(_foodImg.right + 8 , _foodImg.top , 200, 15), NSTextAlignmentLeft, @"", kFontSize(14), UIColorHex(0x333333), NO);
    _energykcalLabel = InsertLabel(hearderView, CGRectMake(_foodImg.right + 8 ,_foodname.bottom + 10 , 150, 15), NSTextAlignmentLeft, @"0千卡/100克", kFontSize(14), UIColorHex(0x333333), NO);
    return hearderView;
}
#pragma mark -- UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
        {
            return _effectNameArray.count > 0 ? 1 : 0;
        }break;
        case 1:
        {
            return _contentArray.count;
        }break;
        case 2:
        {
            return !kIsEmptyString(_foodDetailsModel.food_suggestion) ? 1 : 0;
        }break;
        case 3:
        {
            return _menuListdataArr.count;
        }
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
            CGFloat efficacyNameHight = [self calculateHeight];
            return _effectNameArray.count > 0 ? efficacyNameHight + 40 : 0.01f;
        }break;
        case 1:
        {
            return 40;
        }break;
        case 2:
        {
            CGFloat cellHight = [TJYCommentsCell tableView:tableView rowHeightForObject:_foodDetailsModel.food_suggestion];
            if (cellHight<48) {
                return 72;
            } else {
                return !kIsEmptyString(_foodDetailsModel.food_suggestion) ? cellHight + 40 : 0.01f;
            }
        }break;
        case 3:
        {
            return 90 *kScreenWidth/320;
        }break;
        default:
            break;
    }
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
        {
            return _effectNameArray.count > 0 ? 30 : 0.01f;
        }break;
        case 1:
        {
            return  30 ;
        }
        case 2:
        {
            return !kIsEmptyString(_foodDetailsModel.food_suggestion) ? 30 : 0.01;
        }break;
        case 3:
        {
            return _menuListdataArr.count > 0 ? 30 :0.01;
        }
        default:
            break;
    }
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 40;
    }
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    sectionView.backgroundColor = kBackgroundColor;
    UILabel *sectionTitle = InsertLabel(sectionView, CGRectMake(18, 7.5, 200, 15), NSTextAlignmentLeft,@"", kFontSize(14), UIColorHex(0x626262), NO);
    if (section == 0) {
        _sectionTitleStr = _effectNameArray.count > 0 ? @"功效" : @"";
    }else if (section == 1){
        _sectionTitleStr = @"营养成分(每100克)";
    }else if (section == 2){
        _sectionTitleStr = !kIsEmptyString(_foodDetailsModel.food_suggestion) ? @"营养点评" : @"";
    }else if (section == 3){
         _sectionTitleStr = _menuListdataArr.count > 0 ?@"关联菜谱" : @"";
    }
    sectionTitle.text = _sectionTitleStr;
    return sectionView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    sectionView.backgroundColor = [UIColor whiteColor];
    if (section == 1) {
        InsertView(sectionView, CGRectMake(0,0, kScreenWidth, 0.5), kLineColor);
        UIButton *elementBut = InsertButtonWithType(sectionView, CGRectMake(20, 0, kScreenWidth - 40, 40), 1000, self, @selector(moreBtnClick), UIButtonTypeCustom);
        [elementBut setTitle:@"更多营养" forState:UIControlStateNormal];
        elementBut.titleLabel.font = kFontSize(14);
        [elementBut setTitleColor:[UIColor colorWithHexString:@"0x626262"] forState:UIControlStateNormal];
        return sectionView;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *nutrientCellidentifier = @"nutrientCell";
    static NSString *commentsCellidentifier = @"commentsCell";
    static NSString *relatedRecipesCellidentifier = @"relatedRecipesCell";
    static NSString *foodEffectCellIdentifier = @"foodEffectCell";
    switch (indexPath.section) {
        case 0:
        {// 功效
            TJYFoodEffectCell *foodEffectCell = [[TJYFoodEffectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:foodEffectCellIdentifier];
            [foodEffectCell cellWithEffectNameArr:_effectNameArray efficacyDescriptionArr:_efficacyDescriptionArray hight:_efficacyDescriptionArrayHight];
            foodEffectCell.selectionStyle = UITableViewCellAccessoryNone;
            return foodEffectCell;
        }break;
        case 1:
        {// 营养成分
            TJYNutrientContentCell *nutrientCell = [[TJYNutrientContentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nutrientCellidentifier];
            nutrientCell.selectionStyle = UITableViewCellAccessoryNone;
            nutrientCell.ingredientTypeLabel.text = _ingredientArray[indexPath.row];
            NSString *contentStr = [NSString stringWithFormat:@"%@",_contentArray[indexPath.row]];
            nutrientCell.contentLabel.text = contentStr;
            return nutrientCell;
        }break;
        case 2:
        {// 营养点评
            TJYCommentsCell *commentsCell = [[TJYCommentsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentsCellidentifier];
            [commentsCell setCellDataWithStr:_foodDetailsModel.food_suggestion];
            return commentsCell;
        }break;
        default:
            break;
    }
    /* 关联菜谱 */
    TJYRelatedRecipesCell *relatedRecipesCell = [[TJYRelatedRecipesCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:relatedRecipesCellidentifier];
    [relatedRecipesCell cellInitWithData:_menuListdataArr[indexPath.row] searchText:@""];
    relatedRecipesCell.selectionStyle = UITableViewCellAccessoryNone;
    return  relatedRecipesCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 3:
        {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-02-09"];
#endif
            TJYMenuDetailsVC *menuDetailsVC = [TJYMenuDetailsVC new];
            TJYMenuListModel *menuListModel = _menuListdataArr[indexPath.row];
            menuDetailsVC.menuid = menuListModel.cook_id;
            [self push:menuDetailsVC];
            /*** 处理点赞和阅读的数量 **/
            kSelfWeak;
            menuDetailsVC.likeClickBlock= ^(BOOL isLike){
                NSMutableArray *arr = [NSMutableArray array];
                for (NSInteger i = 0; i < weakSelf.menuListdataArr.count ; i++) {
                    TJYMenuListModel *model = weakSelf.menuListdataArr[i];
                    if (i == indexPath.row) {
                        if (isLike) {
                            model.like_number = model.like_number + 1;
                        }else{
                            model.like_number = model.like_number - 1;
                        }
                    }
                    [arr addObject:model];
                }
                weakSelf.menuListdataArr = arr;
                [weakSelf.tableView reloadData];
            };
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSInteger i = 0; i < weakSelf.menuListdataArr.count ; i++) {
                TJYMenuListModel *model = weakSelf.menuListdataArr[i];
                if (i == indexPath.row) {
                    model.reading_number = model.reading_number + 1;
                }
                [arr addObject:model];
            }
             weakSelf.menuListdataArr = arr;
            [weakSelf.tableView reloadData];
        }break;
        default:
            break;
    }
}
// 计算功效内容最大高度
- (CGFloat)calculateHeight{

    NSArray *a0 = [_efficacyDescriptionArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSUInteger len0 = [(NSString *)obj1 length];
        NSUInteger len1 = [(NSString *)obj2 length];
        return len0 > len1 ? NSOrderedAscending : NSOrderedDescending;
    }];
    CGSize detailSize = [a0[0] boundingRectWithSize:CGSizeMake(kScreenWidth - 30, 1000) withTextFont:kFontSize(12)];
    _efficacyDescriptionArrayHight = detailSize.height;

    return _efficacyDescriptionArrayHight;
}
#pragma mark --- rightButtonAction
// 收藏
- (void)rightButtonAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-02-06"];
#endif
    if (_isCollection) {
        self.rightImageName = @"ic_top_collect_un";
    }else{
        self.rightImageName = @"ic_top_collect_on";
    }
    if (kIsLogined) {
        NSString *body = [NSString stringWithFormat:@"target_type=ingredient&doSubmit=1&target_id=%ld",(long)self.food_id];
        kSelfWeak;
        [[NetworkTool sharedNetworkTool]postMethodWithURL:KCollection body:body success:^(id json) {
            NSInteger status  = [[json objectForKey:@"status"] integerValue];
            NSString *messageStr = [json objectForKey:@"message"];
            if (status== 1) {
                [TJYHelper sharedTJYHelper].isReloadHome = YES;
                _isCollection =!_isCollection;
                [weakSelf.view makeToast:messageStr duration:1.0 position:CSToastPositionCenter];
            }
        } failure:^(NSString *errorStr) {
            if (_isCollection) {
                self.rightImageName = @"ic_top_collect_on";
            }else{
                self.rightImageName = @"ic_top_collect_un";
            }
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }else{
        [self pushToFastLogin];
    }
}
/// 更多元素
- (void)moreBtnClick{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-02-07"];
#endif
    TJYFoodNutritionVC *foodNutritionVC = [TJYFoodNutritionVC new];
    foodNutritionVC.foodDetailsModel = self.foodDetailsModel;
    [self push:foodNutritionVC];
}
#pragma mark -- getter ---

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,64, kScreenWidth, kBodyHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = [self tableHeaderView];
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreFoodData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _tableView.mj_footer = footer;
        footer.hidden = YES;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
