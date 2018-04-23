//
//  TJYMealPagodaView.m
//  Product
//
//  Created by zhuqinlu on 2017/5/18.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYMealPagodaView.h"

@interface TJYMealPagodaView ()
{
    UILabel *saltLab;
    UILabel *oilLab;
    UILabel *soybeansLab;
    UILabel *nutLab;
    UILabel *milkLab;
    UILabel *aquaticProductsLab;
    UILabel *eggLab;
    UILabel *poultryLab;
    UILabel *fruitLab;
    UILabel *vegetablesLab;
    UILabel *cereal_beansLab;
    UILabel *yamLab;
    UILabel *cerealsLab;
}
@end

@implementation TJYMealPagodaView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        CGFloat  imgWidth = 649/2*0.9;
        UIImageView *mealPagoda = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth - imgWidth)/2, 50, imgWidth , 594/2)];
        mealPagoda.image = [UIImage imageNamed:@"img_MealPagoda"];
        [self addSubview:mealPagoda];
        
        saltLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 30, 40, 60, 15), NSTextAlignmentCenter, @"盐--克", kFontSize(11), kSystemColor, NO);
        oilLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 40, saltLab.bottom , 80, 15), NSTextAlignmentCenter, @"油--克", kFontSize(11), kSystemColor, NO);
        
        soybeansLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 50, oilLab.bottom + 8, 100, 15), NSTextAlignmentCenter, @"大豆--克", kFontSize(12), kSystemColor, NO);
        nutLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 50, soybeansLab.bottom , 100, 15), NSTextAlignmentCenter, @"坚果类--克", kFontSize(12), kSystemColor, NO);
        milkLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 50, nutLab.bottom , 100, 15), NSTextAlignmentCenter, @"奶及奶制品-克", kFontSize(12), kSystemColor, NO);

        poultryLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 50, milkLab.bottom + 8, 100, 15), NSTextAlignmentCenter, @"禽畜肉-克", kFontSize(12), kSystemColor, NO);
        aquaticProductsLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 50, poultryLab.bottom, 100, 15), NSTextAlignmentCenter, @"水产品-克", kFontSize(12), kSystemColor, NO);
        eggLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 50,aquaticProductsLab.bottom, 100,15), NSTextAlignmentCenter, @"蛋类-克", kFontSize(12), kSystemColor, NO);
   
        vegetablesLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 60,  eggLab.bottom + 15, 120, 15), NSTextAlignmentCenter, @"蔬菜类-克", kFontSize(12), kSystemColor, NO);
        fruitLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 60,vegetablesLab.bottom, 120, 15), NSTextAlignmentCenter, @"水果类-克", kFontSize(12), kSystemColor, NO);

        cerealsLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 80, mealPagoda.height - 50, 160, 15), NSTextAlignmentCenter, @"谷薯类-克", kFontSize(12), kSystemColor, NO);
        cereal_beansLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 80,cerealsLab.bottom, 160, 15), NSTextAlignmentCenter, @"全谷物及杂豆-克", kFontSize(12), kSystemColor, NO);
        yamLab = InsertLabel(mealPagoda, CGRectMake(mealPagoda.width/2 - 80,cereal_beansLab.bottom , 160, 15), NSTextAlignmentCenter, @"薯类-克", kFontSize(12), kSystemColor, NO);
    }
    return self;
}
#pragma mark -- set Data

