//
//  AddressInfoCell.m
//  Product
//
//  Created by zhuqinlu on 2017/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddressInfoCell.h"

@interface AddressInfoCell ()

@end

@implementation AddressInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, (44 - 20)/2, 80, 20)];
        _titleLab.font = kFontSize(15);
        _titleLab.textColor = UIColorHex(0x313131);
        [self.contentView addSubview:_titleLab];
        
        _contentTF = [[UITextField alloc]initWithFrame:CGRectMake(_titleLab.right , (44 - 30)/2, kScreenWidth - _titleLab.right - 20, 30)];
        _contentTF.textColor = UIColorHex(0x313131);
        _contentTF.font = kFontSize(15);
        _contentTF.borderStyle = UITextBorderStyleNone;
        _contentTF.backgroundColor = [UIColor whiteColor];
        _contentTF.adjustsFontSizeToFitWidth = YES;
        _contentTF.clearButtonMode = YES;
        _contentTF.returnKeyType = UIReturnKeyDone;
        _contentTF.inputAccessoryView = [[UIView alloc] init];
        [self.contentView addSubview:_contentTF];
        
        _arrowImg =[[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 35, (44 - 15)/2 , 15, 15)];
        _arrowImg.image = [UIImage imageNamed:@"ic_pub_arrow_nor"];
        [self.contentView addSubview:_arrowImg];
        
        _arrowImg.hidden = YES;
    }
    return self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.contentTF becomeFirstResponder];
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
