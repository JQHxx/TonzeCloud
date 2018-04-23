
//
//  TJYMenuDetailsRemarksCell.m
//  Product
//
//  Created by zhuqinlu on 2017/5/4.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYMenuDetailsRemarksCell.h"

@implementation TJYMenuDetailsRemarksCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _remarksLabel = InsertLabel(self.contentView, CGRectMake(20, 8, kScreenWidth - 40, 1000), NSTextAlignmentLeft, @"", kFontSize(14), UIColorHex(0x666666), NO);
        _remarksLabel.numberOfLines = 0;
    }
    return self;
}
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object
{
    CGFloat statusLabelWidth = [UIScreen mainScreen].bounds.size.width - 40;
    // 字符串分类提供方法，计算字符串的高度
    CGSize statusLabelSize =[object sizeWithLabelWidth:statusLabelWidth font:[UIFont systemFontOfSize:14]];
    return statusLabelSize.height;
}

- (void)cellInitWithData:(NSString *)str{

    CGSize textSize = [str boundingRectWithSize:CGSizeMake(kScreenWidth - 40, 1000) withTextFont:kFontSize(14)];
    
    _remarksLabel.frame = CGRectMake(20, 8, kScreenWidth - 40, textSize.height);
    _remarksLabel.text = str;
}
@end
