//
//  TJYEvaluationTestCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYEvaluationTestCell.h"

@implementation TJYEvaluationTestCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
      _optionLable = InsertLabel(self.contentView, CGRectMake(15, 14, 200, 20), NSTextAlignmentLeft, @"选项一", kFontSize(15), UIColorHex(0x626262), NO);
        
        _seletedImg =InsertImageView(self.contentView, CGRectMake(kScreenWidth - 40, 12, 24, 24), nil);
    }
    return self;
}

@end
