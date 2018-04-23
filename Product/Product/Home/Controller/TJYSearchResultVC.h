//
//  TJYSearchResultVC.h
//  Product
//
//  Created by zhuqinlu on 2017/4/28.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "TJYSearchFoodVC.h"

@protocol TJYSearchResultViewControllerDelegate <NSObject>
//选择数据
-(void)searchResultViewControllerDidSelectModel:(id )model withType:(SearchType )searchType;
//滑动
-(void)searchResultViewControllerBeginDraggingAction;
//确定
-(void)searchResultViewControllerConfirmAction;
@end

@interface TJYSearchResultVC : BaseViewController

@property (nonatomic,weak)id<TJYSearchResultViewControllerDelegate>controllerDelegate;

@property (nonatomic,assign)SearchType type;
@property (nonatomic, copy )NSString   *keyword;

@property (nonatomic,assign)NSInteger  searchType;

@end
