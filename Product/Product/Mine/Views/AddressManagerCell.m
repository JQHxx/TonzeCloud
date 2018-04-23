//
//  AddressManagerCell.m
//  Product
//
//  Created by zhuqinlu on 2017/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddressManagerCell.h"
#import "UIButton+Extension.h"

@interface AddressManagerCell ()
{
    UILabel *_personInfoLab;     // 姓名，电话
    UILabel *_addressInfoLab;    // 地址信息
    UILabel *_defaultLab;        // 默认
    UIButton    *_defaultBtn;    // 设为默认按钮
    UIButton    *_editorBtn;     // 编辑按钮
    UIButton    *_deleteBtn;     // 删除按钮
}
@end

@implementation AddressManagerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
     
        CALayer *line = [[CALayer alloc]init];
        line.frame = CGRectMake(0, 0, kScreenWidth, 10);
        line.backgroundColor = [UIColor bgColor_Gray].CGColor;
        [self.contentView.layer addSublayer:line];
        
        _personInfoLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, kScreenWidth - 20, 20)];
        _personInfoLab.textColor = UIColorHex(0x313131);
        _personInfoLab.font = kFontSize(15);
        [self.contentView addSubview:_personInfoLab];
        
        _addressInfoLab = [[UILabel alloc]initWithFrame:CGRectMake(_personInfoLab.left, _personInfoLab.bottom + 8, kScreenWidth - 20, 20)];
        _addressInfoLab.textColor = UIColorHex(0x636363);
        _addressInfoLab.font = kFontSize(15);
        [self.contentView addSubview:_addressInfoLab];
        
        _defaultLab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 55, 20, 40, 20)];
        _defaultLab.hidden = YES;
        _defaultLab.layer.cornerRadius=3;
        _defaultLab.clipsToBounds=YES;
        _defaultLab.backgroundColor=kSystemColor;
        _defaultLab.textColor=[UIColor whiteColor];
        _defaultLab.font=[UIFont systemFontOfSize:12];
        _defaultLab.text=@"默认";
        _defaultLab.textAlignment=NSTextAlignmentCenter;
        [self.contentView addSubview:_defaultLab];
        
        CALayer *lens = [[CALayer alloc]init];
        lens.frame = CGRectMake(0, 80,kScreenWidth , 0.5);
        lens.backgroundColor =  UIColorFromRGB(0xe5e5e5).CGColor;
        [self.contentView.layer addSublayer:lens];
        
        _defaultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _defaultBtn.frame = CGRectMake(_personInfoLab.left, 85.5, 100, 30);
        _defaultBtn.titleLabel.font = kFontSize(15);
        [_defaultBtn setTitle:@"默认地址" forState:UIControlStateNormal];
        [_defaultBtn setImage:[UIImage imageNamed:@"pd_ic_pick_un"] forState:UIControlStateNormal];
        [_defaultBtn setTitleColor:UIColorHex(0x313131) forState:UIControlStateNormal];
        [_defaultBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        _defaultBtn.tag = 1000;
        [_defaultBtn addTarget:self action:@selector(btnAciotn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_defaultBtn];
        
        
        _editorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editorBtn.frame = CGRectMake(kScreenWidth - 95 - 90, _defaultBtn.top, 80, 30);
        _editorBtn.titleLabel.font = kFontSize(15);
        [_editorBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_editorBtn setTitleColor:UIColorHex(0x313131) forState:UIControlStateNormal];
        [_editorBtn setImage:[UIImage imageNamed:@"pd_ic_write"] forState:UIControlStateNormal];
        [_editorBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        _editorBtn.tag = 1001;
        [_editorBtn addTarget:self action:@selector(btnAciotn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_editorBtn];
        
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(kScreenWidth - 95, _defaultBtn.top, 80, 30);
        _deleteBtn.titleLabel.font = kFontSize(15);
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:UIColorHex(0x313131) forState:UIControlStateNormal];
        [_deleteBtn setImage:[UIImage imageNamed:@"pd_ic_del"] forState:UIControlStateNormal];
        [_deleteBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        _deleteBtn.tag = 1002;
        [_deleteBtn addTarget:self action:@selector(btnAciotn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteBtn];
    }
    return self;
}
#pragma mark ====== Even Response  =======

- (void)btnAciotn:(UIButton *)sender{
    switch (sender.tag) {
        case 1000:
        {
            if ([self.addressDelegate respondsToSelector:@selector(didSelectDefaultAddressInCell:)]) {
                [_addressDelegate didSelectDefaultAddressInCell:self];
            }
        }
            break;
        case 1001:
        {
            if ([self.addressDelegate respondsToSelector:@selector(didSelectEditAddressInCell:)]) {
            [_addressDelegate didSelectEditAddressInCell:self];
            }
        }
            break;
        case 1002:
        {
            if ([self.addressDelegate respondsToSelector:@selector(didSelectDeleteAddressInCell:)]) {
                [_addressDelegate didSelectDeleteAddressInCell:self];
            }
        }
            break;
        default:
            break;
    }
}
- (void)cellWithModel:(ShippingAddressModel *)addressModel{
    
    NSString *tel = [NSString ql_phoneNumberCodeText:addressModel.ship_mobile];
    NSString *useInfoStr = [NSString stringWithFormat:@"%@     %@",addressModel.ship_name,tel];
    _personInfoLab.text = useInfoStr;
    
    NSString  *areaStr = [addressModel.ship_area stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString  *areaFromStr = [areaStr substringFromIndex:9];
    NSRange range = [areaFromStr rangeOfString:@":"];
    NSString *areaTextStr = [areaFromStr substringToIndex:range.location];
    _addressInfoLab.text = [NSString stringWithFormat:@"%@%@",areaTextStr,addressModel.ship_addr];
    
    _defaultLab.hidden = [addressModel.is_default isEqualToString:@"true"] ? NO  : YES;
    
    if ([addressModel.is_default isEqualToString:@"true"] ) {
        [_defaultBtn setTitle:@"默认地址" forState:UIControlStateNormal];
        [_defaultBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
        [_defaultBtn setImage:[UIImage imageNamed:@"pd_ic_pick_on"] forState:UIControlStateNormal];
    }else{
        [_defaultBtn setTitle:@"设为默认" forState:UIControlStateNormal];
        [_defaultBtn setTitleColor:UIColorHex(0x313131) forState:UIControlStateNormal];
        [_defaultBtn setImage:[UIImage imageNamed:@"pd_ic_pick_un"] forState:UIControlStateNormal];
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
