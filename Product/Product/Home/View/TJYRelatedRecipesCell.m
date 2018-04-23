//
//  TJYRelatedRecipesCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYRelatedRecipesCell.h"
#import "QLCoreTextManager.h"

@interface TJYRelatedRecipesCell ()
{
    CGFloat _abstractHight;// 摘要文本高度
    UIView *len;
}
@end

@implementation TJYRelatedRecipesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _relatedImg =  InsertImageView(self.contentView, CGRectMake(15, 15, 105 * kScreenWidth/320, 70 *kScreenWidth/320), [UIImage imageNamed:@""]);
        
        _relatedNameLab = InsertLabel(self.contentView, CGRectMake(_relatedImg.right + 15, _relatedImg.top, kScreenWidth - _relatedNameLab.left - 20 , 15), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
        
        _cloudIcon = InsertImageView(self.contentView, CGRectMake(kScreenWidth - 35/2 - 20, _relatedImg.top, 35/2, 23/2), [UIImage imageNamed:@"ic_lite_cloud"]);
        
        _relatedInfo =  InsertLabel(self.contentView, CGRectMake(_relatedNameLab.left, _relatedNameLab.bottom + 5, kScreenWidth - _relatedNameLab.left - 20, 15), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x626262), NO);
        _relatedInfo.numberOfLines = 0;
        
        // 阅读量
        UIImageView *readNumberImg = InsertImageView(self.contentView, CGRectMake(_relatedNameLab.left, _relatedImg.bottom - 18, 36/2, 36/2), [UIImage imageNamed:@"ic_lite_read"]);
        _readNumberLab = InsertLabel(self.contentView, CGRectMake(readNumberImg.right + 5,  readNumberImg.top + 2 , 100, 15), NSTextAlignmentLeft, @"", kFontSize(12), UIColorHex(0xc9c9c9), NO);
        
        // 点赞量
        UIImageView *hitImg = InsertImageView(self.contentView, CGRectMake(_readNumberLab.right, readNumberImg.top,36/2, 36/2), [UIImage imageNamed:@"ic_lite_thumbsUp"]);
        
        _hitsLab = InsertLabel(self.contentView, CGRectMake(hitImg.right + 5,  readNumberImg.top + 2, 100, 15), NSTextAlignmentLeft, @"", kFontSize(12), UIColorHex(0xc9c9c9), NO);
        
       len =  InsertView(self, CGRectMake(_relatedImg.left, 90 * kScreenWidth/320 - 0.5 , kScreenWidth - _relatedNameLab.left, 0.5), kLineColor);
    }
    return self;
}

-(void)cellInitWithData:(TJYMenuListModel *)model searchText:(NSString *)searchText{
    
    [_relatedImg sd_setImageWithURL:[NSURL URLWithString:model.image_id_cover] placeholderImage:[UIImage imageNamed:@"img_bg_title@2x"]];
    
    if (!kIsEmptyString(searchText)) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",model.name]];
        [QLCoreTextManager setAttributedValue:attString text:searchText font:kFontSize(15) color:[UIColor redColor]];
        _relatedNameLab.attributedText = attString;
    }else{
       _relatedNameLab.text = model.name;
    }
    
    if (model.is_yun) {
        _cloudIcon.hidden = NO;
    }else{
        _cloudIcon.hidden = YES;
    }
    // 计算摘要文本高度
    CGSize adstractStrSize  = [model.abstract boundingRectWithSize:CGSizeMake(kScreenWidth - _relatedImg.right - 35, 50) withTextFont:kFontSize(12)];
    _abstractHight = adstractStrSize.height;
    
    if (_abstractHight > 15) {
        _relatedInfo.frame =  CGRectMake(_relatedNameLab.left, _relatedNameLab.bottom + 3, kScreenWidth - _relatedNameLab.left - 20, 35);
    }else{
        _relatedInfo.frame =  CGRectMake(_relatedNameLab.left, _relatedNameLab.bottom + 3, kScreenWidth - _relatedNameLab.left - 20, 15);
    }
    _relatedInfo.text = model.abstract;
    
    _readNumberLab.text = [NSString stringWithFormat:@"%ld",model.reading_number];
    
    _hitsLab.text = [NSString stringWithFormat:@"%ld",model.like_number];
    len.frame = CGRectMake(15,90 * kScreenWidth/320 - 0.5 , kScreenWidth - 15, 0.5);
}

- (void)menuCellDisplayWithModel:(MenuCollectModel *)menuModel
{
    [_relatedImg sd_setImageWithURL:[NSURL URLWithString:menuModel.image_url] placeholderImage:[UIImage imageNamed:@"img_bg_title@2x"]];
    
    _relatedNameLab.text = menuModel.name;
    if (menuModel.is_yun) {
        _cloudIcon.hidden = NO;
    }else{
        _cloudIcon.hidden = YES;
    }
    // 计算摘要文本高度
    CGSize adstractStrSize  = [menuModel.abstract boundingRectWithSize:CGSizeMake(kScreenWidth - _relatedImg.right - 35, 50) withTextFont:kFontSize(12)];
    _abstractHight = adstractStrSize.height;
    
    if (_abstractHight > 15) {
        _relatedInfo.frame =  CGRectMake(_relatedNameLab.left, _relatedNameLab.bottom + 3, kScreenWidth - _relatedNameLab.left - 20, 35);
    }else{
        _relatedInfo.frame =  CGRectMake(_relatedNameLab.left, _relatedNameLab.bottom + 3, kScreenWidth - _relatedNameLab.left - 20, 15);
    }
    _relatedInfo.text = menuModel.abstract;
    
    _readNumberLab.text = [NSString stringWithFormat:@"%ld",menuModel.reading_number];
    
    _hitsLab.text = [NSString stringWithFormat:@"%ld",menuModel.like_number]; 
}
@end
