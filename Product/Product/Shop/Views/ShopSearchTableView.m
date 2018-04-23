//
//  ShopSearchTableView.m
//  Product
//
//  Created by 肖栋 on 17/12/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopSearchTableView.h"
#import "ShopSearchTableViewCell.h"
#import "TCHotWordView.h"
#import "TCShopHotWordView.h"

@interface ShopSearchTableView ()<DeleteHistoryDelegate>{
    
    CGFloat hotWordViewHeight;
}
@end
@implementation ShopSearchTableView

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
    
    if ([_shopSearchDelegate respondsToSelector:@selector(shopSearchTableViewDidDeleteAllHistory:)]) {
        [_shopSearchDelegate shopSearchTableViewDidDeleteAllHistory:self];
    }
}
#pragma mark --UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return _hotSearchWordsArray.count>0?1:0;
    }
    return _historyRecordsArray.count>0?_historyRecordsArray.count:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        static NSString *cellIdentifier=@"UITableViewCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        TCShopHotWordView *hotWordView = [[TCShopHotWordView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 61)];
        hotWordView.shopHotWordArr = self.hotSearchWordsArray;
        hotWordView.shopHotSearchClick=^(NSString *title){
            if ([_shopSearchDelegate respondsToSelector:@selector(seleteHotSearch:didSelectTitle:)]) {
                [_shopSearchDelegate seleteHotSearch:self didSelectTitle:title];
            }
        };
        [cell.contentView addSubview:hotWordView];
        return cell;
    } else {
        static NSString *cellIdentifier=@"ShopSearchTableViewCell";
        ShopSearchTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[ShopSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.backgroundColor=[UIColor whiteColor];
        if (_historyRecordsArray.count>0) {
            cell.nameLabel.text = _historyRecordsArray[indexPath.row];
            cell.deleteSearchDelegate = self;
        }
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        if (_historyRecordsArray.count>0) {
            if ([_shopSearchDelegate respondsToSelector:@selector(shopSearchtableView:didSelectKeyword:)]) {
                [_shopSearchDelegate shopSearchtableView:self didSelectKeyword:_historyRecordsArray[indexPath.row]];
            }
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (self.hotSearchWordsArray.count>0) {
            return 61;
        } else {
            return 40;
        }
    }
    if (_historyRecordsArray.count>0) {
        return 48;
    } else {
        return kScreenHeight-kNewNavHeight;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return self.hotSearchWordsArray.count>0?38:0.01;
    } else {
        return self.historyRecordsArray.count>0?38:0.01;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0) {
        return _hotSearchWordsArray.count>0?10:0.01;;
    }
    return _historyRecordsArray.count>0?95:0.01;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 95)];
    footView.backgroundColor=[UIColor bgColor_Gray];
    if (section==0&&_hotSearchWordsArray.count>0) {
        footView.frame = CGRectMake(0, 0, kScreenWidth, 10);
        
    }else if (_historyRecordsArray.count>0&&section!=0) {
        UIButton *deleteAllBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-240)/2, 30, 240, 35)];
        deleteAllBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [deleteAllBtn setTitle:@"清除搜索历史" forState:UIControlStateNormal];
        [deleteAllBtn setTitleColor:[UIColor colorWithHexString:@"0x626262"] forState:UIControlStateNormal];
        [deleteAllBtn addTarget:self action:@selector(clearHistoryRecords) forControlEvents:UIControlEventTouchUpInside];
        [deleteAllBtn.layer setBorderWidth:1];
        deleteAllBtn.layer.cornerRadius = 5;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){221.0/256, 221.0/256, 221.0/256,1 });
        [deleteAllBtn.layer setBorderColor:colorref];//边框颜色
        [footView addSubview:deleteAllBtn];
    }
    return footView;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 38)];
    headView.backgroundColor=[UIColor whiteColor];
    if (section==0&&self.hotSearchWordsArray.count>0) {
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(18, 9, kScreenWidth-50, 20)];
        lab.textColor=[UIColor colorWithHexString:@"0x626262"];
        lab.text=@"热门搜索";
        lab.font=[UIFont systemFontOfSize:13.0f];
        [headView addSubview:lab];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, kScreenWidth, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [headView addSubview:lineLabel];
    }
    if (section==1&&self.historyRecordsArray.count>0) {
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(18, 9, kScreenWidth-50, 20)];
        lab.textColor=[UIColor colorWithHexString:@"0x626262"];
        lab.text= @"搜索历史";
        lab.font=[UIFont systemFontOfSize:13.0f];
        [headView addSubview:lab];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, kScreenWidth, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [headView addSubview:lineLabel];
    }
    
    return headView;
}
#pragma mark 删除单条记录
- (void)deleteSerachHistory:(NSString *)historyStr{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *title in _historyRecordsArray) {
        if (![title isEqualToString:historyStr]) {
            [array addObject:title];
        }
    }
    _historyRecordsArray = array;
    [NSUserDefaultInfos putKey:@"sugarFriendHistory" andValue:_historyRecordsArray];
    
    if ([_shopSearchDelegate respondsToSelector:@selector(deleteHistoryRecord:)]) {
        [_shopSearchDelegate deleteHistoryRecord:_historyRecordsArray];
    }
    
}
#pragma mark -- Setters and Getters
#pragma mark 历史记录
-(void)setHistoryRecordsArray:(NSMutableArray *)historyRecordsArray{
    if (historyRecordsArray==nil) {
        historyRecordsArray=[[NSMutableArray alloc] init];
    }
    _historyRecordsArray=historyRecordsArray;
}
#pragma mark -- UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([_shopSearchDelegate respondsToSelector:@selector(shopSearchTableViewWillBeginDragging:)]) {
        [_shopSearchDelegate shopSearchTableViewWillBeginDragging:self];
    }
}


@end
