//
//  TJYEvaluationTestView.m
//  Product
//
//  Created by zhuqinlu on 2017/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYEvaluationTestVC.h"
#import "TJYEvaluationTestCell.h"
#import "TJYEvaluationResultViewController.h"
#import "TJYHealthContentModel.h"
#import "TJYHealthScoreModel.h"
#import "TJYHealthAssessmentVC.h"

@interface TJYEvaluationTestVC ()<UITableViewDelegate,UITableViewDataSource>{

    NSInteger seletedPage;
    NSMutableArray *seletedArray;
    NSMutableArray *healthContentArray;
    NSMutableArray *scoreArray;
}

@property (nonatomic, strong) UITableView *tableView;
/// 题目内容
@property (nonatomic, copy) UILabel *contentLable;

@end

@implementation TJYEvaluationTestVC

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    self.baseTitle = self.titleStr;
    
    seletedPage=0;
    seletedArray = [[NSMutableArray alloc] init];
    healthContentArray = [[NSMutableArray alloc] init];
    scoreArray = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.tableView];
    [self requestHealthDetailData];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-05-02" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"004-05-02" type:2];
#endif
}

- (void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
    if ([TJYHelper sharedTJYHelper].isHealthScore == YES) {
        [TJYHelper sharedTJYHelper].isHealthScore =  NO;
        seletedPage=0;
        seletedArray = [[NSMutableArray alloc] init];
        [self loadHealthListData];
    }
}

