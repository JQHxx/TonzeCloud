
//
//  TJYFoodClassificationView.m
//  Product
//
//  Created by zhuqinlu on 2017/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYFoodClassificationView.h"

@interface TJYFoodClassificationView ()

/// 重置按钮
@property (nonatomic ,strong) UIButton *resetBtn;
/// 确定按钮
@property (nonatomic ,strong) UIButton *determineBtn;
/// 底部视图
@property (nonatomic ,strong) UIView *footView ;
/// 选中按钮
@property (nonatomic ,strong) UIButton *selectBtn;

@property (nonatomic, assign) NSInteger btnId;

@property (nonatomic ,strong) NSArray  *effectArray;

@property (nonatomic, copy) btnSelectBlock selectBlock;
///
@property (nonatomic ,strong) NSMutableArray *btnArray;

@end

@implementation TJYFoodClassificationView

- (instancetype)initWithFrame:(CGRect)frame effectArray:(NSArray *)effectArray  btnSelectBlock:(btnSelectBlock)btnSelectBlock
{
    if (self = [super initWithFrame:frame]) {
        
        self.selectBlock = btnSelectBlock;
        self.effectArray = effectArray;
        // 添加一个点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapClick)];
        [self addGestureRecognizer:tap];
        
        self.backgroundColor = [UIColor colorWithRed:10/255.0 green:10/255.0 blue:10/255.0 alpha:0.4];
        _rootScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth , 38 + 40  + 38)];
        _rootScrollView.backgroundColor =[UIColor whiteColor];
        
        _rootScrollView.showsHorizontalScrollIndicator=NO;
        [self addSubview:_rootScrollView];
        
        CGFloat btnX = 30 ;
        CGFloat btnW = (kScreenWidth - btnX * 4)/3;
        if (effectArray.count <= 3) {
            for (NSInteger i = 0; i < effectArray.count; i++) {
                UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
                btn.frame = CGRectMake(btnX + i * btnW, 20 ,btnW, 44);
                [btn setTitle:[NSString stringWithFormat:@"%@",effectArray[i]] forState:UIControlStateNormal];
                btn.tag = 1001 + i;
                btn.titleLabel.font = kFontSize(12);
                [btn setTitleColor:UIColorHex(0x313131) forState:UIControlStateNormal];
                [btn setTitleColor:UIColorHex(0xffbe63) forState:UIControlStateSelected];
                [btn setBackgroundImage:[UIImage imageNamed:@"ic_btn_bg_gray"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"ic_btn_bg_orange"] forState:UIControlStateSelected];
                [btn addTarget:self action:@selector(effectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [_rootScrollView addSubview:btn];
                [self.btnArray addObject:btn];
                _selectBtn = btn;
            }
        }else{
            NSInteger w;
            if (effectArray.count % 3 == 0) {
                w  = effectArray.count/3;
            }else{
                w = effectArray.count/3 + 1;
            }
            for (NSInteger i =0; i < 3; i++) {
                for (NSInteger j = 0; j < w; j++ ) {
                    if (i + (3 * j) < effectArray.count) {
                        UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
                        btn.frame = CGRectMake( i * (btnW + 30) + 30, 20 + j * (38 + 15) , btnW, 38);
                        [btn setTitle:[NSString stringWithFormat:@"%@",effectArray[i + (3 * j)]] forState:UIControlStateNormal];
                        btn.tag =i +(3 *j)+ 1001;
                        btn.titleLabel.font = kFontSize(12);
                        [btn setTitleColor:UIColorHex(0x313131) forState:UIControlStateNormal];
                        [btn setTitleColor:UIColorHex(0xff9d38) forState:UIControlStateSelected];
                        [btn setBackgroundImage:[UIImage imageNamed:@"ic_btn_bg_gray"] forState:UIControlStateNormal];
                        [btn setBackgroundImage:[UIImage imageNamed:@"ic_btn_bg_orange"] forState:UIControlStateSelected];
                        [btn addTarget:self action:@selector(effectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                        [_rootScrollView addSubview:btn];
                        [self.btnArray addObject:btn];
                        _selectBtn = btn;
                    }
                }
            }
            _rootScrollView.frame = CGRectMake(0, 0, kScreenWidth,40 + w * 38 + (w - 1)*15 + 38);
            if (_rootScrollView.bottom > kBodyHeight) {
                 _rootScrollView.contentSize = CGSizeMake(kScreenWidth, _rootScrollView.bottom + 10);
            }
        }
        
        _footView = InsertView(_rootScrollView, CGRectMake(0, _rootScrollView.height - 38, _rootScrollView.width, 38), [UIColor whiteColor]);
        InsertView(_footView, CGRectMake(0,0, kScreenWidth,0.5), kLineColor);
        
        _resetBtn =  InsertButtonWithType(_footView, CGRectMake(0, 0 , _footView.width/2, _footView.height), 1000, self, @selector(btnClick:), UIButtonTypeCustom);
        _resetBtn.titleLabel.font = kFontSize(15);
        [_resetBtn setTitleColor:UIColorHex(0x313131) forState:UIControlStateNormal];
        [_resetBtn setTitleColor:kSystemColor forState:UIControlStateSelected];
        [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        
        _determineBtn = InsertButtonWithType(_footView, CGRectMake(_footView.width/2 ,0,_footView.width/2, _footView.height), 1001, self, @selector(btnClick:), UIButtonTypeCustom);
        _determineBtn.titleLabel.font = kFontSize(15);
        [_determineBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
        [_determineBtn setTitleColor:UIColorHex(0x313131) forState:UIControlStateSelected];
        [_determineBtn setTitle:@"确定" forState:UIControlStateNormal];
        /// 线条
        InsertView(_footView, CGRectMake(_rootScrollView.width/2,8, 1, 38- 16), kLineColor);
    }
    return self;
}
#pragma mark -- Action

- (void)btnClick:(UIButton *)btn{
    switch (btn.tag) {
        case 1000:{//重置
            if (btn != _selectBtn) {
                _selectBtn.selected = NO;
                _selectBtn = (UIButton *)btn;
                _btnId = 0;
                if (self.selectBlock) {
                    self.selectBlock(_btnId);
                }
            }
        }break;
        case 1001:{// 确定
            if (self.selectBlock) {
                self.selectBlock(_btnId);
            }
        }
        default:
            break;
    }
}
- (void)effectBtnClick:(UIButton *)btn{
    if (btn != _selectBtn) {
        _selectBtn.selected = NO;
        _selectBtn = (UIButton *)btn;
    }
    _selectBtn.selected = YES;
    _btnId = btn.tag - 1000;
}
// 手势点击
- (void)viewTapClick{
    [self removeFromSuperview];
}
- (NSMutableArray *)effectId{
    if (!_effectId) {
        _effectId = [NSMutableArray array];
    }
    return _effectId;
}
- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

@end
