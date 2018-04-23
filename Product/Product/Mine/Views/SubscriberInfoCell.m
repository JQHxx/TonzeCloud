//
//  SubscriberInfoCell.m
//  Product
//
//  Created by zhuqinlu on 2017/12/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SubscriberInfoCell.h"

@interface SubscriberInfoCell ()
///
@property (nonatomic ,strong) UIImageView *iconImg;
///
@property (nonatomic ,strong) UILabel     *titleLab;
///
@property (nonatomic ,strong) UILabel     *subtitle;
///
@property (nonatomic ,strong) CALayer     *lens;
@end

@implementation SubscriberInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(15, (60 - 16)/2, 32/2, 32/2)];
        [self.contentView addSubview:_iconImg];
        
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(_iconImg.right + 6, 8, kScreenWidth - _iconImg.right - 20, 20)];
        _titleLab.font = kFontSize(15);
        _titleLab.textColor = UIColorHex(0x313131);
        [self.contentView addSubview:_titleLab];
        
        _subtitle = [[UILabel alloc]initWithFrame:CGRectMake(_iconImg.right + 6, _titleLab.bottom + 8, _titleLab.width, 20)];
        _subtitle.font = kFontSize(13);
        _subtitle.numberOfLines = 0;
        _subtitle.textColor = UIColorHex(0x999999);
        [self.contentView addSubview:_subtitle];
        
        _arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 30, (60 - 15)/2, 15, 15)];
        _arrowImg.image = [UIImage imageNamed:@"ic_pub_arrow_nor"];
        _arrowImg.hidden = YES;
        [self.contentView addSubview:_arrowImg];
        
        _lens = [[CALayer alloc]init];
        _lens.frame = CGRectMake(10, _subtitle.bottom + 10,kScreenWidth - 10 , 0.5);
        _lens.backgroundColor = UIColorFromRGB(0xe5e5e5).CGColor;
        [self.contentView.layer addSublayer:_lens];
    }
    return self;
}
#pragma mark ====== Setter =======

- (void)setTitleStr:(NSString *)titleStr{
    _titleLab.text = titleStr;
    if ([titleStr isEqualToString:@"查看物流信息"]) {
        _titleLab.frame = CGRectMake(_iconImg.right + 5, 20, kScreenWidth - _iconImg.right - 20, 20);
    }else{
        _titleLab.frame = CGRectMake(_iconImg.right + 5, 8, kScreenWidth - _iconImg.right - 20, 20);
    }
}
// 地址 && 留言的高度
- (void)setSubStr:(NSString *)subStr{
    CGSize strSize = [subStr boundingRectWithSize:CGSizeMake(kScreenWidth - 52, 1000) withTextFont:kFontSize(13)];
    _subtitle.frame = CGRectMake(_iconImg.right + 5, _titleLab.bottom + 3, _titleLab.width, strSize.height > 20 ? strSize.height : 20);
    _subtitle.text = [NSString isEmpty:subStr] ? @"" :subStr;
    
    _lens.frame = CGRectMake(15, strSize.height > 20 ? _subtitle.bottom + 18 : 59.5,kScreenWidth  - 15, 0.5);
}
- (void)setIconImgStr:(NSString *)iconImgStr{

     _iconImg.image = [UIImage imageNamed:iconImgStr];
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
