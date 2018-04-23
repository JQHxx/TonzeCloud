//
//  TJYCookStepCell.m
//  Product
//
//  Created by zhuqinlu on 2017/5/3.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYCookStepCell.h"


@implementation TJYCookStepCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 30 , 20, 20)];
        imgView.backgroundColor = [UIColor colorWithHexString:@"0xffc72f"];
        imgView.layer.cornerRadius = 10;
        [self.contentView addSubview:imgView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 20, 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.layer.cornerRadius = 10;
        [imgView addSubview:_titleLabel];
        
        _cookStepLable =  InsertLabel(self.contentView, CGRectMake(imgView.right + 5, imgView.top, kScreenWidth - 20 - 30 * 2 - 5, 20), NSTextAlignmentLeft, @"", kFontSize(14), UIColorHex(0x666666), NO);
        _cookStepLable.numberOfLines = 0;
        
        CGSize sizeImg = CGSizeMake(130, 100);
        _stepImg = InsertImageView(self.contentView, CGRectMake(20,_cookStepLable.bottom+30, kScreenWidth - 20 * 2,((kScreenWidth - 20 * 2)/sizeImg.width) * sizeImg.height ), [UIImage imageNamed:@""]);

    }
    return self;
}

- (void)cellInitWithData:(TJYCookSetpModel *)model{
    
    CGSize textHeight = [model.brief boundingRectWithSize:CGSizeMake( kScreenWidth - 20 - 30 * 2 - 5, 1000) withTextFont:kFontSize(14)];
    _textHight = textHeight.height;
    
    _cookStepLable.frame =  CGRectMake(_cookStepLable.left, _cookStepLable.top , _cookStepLable.width, textHeight.height > 20 ? textHeight.height : 20);
    _cookStepLable.text = model.brief;

    [_stepImg sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@""]];
    _stepImg.frame =CGRectMake(_stepImg.left,_cookStepLable.bottom + 30,_stepImg.width,_stepImg.height);

}


+(CGFloat)returnRowHeightForObject:(id)object isScrollDown:(BOOL)isFlag
{
    TJYCookSetpModel * stepModel = (TJYCookSetpModel *)object;
    
    CGFloat height = 0;
    CGSize textHeight = [stepModel.brief boundingRectWithSize:CGSizeMake(kScreenWidth - 20 - 30 * 2 - 5, 1000) withTextFont:kFontSize(14)];
    height = height + 30;
    height = textHeight.height > 20 ? height + textHeight.height : height + 20;
    
    if (!kIsEmptyString(stepModel.image_url))
    {
        CGSize sizeImg = CGSizeMake(130, 100);
        height = height + ((kScreenWidth - 20 * 2)/sizeImg.width) * sizeImg.height + 30;
    }
    
    
    // 表示最后一个cell的高度，在有图片的情况下，多加30间距
    if (isFlag)
    {
        height = height + 30;
    }
    
    return height;
}

//
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object
{
    CGFloat statusLabelWidth = kScreenWidth - 40;
    // 字符串分类提供方法，计算字符串的高度
    CGSize statusLabelSize =[object sizeWithLabelWidth:statusLabelWidth font:[UIFont systemFontOfSize:14]];
    
    return statusLabelSize.height;
}

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object length:(NSInteger)length
{
    CGFloat statusLabelWidth = kScreenWidth - length;
    // 字符串分类提供方法，计算字符串的高度
    CGSize statusLabelSize =[object sizeWithLabelWidth:statusLabelWidth font:[UIFont systemFontOfSize:14]];
    
    return statusLabelSize.height;
}
@end
