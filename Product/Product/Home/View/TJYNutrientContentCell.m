//
//  TJYNutrientContentCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYNutrientContentCell.h"

@implementation TJYNutrientContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _ingredientTypeLabel = InsertLabel(self.contentView, CGRectMake(18, 14, 100, 20), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
        
        _contentLabel =  InsertLabel(self.contentView, CGRectMake(kScreenWidth - 120, 14, 100, 20), NSTextAlignmentRight, @"", kFontSize(14), UIColorHex(0x626262), NO);
    }
    return self;
}

@end
