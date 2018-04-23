//
//  ShopParameterTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopParameterTableViewCell.h"

@interface ShopParameterTableViewCell (){

    UILabel  *nameLabel;
    UILabel  *contentLabel;
}

@end
@implementation ShopParameterTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:nameLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 14, kScreenWidth-150, 20)];
        contentLabel.font = [UIFont systemFontOfSize:13];
        contentLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:contentLabel];
    }
    return self;
}
- (void)cellParameterDict:(NSDictionary *)dict{

    nameLabel.text = [dict objectForKey:@"type_key"];
    CGSize size = [nameLabel.text sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
    nameLabel.frame = CGRectMake(18, 14, size.width, 20);
    
    contentLabel.text = [dict objectForKey:@"type_val"];
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
