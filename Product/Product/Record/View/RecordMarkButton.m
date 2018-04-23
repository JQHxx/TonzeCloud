//
//  RecordMarkButton.m
//  Product
//
//  Created by 肖栋 on 17/5/13.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecordMarkButton.h"
#import "QLCoreTextManager.h"

@implementation RecordMarkButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        
        _markLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, width, 25)];
        _markLabel.font = [UIFont fontWithName:@ "Arial Rounded MT Bold"  size:(30.0)];
        NSString *markStr=@"0分";
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:markStr];
        [QLCoreTextManager setAttributedValue:attributeStr text:@"分" font:kFontSize(13) color:[UIColor whiteColor]];
        _markLabel.attributedText = attributeStr;
        _markLabel.textColor = [UIColor whiteColor];
        _markLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_markLabel];
        
}
    return self;
}

@end
