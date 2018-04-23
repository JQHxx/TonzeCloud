
//
//  TCDietCountView.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/4/13.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TJYDietCountView.h"
#import "TCPieView.h"

@implementation TJYDietCountView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
    }
    return self;
}

-(void)setWeekRecordsDict:(NSDictionary *)weekRecordsDict{
    _weekRecordsDict=weekRecordsDict;
    
    NSInteger highCount=[weekRecordsDict[@"high"] integerValue];
    NSInteger lowCount=[weekRecordsDict[@"low"] integerValue];
    
    //绘制饼图
    NSArray *dataItems=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld",(long)highCount],
                        [NSString stringWithFormat:@"%ld",(long)lowCount],nil];
    NSArray *colorItems=[NSArray arrayWithObjects:[UIColor colorWithHexString:@"#ffde91"],
                         [UIColor bgColor_Gray],nil];
    TCPieView *pieView=[[TCPieView alloc] initWithFrame:CGRectMake(0, 0, 160, 160) dataItems:dataItems colorItems:colorItems];
    [self addSubview:pieView];
    [pieView stroke];   //动画绘制
    
}



@end
