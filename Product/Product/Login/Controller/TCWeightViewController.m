//
//  TCWeightViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCWeightViewController.h"
#import "TXHRrettyRuler.h"
#import "TCWorkRankViewController.h"
#import "TCUserTool.h"

@interface TCWeightViewController ()<TXHRrettyRulerDelegate>{

    UILabel   *weightLabel;
    double   weightValue;
}
@end

@implementation TCWeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"体重";
    weightValue=60.0;
    
    [self initWeightView];
}


#pragma mark -- TXHRrettyRulerDelegate
-(void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView isBool:(BOOL)isbool{
    weightValue=rulerScrollView.rulerValue;
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1fkg",weightValue]];
    [attributeStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0xff9d38"]} range:NSMakeRange(0, attributeStr.length-1)];
    weightLabel.attributedText=attributeStr;
}

#pragma mark -- Event Response
#pragma mark -- 下一步
- (void)nextButton{
    MyLog(@"weight:%.1f",weightValue);
    
    [[TCUserTool sharedTCUserTool] insertValue:[NSNumber numberWithDouble:weightValue] forKey:@"weight"];
    TCWorkRankViewController *workRankVC = [[TCWorkRankViewController alloc] init];
    [self.navigationController pushViewController:workRankVC animated:YES];
}
#pragma mark --Private methods
#pragma mark -- 初始化界面
- (void)initWeightView{
    
    UIImageView *personImg = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2, kNavigationHeight+60, 80, 80)];
    personImg.image = [UIImage imageNamed:@"ic_login_weight"];
    [self.view addSubview:personImg];
    
    weightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, personImg.bottom+20, kScreenWidth, 30)];
    weightLabel.font = [UIFont systemFontOfSize:20];
    weightLabel.textColor = [UIColor colorWithHexString:@"0xff9d38"];
    weightLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:weightLabel];
    
    UILabel *porpmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, weightLabel.bottom+10, kScreenWidth, 20)];
    porpmtLabel.text = @"滑动标尺选择";
    porpmtLabel.textColor = [UIColor grayColor];
    porpmtLabel.font = [UIFont systemFontOfSize:15];
    porpmtLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:porpmtLabel];
    
    TXHRrettyRuler *ruler=[[TXHRrettyRuler alloc] initWithFrame:CGRectMake(0,porpmtLabel.bottom+30, kScreenWidth, 120)];
    ruler.rulerDeletate=self;
    [ruler showRulerScrollViewWithCount:2400 average:[NSNumber numberWithDouble:0.1] currentValue:50.0 smallMode:YES mineCount:10];
    [self.view addSubview:ruler];
    
    weightLabel.text = @"60.0kg";
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, kScreenHeight-60, 150, 40)];
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor colorWithHexString:@"0xff9d38"] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){255.0/256, 157.0/256, 56.0/256,1 });
    [nextButton.layer setBorderColor:colorref];//边框颜色
    [nextButton addTarget:self action:@selector(nextButton) forControlEvents:UIControlEventTouchUpInside];
    nextButton.layer.cornerRadius = 5;
    nextButton.layer.borderWidth = 1;
    [self.view addSubview:nextButton];

}
@end
