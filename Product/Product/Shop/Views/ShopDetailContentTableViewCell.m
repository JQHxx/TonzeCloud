//
//  ShopDetailContentTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/12/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopDetailContentTableViewCell.h"

@interface ShopDetailContentTableViewCell (){

    UILabel *titleLabel;
    UILabel *contentLabel;
}
@end
@implementation ShopDetailContentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
        bgView.backgroundColor = [UIColor bgColor_Gray];
        [self.contentView addSubview:bgView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 20, kScreenWidth, 20)];
        titleLabel.text = @"商品介绍";
        titleLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:titleLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.font = [UIFont systemFontOfSize:13];
        contentLabel.textColor = [UIColor colorWithHexString:@"0x818181"];
        contentLabel.numberOfLines = 0;
        [self.contentView addSubview:contentLabel];
        
    }
    return self;
}
- (void)cellShopDetailContentModel:(GoodsModel *)model{

    contentLabel.text = model.brief;
    CGSize size = [contentLabel.text sizeWithLabelWidth:kScreenWidth-36 font:[UIFont systemFontOfSize:13]];
    contentLabel.frame = CGRectMake(18,titleLabel.bottom+10, kScreenWidth-36, size.height);

}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
