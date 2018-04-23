//
//  TCSearchTableView.m
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSearchTableView.h"
#import "TJYHotWordView.h"



@interface TCSearchTableView (){
    CGFloat hotWordViewHeight;
    CGFloat historyRecordsHeight;
    
}

@end

@implementation TCSearchTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self=[super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor=[UIColor bgColor_Gray];
        self.dataSource=self;
        self.delegate=self;
        self.showsVerticalScrollIndicator=NO;
        self.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return self;
}

#pragma mark -- Event Response
#pragma mark 清空历史记录
-(void)clearHistoryRecords{
#if !DEBUG
    if (_searchType==FoodSearchType) {
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-03-08"];
    }else if (_searchType==KnowledgeSearchType){
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-04-05"];
    }else if (_searchType==MenuSearchType){
        
    }else if (_searchType==FoodAddSearchType){
        
    }
#endif
    if ([self.searchDelegate respondsToSelector:@selector(searchTableViewDidDeleteAllHistory:)]) {
        [self.searchDelegate searchTableViewDidDeleteAllHistory:self];
    }
}
#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 35)];
    headView.backgroundColor=[UIColor clearColor];
    
    if (section==0) {
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, kScreenWidth-50, 25)];
        lab.textColor=[UIColor darkGrayColor];
        lab.text=@"热门搜索";
        lab.font=[UIFont systemFontOfSize:14.0f];
        [headView addSubview:lab];

    } else if(section==1&&self.historyRecordsArray.count>0) {
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, kScreenWidth-50, 25)];
        lab.textColor=[UIColor darkGrayColor];
        lab.text=@"历史记录";
        lab.font=[UIFont systemFontOfSize:14.0f];
        [headView addSubview:lab];
        
        if (section==1 && self.historyRecordsArray.count!=0) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 30, 10, 25, 25)];
            [btn setBackgroundImage:[UIImage imageNamed:@"delete_search"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clearHistoryRecords) forControlEvents:UIControlEventTouchUpInside];
            [headView addSubview:btn];
        }
    }
    
    return headView;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCHistoryTableViewCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
        }
    }
    cell.backgroundColor=[UIColor bgColor_Gray];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (indexPath.section==0) {
        TJYHotWordView *hotWordView=[[TJYHotWordView alloc] init];
        hotWordView.hotWordsArray=self.hotSearchWordsArray;
        __weak typeof(hotWordView) weakWordView=hotWordView;
        hotWordView.viewHeightRecalc=^(CGFloat height){
            hotWordViewHeight=height;
            weakWordView.frame=CGRectMake(0, 5, kScreenWidth, height);
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        };
        
        hotWordView.hotSearchClick=^(NSString *title){
        #if !DEBUG
            if (_searchType==FoodSearchType) {
                [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-03-06"];
            }else if (_searchType==KnowledgeSearchType){
                [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-04-03"];
            }else if (_searchType==MenuSearchType){
                
            }else if (_searchType==FoodAddSearchType){
                
            }
       #endif
            if ([_searchDelegate respondsToSelector:@selector(searchtableView:didSelectKeyword:)]) {
                [_searchDelegate searchtableView:self didSelectKeyword:title];
            }
        };
        [cell.contentView addSubview:hotWordView];
    }else{
        TJYHotWordView *historyView=[[TJYHotWordView alloc] init];
        historyView.hotWordsArray=self.historyRecordsArray;
        __weak typeof(historyView) weakWordView=historyView;
        historyView.viewHeightRecalc=^(CGFloat height){
            historyRecordsHeight=height;
            weakWordView.frame=CGRectMake(0, 5, kScreenWidth, height);
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        };
        historyView.hotSearchClick=^(NSString *title){
       #if !DEBUG
            if (_searchType==FoodSearchType) {
                [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-03-07"];
            }else if (_searchType==KnowledgeSearchType){
                [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"004-04-04"];
            }else if (_searchType==MenuSearchType){
                
            }else if (_searchType==FoodAddSearchType){
                
            }
       #endif
            if ([_searchDelegate respondsToSelector:@selector(searchtableView:didSelectKeyword:)]) {
                [_searchDelegate searchtableView:self didSelectKeyword:title];
            }
        };
        [cell.contentView addSubview:historyView];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section==0?hotWordViewHeight:historyRecordsHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==1) {
        return self.historyRecordsArray.count>0?35:0.01;
    }
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

#pragma mark -- Setters and Getters
#pragma mark 热门搜索数据
-(void)setHotSearchWordsArray:(NSMutableArray *)hotSearchWordsArray{
    if (hotSearchWordsArray==nil) {
        hotSearchWordsArray=[[NSMutableArray alloc] init];
    }
    _hotSearchWordsArray=hotSearchWordsArray;
}
#pragma mark 历史记录
-(void)setHistoryRecordsArray:(NSMutableArray *)historyRecordsArray{
    if (historyRecordsArray==nil) {
        historyRecordsArray=[[NSMutableArray alloc] init];
    }
    _historyRecordsArray=historyRecordsArray;
}

-(void)setSearchType:(SearchType)searchType{
    _searchType=searchType;
}

#pragma mark -- UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([_searchDelegate respondsToSelector:@selector(searchTableViewWillBeginDragging:)]) {
        [_searchDelegate searchTableViewWillBeginDragging:self];
    }
}

@end
