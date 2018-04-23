//
//  TCShopHotWordView.m
//  Product
//
//  Created by 肖栋 on 18/1/16.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import "TCShopHotWordView.h"

@implementation TCShopHotWordView

- (void)setShopHotWordArr:(NSMutableArray *)shopHotWordArr{
    _shopHotWordArr = shopHotWordArr;
    
    CGFloat width = 18;
    for (int i=0; i<_shopHotWordArr.count; i++) {
        
        NSString *titleStr = _shopHotWordArr[i];
        if (titleStr.length>0) {
            CGSize size = [titleStr sizeWithLabelWidth:kScreenWidth font:[UIFont systemFontOfSize:14]];
            UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(width, 15, size.width+30, 30)];
            [item setTitle:titleStr forState:UIControlStateNormal];
            [item setTitleColor:[UIColor colorWithHexString:@"0x626262"] forState:UIControlStateNormal];
            item.titleLabel.font = [UIFont systemFontOfSize:14];
            item.layer.cornerRadius = 15;
            item.clipsToBounds = YES;
            item.layer.borderWidth = 0.5;
            item.layer.borderColor = [kRGBColor(200, 200, 200) CGColor];
            item.tag = 100+i;
            [item addTarget:self action:@selector(seleteHotWord:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:item];
            
            width = width + size.width+45;
            self.contentSize = CGSizeMake(width, 61);
            self.showsHorizontalScrollIndicator = NO;
        }
    }
}

- (void)seleteHotWord:(UIButton *)button{
    NSString *title = _shopHotWordArr[button.tag-100];
    if (self.shopHotSearchClick) {
        self.shopHotSearchClick(title);
    }

}
@end
