//
//  SportRecordTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SportRecordTableViewCell.h"

@implementation SportRecordTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)cellDisplayWithModel:(SportRecordModel *)sport{

    [self.sportImage sd_setImageWithURL:[NSURL URLWithString:sport.motion_type_image_url] placeholderImage:nil];
    
    self.sportName.text=sport.motion_type_name;
    
    NSString *valueStr=[NSString stringWithFormat:@"%ld分钟",(long)[sport.motion_time integerValue]];
    self.SportTime.hidden=NO;
    
    NSString *startTime=[[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:sport.motion_bigin_time format:@"HH:mm"];
    self.SportTime.text=kIsEmptyString(startTime)?@"":startTime;
    
    self.SportCalory.text=[NSString stringWithFormat:@"%ld千卡",(long)[sport.calorie integerValue]];
    self.sportTimeLength.text=valueStr;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
