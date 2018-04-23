
//
//  TJYRecommentDateView.m
//  Product
//
//  Created by zhuqinlu on 2017/5/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYRecommentDateView.h"

@interface TJYRecommentDateView ()

/// 7天日期
@property (nonatomic ,strong) NSMutableArray * dateDaysArr;
/// 选择按钮
@property (nonatomic ,strong) UIButton *selectedBtn;

@property (nonatomic ,strong) NSMutableArray *dataBtnArray;

@end

@implementation TJYRecommentDateView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        NSInteger i;
        self.dateDaysArr =  [[TJYHelper sharedTJYHelper] getDataFromBeforeAndAfterDays];
        NSArray *weekDaysArr= [[TJYHelper sharedTJYHelper] getWeekdays];
        
        for (i= 0; i < self.dateDaysArr.count;i++) {
            InsertLabel(self, CGRectMake(i * kScreenWidth/7, 5, kScreenWidth/7, 15), NSTextAlignmentCenter,weekDaysArr[i] , kFontSize(14), UIColorHex(0x626262), NO);
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame =CGRectMake(i * kScreenWidth/7 + (kScreenWidth/7- 30)/2, 30, 33,22);
            btn.layer.cornerRadius = 10;
            [btn addTarget:self action:@selector(dateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag =  1000 + i;
            btn.layer.cornerRadius = 15;
            btn.titleLabel.font = kFontSize(14);
            [btn setTitleColor:UIColorHex(0x626262) forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageNamed:@"ic_btn_orange"] forState:UIControlStateSelected];
            [btn setTitle:[NSString stringWithFormat:@"%@",self.dateDaysArr[i]] forState:UIControlStateNormal];
            if (i == 3) {
                [btn setTitle:@"今" forState:UIControlStateNormal];
            }
        
            [self addSubview:btn];
            _selectedBtn = btn;
            [self.dataBtnArray addObject:btn];
        }
        ((UIButton *)[self.dataBtnArray objectAtIndex:3]).selected=YES;
    }
    return self;
}
#pragma mark -- Acton

- (void)dateBtnClick:(UIButton *)sender{
    ((UIButton *)[self.dataBtnArray objectAtIndex:3]).selected=NO;
    
    if (sender != _selectedBtn) {
        _selectedBtn.selected = NO;
        _selectedBtn = (UIButton *)sender;
    }
    _selectedBtn.selected = YES;
    
    if (self.dateBtnClickBlock) {
        self.dateBtnClickBlock(sender.tag - 1000);
    }
}
#pragma  mark -- Getter -- 

- (NSMutableArray *)dataBtnArray{
    if (!_dataBtnArray) {
        _dataBtnArray = [NSMutableArray array];
    }
    return _dataBtnArray;
}
- (NSMutableArray *)dateDaysArr{
    if (!_dateDaysArr) {
        _dateDaysArr =[NSMutableArray array];
    }
    return _dateDaysArr;
}

@end
