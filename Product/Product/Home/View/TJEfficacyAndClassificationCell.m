//
//  TJEfficacyAndClassificationCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJEfficacyAndClassificationCell.h"

@implementation TJEfficacyAndClassificationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _foodImg =  InsertImageView(self.contentView, CGRectMake(15, 10, 25, 25), [UIImage imageNamed:@""]);
        
        _foodNameLab = InsertLabel(self.contentView, CGRectMake(_foodImg.right + 10, 8, 200, 15), NSTextAlignmentLeft, @"", kFontSize(14), UIColorHex(0x333333), NO);
        
        _foodAmountLab =  InsertLabel(self.contentView, CGRectMake(_foodNameLab.left, _foodNameLab.bottom + 5, 200, 15), NSTextAlignmentLeft, @"", kFontSize(14), UIColorHex(0x999999), NO);
    }
    return self;
}

@end
