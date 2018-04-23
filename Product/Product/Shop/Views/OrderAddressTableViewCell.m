//
//  OrderAddressTableViewCell.m
//  Product
//
//  Created by vision on 18/1/19.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import "OrderAddressTableViewCell.h"

@interface OrderAddressTableViewCell () {
    UIImageView   *iconImageView;
    UILabel       *nameLabel;
    UILabel       *phoneLabel;
    UILabel       *addressLabel;
    UILabel       *defaultBagdeLabel;  //默认标签
}

@end

@implementation OrderAddressTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *bgImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
        bgImageView.image=[UIImage imageNamed:@"pd_bg_address"];
        bgImageView.contentMode=UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:bgImageView];
        
        
        iconImageView=[[UIImageView alloc] initWithFrame:CGRectMake(18, 45, 20, 20)];
        iconImageView.image=[UIImage imageNamed:@"pd_ic_address"];
        [self.contentView addSubview:iconImageView];
        
        nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(48, 10, 80, 30)];
        nameLabel.font=[UIFont boldSystemFontOfSize:15];
        nameLabel.textColor=[UIColor colorWithHexString:@"#313131"];
        [self.contentView addSubview:nameLabel];
        
        phoneLabel=[[UILabel alloc] initWithFrame:CGRectMake(nameLabel.right, 10, 110, 30)];
        phoneLabel.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:phoneLabel];
        
        defaultBagdeLabel=[[UILabel alloc] initWithFrame:CGRectMake(phoneLabel.right, 15, 40, 20)];
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
        addressLabel.textColor=[UIColor colorWithHexString:@"#313131"];
        addressLabel.numberOfLines=0;
        [self.contentView addSubview:addressLabel];
    }
    return self;
}

#pragma mark －－Public Methods
-(void)orderAddressTableViewCellDisplayWithAddress:(ShippingAddressModel *)model{
    defaultBagdeLabel.hidden=![model.is_default isEqualToString:@"true"];
    nameLabel.text=model.ship_name;
    phoneLabel.text=model.ship_mobile;
    NSString *areaStr=[self parseAddressAreaWithArea:model.ship_area];
    addressLabel.text=[NSString stringWithFormat:@"%@%@",areaStr,model.ship_addr];
    CGFloat addressH=[addressLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-iconImageView.right-60, 60) withTextFont:addressLabel.font].height;
    addressLabel.frame=CGRectMake(48, nameLabel.bottom+5, kScreenWidth-iconImageView.right-60, addressH);
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
