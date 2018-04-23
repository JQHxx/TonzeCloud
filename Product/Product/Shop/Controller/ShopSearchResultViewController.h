//
//  ShopSearchResultViewController.h
//  Product
//
//  Created by 肖栋 on 17/12/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
@protocol ShopSearchResultDelegate <NSObject>

- (void)seleteSearchShopID:(NSInteger)goods_id;
@end
@interface ShopSearchResultViewController : BaseViewController

@property (nonatomic,assign)id<ShopSearchResultDelegate>shopSearchDelegate;

@property (nonatomic, copy )NSString   *keyword;

@property (nonatomic, assign)NSInteger   page;

@property (nonatomic,strong)UITableView       *tableView;
@end
