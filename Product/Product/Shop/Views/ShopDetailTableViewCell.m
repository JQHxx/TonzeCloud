//
//  ShopDetailTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/12/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopDetailTableViewCell.h"

@interface ShopDetailTableViewCell (){

    UILabel *shopNameLabel;
    UILabel *shopPriceLabel;
    UILabel *shopMuchLabel;
    UILabel *textLabel;
    UILabel *detailLabel;
}

@end

@implementation ShopDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        shopNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        shopNameLabel.font = [UIFont systemFontOfSize:17];
        shopNameLabel.numberOfLines = 2;
        shopNameLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        [self.contentView addSubview:shopNameLabel];
        
        shopMuchLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        shopMuchLabel.font = [UIFont systemFontOfSize:24];
        shopMuchLabel.textColor = [UIColor colorWithHexString:@"0xff3b30"];
        [self.contentView addSubview:shopMuchLabel];
        
        shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        shopPriceLabel.font = [UIFont systemFontOfSize:12];
        shopPriceLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        [self.contentView addSubview:shopPriceLabel];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.font = [UIFont systemFontOfSize:15];
        textLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        [self.contentView addSubview:textLabel];
        
        detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        detailLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:detailLabel];
    }
    return self;
}
- (void)cellShopDetailModel:(GoodsModel *)model{
    textLabel.hidden = YES;
    detailLabel.hidden = YES;
    shopNameLabel.hidden = NO;
    shopMuchLabel.hidden = NO;
    shopPriceLabel.hidden = NO;

    shopNameLabel.text = model.title;
    CGSize nameSize =[shopNameLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:17]];
    shopNameLabel.frame = CGRectMake(18, 13, kScreenWidth-36, nameSize.height>41?41:nameSize.height);
    
    shopMuchLabel.text = [NSString stringWithFormat:@"¥%.2f",[model.price floatValue]];
    CGSize size = [shopMuchLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:24]];
    shopMuchLabel.frame =CGRectMake(18, 94-32, size.width, 25);
    
    shopPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",[model.mktprice floatValue]];
    shopPriceLabel.frame = CGRectMake(shopMuchLabel.right+10, shopMuchLabel.top+10, kScreenWidth/3, 15);
    //中划线
    NSMutableAttributedString *attributeMarket = [[NSMutableAttributedString alloc] initWithString:shopPriceLabel.text];
    [attributeMarket setAttributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle], NSBaselineOffsetAttributeName : @(NSUnderlineStyleSingle)} range:NSMakeRange(0,shopPriceLabel.text.length)];
    
    shopPriceLabel.attributedText = attributeMarket;


}
- (void)cellShopParameterModel:(GoodsModel *)model row:(NSInteger)indexPath{
    textLabel.hidden = NO;
    detailLabel.hidden = NO;
    shopNameLabel.hidden = YES;
    shopMuchLabel.hidden = YES;
    shopPriceLabel.hidden = YES;

    if ((model.spec.count>0&&model.params.count>0&&indexPath==0)||(model.spec.count==0&&model.params.count>0)) {
        textLabel.text = @"商品参数";
        CGSize textSize = [textLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
        textLabel.frame = CGRectMake(18, (50-textSize.height)/2, textSize.width, textSize.height);
        
        detailLabel.text = @"查看";
        detailLabel.font = [UIFont systemFontOfSize:13];
        detailLabel.textColor = [UIColor colorWithHexString:@"0x626262"];
        detailLabel.frame = CGRectMake(textLabel.right+20, (50-15)/2, kScreenWidth-textLabel.right-60, 15);
    }else{
        textLabel.text = @"选择规格";
        CGSize textSize = [textLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:15]];
        textLabel.frame = CGRectMake(18, (50-textSize.height)/2, textSize.width, textSize.height);
        
        NSMutableArray *detailArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in model.spec) {
            NSArray *type_info = [dict objectForKey:@"type_info"];
            for (NSDictionary *type_dict in type_info) {
                if ([[type_dict objectForKey:@"product_id"] integerValue]>0) {
                }else{
                    [detailArr addObject:[type_dict objectForKey:@"spec_value"]];
                }
            }
        }
        detailLabel.text =[detailArr componentsJoinedByString:@"／"];
        detailLabel.font = [UIFont systemFontOfSize:15];
        detailLabel.textColor = [UIColor colorWithHexString:@"0xf39800"];
        detailLabel.frame = CGRectMake(textLabel.right+20, (50-15)/2, kScreenWidth-textLabel.right-60, 15);
    }
   
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
