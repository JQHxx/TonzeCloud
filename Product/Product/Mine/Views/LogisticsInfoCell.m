//
//  LogisticsInfoCell.m
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "LogisticsInfoCell.h"
#import "UILabel+Extension.h"

@interface LogisticsInfoCell()
{
    UIImageView     *_goodsImgView;         // 商品图片
    UILabel         *_goodsNumLab;          // 商品数量
    UILabel         *_logisticsCompanyLab;  // 物流公司
    UILabel         *_logisticsSingleNumberLab; // 物流单号
    UILabel         *_logisticsCallLab;     // 物流电话
}
@end

@implementation LogisticsInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = kSystemColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _goodsImgView = [[UIImageView alloc]initWithFrame:CGRectMake(18, 18, 84, 84)];
        _goodsImgView.backgroundColor = [UIColor bgColor_Gray];
        _goodsImgView.image = [UIImage imageNamed:@"pd_img_nor"];
        [self.contentView addSubview:_goodsImgView];
        
        UILabel *goodsInfnBg = [[UILabel alloc]initWithFrame:CGRectMake(0, _goodsImgView.height - 15, _goodsImgView.width, 15)];
        goodsInfnBg.backgroundColor = UIColorHex_Alpha(0x2C2C2C, 0.9);
        [_goodsImgView addSubview:goodsInfnBg];
        
        _goodsNumLab = [[UILabel alloc]initWithFrame:CGRectMake(0, _goodsImgView.height - 15, _goodsImgView.width, 15)];
        _goodsNumLab.font = kFontSize(12);
        _goodsNumLab.textAlignment = NSTextAlignmentCenter;
        _goodsNumLab.textColor = [UIColor whiteColor];
        [_goodsImgView addSubview:_goodsNumLab];
        
        
        _logisticsCompanyLab = [[UILabel alloc]initWithFrame:CGRectMake(_goodsImgView.right + 18, _goodsImgView.top + 6, kScreenWidth - _goodsImgView.right - 20, 20)];
        _logisticsCompanyLab.font = kFontSize(13);
        _logisticsCompanyLab.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_logisticsCompanyLab];
        
        _logisticsSingleNumberLab = [[UILabel alloc]initWithFrame:CGRectMake(_logisticsCompanyLab.left, _logisticsCompanyLab.bottom + 6, _logisticsCompanyLab.width, _logisticsCompanyLab.height)];
        _logisticsSingleNumberLab.font = kFontSize(13);
        _logisticsSingleNumberLab.isCopyable = YES;
        _logisticsSingleNumberLab.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_logisticsSingleNumberLab];
        
        _logisticsCallLab = [[UILabel alloc]initWithFrame:CGRectMake(_logisticsCompanyLab.left, _logisticsSingleNumberLab.bottom + 6, _logisticsCompanyLab.width, _logisticsCompanyLab.height)];
        _logisticsCallLab.font = kFontSize(13);
        _logisticsCallLab.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_logisticsCallLab];

    }
    return self;
}
- (void)cellWithGoodsInfoModel:(GoodsInfoModel *)model  deliveryModel:(DeliveryModel *)deliveryModel{

    NSDictionary *goodsPicDic = model.goods_pic[0];
    [_goodsImgView sd_setImageWithURL:[NSURL URLWithString:[goodsPicDic objectForKey:@"s_url"]] placeholderImage:[UIImage imageNamed:@"pd_img_nor"]];
    _goodsNumLab.text = [NSString stringWithFormat:@"%@件商品",model.goods_num];
    
    _logisticsCompanyLab.text = [NSString stringWithFormat:@"配送企业：%@",deliveryModel.logi_name];

    _logisticsSingleNumberLab.text =[NSString stringWithFormat: @"快递单号：%@",deliveryModel.LogisticCode];
    
    _logisticsCallLab.text = [NSString stringWithFormat:@"联系电话：%@",deliveryModel.logi_tel];
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
