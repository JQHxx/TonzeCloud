

//
//  CloudRecipesCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "CloudRecipesCell.h"

@implementation CloudRecipesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setCloudRecipesCell];
    }
    return self;
}
#pragma mark ====== Set UI =======
- (void)setCloudRecipesCell{
    
    _menuImg = [[UIImageView alloc]initWithFrame:CGRectMake(15, (20 * kScreenWidth/320)/2 , 105 * kScreenWidth/320 , 70 *kScreenWidth/320)];
    [self addSubview:_menuImg];
    
    //菜谱名称
    _menuNameLab = InsertLabel(self,CGRectMake(_menuImg.right + 8, _menuImg.top, kScreenWidth - _menuImg.right - 40, 15), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
    
    _menuInfoLab = InsertLabel(self,CGRectMake(_menuNameLab.left , _menuNameLab.bottom + 5, kScreenWidth -_menuImg.right - 25, 40), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x959595), NO);
    _menuInfoLab.numberOfLines = 0;
    
    // 云菜谱图标
    UIImageView *cloudIcon = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 15 - 35/2, _menuImg.top , 35/2, 23/2)];
    cloudIcon.image = [UIImage imageNamed:@"ic_lite_cloud"];
    [self addSubview:cloudIcon];
}
#pragma mark ====== Set Data =======
- (void)setMenuListWithModel:(TJYMenuListModel *)model{
    
    [_menuImg sd_setImageWithURL:[NSURL URLWithString:model.image_id_cover] placeholderImage:[UIImage imageNamed:@"img_bg_title.png"]];
    
    _menuNameLab.text = model.name;
    
    _menuInfoLab.text = model.abstract;
}


@end
