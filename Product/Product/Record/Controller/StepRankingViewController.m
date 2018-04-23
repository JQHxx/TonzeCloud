//
//  StepRankingViewController.m
//  Product
//
//  Created by vision on 17/5/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StepRankingViewController.h"
#import "StepRankModel.h"
#import "RankTableViewCell.h"
#import "RankHeadView.h"
#import "TJYUserModel.h"

@interface StepRankingViewController ()<UITableViewDelegate,UITableViewDataSource>{
    StepRankModel        *myRankModel;
    NSMutableArray       *rankArray;
}

@property(nonatomic,strong)UITableView  *rankTableView;

@end

@implementation StepRankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"步数排行榜";
    
    rankArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.rankTableView];
    
    [self requestStepRanking];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-04-01" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"005-04-01" type:2];
#endif
}


#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return rankArray.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*150/375+70)];
    view.backgroundColor=[UIColor bgColor_Gray];
    if (rankArray.count>0) {
        RankHeadView *headView=[[RankHeadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*150/375+60)];
        headView.myRank=myRankModel;
        [view addSubview:headView];
    }
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"RankTableViewCell";
    RankTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[RankTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    if (indexPath.row==0) {
        cell.imgView.image = [UIImage imageNamed:@"walk_ic_medal_01"];
    } else if(indexPath.row==1) {
        cell.imgView.image = [UIImage imageNamed:@"walk_ic_medal_02"];
    }else if(indexPath.row==2){
        cell.imgView.image = [UIImage imageNamed:@"walk_ic_medal_03"];
    }
    StepRankModel *stepModel=rankArray[indexPath.row];
    [cell rankCellDisplayWithModel:stepModel];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kScreenWidth*150/375+70;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 58;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}


#pragma mark Private Methods
-(void)requestStepRanking{
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kStepRank body:nil success:^(id json) {
        NSArray *result=[json objectForKey:@"result"];
        if (kIsArray(result)&&result.count>0) {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            NSInteger userID=[[NSUserDefaultInfos getValueforKey:kUserID] integerValue];
            for (NSDictionary *dict in result) {
                StepRankModel *rankModel=[[StepRankModel alloc] init];
                [rankModel setValues:dict];
                [tempArr addObject:rankModel];
                
                if (userID==rankModel.user_id) {
                    myRankModel=rankModel;
                }
            }
            rankArray=tempArr;
            [self.rankTableView reloadData];
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- Setters and Getters
-(UITableView *)rankTableView{
    if (!_rankTableView) {
        _rankTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight) style:UITableViewStylePlain];
        _rankTableView.dataSource=self;
        _rankTableView.delegate=self;
        _rankTableView.showsVerticalScrollIndicator=NO;
        _rankTableView.tableFooterView=[[UIView alloc] init];
        _rankTableView.backgroundColor=[UIColor bgColor_Gray];
    }
    return _rankTableView;
}


@end
