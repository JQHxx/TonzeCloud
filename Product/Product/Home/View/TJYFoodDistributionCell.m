
//
//  TJYFoodDistributionCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYFoodDistributionCell.h"

@implementation TJYFoodDistributionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _foodImg = InsertImageView(self.contentView, CGRectMake(15, (58- 40)/2, 40, 40), [UIImage imageNamed:@""]);
        _menuNameLable = InsertLabel(self.contentView, CGRectMake(_foodImg.right + 10, _foodImg.top, 180, 20), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
        _weightLabel=  InsertLabel(self.contentView, CGRectMake(_menuNameLable.left,_menuNameLable.bottom + 3 , 150, 15), NSTextAlignmentLeft, @"", kFontSize(14), UIColorHex(0x959595), NO);
        _caloriesLable = InsertLabel(self.contentView, CGRectMake(kScreenWidth - 165,(58 - 15)/2, 150, 15), NSTextAlignmentRight, @"", kFontSize(15), UIColorHex(0x999999), NO);
        InsertView(self.contentView, CGRectMake(_foodImg.right,58 - 0.5, kScreenWidth - _foodImg.right, 0.5), kLineColor);
    }
    return self;
}

- (void)cellInitWithData:(TJYFoodRecommendModel *)model{

    [_foodImg sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    _menuNameLable.text = model.food_name;
    _weightLabel.text = [NSString stringWithFormat:@"%@克",model.weight];
    NSString *energykcalStr = [NSString stringWithFormat:@"%ld千卡",model.energykcal];
    NSAttributedString *atttext = [NSString ql_changeRangeText:energykcalStr noRangeInedex:2 changeColor:kSystemColor];
    _caloriesLable.attributedText = atttext;
}

@end