#pragma mark -- UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (healthContentArray.count>0) {
        TJYHealthContentModel *contentModel = healthContentArray[seletedPage==healthContentArray.count?seletedPage-1:seletedPage];
        NSArray *dict = contentModel.answer;
        return dict.count;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TJYEvaluationTestCell";
    TJYEvaluationTestCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TJYEvaluationTestCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    TJYHealthContentModel *contentModel = healthContentArray[seletedPage==healthContentArray.count?seletedPage-1:seletedPage];
    NSArray *dict = contentModel.answer;
    cell.optionLable.text = [dict[indexPath.row] objectForKey:@"name"];

    if (seletedArray.count>seletedPage) {
        if (indexPath.row+1 == [seletedArray[seletedPage] integerValue]) {
            cell.seletedImg.image = [UIImage imageNamed:@"ic_pub_pick"];
        }else{
            cell.seletedImg.image = [UIImage imageNamed:@"ic_pub_choose_nor"];
        }
    }else if(seletedPage== healthContentArray.count){
        if (indexPath.row+1 == [seletedArray[seletedPage-1] integerValue]) {
            cell.seletedImg.image = [UIImage imageNamed:@"ic_pub_pick"];
        }else{
            cell.seletedImg.image = [UIImage imageNamed:@"ic_pub_choose_nor"];
        }
    }
    else {
        cell.seletedImg.image = [UIImage imageNamed:@"ic_pub_choose_nor"];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-05-02"];
#endif
    [self performSelector:@selector(initContentView) withObject:nil afterDelay:0.3];
    if (seletedArray.count>0) {
        if (seletedArray.count==seletedPage) {
            [seletedArray replaceObjectAtIndex:seletedPage-1 withObject:[NSString stringWithFormat:@"%ld",(long)(indexPath.row+1)]];
        } else {
            [seletedArray replaceObjectAtIndex:seletedPage withObject:[NSString stringWithFormat:@"%ld",(long)(indexPath.row+1)]];
            
        }
    }
    [self.tableView reloadData];
}
#pragma mark -- 延迟0.3秒执行
- (void)initContentView{
    if (seletedPage<healthContentArray.count) {
        seletedPage++;
    }
    if (seletedPage<healthContentArray.count) {
        //创建CATransition对象
        CATransition *animation = [CATransition animation];
        //设置时间
        animation.duration = 0.2f;
        //设置类型
        animation.type = kCATransitionMoveIn;
        //设置方向
        animation.subtype = kCATransitionFromRight;
        //设置运动速度变化
        animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
        
        [self.tableView.layer addAnimation:animation forKey:@"animation"];
    }
    [self.tableView reloadData];

}
#pragma mark -- TabeleHeaderView
- (UIView *)tableViewHeaderView{
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0,64, kScreenWidth, 300)];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 45, 60, 20)];
    if (healthContentArray.count>0) {
        [button setBackgroundImage:[UIImage imageNamed:@"btn_pingu_mark"] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%ld/%ld",seletedPage+1>healthContentArray.count?seletedPage:seletedPage+1,healthContentArray.count] forState:UIControlStateNormal];
        button.titleLabel.textColor = [UIColor whiteColor];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    [headerView addSubview:button];
    
    NSString *contentText = nil;
    if (healthContentArray.count>0) {
        if (seletedPage == healthContentArray.count) {
            TJYHealthContentModel *contentModel = healthContentArray[seletedPage-1];
            contentText  = contentModel.name;
        }
        else{
        TJYHealthContentModel *contentModel = healthContentArray[seletedPage];
        contentText  = contentModel.name;
    }
    }
    CGSize contentTextSize = [contentText boundingRectWithSize:CGSizeMake(kScreenWidth - 40, 300) withTextFont:kFontSize(24)];
    
    _contentLable = InsertLabel(headerView,CGRectMake(20, button.bottom+8, contentTextSize.width, contentTextSize.height) , NSTextAlignmentLeft, contentText, kFontSize(24), UIColorHex(0x666666), YES);
    headerView.frame = CGRectMake(0, 64, kScreenWidth, _contentLable.bottom + 30);
    
    return headerView;
}
#pragma mark -- 重新加载健康内容
- (void)loadHealthListData{
    for (int i=0; i<healthContentArray.count; i++) {
        [seletedArray addObject:@"0"];
    }
     healthContentArray = [NSMutableArray arrayWithArray:[TJYHelper sharedTJYHelper].healthList];
     scoreArray = [NSMutableArray arrayWithArray:[TJYHelper sharedTJYHelper].healthResult];
    [self.tableView reloadData];

}
#pragma mark -- 获取健康评估内容
- (void)requestHealthDetailData{
    NSString *body = [NSString stringWithFormat:@"assess_id=%ld",self.assess_id];
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kHealthContent body:body success:^(id json) {
        NSDictionary *dict =[json objectForKey:@"result"];
        NSArray *array = [dict objectForKey:@"question"];
        NSArray *scoreStand = [dict objectForKey:@"rules"];
        NSMutableArray *healthArray = [[NSMutableArray alloc] init];
        NSMutableArray *healthhArray = [[NSMutableArray alloc] init];

        for (int i=0; i<array.count; i++) {
            TJYHealthContentModel *contentModel = [[TJYHealthContentModel alloc] init];
            [contentModel setValues:array[i]];
            [healthhArray addObject:contentModel];
        }
        healthContentArray = healthhArray;
        [TJYHelper sharedTJYHelper].healthList = healthContentArray;

        for (int i=0; i<scoreStand.count; i++) {
            TJYHealthScoreModel *scoreModel = [[TJYHealthScoreModel alloc] init];
            [scoreModel setValues:scoreStand[i]];
             [healthArray addObject:scoreModel];
        }
        scoreArray = healthArray;
        [TJYHelper sharedTJYHelper].healthResult = scoreArray;
        for (int i=0; i<healthContentArray.count; i++) {
            [seletedArray addObject:@"0"];
        }
        [self.tableView reloadData];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- TableFooterView
- (UIView *)tableFooterView{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0,  0, kScreenWidth, 200)];
    
    UIButton *determineBtn = InsertButtonWithType(footerView, CGRectMake(24, 80, 102, 44), 1000, self, @selector(determineClick), UIButtonTypeCustom);
    
    UIButton *nextButton =InsertButtonWithType(footerView, CGRectMake(80, 80, kScreenWidth-160, 44), 1000, self, @selector(determineClick), UIButtonTypeCustom);
    nextButton.backgroundColor = [UIColor colorWithHexString:@"0xffbe23"];
    [nextButton setTitle:@"完成测试" forState:UIControlStateNormal];
    nextButton.hidden = YES;
    
    if (healthContentArray.count>0) {
        determineBtn.titleLabel.textColor = [UIColor whiteColor];
        determineBtn.titleLabel.font = kFontSize(13);
        [determineBtn setBackgroundImage:[UIImage imageNamed:@"btn_pingu_up"] forState:UIControlStateNormal];
        determineBtn.layer.cornerRadius = 5;
        if (seletedPage==healthContentArray.count) {
            [determineBtn setTitle:@"完成测试" forState:UIControlStateNormal];
            determineBtn.hidden = YES;
            nextButton.hidden =NO;
        }else if (seletedPage==0){
            determineBtn.hidden = YES;
            nextButton.hidden =YES;
        }else{
            determineBtn.hidden = NO;
            [determineBtn setTitle:@"上一题" forState:UIControlStateNormal];
            nextButton.hidden =YES;
        }
    }
    
    return footerView;
}
#pragma mark -- Action 
/* 下一步点击 */
- (void)determineClick{
        if (healthContentArray.count==seletedPage) {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-05-04"];
#endif
            NSInteger num = 0;
            for (int i=0; i<healthContentArray.count; i++) {
                TJYHealthContentModel *contentModel = healthContentArray[i];
                NSArray *dataArray = contentModel.answer;
                NSInteger page = [seletedArray[i] integerValue]-1;
                NSInteger value = [[dataArray[page>0?page:0] objectForKey:@"score"] integerValue];
                num = num+value;
            }
            NSString *contentString = nil;
            for (int i=0; i<scoreArray.count; i++) {
                TJYHealthScoreModel *scoreModel = scoreArray[i];
                if (num>=scoreModel.begin_score&&num<=scoreModel.end_score) {
                    contentString = scoreModel.brief;
                }
            }
            TJYEvaluationResultViewController *resultVC = [[TJYEvaluationResultViewController alloc] init];
            resultVC.index = self.assess_id;
            resultVC.titleStr = self.titleStr;
            resultVC.num = num;
            resultVC.brief = contentString;
            NSDictionary *dict = @{@"num":[NSString stringWithFormat:@"%ld",num],@"accs_id":[NSString stringWithFormat:@"%ld",self.assess_id],@"brief":contentString};
            [NSUserDefaultInfos putKey:@"dict" anddict:dict];

            
            [self.navigationController pushViewController:resultVC animated:YES];
        }else{
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-05-03"];
#endif
            seletedPage--;
            //创建CATransition对象
            CATransition *animation = [CATransition animation];
            //设置时间
            animation.duration = 0.3f;
            //设置类型
            animation.type = kCATransitionMoveIn;
            //设置方向
            animation.subtype = kCATransitionFromLeft;
            //设置运动速度变化
            animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
            
            [self.tableView.layer addAnimation:animation forKey:@"animation"];

        }
    [self.tableView reloadData];
}
#pragma mark -- 返回
- (void)leftButtonAction{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[TJYHealthAssessmentVC class]]) {
            TJYHealthAssessmentVC *revise =(TJYHealthAssessmentVC *)controller;
            [self.navigationController popToViewController:revise animated:YES];
        }
    }
}
#pragma  mark -- Getter-
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth,kBodyHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = kBackgroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    _tableView.tableHeaderView = [self tableViewHeaderView];
    _tableView.tableFooterView = [self tableFooterView];
    return _tableView;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
