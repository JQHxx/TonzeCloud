//
//  TJYCommentsCell.h
//  Product
//
//  Created by zhuqinlu on 2017/5/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJYCommentsCell : UITableViewCell

/// 点评
@property (nonatomic ,strong) UILabel *commentsLabel;

- (void)setCellDataWithStr:(NSString *)str;

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object;

@end
