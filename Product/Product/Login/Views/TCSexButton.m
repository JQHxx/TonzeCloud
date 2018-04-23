//
//  TCSexButton.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCSexButton.h"

@implementation TCSexButton

-(instancetype)initWithFrame:(CGRect)frame dict:(NSDictionary *)dict{

    self=[super initWithFrame:frame];
    if (self) {
        CGFloat btnw = frame.size.width;
      
        UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, btnw, btnw)];
        headImg.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
        headImg.layer.cornerRadius = btnw/2;
        [self addSubview:headImg];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, headImg.bottom+20, btnw, 20)];
        title.text = [dict objectForKey:@"title"];
        title.font = [UIFont systemFontOfSize:22];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
    }
    return self;

}
@end