- (void)setTotalCalorie:(NSInteger)totalCalorie{
        if (totalCalorie >= 0 && totalCalorie < 1100) {
            saltLab.text = [NSString stringWithFormat:@"盐＜2克"];
            oilLab.text = [NSString stringWithFormat:@"油15~20克"];
            milkLab.text = [NSString stringWithFormat:@"奶及奶制品 500克"];
            soybeansLab.text = [NSString stringWithFormat:@"大豆类 5克"];
            nutLab.text = [NSString stringWithFormat:@"坚果类 无"];
            poultryLab.text = [NSString stringWithFormat:@"禽畜肉 15克"];
            aquaticProductsLab.text = [NSString stringWithFormat:@"水产品 15克"];
            eggLab.text = [NSString stringWithFormat:@"蛋类 20克"];
            vegetablesLab.text = [NSString stringWithFormat:@"蔬菜类 200克"];
            fruitLab.text = [NSString stringWithFormat:@"水果类 150克"];
            cerealsLab.text = [NSString stringWithFormat:@"谷薯类 85克"];
            cereal_beansLab.text = [NSString stringWithFormat:@"全谷物及杂豆 适量"];
            yamLab.text = [NSString stringWithFormat:@"薯类 适量"];
        }else if (totalCalorie >= 1100 && totalCalorie < 1300){
            saltLab.text = [NSString stringWithFormat:@"盐＜3克"];
            oilLab.text = [NSString stringWithFormat:@"油20~25克"];
            milkLab.text = [NSString stringWithFormat:@"奶及奶制品 500克"];
            soybeansLab.text = [NSString stringWithFormat:@"大豆类 15克"];
            nutLab.text = [NSString stringWithFormat:@"坚果类 适量"];
            aquaticProductsLab.text = [NSString stringWithFormat:@"水产品 20克"];
            eggLab.text = [NSString stringWithFormat:@"蛋类 25克"];
            poultryLab.text = [NSString stringWithFormat:@"禽畜肉 25克"];
            fruitLab.text = [NSString stringWithFormat:@"水果类 150克"];
            vegetablesLab.text = [NSString stringWithFormat:@"蔬菜类 250克"];
            cerealsLab.text = [NSString stringWithFormat:@"谷薯类 100克"];
            cereal_beansLab.text = [NSString stringWithFormat:@"全谷物及杂豆 适量"];
            yamLab.text = [NSString stringWithFormat:@"薯类 适量"];
        }else if (totalCalorie >= 1300 && totalCalorie < 1500){
            saltLab.text = [NSString stringWithFormat:@"盐＜4克"];
            oilLab.text = [NSString stringWithFormat:@"油20~25克"];
            milkLab.text = [NSString stringWithFormat:@"奶及奶制品 350克"];
            soybeansLab.text = [NSString stringWithFormat:@"大豆类 15克"];
            nutLab.text = [NSString stringWithFormat:@"坚果类 适量"];
            poultryLab.text = [NSString stringWithFormat:@"禽畜肉 40克"];
            aquaticProductsLab.text = [NSString stringWithFormat:@"水产品 40克"];
            eggLab.text = [NSString stringWithFormat:@"蛋类 40克"];
            fruitLab.text = [NSString stringWithFormat:@"水果类 150克"];
            vegetablesLab.text = [NSString stringWithFormat:@"蔬菜类 300克"];
            cerealsLab.text = [NSString stringWithFormat:@"谷薯类 150克"];
            cereal_beansLab.text = [NSString stringWithFormat:@"全谷物及杂豆适量"];
            yamLab.text = [NSString stringWithFormat:@"薯类 适量"];
        }else if (totalCalorie >= 1500 && totalCalorie < 1700){
            saltLab.text = [NSString stringWithFormat:@"盐＜6克"];
            oilLab.text = [NSString stringWithFormat:@"油20~25克"];
            milkLab.text = [NSString stringWithFormat:@"奶及奶制品 300克"];
            soybeansLab.text = [NSString stringWithFormat:@"大豆类 15克"];
            nutLab.text = [NSString stringWithFormat:@"坚果类 10克"];
            poultryLab.text = [NSString stringWithFormat:@"禽畜肉 40克"];
            aquaticProductsLab.text = [NSString stringWithFormat:@"水产品 40克"];
            eggLab.text = [NSString stringWithFormat:@"蛋类 40克"];
            fruitLab.text = [NSString stringWithFormat:@"水果类 200克"];
            vegetablesLab.text = [NSString stringWithFormat:@"蔬菜类 300克"];
            cerealsLab.text = [NSString stringWithFormat:@"谷薯类 200克"];
            cereal_beansLab.text = [NSString stringWithFormat:@"全谷物及杂豆 50~150克"];
            yamLab.text = [NSString stringWithFormat:@"薯类 50~100克"];
        }else if (totalCalorie >= 1700 && totalCalorie < 1900)
        {
            saltLab.text = [NSString stringWithFormat:@"盐＜6克"];
            oilLab.text = [NSString stringWithFormat:@"油 25克"];
            milkLab.text = [NSString stringWithFormat:@"奶及奶制品 300克"];
            soybeansLab.text = [NSString stringWithFormat:@"大豆类 15克"];
            nutLab.text = [NSString stringWithFormat:@"坚果类 10克"];
            poultryLab.text = [NSString stringWithFormat:@"禽畜肉 50克"];
            aquaticProductsLab.text = [NSString stringWithFormat:@"水产品 50克"];
            eggLab.text = [NSString stringWithFormat:@"蛋类 50克"];
            fruitLab.text = [NSString stringWithFormat:@"水果类 200克"];
            vegetablesLab.text = [NSString stringWithFormat:@"蔬菜类 400克"];
            cerealsLab.text = [NSString stringWithFormat:@"谷薯类 225克"];
            cereal_beansLab.text = [NSString stringWithFormat:@"全谷物及杂豆 50~100克"];
            yamLab.text = [NSString stringWithFormat:@"薯类 50~100克"];
        }else if(totalCalorie >=1900 && totalCalorie < 2100){
            saltLab.text = [NSString stringWithFormat:@"盐＜6克"];
            oilLab.text = [NSString stringWithFormat:@"油 25克"];
            soybeansLab.text = [NSString stringWithFormat:@"大豆类 15克"];
            nutLab.text = [NSString stringWithFormat:@"坚果类 10克"];
            milkLab.text = [NSString stringWithFormat:@"奶及奶制品 300克"];
            aquaticProductsLab.text = [NSString stringWithFormat:@"水产品 50克"];
            eggLab.text = [NSString stringWithFormat:@"蛋类 50克"];
            poultryLab.text = [NSString stringWithFormat:@"禽畜肉 50克"];
            fruitLab.text = [NSString stringWithFormat:@"水果类 300克"];
            vegetablesLab.text = [NSString stringWithFormat:@"蔬菜类 450克"];
            cerealsLab.text = [NSString stringWithFormat:@"谷薯类 250克"];
            cereal_beansLab.text = [NSString stringWithFormat:@"全谷物及杂豆 50~150克"];
            yamLab.text = [NSString stringWithFormat:@"薯类 50~100克"];
        }else if (totalCalorie >= 2100 && totalCalorie < 2300){
            saltLab.text = [NSString stringWithFormat:@"盐＜6克"];
            oilLab.text = [NSString stringWithFormat:@"油 25克"];
            milkLab.text = [NSString stringWithFormat:@"奶及奶制品 300克"];
            soybeansLab.text = [NSString stringWithFormat:@"大豆类 25克"];
            nutLab.text = [NSString stringWithFormat:@"坚果类 10克"];
            poultryLab.text = [NSString stringWithFormat:@"禽畜肉 75克"];
            aquaticProductsLab.text = [NSString stringWithFormat:@"水产品 75克"];
            eggLab.text = [NSString stringWithFormat:@"蛋类 50克"];
            fruitLab.text = [NSString stringWithFormat:@"水果类 300克"];
            vegetablesLab.text = [NSString stringWithFormat:@"蔬菜类 450克"];
            cerealsLab.text = [NSString stringWithFormat:@"谷薯类 275克"];
            cereal_beansLab.text = [NSString stringWithFormat:@"全谷物及杂豆 50~150克"];
            yamLab.text = [NSString stringWithFormat:@"薯类 50~100克"];
        }else if (totalCalorie >= 2300 && totalCalorie < 2500){
            saltLab.text = [NSString stringWithFormat:@"盐＜6克"];
            oilLab.text = [NSString stringWithFormat:@"油 30克"];
            milkLab.text = [NSString stringWithFormat:@"奶及奶制品 300克"];
            soybeansLab.text = [NSString stringWithFormat:@"大豆类 25克"];
            nutLab.text = [NSString stringWithFormat:@"坚果类 10克"];
            poultryLab.text = [NSString stringWithFormat:@"禽畜肉 75克"];
            aquaticProductsLab.text = [NSString stringWithFormat:@"水产品 75克"];
            eggLab.text = [NSString stringWithFormat:@"蛋类 50克"];
            fruitLab.text = [NSString stringWithFormat:@"水果类 350克"];
            vegetablesLab.text = [NSString stringWithFormat:@"蔬菜类 500克"];
            cerealsLab.text = [NSString stringWithFormat:@"谷薯类 300克"];
            cereal_beansLab.text = [NSString stringWithFormat:@"全谷物及杂豆 50~150克"];
            yamLab.text = [NSString stringWithFormat:@"薯类 50~100克"];
        }else if (totalCalorie >= 2500 && totalCalorie < 2700){
            saltLab.text = [NSString stringWithFormat:@"盐＜6克"];
            oilLab.text = [NSString stringWithFormat:@"油30克"];
            milkLab.text = [NSString stringWithFormat:@"奶及奶制品 300克"];
            soybeansLab.text = [NSString stringWithFormat:@"大豆类 25克"];
            nutLab.text = [NSString stringWithFormat:@"坚果类 10克"];
            poultryLab.text = [NSString stringWithFormat:@"禽畜肉 75克"];
            aquaticProductsLab.text = [NSString stringWithFormat:@"水产品 75克"];
            eggLab.text = [NSString stringWithFormat:@"蛋类 50克"];
            fruitLab.text = [NSString stringWithFormat:@"水果类 350克"];
            vegetablesLab.text = [NSString stringWithFormat:@"蔬菜类 500克"];
            cerealsLab.text = [NSString stringWithFormat:@"谷薯类 350克"];
            cereal_beansLab.text = [NSString stringWithFormat:@"全谷物及杂豆 无"];
            yamLab.text = [NSString stringWithFormat:@"薯类 125克"];
        }else if (totalCalorie >= 2700 && totalCalorie < 2800){
            saltLab.text = [NSString stringWithFormat:@"盐＜6克"];
            oilLab.text = [NSString stringWithFormat:@"油 30克"];
            milkLab.text = [NSString stringWithFormat:@"奶及奶制品 300克"];
            soybeansLab.text = [NSString stringWithFormat:@"大豆类 25克"];
            nutLab.text = [NSString stringWithFormat:@"坚果类 10克"];
            poultryLab.text = [NSString stringWithFormat:@"禽畜肉 100克"];
            aquaticProductsLab.text = [NSString stringWithFormat:@"水产品 100克"];
            eggLab.text = [NSString stringWithFormat:@"蛋类 50克"];
            fruitLab.text = [NSString stringWithFormat:@"水果类 400克"];
            vegetablesLab.text = [NSString stringWithFormat:@"蔬菜类 500克"];
            cerealsLab.text = [NSString stringWithFormat:@"谷薯类 375克"];
            cereal_beansLab.text = [NSString stringWithFormat:@"全谷物及杂豆 无"];
            yamLab.text = [NSString stringWithFormat:@"薯类 125克"];
        }else {// 2800 - 3000
            saltLab.text = [NSString stringWithFormat:@"盐＜6克"];
            oilLab.text = [NSString stringWithFormat:@"油 35克"];
            soybeansLab.text = [NSString stringWithFormat:@"大豆类 25克"];
            nutLab.text = [NSString stringWithFormat:@"坚果类 10克"];
            milkLab.text = [NSString stringWithFormat:@"奶及奶制品 300克"];
            aquaticProductsLab.text = [NSString stringWithFormat:@"水产品 125克"];
            eggLab.text = [NSString stringWithFormat:@"蛋类 50克"];
            poultryLab.text = [NSString stringWithFormat:@"禽畜肉 100克"];
            fruitLab.text = [NSString stringWithFormat:@"水果类 400克"];
            vegetablesLab.text = [NSString stringWithFormat:@"蔬菜类 600克"];
            cerealsLab.text = [NSString stringWithFormat:@"谷薯类 400克"];
            cereal_beansLab.text = [NSString stringWithFormat:@"全谷物及杂豆 无"];
            yamLab.text = [NSString stringWithFormat:@"薯类 125克"];
        }
}

@end
