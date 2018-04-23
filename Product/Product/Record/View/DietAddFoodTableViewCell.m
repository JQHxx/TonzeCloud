//
//  DietAddFoodTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/4/21.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DietAddFoodTableViewCell.h"

@implementation DietAddFoodTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)cellFoodDisplayWith:(FoodAddModel *)foodModel{

    if (foodModel.type == 1||foodModel.type==3) { //食物
        [self.foodImageView sd_setImageWithURL:[NSURL URLWithString:foodModel.image_url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
        self.foodNameLabel.text=foodModel.name;
        self.foodWeightLabel.text=[NSString stringWithFormat:@"%@克",foodModel.weight];
        CGFloat weightValue=[foodModel.weight integerValue];
        
        CGFloat calory=foodModel.energykcal;
        if ([TJYHelper sharedTJYHelper].isHistoryDiet == YES) {
            self.foodColaryLabel.text=[NSString stringWithFormat:@"%ld千卡",(long)calory];
        }else{
             self.foodColaryLabel.text=[NSString stringWithFormat:@"%ld千卡",(long)(calory*weightValue/100.0)];
        }

    } else { //菜谱
        [self.foodImageView sd_setImageWithURL:[NSURL URLWithString:foodModel.image_id_cover] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
        self.foodNameLabel.text=foodModel.name;
        self.foodWeightLabel.text=[NSString stringWithFormat:@"%@克",foodModel.weight];
        CGFloat weightValue=[foodModel.weight integerValue];
        
        CGFloat calory=foodModel.calories_pre100;
        if ([TJYHelper sharedTJYHelper].isHistoryDiet == YES) {
            self.foodColaryLabel.text=[NSString stringWithFormat:@"%ld千卡",(long)calory];
        }else{
            self.foodColaryLabel.text=[NSString stringWithFormat:@"%ld千卡",(long)(calory*weightValue/100.0)];
        }

        
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
