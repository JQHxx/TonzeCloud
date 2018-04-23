//
//  SportViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SportViewController.h"
#import "SportTableViewCell.h"
#import "FoodMenuView.h"
#import "SportTableModel.h"

@interface SportViewController ()<UITableViewDelegate,UITableViewDataSource,FoodMenuViewDelegate>{

    NSInteger  page;
    NSMutableArray *typeArray;
    NSMutableArray *sportTableArray;
    NSInteger           selectIndex;
    

}
@property (nonatomic,strong)FoodMenuView      *menuView;          //菜单栏
@property (nonatomic,strong)UITableView *sportTypeTableView;
@property (nonatomic,strong)BlankView         *sportBlankView;

@end
@implementation SportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"运动类型";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    page = 1;
    selectIndex = 0;
    typeArray = [[NSMutableArray alloc] init];
    sportTableArray = [[NSMutableArray alloc] init];

    [typeArray addObject:@""];
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.sportTypeTableView];
    [self.sportTypeTableView addSubview:self.sportBlankView];
    _sportBlankView.hidden = YES;
    
    [self requestSportMenuData];
}
#pragma mark  TCMenuViewDelegate
-(void)foodMenuView:(FoodMenuView *)menuView actionWithIndex:(NSInteger)index{
    selectIndex=index;
    page=1;
    [self requestSportTable:typeArray[index]];
    
}
#pragma mark -- UITableViewDelegate and UITableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return sportTableArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"SportTableViewCell";
    SportTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"SportTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    SportTableModel *model = sportTableArray[indexPath.row];
    [cell cellSportDisplayWith:model];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     SportTableModel *model = sportTableArray[indexPath.row];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%ld",model.calorie] forKey:@"calory"];
    [dict setObject:model.name forKey:@"name"];
    [dict setObject:[NSString stringWithFormat:@"%ld",model.motion_id] forKey:@"sportid"];
    if ([_controllerDelegate respondsToSelector:@selector(sportsViewControllerDidSelectDict:)]) {
        [_controllerDelegate sportsViewControllerDidSelectDict:dict];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- Event Response
#pragma mark -- 左／右滑
-(void)swipSportTableView:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        selectIndex++;
        if (selectIndex>typeArray.count-1) {
            selectIndex=typeArray.count-1;
            return;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        selectIndex--;
        if (selectIndex<0) {
            selectIndex=0;
            return;
        }
    }
    UIButton *btn;
    for (UIView *view in self.menuView.rootScrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&(view.tag == selectIndex+100)) {
            btn = (UIButton*)view;
        }
    }
    [self.menuView changeFoodViewWithButton:btn];
}
#pragma mark 加载最新食材
-(void)loadNewSportData{
    page=1;
    [self requestSportTable:typeArray[selectIndex]];
}

#pragma mark 加载更多食材
-(void)loadMoreSportData{
    page++;
    [self requestSportTable:typeArray[selectIndex]];
}
#pragma mark -- 获取运动分类数据
- (void)requestSportMenuData{
    
    NSMutableArray *titleArray = [[NSMutableArray alloc] init];
    [titleArray addObject:@"常用"];
    NSString *body = nil;

    body =@"";
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kSportRecordMenu body:body success:^(id json) {
        
        NSArray *dataArray = [json objectForKey:@"result"];
        for (int i=0; i<dataArray.count; i++) {
            [titleArray addObject:[dataArray[i] objectForKey:@"name"]];
            [typeArray addObject:[dataArray[i] objectForKey:@"motion_type"]];
        }
        self.menuView.foodMenusArray = titleArray;
        [self requestSportTable:typeArray[0]];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
- (void)requestSportTable:(NSString *)type{
    NSString *body = nil;
    body = [NSString stringWithFormat:@"page_size=20&page_num=%ld&motion_type=%@&&motion_record_id=%ld",page,type,self.motion_record_id];
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kSportRecordTable body:body success:^(id json) {
        
        NSDictionary *pager=[json objectForKey:@"pager"];
        if (kIsDictionary(pager)&&pager.count>0) {
            NSInteger totalValues=[[pager valueForKey:@"pagecount"] integerValue];
            self.sportTypeTableView.mj_footer.hidden=(totalValues-page)<=0;
        }
        NSArray *dataArray = [json objectForKey:@"result"];
        
        NSMutableArray *modelArray = [[NSMutableArray alloc] init];
        for (int i=0; i<dataArray.count; i++) {
            SportTableModel *model = [[SportTableModel alloc] init];
            [model setValues:dataArray[i]];
            [modelArray addObject:model];
        }
        if (page==1) {
            sportTableArray = modelArray;
            self.sportBlankView.hidden=sportTableArray.count>0;
        } else {
            [sportTableArray addObjectsFromArray:modelArray];
        }
        [self.sportTypeTableView reloadData];
        [self.sportTypeTableView.mj_header endRefreshing];
        [self.sportTypeTableView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
    
}
#pragma mark -- Getters and Setters
#pragma mark 菜单栏
-(FoodMenuView *)menuView{
    if (_menuView==nil) {
        _menuView=[[FoodMenuView alloc] initWithFrame:CGRectMake(0,64, kScreenWidth, 40)];
        _menuView.delegate=self;
    }
    return _menuView;
}
#pragma mark 个人数据
-(UITableView *)sportTypeTableView{
    if (_sportTypeTableView==nil) {
        _sportTypeTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, _menuView.bottom, kScreenWidth, kScreenHeight-_menuView.bottom) style:UITableViewStylePlain];
        _sportTypeTableView.delegate=self;
        _sportTypeTableView.dataSource=self;
        _sportTypeTableView.showsVerticalScrollIndicator=NO;
        _sportTypeTableView.tableFooterView=[[UIView alloc] init];
        
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewSportData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _sportTypeTableView.mj_header=header;
        
        // 上拉加载更多
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreSportData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _sportTypeTableView.mj_footer = footer;
        footer.hidden=YES;

        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipSportTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_sportTypeTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipSportTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_sportTypeTableView addGestureRecognizer:swipGestureRight];

    }
    return _sportTypeTableView;
}
#pragma mark 无数据空白页
-(BlankView *)sportBlankView{
    if (_sportBlankView==nil) {
        _sportBlankView=[[BlankView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 200) img:@"img_tips_no" text:@"该分类下暂无食材"];
    }
    return _sportBlankView;
}

@end
