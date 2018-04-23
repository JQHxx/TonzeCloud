//
//  SportTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SportTableViewCell.h"

@implementation SportTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)cellSportDisplayWith:(SportTableModel *)Model{

    [self.imgView sd_setImageWithURL:[NSURL URLWithString:Model.image_url] placeholderImage:nil];
    self.sportType.text = Model.name;
    self.consumeLab.text = [NSString stringWithFormat:@"%ld千卡／30分钟",Model.calorie];
    self.sportWorkRank.text = Model.motion_intensity;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
