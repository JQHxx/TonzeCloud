
//
//  TJYPushRecipesCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYPushRecipesCell.h"

@implementation TJYPushRecipesCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _foodImg = InsertImageView(self.contentView, CGRectMake(15, 5, 40, 40), [UIImage imageNamed:@"云炖锅"]);
        _menuNameLable = InsertLabel(self.contentView, CGRectMake(_foodImg.right + 10, _foodImg.top, 150, 20), NSTextAlignmentLeft, @"红烧牛肉", kFontSize(14), UIColorHex(0x333333), NO);
        _weightLabel=  InsertLabel(self.contentView, CGRectMake(_menuNameLable.left,_menuNameLable.bottom + 10 , 100, 15), NSTextAlignmentLeft, @"100克", kFontSize(14), UIColorHex(0x999999), NO);
        _caloriesLable = InsertLabel(self.contentView, CGRectMake(kScreenWidth - 160,(self.contentView.height - 20)/2, 150, 20), NSTextAlignmentRight, @"1000卡", kFontSize(16), UIColorHex(0x999999), NO);
    }
    return self;
}

@end
