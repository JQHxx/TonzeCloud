//
//  ZQSelectButton.m
//  YY
//
//  Created by mahailin on 15/9/28.
//  Copyright © 2015年 admin. All rights reserved.
//

#import "ZQSelectButton.h"

@implementation ZQSelectButton

#pragma mark -
#pragma mark ==== 系统方法 ====
#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _titleHeight = 0.f;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _titleHeight = 0.f;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (_titleHeight == 0.f)
    {
        return [super imageRectForContentRect:contentRect];
    }
    
    return CGRectMake((contentRect.size.width - self.currentImage.size.width) / 2,
                      contentRect.size.height - self.currentImage.size.height - _titleHeight,
                      self.currentImage.size.width,
                      self.currentImage.size.height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    if (_titleHeight == 0.f)
    {
        return [super titleRectForContentRect:contentRect];
    }
    
    UIEdgeInsets titleInsets = [self titleEdgeInsets];
    
    return CGRectMake(contentRect.origin.x + titleInsets.left,
                      CGRectGetMaxY(contentRect) - (titleInsets.top + titleInsets.bottom) - _titleHeight,
                      contentRect.size.width - (titleInsets.right + titleInsets.left),
                      _titleHeight);
}

#pragma mark -
#pragma mark ==== 数据初始化 ====
#pragma mark -

- (void)setSelectState:(BOOL)selectState
{
    _selectState = selectState;
    
    if (selectState)
    {
        [self setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
        [self setTitleColor:self.selectedTextColor forState:UIControlStateSelected];
        [self setTitleColor:self.selectedTextColor forState:UIControlStateHighlighted];
        [self setImage:self.selectedImage forState:UIControlStateNormal];
        [self setImage:self.selectedImage forState:UIControlStateSelected];
        [self setImage:self.selectedImage forState:UIControlStateHighlighted];
        [self setBackgroundImage:self.selectedBackgroundImage forState:UIControlStateNormal];
        [self setBackgroundImage:self.selectedBackgroundImage forState:UIControlStateSelected];
        [self setBackgroundImage:self.selectedBackgroundImage forState:UIControlStateHighlighted];
        [self setBackgroundColor:self.selectedBackgroundColor];
    }
    else
    {
        [self setTitleColor:self.normalTextColor forState:UIControlStateNormal];
        [self setTitleColor:self.normalTextColor forState:UIControlStateSelected];
        [self setTitleColor:self.normalTextColor forState:UIControlStateHighlighted];
        [self setImage:self.normalImage forState:UIControlStateNormal];
        [self setImage:self.normalImage forState:UIControlStateSelected];
        [self setImage:self.normalImage forState:UIControlStateHighlighted];
        [self setBackgroundImage:self.normalBackgroundImage forState:UIControlStateNormal];
        [self setBackgroundImage:self.normalBackgroundImage forState:UIControlStateSelected];
        [self setBackgroundImage:self.normalBackgroundImage forState:UIControlStateHighlighted];
        [self setBackgroundColor:self.normalBackgroundColor];
    }
}

- (void)setTitleHeight:(CGFloat)titleHeight
{
    _titleHeight = titleHeight;
    [self setNeedsLayout];
}

- (void)setNormalTextColor:(UIColor *)normalTextColor
{
    _normalTextColor = normalTextColor;
    [self setTitleColor:normalTextColor forState:UIControlStateNormal];
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor
{
    _selectedTextColor = selectedTextColor;
    [self setTitleColor:selectedTextColor forState:UIControlStateSelected];
    [self setTitleColor:selectedTextColor forState:UIControlStateHighlighted];
}

- (void)setNormalImage:(UIImage *)normalImage
{
    _normalImage = normalImage;
    [self setImage:normalImage forState:UIControlStateNormal];
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    _selectedImage = selectedImage;
    [self setImage:selectedImage forState:UIControlStateSelected];
    [self setImage:selectedImage forState:UIControlStateHighlighted];
}

- (void)setNormalBackgroundImage:(UIImage *)normalBackgroundImage
{
    _normalBackgroundImage = normalBackgroundImage;
    [self setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
}

- (void)setSelectedBackgroundImage:(UIImage *)selectedBackgroundImage
{
    _selectedBackgroundImage = selectedBackgroundImage;
    [self setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected];
    [self setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted];
}

@end
