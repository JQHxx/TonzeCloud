//
//  TJYFoodLibraryCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYFoodLibraryCell.h"
#import "QLCoreTextManager.h"

@implementation TJYFoodLibraryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _foodImg =  InsertImageView(self.contentView, CGRectMake(15, 9, 40, 40), [UIImage imageNamed:@""]);
        
        _foodNameLab = InsertLabel(self.contentView, CGRectMake(_foodImg.right + 10, 8, kScreenWidth-_foodImg.right-30, 15), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
        
        _foodEnergyLab =  InsertLabel(self.contentView, CGRectMake(_foodNameLab.left, _foodNameLab.bottom + 8, 180, 15), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x626262), NO);
    }
    return self;
}

- (void)initWithFoodListModel:(TJYFoodListModel *)model orderbyStr:(NSString *)orderbyStr{
    
    [_foodImg sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    _foodNameLab.text = model.name;
    
    NSString *contentStr;
//    NSAttributedString *contentAttributText;
    if ([orderbyStr isEqualToString:@"energykcal"] || [orderbyStr isEqualToString:@"id"] || [orderbyStr isEqualToString:@""]) {
        contentStr = [self string:model.energykcal unit:@"千卡/100克"];
//        contentStr = [NSString stringWithFormat:@"%ld千卡/100克",(long)model.energykcal];
//        contentAttributText = [NSString ql_changeRangeText:contentStr noRangeInedex:7 changeColor:[UIColor redColor]];
    }else if ([orderbyStr isEqualToString:@"protein"]){
        contentStr = [self string:model.protein unit:@"克/100克"];
//        contentStr = [NSString stringWithFormat:@"%ld克/100克",(long)model.protein];
    }else if ([orderbyStr isEqualToString:@"carbohydrate"]){
        contentStr = [self string:model.carbohydrate unit:@"克/100克"];

    }else if ([orderbyStr isEqualToString:@"fat"]){
        contentStr = [self string:model.fat unit:@"克/100克"];
    }else if ([orderbyStr isEqualToString:@"insolublefiber"]){
        contentStr = [self string:model.insolublefiber unit:@"克/100克"];
    }else if ([orderbyStr isEqualToString:@"totalvitamin"]){
        contentStr = [self string:model.totalvitamin unit:@"克/100克"];
    }else if ([orderbyStr isEqualToString:@"vitaminC"]){
        contentStr = [self string:model.vitaminC unit:@"毫克/100克"];
    }else if ([orderbyStr isEqualToString:@"vitaminE"]){
        contentStr = [self string:model.vitaminE unit:@"毫克/100克"];
    }else if ([orderbyStr isEqualToString:@"cholesterol"]){
        contentStr = [self string:model.carbohydrate unit:@"毫克/100克"];
    }
    _foodEnergyLab.text = contentStr;
    
    if (self.isFromNutritionScale) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:_foodEnergyLab.text];
        NSString * content = [NSString stringWithFormat:@"%ld",(long)model.energykcal];
        [str addAttribute:NSForegroundColorAttributeName value:UIColorHex(0xf39700) range:NSMakeRange(0,content.length)];
        _foodEnergyLab.attributedText = str;
    }
    
}
- (void)setdataWithFoodListModel:(TJYFoodListModel *)model searchText:(NSString *)searchText
{
    [_foodImg sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    _foodNameLab.text = model.name;
//    NSString  *contentStr = [NSString stringWithFormat:@"%ld千卡/100克",(long)model.energykcal];
//    NSAttributedString *contentAttributText = [NSString ql_changeRangeText:contentStr noRangeInedex:7 changeColor:[UIColor redColor]];
    _foodEnergyLab.text =  [NSString stringWithFormat:@"%ld千卡/100克",(long)model.energykcal];;
    
    if (!kIsEmptyString(searchText)) {
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",model.name]];
        [QLCoreTextManager setAttributedValue:attString text:searchText font:kFontSize(15) color:[UIColor redColor]];
        _foodNameLab.attributedText = attString;
    }
}
#pragma mark -- 拼接字符串
- (NSString *)string:(NSInteger)intvalue unit:(NSString *)unit{
    NSString *string = [[NSString alloc] init];
    string = intvalue==0?[NSString stringWithFormat:@"--%@",unit]:[NSString stringWithFormat:@"%ld%@",(long)intvalue,unit];
    return string;
}


@end
