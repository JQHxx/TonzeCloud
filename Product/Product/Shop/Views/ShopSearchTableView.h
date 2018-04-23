//
//  ShopSearchTableView.h
//  Product
//
//  Created by 肖栋 on 17/12/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShopSearchTableView;

@protocol ShopSearchTableViewDelegate <NSObject>

//开始滑动
-(void)shopSearchTableViewWillBeginDragging:(ShopSearchTableView *)searchTableView;
//选择热门词或搜索历史
-(void)shopSearchtableView:(ShopSearchTableView *)searchTableView didSelectKeyword:(NSString *)keyword;
//清除搜索历史
-(void)shopSearchTableViewDidDeleteAllHistory:(ShopSearchTableView *)searchTableView;
//清除单条搜索历史
-(void)deleteHistoryRecord:(NSMutableArray *)history;
//点击热门搜索
- (void)seleteHotSearch:(ShopSearchTableView *)searchTableView didSelectTitle:(NSString *)title;
@end
@interface ShopSearchTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,weak)id<ShopSearchTableViewDelegate>shopSearchDelegate;

@property (nonatomic,strong)NSMutableArray  *historyRecordsArray;

@property (nonatomic,strong)NSMutableArray  *hotSearchWordsArray;

@end
