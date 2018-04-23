//
//  TJYCookStepCell.h
//  Product
//
//  Created by zhuqinlu on 2017/5/3.
//  Copyright © 2017年 TianJi. All rights reserved.
//   菜谱详情 制作步骤 

#import <UIKit/UIKit.h>
#import "TJYCookSetpModel.h"

@interface TJYCookStepCell : UITableViewCell
{
    CGFloat _textHight;// 文本高度
}
///
@property (nonatomic ,strong) UILabel *cookStepLable;

///
@property (nonatomic ,strong) UIImageView *stepImg;

@property (nonatomic ,strong) UILabel *titleLabel;

- (void)cellInitWithData:(TJYCookSetpModel *)model;

+(CGFloat)returnRowHeightForObject:(id)object isScrollDown:(BOOL)isFlag;

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object;
//
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object length:(NSInteger)length;

@end
