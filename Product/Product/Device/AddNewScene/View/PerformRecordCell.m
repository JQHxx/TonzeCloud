

//
//  PerformRecordCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "PerformRecordCell.h"

@implementation PerformRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setPerformRecordCell];
    }
    return self;
}
#pragma mark ====== Set UI =======
- (void)setPerformRecordCell{
    _performNameLab = InsertLabel(self.contentView, CGRectMake(20, 10, 200, 20), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
    _timeLab = InsertLabel(self.contentView, CGRectMake(_performNameLab.left, _performNameLab.bottom + 5, 200, 20), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x959595), NO);
    
    InsertImageView(self.contentView, CGRectMake(kScreenWidth - 35, (60 - 15)/2 , 15, 15), [UIImage imageNamed:@"ic_pub_arrow_nor"]);
    
    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(0, 60 - 0.5, kScreenWidth, 0.5)];
    len.backgroundColor = UIColorHex(0xE0E0E0);
    [self.contentView addSubview:len];
}
#pragma mark ====== set Data =======
- (void)setCellWithModel:(PerformRecordModel *)model{
    _performNameLab.text = model.scene_name;
    _timeLab.text =  [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:model.start_time format:@"yyyy-MM-dd HH:mm"];
}
@end
