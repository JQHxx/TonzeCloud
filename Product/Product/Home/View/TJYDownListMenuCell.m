
//
//  TJYDownListMenuCell.m
//  Product
//
//  Created by zhuqinlu on 2017/5/10.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYDownListMenuCell.h"

@implementation TJYDownListMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews {
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.frame.size.height - 1)];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = UIColorHex(0x626262);
    self.titleLbl = titleLbl;
    self.titleLbl.font = kFontSize(14);
    [self addSubview:titleLbl];
    
    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 0.5, kScreenWidth - 10, 0.5)];
    bottomLine.backgroundColor = kLineColor;
//    bottomLine.highlightedTextColor = [UIColor redColor];
    [self addSubview:bottomLine];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
