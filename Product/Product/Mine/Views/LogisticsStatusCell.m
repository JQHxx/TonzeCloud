//
//  LogisticsStatusCell.m
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "LogisticsStatusCell.h"
#import "GoodsInfoModel.h"

@interface LogisticsStatusCell ()
{
    UIImageView *_stateImg;          // 派件状态
    UILabel *_stateInfoLab;      // 状态信息
    UIImageView *_stateInfoImg;  // 状态底图
    UILabel  *_startAddLab;      // 始发地
    UILabel  *_endAddLab;        // 目的地
}
@end

@implementation LogisticsStatusCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(62, 44 , kScreenWidth - 120,1)];
        len.backgroundColor = UIColorHex(0xc5c5c5);
        [self.contentView addSubview:len];
        
        UILabel *hasBeenShippedLab= [[UILabel alloc]initWithFrame:CGRectMake(40,len.top - 30, 40, 20)];
        hasBeenShippedLab.font = kFontSize(13);
        hasBeenShippedLab.textColor = UIColorHex(0x999999);
        hasBeenShippedLab.text = @"待发货";
        [self.contentView addSubview:hasBeenShippedLab];
        
        UILabel *inTransitLab = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 20,hasBeenShippedLab.top , 40, 20)];
        inTransitLab.font = kFontSize(13);
        inTransitLab.textColor = UIColorHex(0x999999);
        inTransitLab.text = @"运输中";
        inTransitLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:inTransitLab];
        
        
        UILabel *signLab = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 78,hasBeenShippedLab.top , 40, 20)];
        signLab.font = kFontSize(13);
        signLab.textColor = UIColorHex(0x999999);
        signLab.text = @"已签收";
        [self.contentView addSubview:signLab];
        
        UIImageView *hasBeenShippedImg = [[UIImageView alloc]initWithFrame:CGRectMake(60, len.top - 4, 10, 10)];
        hasBeenShippedImg.backgroundColor = UIColorHex(0xC5C5C5);
        hasBeenShippedImg.layer.cornerRadius = 5;
        hasBeenShippedImg.userInteractionEnabled = YES;
        [self.contentView addSubview:hasBeenShippedImg];
        
        UIImageView *inTransitLabImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 5, hasBeenShippedImg.top, 10, 10)];
        inTransitLabImg.backgroundColor = UIColorHex(0xC5C5C5);
        inTransitLabImg.layer.cornerRadius = 5;
        inTransitLabImg.userInteractionEnabled = YES;
        [self.contentView addSubview:inTransitLabImg];
        
        UIImageView *signImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 60, hasBeenShippedImg.top, 10, 10)];
        signImg.backgroundColor = UIColorHex(0xC5C5C5);
        signImg.layer.cornerRadius = 5;
        signImg.userInteractionEnabled = YES;
        [self.contentView addSubview:signImg];
    
        _stateImg =[[UIImageView alloc]initWithFrame:CGRectZero];
        _stateImg.backgroundColor = UIColorHex(0xf39800);
        _stateImg.layer.cornerRadius = 5;
        _stateImg.hidden = YES;
        [self.contentView addSubview:_stateImg];
        
        _stateInfoImg =[[UIImageView alloc]initWithFrame:CGRectMake(- 60, 20, 53, 20)];
        _stateInfoImg.backgroundColor = UIColorHex(0xf39800);
        _stateInfoImg.layer.cornerRadius = 8;
        [self.contentView addSubview:_stateInfoImg];
        
        _stateInfoLab =[[UILabel alloc]initWithFrame:CGRectMake(-60,_stateImg.top, 53, 20)];
        _stateInfoLab.font = kFontSize(13);
        _stateInfoLab.textAlignment = NSTextAlignmentCenter;
        _stateInfoLab.textColor = UIColorHex(0xffffff);
        [self.contentView addSubview:_stateInfoLab];
        
        // 始发地
        _startAddLab = [[UILabel alloc]initWithFrame:CGRectMake(46,len.bottom + 10 , 100, 20)];
        _startAddLab.font = kFontSize(13);
        _startAddLab.textColor = UIColorHex(0x999999);
     
        [self.contentView addSubview:_startAddLab];
        
        _endAddLab = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 160,_startAddLab.top ,120, 20)];
        _endAddLab.font = kFontSize(13);
        _endAddLab.textAlignment = NSTextAlignmentRight;
        _endAddLab.textColor = UIColorHex(0x999999);
        [self.contentView addSubview:_endAddLab];
    }
    return self;
}
- (void)cellWithGoodsInfoModel:(GoodsInfoModel *)model{
    // 始终地
    CGSize startSize = [model.Consignor boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:kFontSize(13)];
    _startAddLab.frame = CGRectMake( 60 - startSize.width/2 , 55 ,startSize.width, 20);
    _startAddLab.text = model.Consignor;
    
    CGSize endSize = [model.Consignee boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:kFontSize(13)];
    _endAddLab.frame = CGRectMake(kScreenWidth - 60 - endSize.width/2, 55 ,endSize.width, 20);
    _endAddLab.text = model.Consignee;
}
- (void)setType:(NSInteger)type{
    _stateImg.hidden = NO;
    switch (type) {
        case 0:
        {
            _stateImg.frame = CGRectMake(60, 40, 10, 10);
            _stateInfoImg.frame = CGRectMake(60 - 53/2, 16, 53, 20);
            _stateInfoLab.frame = _stateInfoImg.frame;
            _stateInfoLab.text  = @"待发货";
        }break;
        case 1:
        {
            _stateImg.frame = CGRectMake(kScreenWidth/2 - 5, 40, 10, 10);
            _stateInfoImg.frame = CGRectMake(kScreenWidth/2 - 53/2, 16, 53, 20);
            _stateInfoLab.frame = _stateInfoImg.frame;
            _stateInfoLab.text  = @"运输中";
        }break;
        case 2:{
            _stateImg.frame = CGRectMake(kScreenWidth - 60, 40, 10, 10);
            _stateInfoImg.frame = CGRectMake(kScreenWidth - 60 - 53/2, 16, 53, 20);
            _stateInfoLab.frame = _stateInfoImg.frame;
            _stateInfoLab.text  = @"已签收";
        }break;
        default:
            break;
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
