//
//  AddressTableViewCell.m
//  Product
//
//  Created by vision on 17/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddressTableViewCell.h"

@interface AddressTableViewCell () {
    UIImageView   *iconImageView;
    UILabel       *nameLabel;
    UILabel       *phoneLabel;
    UILabel       *addressLabel;
    UILabel       *defaultBagdeLabel;  //默认标签
}

@end

@implementation AddressTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        iconImageView=[[UIImageView alloc] initWithFrame:CGRectMake(18, 25, 20, 20)];
        [self.contentView addSubview:iconImageView];
        
        nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(48, 10, 80, 20)];
        nameLabel.font=[UIFont boldSystemFontOfSize:15];
        nameLabel.textColor=[UIColor colorWithHexString:@"#313131"];
        [self.contentView addSubview:nameLabel];
        
        phoneLabel=[[UILabel alloc] initWithFrame:CGRectMake(nameLabel.right, 10, 110, 20)];
        phoneLabel.font=[UIFont systemFontOfSize:15];
        [self.contentView addSubview:phoneLabel];
        
        defaultBagdeLabel=[[UILabel alloc] initWithFrame:CGRectMake(phoneLabel.right, 10, 40, 20)];
        defaultBagdeLabel.textColor=[UIColor whiteColor];
        defaultBagdeLabel.backgroundColor=kSystemColor;
        defaultBagdeLabel.layer.cornerRadius=3;
        defaultBagdeLabel.clipsToBounds=YES;
        defaultBagdeLabel.textAlignment=NSTextAlignmentCenter;
        defaultBagdeLabel.text=@"默认";
        defaultBagdeLabel.font=[UIFont systemFontOfSize:12];
        [self.contentView addSubview:defaultBagdeLabel];
        defaultBagdeLabel.hidden=YES;
        
        addressLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        addressLabel.font=[UIFont systemFontOfSize:14];
        addressLabel.textColor=[UIColor colorWithHexString:@"#999999"];
        addressLabel.numberOfLines=0;
        [self.contentView addSubview:addressLabel];
        
        UIButton *editAddressBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-35, 15, 30, 30)];
        [editAddressBtn setImage:[UIImage imageNamed:@"pd_ic_write"] forState:UIControlStateNormal];
        [self.contentView addSubview:editAddressBtn];
        self.editAddressBtn=editAddressBtn;
        
    }
    return self;
}

#pragma mark -- Event Response


#pragma mark －－Public Methods
-(void)addressTableViewCellDisplayWithAddress:(ShippingAddressModel *)model{
    
    iconImageView.image=model.isSelected?[UIImage imageNamed:@"pd_ic_pick_on"]:[UIImage imageNamed:@"pd_ic_pick_un"];
    defaultBagdeLabel.hidden=![model.is_default isEqualToString:@"true"];
    
    nameLabel.text=model.ship_name;
    phoneLabel.text=model.ship_mobile;
    NSString *areaStr=[self parseAddressAreaWithArea:model.ship_area];
    addressLabel.text=[NSString stringWithFormat:@"%@%@",areaStr,model.ship_addr];
    CGFloat addressH=[addressLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-80, CGFLOAT_MAX) withTextFont:addressLabel.font].height;
    addressLabel.frame=CGRectMake(48, nameLabel.bottom+10, kScreenWidth-80, addressH);
}

#pragma mark 获取cell高度
+(CGFloat)getCellHeightWithAddress:(ShippingAddressModel *)model{
    NSString *str1=[model.ship_area substringFromIndex:9];
    NSRange range=[str1 rangeOfString:@":"];
    NSString *str2=[str1 substringToIndex:range.location];
    NSArray *subArray=[str2 componentsSeparatedByString:@"/"];
    NSString *areaStr=@"";
    for (NSString *str in subArray) {
        areaStr=[areaStr stringByAppendingString:str];
    }
    
    NSString *addressStr=[NSString stringWithFormat:@"%@%@",areaStr,model.ship_addr];
    CGFloat addressH=[addressStr boundingRectWithSize:CGSizeMake(kScreenWidth-80, CGFLOAT_MAX) withTextFont:[UIFont systemFontOfSize:14]].height;
    
    return 40+addressH+10;
}

#pragma mark 解析地址省市区
-(NSString *)parseAddressAreaWithArea:(NSString *)area{
    NSString *str1=[area substringFromIndex:9];
    NSRange range=[str1 rangeOfString:@":"];
    NSString *str2=[str1 substringToIndex:range.location];
    NSArray *subArray=[str2 componentsSeparatedByString:@"/"];
    NSString *areaStr=@"";
    for (NSString *str in subArray) {
        areaStr=[areaStr stringByAppendingString:str];
    }
    return areaStr;
}

@end
