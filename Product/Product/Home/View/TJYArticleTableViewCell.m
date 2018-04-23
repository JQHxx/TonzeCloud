//
//  TJYArticleTableViewCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYArticleTableViewCell.h"
#import "QLCoreTextManager.h"

@interface TJYArticleTableViewCell ()
{
    CALayer     *_lens;
}
@end

@implementation TJYArticleTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _Img = InsertImageView(self.contentView, CGRectMake(10,(20 * kScreenWidth/320)/2, 120 * kScreenWidth/320, 80 * kScreenWidth/320), [UIImage imageNamed:@"img_bg_title"]);
        
        _titleLabel = InsertLabel(self.contentView, CGRectMake(_Img.right + 15, _Img.top , kScreenWidth - _Img.right - 20, 40), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
        _titleLabel.numberOfLines = 0;
        
        _readCountLabel = InsertLabel(self.contentView, CGRectMake(_Img.right ,70 *kScreenWidth/320 , kScreenWidth - _Img.right - 20, 20), NSTextAlignmentRight, @"", kFontSize(12), UIColorHex(0x9c9c9c), NO);
        
        _lens = [[CALayer alloc]init];
        _lens.frame = CGRectMake(10, 100 * kScreenWidth/320 - 0.5, kScreenWidth - 10, 0.5);
        _lens.hidden = YES;
        _lens.backgroundColor = UIColorHex(0xe5e5e5).CGColor;
        [self.layer addSublayer:_lens];
    }
    return self;
}
- (void)cellDisplayWithModel:(TJYArticleModel *)model type:(NSInteger )type   searchText:(NSString *)searchText{
    
    [_Img sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@"img_bg_title"]];
    
    if (type==1) {
        _lens.hidden = NO;
    }
    
    CGFloat titleTextWidth = kScreenWidth - _Img.right - 20;
    CGSize titleSize = [model.title boundingRectWithSize:CGSizeMake(titleTextWidth, 100) withTextFont:kFontSize(15)];
    if (titleSize.height > 20) {
        _titleLabel.frame = CGRectMake(_Img.right + 15, _Img.top , kScreenWidth - _Img.right - 20, 40);
    }else{
        _titleLabel.frame = CGRectMake(_Img.right + 15, _Img.top , kScreenWidth - _Img.right - 20, 20);
    }
    if (!kIsEmptyString(searchText)) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",model.title]];
        [QLCoreTextManager setAttributedValue:attString text:searchText font:kFontSize(15) color:[UIColor redColor]];
        _titleLabel.attributedText = attString;
    }else{
        _titleLabel.text = model.title;
    }
    
    _readCountLabel.text=[NSString stringWithFormat:@"%ld人阅读",(long)model.reading_number>0?model.reading_number : model.reading_number];
}
@end
