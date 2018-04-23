//
//  TCHotWordView.m
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHotWordView.h"

#define kItemFont      14
#define kItemHeight    30
#define kNewAddWidth   20  //给按钮额外增加的宽度
#define kMarginWidth   10  //按钮之间的间距
#define kSpacingWidth  15  //距离边缘的距离

@implementation TCHotWordView

-(instancetype)init{
    self=[super init];
    return self;
}

#pragma mark -- 自动布局
- (void)layoutSubviews{
    [super layoutSubviews];
    NSMutableArray *itemArr = [NSMutableArray new];
    for (UIView *view in self.subviews) {
        [itemArr addObject:view];
    }
    //重新布局
    //先取出第一个button并布好局
    UIButton *lastBtn = nil;
    for (int i = 0; i < itemArr.count; i++) {
        UIButton *item = itemArr[i];
        [item setTitle:self.hotWordsArray[i] forState:UIControlStateNormal];
        //设置文字的宽度
        CGFloat tempWidth=[self.hotWordsArray[i] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kItemFont]}  context:nil].size.width;
        item.width =tempWidth +kNewAddWidth;
        item.height = kItemHeight;
        if (i == 0) {  //第一个的时候放心大胆的布局，并记录下上一个button的位置
            if(item.width >kScreenWidth - 2*kSpacingWidth){//单行文字超过一行处理
                item.width = kScreenWidth -2*kSpacingWidth;
            }
            item.x = kSpacingWidth;
            item.y = 0;
            lastBtn =item;
        }else{//依据上一个button来布局
            if (lastBtn.right+item.width+kMarginWidth>kScreenWidth) {  //不足以再摆一行了
                item.y = lastBtn.bottom+kMarginWidth;
                item.x = kSpacingWidth;
                if(item.width >kScreenWidth - 2*kSpacingWidth){//单行文字超过一行处理
                    item.width = kScreenWidth -2*kSpacingWidth;
                }
            }else{
                item.y = lastBtn.y;
                item.x=lastBtn.right+kMarginWidth;
            }
        //    保存上一次的Button
            lastBtn = item;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    //动态计算高度
    if (self.viewHeightRecalc) {
        weakSelf.viewHeightRecalc(lastBtn.bottom+kMarginWidth);
    }
}

#pragma mark -- Event Response
-(void)itemClickActionForBtn:(UIButton *)sender{
    MyLog(@"%@",sender.currentTitle);
    if (self.hotSearchClick) {
        self.hotSearchClick(sender.currentTitle);
    }
}


#pragma mark -- setters and getters
-(void)setHotWordsArray:(NSArray *)hotWordsArray{
    _hotWordsArray=hotWordsArray;
    
    NSInteger num;
    if (hotWordsArray.count > 20) {
        num = 20;
    }else{
        num = hotWordsArray.count;
    }
    for (int i = 0; i < num; i ++) {
        UIButton *item = [[UIButton alloc] init];
        item.titleLabel.font = [UIFont systemFontOfSize:kItemFont];
        [item setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        item.layer.cornerRadius = 2.0;
        item.clipsToBounds = YES;
        item.layer.borderWidth = 0.5;
        item.layer.borderColor = [kRGBColor(200, 200, 200) CGColor] ;
        [item addTarget:self action:@selector(itemClickActionForBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:item];
    }
}

@end
