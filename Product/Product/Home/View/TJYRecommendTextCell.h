//
//  TJYRecommendTextCell.h
//  Product
//
//  Created by zhuqinlu on 2017/5/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJYRecommendTextCell : UITableViewCell

@property (nonatomic ,strong) UILabel *commentsLabel;

- (void)setCellDataWithStr:(NSString *)str;

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object;


@end
