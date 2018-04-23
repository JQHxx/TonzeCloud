
//
//  TJYIngredientCell.m
//  Product
//
//  Created by zhuqinlu on 2017/5/3.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYIngredientCell.h"

@implementation TJYIngredientCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _ingredientNameLab =  InsertLabel(self.contentView, CGRectMake(15,20/2 , 200, 20), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x313131), NO);
        
        _ingredientWeightLab =  InsertLabel(self.contentView, CGRectMake(kScreenWidth - 165,20/2 , 150, 20), NSTextAlignmentRight, @"", kFontSize(13), UIColorHex(0x313131), NO);
    }
    return self;
}
- (void)cellInitWithData:(TJYCookIngredientModel *)model{
    
    _ingredientNameLab.text = model.ingredient_name;
    _ingredientWeightLab.text = [NSString stringWithFormat:@"%ld克",(long)model.ingredient_weight];
}
@end
