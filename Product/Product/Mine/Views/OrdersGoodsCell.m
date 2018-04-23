//
//  OrdersGoodsCell.m
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "OrdersGoodsCell.h"

@interface OrdersGoodsCell ()
{
    UIImageView *_goodsImgView;
    UILabel     *_goodsTitleLab;
    UILabel     *_goodsPriceLab;
    UILabel     *_goodsNumberLab;
    UILabel     *_goodsTpyeLab;
}
@end

@implementation OrdersGoodsCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _goodsImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (100 - 80)/2 * kScreenWidth/375, 80* kScreenWidth/375, 80* kScreenWidth/375)];
        _goodsImgView.layer.borderWidth = 0.5;
        _goodsImgView.layer.borderColor = UIColorHex(0xe5e5e5).CGColor;
        [self.contentView addSubview:_goodsImgView];
        
        _goodsTitleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsTitleLab.font = [UIFont systemFontOfSize:13];
        _goodsTitleLab.textColor = UIColorHex(0x313131);
        _goodsTitleLab.numberOfLines = 2;
        [self.contentView addSubview:_goodsTitleLab];
        
        _goodsTpyeLab =[[UILabel alloc] initWithFrame:CGRectZero];
        _goodsTpyeLab.font = [UIFont systemFontOfSize:12];
        _goodsTpyeLab.textColor = UIColorHex(0x999999);
        [self.contentView addSubview:_goodsTpyeLab];
        
        
        _goodsPriceLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsPriceLab.font = [UIFont systemFontOfSize:13];
        _goodsPriceLab.textColor = [UIColor redColor];
        [self.contentView addSubview:_goodsPriceLab];
        
        _goodsNumberLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsNumberLab.font = [UIFont systemFontOfSize:13];
        _goodsNumberLab.textColor = UIColorHex(0x313131);
        [self.contentView addSubview:_goodsNumberLab];
    }
    return self;
}
#pragma mark ====== set Model =======
- (void)cellWithModel:(OrderItemsModel *)model{
    
    CALayer *lens = [[CALayer alloc]init];
    lens.frame = CGRectMake(15, 100 * kScreenWidth/375 - 0.5, kScreenWidth - 15, 0.5);
    lens.backgroundColor = UIColorFromRGB(0xe5e5e5).CGColor;
    [self.contentView.layer addSublayer:lens];
    
    [_goodsImgView sd_setImageWithURL:[NSURL URLWithString:[model.goods_pic objectForKey:@"s_url"]] placeholderImage:[UIImage imageNamed:@"pd_img_lite_nor"]];
    
    _goodsTitleLab.text = model.goods_name;
    
    CGSize goodsnameSize = [_goodsTitleLab.text sizeWithLabelWidth:kScreenWidth-_goodsImgView.right- 55 font:[UIFont systemFontOfSize:13]];
    _goodsTitleLab.frame =CGRectMake(_goodsImgView.right+10, goodsnameSize.height > 18  ?_goodsImgView.top + 2 * kScreenWidth/375 : _goodsImgView.top + 5 * kScreenWidth/375 ,kScreenWidth-_goodsImgView.right-55, goodsnameSize.height>36?36:goodsnameSize.height);
    
    _goodsTpyeLab.frame = CGRectMake(_goodsTitleLab.left, goodsnameSize.height > 18 ?    _goodsTitleLab.bottom  : _goodsTitleLab.bottom + 10 * kScreenWidth/375 , _goodsTitleLab.width , 15);
    _goodsTpyeLab.text = model.spec_info;
    
    _goodsPriceLab.text = [NSString stringWithFormat:@"¥%@",[NSString notRounding:model.price afterPoint:2]];
    CGSize size = [_goodsPriceLab.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:13]];
    _goodsPriceLab.frame =CGRectMake(_goodsImgView.right+10, _goodsImgView.bottom - 18 * kScreenWidth/375 , size.width, 15);
    
    _goodsNumberLab.text = [NSString stringWithFormat:@"x%@",model.quantity];
    _goodsNumberLab.textAlignment = NSTextAlignmentRight;
    _goodsNumberLab.textColor = UIColorHex(0x313131);
    _goodsNumberLab.frame = CGRectMake(kScreenWidth - 120, _goodsTitleLab.top, 105, 20);
    
}
- (void)initWithShopFavoriteModel:(GoodsFavoriteModel *)model{

    _goodsImgView.frame = CGRectMake(15, 10, 80, 80);
    [_goodsImgView sd_setImageWithURL:[NSURL URLWithString:[model.goods_pic objectForKey:@"s_url"]] placeholderImage:[UIImage imageNamed:@"pd_img_lite_nor"]];

    _goodsTitleLab.text = model.goods_name;
    _goodsTitleLab.textColor = [UIColor colorWithHexString:@"0x313131"];
    _goodsTitleLab.font = [UIFont systemFontOfSize:13];
    
    CGSize nameSize = [_goodsTitleLab.text sizeWithLabelWidth:kScreenWidth-_goodsImgView.right- 30 font:[UIFont systemFontOfSize:13]];
    _goodsTitleLab.frame =CGRectMake(_goodsImgView.right+10, _goodsImgView.top+5,kScreenWidth-_goodsImgView.right-60, nameSize.height>36?36:nameSize.height);
    
    _goodsPriceLab.text = [NSString stringWithFormat:@"¥%.2f",model.price];
    _goodsPriceLab.font = [UIFont systemFontOfSize:13];
    _goodsPriceLab.textColor = [UIColor colorWithHexString:@"0xf33f00"];
    CGSize size = [_goodsPriceLab.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:13]];
    _goodsPriceLab.frame =CGRectMake(_goodsImgView.right+10, _goodsImgView.bottom-25, size.width, 20);
    
    _goodsNumberLab.text = [NSString stringWithFormat:@"¥%.2f",model.goods_price];
    _goodsNumberLab.textColor = [UIColor colorWithHexString:@"0x999999"];
    _goodsNumberLab.frame = CGRectMake(_goodsPriceLab.right+15, _goodsPriceLab.top+5, kScreenWidth/3, 15);
    //中划线
    NSMutableAttributedString *attributeMarket = [[NSMutableAttributedString alloc] initWithString:_goodsNumberLab.text];
    [attributeMarket setAttributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle], NSBaselineOffsetAttributeName : @(NSUnderlineStyleSingle)} range:NSMakeRange(0,_goodsNumberLab.text.length)];
    
    _goodsNumberLab.attributedText = attributeMarket;
    
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
