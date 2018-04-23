//
//  DietRecordTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/4/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DietRecordTableViewCell.h"

@implementation DietRecordTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)cellDisplayWithFoodDict:(NSDictionary *)foodDict{
    

    [self.foodsImageView sd_setImageWithURL:[NSURL URLWithString:foodDict[@"image_url"]] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    self.foodNameLabel.text=foodDict[@"item_name"];
    
    NSInteger weight=[foodDict[@"item_weight"] integerValue];
    self.foodsWeightLabel.text=[NSString stringWithFormat:@"%ld克",(long)weight];
    
    NSInteger calories=[foodDict[@"item_calories"] integerValue];
    self.foodEnergyLabel.text=[NSString stringWithFormat:@"%ld千卡",(long)calories];
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
