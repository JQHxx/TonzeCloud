//
//  AddFoodTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddFoodTableViewCell.h"
@interface AddFoodTableViewCell (){
    FoodAddModel  *foodModel;
}

@end
@implementation AddFoodTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setCellType:(NSInteger)cellType{
    _cellType=cellType;
}
-(void)cellDisplayWithFood:(FoodAddModel *)model{
    foodModel=model;
    
    if (model.type==1||model.type==3) {
        [self.foodImageView sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
        self.foodNameLabel.text=model.name;
        
        self.foodWeightLabel.text=[NSString stringWithFormat:@"%ld千卡/100克",(long)model.calories_pre100>0?model.calories_pre100:model.energykcal];
        if (![model.isSelected boolValue]) {
            self.foodColaryLabel.hidden=YES;
            self.choose.hidden=YES;
        }else{
            self.foodColaryLabel.hidden=NO;
            self.choose.hidden=NO;
            self.foodColaryLabel.text=[NSString stringWithFormat:@"%@克",model.weight];
            if (_cellType==1) {
                [self.choose setImage:[UIImage imageNamed:@"ic_n_meal_del"] forState:UIControlStateNormal];
            }
        }
   
    } else {
        [self.foodImageView sd_setImageWithURL:[NSURL URLWithString:model.image_id_cover] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
        self.foodNameLabel.text=model.name;
        self.foodWeightLabel.text=[NSString stringWithFormat:@"%ld千卡/100克",(long)model.energykcal>0?model.energykcal:model.calories_pre100];
        if (![model.isSelected boolValue]) {
            self.foodColaryLabel.hidden=YES;
            self.choose.hidden=YES;
        }else{
            self.foodColaryLabel.hidden=NO;
            self.choose.hidden=NO;
            self.foodColaryLabel.text=[NSString stringWithFormat:@"%@克",model.weight];
            if (_cellType==1) {
                [self.choose setImage:[UIImage imageNamed:@"ic_n_meal_del"] forState:UIControlStateNormal];
            }
        }

    }
}

- (IBAction)deleteFoodAction:(id)sender {
        if ([_cellDelegate respondsToSelector:@selector(foodTableViewCellDeleteFood:)]) {
            [_cellDelegate foodTableViewCellDeleteFood:foodModel];
        }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
