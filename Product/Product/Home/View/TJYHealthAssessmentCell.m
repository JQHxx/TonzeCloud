
//
//  TJYHealthAssessmentCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/18.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYHealthAssessmentCell.h"

@implementation TJYHealthAssessmentCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _titleImg = [[UIImageView alloc]initWithFrame:CGRectMake((frame.size.width -  80)/2, 20 ,80 ,80)];
        [self addSubview:_titleImg];
        
        _titleLabel = InsertLabel(self, CGRectMake(0, _titleImg.bottom + 15, frame.size.width, 15), NSTextAlignmentCenter, @"", kFontSize(15), UIColorHex(0x3333333), NO);
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _titleLabel.bottom + 10,frame.size.width, 55)];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        _contentLabel.numberOfLines = 3;
        [self addSubview:_contentLabel];
    }
    return self;
}

@end
