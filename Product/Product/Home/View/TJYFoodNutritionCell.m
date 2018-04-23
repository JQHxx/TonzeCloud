//
//  TJYFoodNutritionCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYFoodNutritionCell.h"

@implementation TJYFoodNutritionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _ingredientNameLab = InsertLabel(self.contentView, CGRectMake(18, 14, 100, 20), NSTextAlignmentLeft, @"", kFontSize(14), UIColorHex(0x9999999), NO);
        _parameterLab =  InsertLabel(self.contentView, CGRectMake(kScreenWidth - 120, 14, 100, 20), NSTextAlignmentRight, @"", kFontSize(14), UIColorHex(0x999999), NO);
        
//        InsertView(self.contentView, CGRectMake(0, self.contentView.height - 0.5, kScreenWidth, 0.5), UIColorHex(0xd1d1d1));
    }
    return self;
}

@end
