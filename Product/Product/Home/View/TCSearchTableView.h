//
//  TCSearchTableView.h
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYSearchFoodVC.h"

@class TCSearchTableView;

@protocol TJYSearchTableViewDelegate <NSObject>

//开始滑动
-(void)searchTableViewWillBeginDragging:(TCSearchTableView *)searchTableView;
//选择热门词或搜索历史
-(void)searchtableView:(TCSearchTableView *)searchTableView didSelectKeyword:(NSString *)keyword;
//清除搜索历史
-(void)searchTableViewDidDeleteAllHistory:(TCSearchTableView *)searchTableView;

@end

@interface TCSearchTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,weak)id<TJYSearchTableViewDelegate>searchDelegate;

@property (nonatomic,strong)NSMutableArray  *hotSearchWordsArray;
@property (nonatomic,strong)NSMutableArray  *historyRecordsArray;

@property (nonatomic,assign)SearchType searchType;

@end
