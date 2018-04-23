//
//  TJYMenuTableViewCell.m
//  Product
//
//  Created by vision on 17/5/4.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYMenuTableViewCell.h"
#import "UIInitMethod.h"

@interface TJYMenuTableViewCell (){
    UIImageView     *menuImageView;
    UILabel         *menuNameLabel;
    UILabel         *menuInfoLabel;
    
    UIImageView     *readImageView;
    UILabel         *readLbl;
    
    UIImageView     *praiseImageView;
    UILabel         *praiseLbl;
}

@end


@implementation TJYMenuTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        menuImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 80,80 )];
        [self.contentView addSubview:menuImageView];
        
        menuNameLabel = InsertLabel(self.contentView,CGRectMake(menuImageView.right+10, 5, kScreenWidth-menuImageView.right-10, 20), NSTextAlignmentLeft, @"菜谱名称", kFontSize(16), UIColorHex(0x333333), YES);
        
        menuInfoLabel = InsertLabel(self.contentView, CGRectMake(menuImageView.right+10,menuNameLabel.bottom ,kScreenWidth-menuImageView.right-10 , 40), NSTextAlignmentLeft, @"菜谱简介菜谱简介菜谱简介菜谱简介", kFontSize(14), UIColorHex(0x999999), NO);
        menuInfoLabel.numberOfLines=2;
        
        readImageView=[[UIImageView alloc] initWithFrame:CGRectMake(menuImageView.right+10, menuInfoLabel.bottom, 20, 20)];
        readImageView.image=[UIImage imageNamed:@"ic_lite_yue"];
        [self.contentView addSubview:readImageView];
        
        readLbl=[[UILabel alloc] initWithFrame:CGRectMake(readImageView.right+5, menuInfoLabel.bottom, (kScreenWidth-menuImageView.right-10)/2-30, 20)];
        readLbl.textColor=UIColorHex(0x66666);
        readLbl.font=kFontSize(12);
        [self.contentView addSubview:readLbl];
        
        praiseImageView=[[UIImageView alloc] initWithFrame:CGRectMake(readLbl.right+10, menuInfoLabel.bottom, 20, 20)];
        praiseImageView.image=[UIImage imageNamed:@"ic_lite_zan"];
        [self.contentView addSubview:praiseImageView];
        
        praiseLbl=[[UILabel alloc] initWithFrame:CGRectMake(praiseImageView.right+5, menuInfoLabel.bottom, (kScreenWidth-menuImageView.right-10)/2-30, 20)];
        praiseLbl.textColor=UIColorHex(0x66666);
        praiseLbl.font=kFontSize(12);
        [self.contentView addSubview:praiseLbl];
        
    }
    return self;
}


-(void)menuCellDisplayWithModel:(MenuCollectModel *)menuModel{
    [menuImageView sd_setImageWithURL:[NSURL URLWithString:menuModel.image_url] placeholderImage:[UIImage imageNamed:@"img_bg40x40"]];
    menuNameLabel.text = menuModel.name;
    menuInfoLabel.text = menuModel.abstract;
    readLbl.text=[NSString stringWithFormat:@"%ld",(long)menuModel.reading_number];
    praiseLbl.text=[NSString stringWithFormat:@"%ld",(long)menuModel.like_number];
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
