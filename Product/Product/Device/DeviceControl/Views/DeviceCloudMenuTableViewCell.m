//
//  DeviceCloudMenuTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/5/10.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DeviceCloudMenuTableViewCell.h"

@implementation DeviceCloudMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)cellDisplayWithModel:(deviceCloudMenuModel *)model{
    
    [self.cloudMenuImg sd_setImageWithURL:[NSURL URLWithString:model.image_id_cover] placeholderImage:[UIImage imageNamed:@"img_bg_title.png"]];
    self.cloudMenuName.text = model.name;
    self.cloudMenuName.textColor = [UIColor colorWithHexString:@"0x313131"];
    self.cloudMenuDetail.text = model.abstract;
    self.cloudMenuDetail.textColor = [UIColor colorWithHexString:@"0x7d7d7d"];
    self.eyeNumber.text =  [NSString stringWithFormat:@"%ld",model.reading_number];
    self.seletedNumber.text =[NSString stringWithFormat:@"%ld",model.like_number];
    self.seletedNumber.textColor = [UIColor colorWithHexString:@"0xc9c9c9"];
    self.eyeNumber.textColor = [UIColor colorWithHexString:@"0xc9c9c9"];
    self.isYunImage.image = [UIImage imageNamed:model.is_yun==YES?@"ic_lite_yun":@""];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
