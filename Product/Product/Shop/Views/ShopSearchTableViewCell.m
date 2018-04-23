//
//  ShopSearchTableViewCell.m
//  Product
//
//  Created by 肖栋 on 17/12/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopSearchTableViewCell.h"

@implementation ShopSearchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 14, kScreenWidth-80, 20)];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        [self.contentView addSubview:_nameLabel];
        
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, 9, 50, 30)];
        [deleteBtn setImage:[UIImage imageNamed:@"pub_ic_lite_del"] forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteButton) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteBtn];
    }
    return self;
}

- (void)deleteButton{
    
    if ([_deleteSearchDelegate respondsToSelector:@selector(deleteSerachHistory:)]) {
        [_deleteSearchDelegate deleteSerachHistory:_nameLabel.text];
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
