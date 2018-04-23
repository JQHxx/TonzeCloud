//
//  TJYMealPagodaVC.m
//  Product
//
//  Created by zhuqinlu on 2017/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYMealPagodaVC.h"
#import "TJYMealPagodaView.h"

@interface TJYMealPagodaVC ()

@property (nonatomic, strong) UIScrollView *scrollView;
/// 塔型图
@property (nonatomic ,strong) TJYMealPagodaView *mealPagodaView;

@end

@implementation TJYMealPagodaVC

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.baseTitle = @"膳食宝塔";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self MealPagodasetUI];
}
#pragma mark -- Build UI
- (void)MealPagodasetUI{
    [self.view addSubview:self.scrollView];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 96)];
    headerView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:headerView];
    UILabel *intakeLab = InsertLabel(_scrollView, CGRectMake(0,20 , kScreenWidth, 20), NSTextAlignmentCenter, @"推荐摄入量", kFontSize(16), UIColorHex(0x626262), NO);
    
    UILabel *caloriesLab = InsertLabel(_scrollView, CGRectMake(0,intakeLab.bottom +10 , kScreenWidth, 30), NSTextAlignmentCenter, @"", kFontSize(32), kSystemColor, NO);
    caloriesLab.text = [NSString stringWithFormat:@"%ld千卡",(long)_total_calorie];
    // 横线
    InsertView(_scrollView, CGRectMake(0, headerView.height - 0.5, kScreenWidth, 0.5), kBackgroundColor);
    /// 绘制塔型图案
    [_scrollView addSubview:self.mealPagodaView];
    self.mealPagodaView.totalCalorie = self.total_calorie;
    
    UIImageView *waterImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth - 197)/2 ,self.mealPagodaView.bottom + 80 , 37, 37)];
    waterImg.image = [UIImage imageNamed:@"ic_water_plan"];
    [_scrollView addSubview:waterImg];
    
    UILabel *waterLab = [[UILabel alloc]initWithFrame:CGRectMake(waterImg.right + 20, waterImg.top + 10, 140, 15)];
    waterLab.text = @"水  1500-1700毫升";
    waterLab.font = kFontSize(16);
    waterLab.textColor = UIColorHex(0x6DC8F3);
    [_scrollView addSubview:waterLab];
    
    UILabel *tipLab = InsertLabel(_scrollView, CGRectMake(30, waterLab.bottom + 50 , kScreenWidth -60, 25), NSTextAlignmentCenter, @"请保持营养均衡、保证食物的多样化，尽可能的遵循《中国居民膳食指南》做到膳食平衡模式。", kFontSize(12), UIColorHex(0x939393), YES);
    _scrollView.contentSize = CGSizeMake(kScreenWidth, tipLab.bottom + 20);
}
#pragma mark -- Getter --
- (UIScrollView *)scrollView{

    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight)];
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}
- (TJYMealPagodaView *)mealPagodaView
{
    if (!_mealPagodaView) {
        _mealPagodaView = [[TJYMealPagodaView alloc]initWithFrame:CGRectMake(0, 96, kScreenWidth, 594/2)];
    }
    return _mealPagodaView;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
