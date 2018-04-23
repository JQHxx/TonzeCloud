//
//  ShopSearchTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/12/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DeleteHistoryDelegate <NSObject>

//开始滑动
-(void)deleteSerachHistory:(NSString *)historyStr;

@end
@interface ShopSearchTableViewCell : UITableViewCell

@property (nonatomic ,weak)id<DeleteHistoryDelegate>deleteSearchDelegate;

@property (nonatomic ,strong)UILabel *nameLabel;

@end
