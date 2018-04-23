//
//  StorageAttrView.m
//  Product
//
//  Created by vision on 17/6/12.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StorageAttrView.h"

@interface StorageAttrView (){
    UILabel       *valueLabel;
    UILabel       *nameLabel;
    UIImageView   *attrImageView;
}

@end

@implementation StorageAttrView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat viewWidth=frame.size.width;
        
        valueLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 5, viewWidth/2, 40)];
        valueLabel.font=[UIFont systemFontOfSize:24];
        valueLabel.textColor=kRGBColor(36, 157, 192);
        [self addSubview:valueLabel];
        
        nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, valueLabel.bottom, 80, 20)];
        nameLabel.font=[UIFont systemFontOfSize:14];
        nameLabel.textColor=[UIColor colorWithHexString:@"#626262"];
        [self addSubview:nameLabel];
        
        attrImageView=[[UIImageView alloc] initWithFrame:CGRectMake(valueLabel.right+10, 20, 40, 40)];
        [self addSubview:attrImageView];
    }
    return self;
}


-(void)setAttrDict:(NSDictionary *)attrDict{
    _attrDict=attrDict;
    valueLabel.text=attrDict[@"value"];
    nameLabel.text=attrDict[@"name"];
    attrImageView.image=[UIImage imageNamed:attrDict[@"image"]];
}

@end
