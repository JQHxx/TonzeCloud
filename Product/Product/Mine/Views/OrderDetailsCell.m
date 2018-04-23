
//
//  OrderDetailsCell.m
//  Product
//
//  Created by zhuqinlu on 2017/12/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "OrderDetailsCell.h"

@interface OrderDetailsCell ()

@end

@implementation OrderDetailsCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 80, 20)];
        _titleLab.font = kFontSize(13);
        _titleLab.textColor = UIColorHex(0x313131);
        [self.contentView addSubview:_titleLab];
        
        _contentLab = [[UILabel alloc]initWithFrame:CGRectMake(_titleLab.right + 5, _titleLab.top, 200, 20)];
        _contentLab.font = kFontSize(13);
        _contentLab.textColor = UIColorHex(0x999999);
        [self.contentView addSubview:_contentLab];
        
        _pasteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pasteBtn.frame = CGRectMake(kScreenWidth - 75, 5, 60, 24);
        [_pasteBtn setTitle:@"复制" forState:UIControlStateNormal];
        _pasteBtn.layer.cornerRadius = 2;
        _pasteBtn.layer.borderWidth = 0.5;
        _pasteBtn.titleLabel.font = kFontSize(13);
        _pasteBtn.layer.borderColor = UIColorHex(0x999999).CGColor;
        [_pasteBtn setTitleColor:UIColorHex(0x626262) forState:UIControlStateNormal];
        [_pasteBtn addTarget:self action:@selector(copyClick) forControlEvents:UIControlEventTouchUpInside];
        _pasteBtn.hidden = YES;
        [self.contentView addSubview:_pasteBtn];
        
    }
    return self;
}
#pragma mark ====== 复制订单 =======
- (void)copyClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectDuplicateOrder)]) {
        [self.delegate didSelectDuplicateOrder];
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
