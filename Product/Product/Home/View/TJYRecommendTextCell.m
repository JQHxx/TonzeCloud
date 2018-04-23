//
//  TJYRecommendTextCell.m
//  Product
//
//  Created by zhuqinlu on 2017/5/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYRecommendTextCell.h"

@implementation TJYRecommendTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _commentsLabel =  InsertLabel(self.contentView, CGRectMake(15,0, kScreenWidth - 30, 100), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x626262), NO);
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
    CGFloat statusLabelWidth = kScreenWidth - 30;
    CGSize statusLabelSize =[object sizeWithLabelWidth:statusLabelWidth font:[UIFont systemFontOfSize:12]];
    return statusLabelSize.height + 10;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize textSize = [self.commentsLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 30, 1000) withTextFont:kFontSize(13) ];
    _commentsLabel.frame = CGRectMake(15, 0, kScreenWidth - 30,textSize.height);
}


@end
