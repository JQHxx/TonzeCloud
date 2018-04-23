//
//  ScaleHistoryViewController.m
//  Product
//
//  Created by vision on 17/5/8.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ScaleHistoryViewController.h"
#import "ScaleViewController.h"
#import "ScaleHistoryCell.h"
#import "ScaleModel.h"
#import "BlankView.h"

@interface ScaleHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray     *sectionArray;
    NSMutableArray     *scaleHistoryArray;
    NSInteger          page;
}

@property (nonatomic,strong)UITableView  *scaleTableView;
@property (nonatomic,strong)BlankView    *scaleBlankView;

@end

@implementation ScaleHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"历史记录";
    
    sectionArray=[[NSMutableArray alloc] init];
    scaleHistoryArray=[[NSMutableArray alloc] init];
    page=1;

    [self.view addSubview:self.scaleTableView];
    [self.view addSubview:self.scaleBlankView];
    self.scaleBlankView.hidden=YES;
    
    [self requestScaleHistoryData];
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return scaleHistoryArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dict=scaleHistoryArray[section];
    NSString *dateStr=sectionArray[section];
    NSArray *list=[dict valueForKey:dateStr];
    return list.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return sectionArray[section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdntifier=@"ScaleHistoryCell";
    ScaleHistoryCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdntifier];
    if (cell==nil) {
        cell=[[ScaleHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdntifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *dict=scaleHistoryArray[indexPath.section];
    NSString *dateStr=sectionArray[indexPath.section];
    NSArray *scalelist=[dict valueForKey:dateStr];
    ScaleModel *model =scalelist[indexPath.row];
    [cell scaleCellDisplayWithModel:model];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict=scaleHistoryArray[indexPath.section];
    NSString *dateStr=sectionArray[indexPath.section];
    NSArray *scalelist=[dict valueForKey:dateStr];
    ScaleModel *model =scalelist[indexPath.row];
    
    ScaleViewController *scaleVC=[[ScaleViewController alloc] init];
    scaleVC.scaleModel=model;
    scaleVC.user_id = model.user_id;
    scaleVC.record_id = model.constitution_analyzer_id;
    scaleVC.shareScore = model.score;
    [self.navigationController pushViewController:scaleVC animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}


#pragma mark -- Private methods
#pragma mark  加载最新记录
-(void)loadNewRecordData{
    page=1;
    [self requestScaleHistoryData];
}

#pragma mark 加载更多记录
-(void)loadMoreRecordData{
    page++;
    [self requestScaleHistoryData];
}

#pragma mark 加载体指标记录
-(void)requestScaleHistoryData{
    NSString *body=[NSString stringWithFormat:@"page_num=%ld&page_size=20&way=2&type=2",(long)page];
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kWeightRecordList body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            self.scaleBlankView.hidden=YES;
            NSArray *tempDateArr=[result allKeys];
            tempDateArr=[tempDateArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj2 compare:obj1]; //降序
            }];
            if (page==1) {
                sectionArray=[NSMutableArray arrayWithArray:tempDateArr];
            }else{
                [sectionArray addObjectsFromArray:tempDateArr];
            }
            
            NSMutableArray *tempDataArr=[[NSMutableArray alloc] init];
            for (NSString *dateKey in tempDateArr) {
                NSArray *scaleArr=[result valueForKey:dateKey];
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dict in scaleArr) {
                    TJYUserModel *user=[TonzeHelpTool sharedTonzeHelpTool].user;
                    ScaleModel *model=[[ScaleModel alloc] init];
                    [model setValues:dict];
                    
                    model.age=model.age>0?model.age:user.age;
                    model.sex=model.sex==3?user.sex:model.sex;
                    model.height=kIsEmptyString(model.height)?user.height:model.height;
                    [tempArr addObject:model];
                }
                NSDictionary *data=[[NSDictionary alloc] initWithObjectsAndKeys:tempArr,dateKey, nil];
                [tempDataArr addObject:data];
            }
            if (page==1) {
                scaleHistoryArray =tempDataArr;
            }else{
                [scaleHistoryArray addObjectsFromArray:tempDataArr];
            }
        }else{
            scaleHistoryArray=[[NSMutableArray alloc] init];
            self.scaleBlankView.hidden=NO;
        }
        [self.scaleTableView reloadData];
        [self.scaleTableView.mj_header endRefreshing];
        [self.scaleTableView.mj_footer endRefreshing];
    } failure:^(NSString *errorStr) {
        [self.scaleTableView.mj_header endRefreshing];
        [self.scaleTableView.mj_footer endRefreshing];
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}


#pragma mark -- Setters and Getters
#pragma mark 体指标历史记录
-(UITableView *)scaleTableView{
    if (!_scaleTableView) {
        _scaleTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight) style:UITableViewStyleGrouped];
        _scaleTableView.delegate=self;
        _scaleTableView.dataSource=self;
        _scaleTableView.showsVerticalScrollIndicator=NO;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewRecordData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.lastUpdatedTimeLabel.hidden=YES;  //隐藏时间
        _scaleTableView.mj_header=header;
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreRecordData)];
        footer.automaticallyRefresh = NO;// 禁止自动加载
        _scaleTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _scaleTableView;
}

-(BlankView *)scaleBlankView{
    if (!_scaleBlankView) {
        _scaleBlankView=[[BlankView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 200) img:@"img_pub_none" text:@"暂无体指标记录"];
    }
    return _scaleBlankView;
}


@end
