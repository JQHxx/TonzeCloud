//
//  TJYMenuDetailsRemarksCell.h
//  Product
//
//  Created by zhuqinlu on 2017/5/4.
//  Copyright © 2017年 TianJi. All rights reserved.
//  -- 菜谱详情 -- 小贴上

#import <UIKit/UIKit.h>

@interface TJYMenuDetailsRemarksCell : UITableViewCell

/// 小贴士
@property (nonatomic ,strong) UILabel *remarksLabel;


/**
 *  传入每一行cell数据，返回行高，提供接口
 *
 *  @param tableView 当前展示的tableView
 *  @param object cell的展示数据内容
 */
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object;

- (void)cellInitWithData:(NSString *)str;


@end
