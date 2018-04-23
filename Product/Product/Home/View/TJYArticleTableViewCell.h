//
//  TJYArticleTableViewCell.h
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYArticleModel.h"

@interface TJYArticleTableViewCell : UITableViewCell

@property (nonatomic ,strong) UIImageView *Img;

@property (nonatomic ,strong) UILabel *titleLabel;


@property (strong, nonatomic)UILabel *readCountLabel;

- (void)cellDisplayWithModel:(TJYArticleModel *)model type:(NSInteger )type searchText:(NSString *)searchText;

@end
