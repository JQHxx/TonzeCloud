//
//  TJYOrderbyView.m
//  Product
//
//  Created by zhuqinlu on 2017/5/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYOrderbyView.h"
#import "UIButton+Extension.h"

@interface TJYOrderbyView ()
{
    UIButton *_selectBtn;
    UIImageView *_selectImg;
    UIScrollView *_rootScrollView;
    NSArray *_orderbyArray;
    UIImageView *checkImg;
    NSInteger _index;
}
///
@property (nonatomic, copy) orderbySelectBlock orderbySelectBlock;
///
@property (nonatomic ,strong) NSMutableArray *btnArray;
///
@property (nonatomic ,strong) NSMutableArray *chectImgArray;
@end

@implementation TJYOrderbyView

- (instancetype)initWithFrame:(CGRect)frame orderbyArray:(NSArray *)orderby  orderbySelectBlock:(orderbySelectBlock)orderbySelectBlock{

    if (self = [super initWithFrame:frame]) {
        
        // 添加一个点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapClick)];
        [self addGestureRecognizer:tap];
        
        self.orderbySelectBlock = orderbySelectBlock;
        _orderbyArray = orderby;
        
        self.backgroundColor = [UIColor colorWithRed:10/255.0 green:10/255.0 blue:10/255.0 alpha:0.4];
        _rootScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth , 5 * 40 + 40)];
        _rootScrollView.backgroundColor =[UIColor whiteColor];
        [self addSubview:_rootScrollView];
        
        for (NSInteger i =0; i < 2; i++) {
            for (NSInteger j = 0; j < _orderbyArray.count/2; j++ ) {
                if (i + (2 * j) == _orderbyArray.count) {
                    break;
                }
                UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
                btn.frame = CGRectMake( i * (kScreenWidth/2 - 15) + 15, 20 + j * (30 + 10) , 100, 30);
                [btn setTitle:[NSString stringWithFormat:@"%@",_orderbyArray[i + (2 * j)]] forState:UIControlStateNormal];
                btn.tag =i +(2 *j)+ 1000;
                btn.titleLabel.font = kFontSize(15);
                [btn setTitleColor:UIColorHex(0x313131) forState:UIControlStateNormal];
                [btn setTitleColor:kSystemColor forState:UIControlStateSelected];
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [btn addTarget:self action:@selector(orderbyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [_rootScrollView addSubview:btn];
                
                checkImg = [[UIImageView alloc]initWithFrame:CGRectMake(btn.right + 10, btn.top, 22, 22)];
                checkImg.image = [UIImage imageNamed:@"ic_pub_arrow"];
                checkImg.tag =i +(2 *j)+ 2000;
                [_rootScrollView addSubview:checkImg];
                checkImg.hidden = YES;
                [self.btnArray addObject:btn];
                _selectBtn = btn;
                
    
                [self.chectImgArray addObject:checkImg]; 
            }
        }
        ((UIButton *)[self.btnArray objectAtIndex:0]).selected=YES;
        ((UIImageView *)[self.chectImgArray objectAtIndex:0]).hidden= NO;
    }
    return self;
}
#pragma mark -- Action
- (void)orderbyBtnClick:(UIButton *)sender{
  
    for (UIImageView *image in self.chectImgArray) {
        image.hidden = YES;
    }
    
    UIImageView * image = [self viewWithTag:sender.tag + 1000];
    image.hidden = NO;
    
    
    ((UIButton *)[self.btnArray objectAtIndex:0]).selected = NO;
    if (sender != _selectBtn) {
        _selectBtn.selected = NO;
        _selectBtn = (UIButton *)sender;
    }
    _selectBtn.selected = YES;
    if (self.orderbySelectBlock) {
        self.orderbySelectBlock(sender.tag - 1000);
    }
}
- (void)viewTapClick{
    [self removeFromSuperview];
}

- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

- (NSMutableArray *)chectImgArray{
    if (!_chectImgArray) {
        _chectImgArray = [NSMutableArray array];
    }
    return _chectImgArray;
}

@end
