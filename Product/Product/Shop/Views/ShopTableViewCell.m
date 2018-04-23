//
//  ShopTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopTableViewCell.h"


@interface ShopTableViewCell (){

    UIImageView *shopImage;
    UILabel     *shopNameLabel;
    UILabel     *shopMuchLabel;
    UILabel     *shopPriceLabel;
}
@end

@implementation ShopTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        shopImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        shopImage.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:shopImage];
        
        shopNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        shopNameLabel.font = [UIFont systemFontOfSize:15];
        shopNameLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        shopNameLabel.numberOfLines = 2;
        [self.contentView addSubview:shopNameLabel];
        
        shopMuchLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        shopMuchLabel.font = [UIFont systemFontOfSize:18];
        shopMuchLabel.textColor = [UIColor colorWithHexString:@"0xf33f00"];
        [self.contentView addSubview:shopMuchLabel];
        
        shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        shopPriceLabel.font = [UIFont systemFontOfSize:12];
        shopPriceLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:shopPriceLabel];
    }
    return self;
}
- (void)CellShopModel:(ShopModel *)model{
    
    NSDictionary *imgdict =model.image;
    if (kIsDictionary(imgdict)) {
        NSString *urlstr = [NSString stringWithFormat:@"%@",[imgdict objectForKey:@"s_url"]];
        [shopImage sd_setImageWithURL:[NSURL URLWithString:urlstr] placeholderImage:[UIImage imageNamed:@"pd_img_lite_nor"]];
    }
    
    shopNameLabel.text = model.name;
    CGSize nameSize = [shopNameLabel.text sizeWithLabelWidth:kScreenWidth-shopImage.right-30 font:[UIFont systemFontOfSize:15]];
    shopNameLabel.frame =CGRectMake(shopImage.right+10, shopImage.top+5,kScreenWidth-shopImage.right-30, nameSize.height>36?36:nameSize.height);
    
    shopMuchLabel.text = [NSString stringWithFormat:@"¥%.2f",model.price];
    CGSize size = [shopMuchLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:18]];
    shopMuchLabel.frame =CGRectMake(shopImage.right+10, shopImage.bottom-25, size.width, 20);
    
    shopPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",model.mktprice];
    shopPriceLabel.frame = CGRectMake(shopMuchLabel.right+10, shopMuchLabel.top+5, kScreenWidth/3, 15);
    //中划线
    NSMutableAttributedString *attributeMarket = [[NSMutableAttributedString alloc] initWithString:shopPriceLabel.text];
    [attributeMarket setAttributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle], NSBaselineOffsetAttributeName : @(NSUnderlineStyleSingle)} range:NSMakeRange(0,shopPriceLabel.text.length)];
    
    shopPriceLabel.attributedText = attributeMarket;

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
