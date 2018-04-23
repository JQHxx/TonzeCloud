//
//  TJYEvaluationResultViewController.m
//  Product
//
//  Created by 肖栋 on 17/5/2.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYEvaluationResultViewController.h"
#import "TJYHealthAssessmentVC.h"
#import "TJYEvaluationTestVC.h"

@interface TJYEvaluationResultViewController (){

    NSInteger pageIndex;
}

@end

@implementation TJYEvaluationResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.titleStr;
    self.view.backgroundColor = [UIColor bgColor_Gray];
    pageIndex=0;
    
    [self initResultView];
}
#pragma mark -- 返回
- (void)leftButtonAction{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[TJYHealthAssessmentVC class]]) {
            TJYHealthAssessmentVC *revise =(TJYHealthAssessmentVC *)controller;
            [self.navigationController popToViewController:revise animated:YES];
        }
    }
}
#pragma mark -- 再次测试
- (void)againTest{
    if (self.navigationController.viewControllers.count>3) {
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[TJYEvaluationTestVC class]]) {
                    TJYEvaluationTestVC *revise =(TJYEvaluationTestVC *)controller;
                    [TJYHelper sharedTJYHelper].isHealthScore = YES;
                    [self.navigationController popToViewController:revise animated:YES];
                }
            }
    }else{
        TJYEvaluationTestVC *revise =[[TJYEvaluationTestVC alloc] init];
        revise.assess_id = self.index;
        revise.titleStr = self.titleStr;
        [self.navigationController pushViewController:revise animated:YES];
    }
}
#pragma mark -- 初始化界面
- (void)initResultView{
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-160-64)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-96)/2, 36+64, 96, 83)];
    imgView.image = [UIImage imageNamed:@"ic_pingu_end"];
    [self.view addSubview:imgView];

    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = self.brief;
    CGSize contentTextSize = [contentLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 50, 300) withTextFont:kFontSize(15)];
    contentLabel = InsertLabel(self.view,CGRectMake(25, imgView.bottom+20, contentTextSize.width, contentTextSize.height+10) , NSTextAlignmentCenter, contentLabel.text, kFontSize(14), UIColorHex(0x626262), YES);
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight-100, kScreenWidth, 20)];
    NSString *timeStr =[[[TJYHelper sharedTJYHelper] getCurrentDateTime] substringToIndex:10];
    NSString *time = [NSString stringWithFormat:@"最后评测时间:%@",timeStr];
    timeLabel.text = time;
    timeLabel.font = [UIFont systemFontOfSize:13];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor colorWithHexString:@"0x959595"];
    [self.view addSubview:timeLabel];
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-132)/2, timeLabel.bottom+10, 132, 41)];
    [nextBtn setTitle:@"再次测试" forState:UIControlStateNormal];
    nextBtn.backgroundColor = [UIColor colorWithHexString:@"0xffbe23"];
    nextBtn.titleLabel.textColor = [UIColor whiteColor];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [nextBtn addTarget:self action:@selector(againTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

@end
