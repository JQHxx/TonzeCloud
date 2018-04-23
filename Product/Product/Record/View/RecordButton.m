//
//  RecordButton.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecordButton.h"

@implementation RecordButton

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        image = [[UIImageView alloc] initWithFrame:CGRectMake((width-64)/2, 10, 64, 64)];
        [self addSubview:image];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, image.bottom+10, width, 30)];
        contentLabel.font = [UIFont systemFontOfSize:20];
        contentLabel.textAlignment  = NSTextAlignmentCenter;
        [self addSubview:contentLabel];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, contentLabel.bottom+10, width, 20)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor grayColor];
        [self addSubview:titleLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom+5, width, 20)];
        dateLabel.textColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:dateLabel];
    }
    return self;
}
- (void)setRecordDict:(NSDictionary *)recordDict{
    
    image.image = [UIImage imageNamed:[recordDict objectForKey:@"image"]];
    contentLabel.text = [recordDict objectForKey:@"content"];
    titleLabel.text = [recordDict objectForKey:@"title"];
    dateLabel.text = [recordDict objectForKey:@"date"];
    titleLabel.textColor = [UIColor colorWithHexString:[recordDict objectForKey:@"color"]];
    contentLabel.textColor = [UIColor colorWithHexString:[recordDict objectForKey:@"color"]];
}
@end
