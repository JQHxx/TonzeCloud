//
//  DietHistoryTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/4/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DietHistoryTableViewCell.h"

@implementation DietHistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)cellDisplayWithModel:(FoodRecordModel *)diet{

    NSString *dietTime=[[TJYHelper sharedTJYHelper] getDietPeriodChNameWithPeriod:diet.time_slot];
    NSString *path=[[NSBundle mainBundle] pathForResource:@"dietTime" ofType:@"plist"];
    NSDictionary *dict=[[NSDictionary alloc] initWithContentsOfFile:path];
    self.dietImageView.image=[UIImage imageNamed:dict[diet.time_slot]];
    self.dietTimeLabel.text=dietTime;
    
    NSArray *foodsArr=diet.item;
    NSInteger total_energy=0;
    for (NSDictionary *dict in foodsArr) {
        total_energy+=[dict[@"item_calories"] integerValue];
    }
    
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld千卡",(long)total_energy]];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:kRGBColor(244, 182, 123) range:NSMakeRange(0, attributeStr.length-2)];
    self.caloryLabel.attributedText=attributeStr;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
