//
//  FoodClassCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYMenuCell.h"

@interface TJYMenuCell ()
{
    CGSize  _likeTextWidth;/// 点赞文字的宽度
    CGFloat _abstractHight; /// 摘要文本宽度
}
@property (nonatomic ,strong) UIView *len;

@end

@implementation TJYMenuCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _menuImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame))];
        _menuImage.contentMode = UIViewContentModeScaleAspectFill;
        _menuImage.clipsToBounds = YES;
        [self addSubview:_menuImage];
        
        //菜谱名称
        _recipeNameLabel = InsertLabel(self,CGRectMake(12, CGRectGetMaxY(_menuImage.frame)+12, CGRectGetWidth(self.frame)-30, 15), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), YES);
        // 摘要
        _menuIntroductionLab  = InsertLabel(self,CGRectMake(_recipeNameLabel.left, _recipeNameLabel.bottom + 6, kScreenWidth - CGRectGetMaxX(_recipeNameLabel.frame) - 20, 15), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x919191), NO);
        
        // 云菜谱图标
        _cloudIcon = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 12 - 35/2, _recipeNameLabel.top , 35/2, 23/2)];
        _cloudIcon.image = [UIImage imageNamed:@"ic_lite_cloud"];
        [self addSubview:_cloudIcon];

        // 阅读量
        _readImg = [[UIImageView alloc]initWithFrame:CGRectMake(12, _recipeNameLabel.bottom + 8 , 36/2, 36/2)];
        _readImg.image = [UIImage imageNamed:@"ic_lite_read"];
        [self addSubview:_readImg];
        _readLabel = InsertLabel(self, CGRectMake(_readImg.right ,_readImg.top, 100, 15), NSTextAlignmentLeft, @"", kFontSize(12), UIColorHex(0xc9c9c9), NO);
        // 点赞量
        _thumbsUpImg = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 300, _readImg.top , 36/2, 36/2)];
        _thumbsUpImg.image = [UIImage imageNamed:@"ic_lite_thumbsUp"];
        [self addSubview:_thumbsUpImg];
        _hitsLabel = InsertLabel(self, CGRectMake(_thumbsUpImg.right + 8,_readImg.top, 100, 15), NSTextAlignmentLeft, @"", kFontSize(12), UIColorHex(0xc9c9c9), NO);

        _len =InsertView(self, CGRectMake(15, 90 * kScreenWidth/320 - 0.5 , kScreenWidth - 15, 0.5), UIColorHex(0xd1d1d1));
    }
    return self;
}
/// 瀑布流型布局
- (void)updataWaterfallsFlowFrame{
    _len.hidden = YES;
    _menuIntroductionLab.numberOfLines = 1;
    
    _menuImage.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame),120 * kScreenWidth/320);
    
    _recipeNameLabel.frame = CGRectMake(12, CGRectGetMaxY(_menuImage.frame)+12, CGRectGetWidth(self.frame)- 24 - 35/2, 15);
    _cloudIcon.frame = CGRectMake(CGRectGetWidth(self.frame) - 12 - 35/2, _recipeNameLabel.top , 35/2, 23/2);
    
    _menuIntroductionLab.frame = CGRectMake(_recipeNameLabel.left, _recipeNameLabel.bottom + 5,_recipeNameLabel.width , 12);
    _readImg.frame = CGRectMake(12, _menuIntroductionLab.bottom + 3, 36/2, 36/2);
    
    _readLabel.frame = CGRectMake(_readImg.right + 3,_readImg.top + 2, 100, 15);
    
    _thumbsUpImg.frame = CGRectMake(CGRectGetWidth(self.frame) - _likeTextWidth.width - 38, _readImg.top, 36/2, 36/2);
    _hitsLabel.frame =CGRectMake(_thumbsUpImg.right + 5 ,_readImg.top + 2, _likeTextWidth.width, 15);
}
/// 横向型布局
- (void)UpdateLineFrame{
    _menuIntroductionLab.numberOfLines = 0;
    _menuIntroductionLab.hidden = NO;
    _len.hidden = NO;
    
    _menuImage.frame = CGRectMake(15, (20 * kScreenWidth/320)/2 , 105 * kScreenWidth/320 , 70 *kScreenWidth/320);
    
    _recipeNameLabel.frame = CGRectMake(_menuImage.right + 15, _menuImage.top, 200, 20);

    _cloudIcon.frame = CGRectMake(kScreenWidth - 20 - 35/2, _recipeNameLabel.top , 35/2, 23/2);
    
    if (_abstractHight > 15) {
        _menuIntroductionLab.frame = CGRectMake(_recipeNameLabel.left, _recipeNameLabel.bottom , kScreenWidth - _menuImage.right - 35, 35);
    }else{
        _menuIntroductionLab.frame = CGRectMake(_recipeNameLabel.left, _recipeNameLabel.bottom , kScreenWidth - _menuImage.right - 35, 15);
    }
    
    _readImg.frame = CGRectMake(_recipeNameLabel.left,_menuImage.bottom - 18 , 36/2, 36/2);
    _readLabel.frame = CGRectMake(_readImg.right + 5, _readImg.top +2 , 100,15);
    
    _thumbsUpImg.frame =CGRectMake(_readLabel.right, _readImg.top , 36/2, 36/2);
    _hitsLabel.frame =  CGRectMake(_thumbsUpImg.right + 8,_readLabel.top , 100, 15);
}
- (void)cellInitWithMenuListModel:(TJYMenuListModel *)menuListModel{
    
    [_menuImage sd_setImageWithURL:[NSURL URLWithString:menuListModel.image_id_cover] placeholderImage:[UIImage imageNamed:@"img_bg_title"]];
    
    _recipeNameLabel.text = menuListModel.name;
    
    _menuIntroductionLab.text = menuListModel.abstract;
    
    if (menuListModel.is_yun!=1) {
        _cloudIcon.hidden = YES;
    }else{
        _cloudIcon.hidden = NO;
    }
    _readLabel.text = [NSString stringWithFormat:@"%ld",(long)menuListModel.reading_number];
    
    _hitsLabel.text =[NSString stringWithFormat:@"%ld",(long)menuListModel.like_number];
    // 计算点赞的文本宽度
    NSString *numberStr = [NSString stringWithFormat:@"%ld",(long)menuListModel.like_number];
    _likeTextWidth = [numberStr boundingRectWithSize:CGSizeMake(100, 1000) withTextFont:kFontSize(12)];
    // 计算摘要文本高度
   CGSize adstractStrSize  = [menuListModel.abstract boundingRectWithSize:CGSizeMake(kScreenWidth - _menuImage.right - 35, 50) withTextFont:kFontSize(13)];
    _abstractHight = adstractStrSize.height;
}

@end
