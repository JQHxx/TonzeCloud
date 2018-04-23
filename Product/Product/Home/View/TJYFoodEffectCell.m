
//
//  TJYFoodEffectCell.m
//  Product
//
//  Created by zhuqinlu on 2017/5/8.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYFoodEffectCell.h"

@interface TJYFoodEffectCell ()<UIScrollViewDelegate>

@property (nonatomic, strong)   UIScrollView *scroll;
@property (nonatomic, strong)   UIPageControl *pageControl;

@end

@implementation TJYFoodEffectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        _scroll =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.height)];
        _scroll.pagingEnabled = YES;
        _scroll.showsHorizontalScrollIndicator = NO;
        _scroll.delegate = self;
        
        _pageControl =[[UIPageControl alloc]initWithFrame:CGRectMake(0, self.height - 15, kScreenWidth, 10)];
        _pageControl.backgroundColor = [UIColor whiteColor];
        _pageControl.highlighted = YES;
        _pageControl.pageIndicatorTintColor = kBackgroundColor;// 设置非选中页的圆点颜色
        _pageControl.currentPageIndicatorTintColor = kSystemColor;
        _pageControl.userInteractionEnabled = NO;
        _pageControl.currentPage = 0;
        
        [_pageControl addTarget:self action:@selector(pagechanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_scroll];
        [self addSubview:_pageControl];
    }
    return self;
}
- (void)cellWithEffectNameArr:(NSArray *)effectNameArr efficacyDescriptionArr:(NSArray *)efficacyDescriptionArr hight:(CGFloat )hight
{
    _scroll.frame = CGRectMake(0, 0, kScreenWidth, hight+ 40);
    _scroll.contentSize=CGSizeMake(kScreenWidth * efficacyDescriptionArr.count, _scroll.height);
    _pageControl.frame = CGRectMake(0,_scroll.height - 10, kScreenWidth, 10);
    if (effectNameArr.count > 1) {
        _pageControl.numberOfPages =efficacyDescriptionArr.count;
    }
    
    for (NSInteger i =0; i < efficacyDescriptionArr.count; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i * kScreenWidth, 0 , kScreenWidth, _scroll.height - 10)];
        view.backgroundColor = [UIColor whiteColor];
        [_scroll addSubview:view];
        
        UILabel *effectLabel = [[UILabel alloc]initWithFrame:CGRectMake(15 + i * kScreenWidth, 10 , kScreenWidth - 30, 15)];
        effectLabel.text = [NSString stringWithFormat:@"%@",effectNameArr[i]];
        effectLabel.font = kFontSize(14);
        effectLabel.textColor = UIColorHex(0x313131);
        [_scroll addSubview:effectLabel];
        
        UILabel *effectInfoLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        effectInfoLabel.text = [NSString stringWithFormat:@"%@",efficacyDescriptionArr[i]];
        CGSize detailSize = [effectInfoLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 30, 1000) withTextFont:kFontSize(12)];
        effectInfoLabel.frame = CGRectMake(15 +i *kScreenWidth , 20 ,kScreenWidth - 30 , detailSize.height+15);
        effectInfoLabel.numberOfLines = 0;
        effectInfoLabel.textColor = UIColorHex(0x636363);
        effectInfoLabel.font = kFontSize(12);
        [_scroll addSubview:effectInfoLabel];
    }
}

-(void)pagechanged:(UIPageControl *)sender
{
    NSInteger page = _pageControl.currentPage;
    
    [_scroll setContentOffset:CGPointMake(kScreenWidth *page, 0) animated:YES];
}
#pragma mark --  UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = fabs(_scroll.contentOffset.x/_scroll.frame.size.width);
    _pageControl.currentPage = index;
}

@end
