//
//  TJYIntensityTableViewCell.m
//  Product
//
//  Created by vision on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYIntensityTableViewCell.h"

@interface TJYIntensityTableViewCell () {
    UILabel    *titleLabel;
    UILabel    *contentLabel;
    UIButton   *selectButton;
}

@end

@implementation TJYIntensityTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth/3*2, 20)];
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:titleLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.textColor = [UIColor lightGrayColor];
        contentLabel.font = [UIFont systemFontOfSize:12];
        contentLabel.numberOfLines=0;
        [self.contentView addSubview:contentLabel];
        
        selectButton=[[UIButton alloc] initWithFrame:CGRectZero];
        [selectButton setImage:[UIImage imageNamed:@"ic_pub_choose_nor"] forState:UIControlStateNormal];
        [selectButton setImage:[UIImage imageNamed:@"ic_pub_pick_food"] forState:UIControlStateSelected];
        [self.contentView addSubview:selectButton];
    }
    return self;
}

-(void)cellDisplayWithLabor:(TJYLaborModel *)model{
    titleLabel.text=model.title;
    
    NSString *contentStr=model.content;
    CGFloat contentH=[contentStr boundingRectWithSize:CGSizeMake(kScreenWidth-70, CGFLOAT_MAX) withTextFont:[UIFont systemFontOfSize:12]].height;
    contentLabel.frame=CGRectMake(20, titleLabel.bottom, kScreenWidth-70, contentH+10);
    contentLabel.text=contentStr;
    
    CGFloat cellH=contentH+40;
    selectButton.frame=CGRectMake(kScreenWidth-40, (cellH-25)/2, 25, 25);
    selectButton.selected=[model.isSelected boolValue];
}

+(CGFloat)getCellHeightWithLabor:(TJYLaborModel *)model{
    NSString *contentStr=model.content;
    CGFloat contentH=[contentStr boundingRectWithSize:CGSizeMake(kScreenWidth-70, CGFLOAT_MAX) withTextFont:[UIFont systemFontOfSize:12]].height;
    return contentH+40;
}



@end
