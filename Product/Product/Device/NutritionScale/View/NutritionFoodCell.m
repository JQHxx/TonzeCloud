//
//  NutritionFoodCell.m
//  Product
//
//  Created by mk-imac2 on 2017/9/2.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "NutritionFoodCell.h"

@interface NutritionFoodCell()

@property (nonatomic,strong) TJYFoodListModel * foodModel;

@property (nonatomic,copy) NutritionFoodBlock foodBlock;

@end

@implementation NutritionFoodCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.btnDelete addTarget:self action:@selector(onBtnDelete:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)renderNutritionFoodCell:(id)data foodBlock:(NutritionFoodBlock)block
{
    self.foodModel = (TJYFoodListModel *)data;
    self.foodBlock = block;
    
    [self.imgFood sd_setImageWithURL:[NSURL URLWithString:self.foodModel.image_url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    self.lblFood.text=self.foodModel.name;
    
    self.lblWeight.text=[NSString stringWithFormat:@"%.0f克",self.foodModel.weight];
    
    self.lblHeat.text=[self handleNutrition:self.foodModel.totalkcal withUnit:@"千卡"];
    
    [self.btnDelete setImage:[UIImage imageNamed:@"ic_n_meal_del"] forState:UIControlStateNormal];


}

-(NSString *)handleNutrition:(CGFloat)type withUnit:(NSString *)strUnit
{
    NSString * content = @"";
    
    if(type != 0)
    {
        content = [NSString stringWithFormat:@"%.0f%@",type,strUnit];
    }
    else
    {
        content = [NSString stringWithFormat:@"--%@",strUnit];
    }
    
    return content;
}



-(void)onBtnDelete:(id)sender
{
    if (self.foodBlock) {
        self.foodBlock(self.foodModel);
    }
}

@end
