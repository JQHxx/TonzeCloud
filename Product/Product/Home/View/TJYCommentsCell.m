
//
//  TJYCommentsCell.m
//  Product
//
//  Created by zhuqinlu on 2017/5/5.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYCommentsCell.h"

@implementation TJYCommentsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 48, 48)];
        image.image = [UIImage imageNamed:@"ic_food_dianping"];
        image.layer.cornerRadius = 24;
        image.layer.masksToBounds  = YES;
        [self addSubview:image];
        
        _commentsLabel =  InsertLabel(self.contentView, CGRectMake(78,12, kScreenWidth - 100, 100), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x626262), NO);

        _commentsLabel.numberOfLines = 0;
    }
    return self;
}
- (void)setCellDataWithStr:(NSString *)str{
    _commentsLabel.text = str;
}
//
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object
{
    CGFloat statusLabelWidth = kScreenWidth - 40;
    // 字符串分类提供方法，计算字符串的高度
    CGSize statusLabelSize =[object sizeWithLabelWidth:statusLabelWidth font:[UIFont systemFontOfSize:12]];
    
    return statusLabelSize.height + 10;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize textSize = [self.commentsLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 100, 1000) withTextFont:kFontSize(12)];
    _commentsLabel.frame = CGRectMake(78, 12, kScreenWidth - 100,textSize.height+20);

}

@end
