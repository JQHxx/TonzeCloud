//
//  TCHeightViewController.m
//  TonzeCloud
//
//  Created by 肖栋 on 17/3/30.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHeightViewController.h"
#import "TCWeightViewController.h"
#import "TXHRrettyRuler.h"
#import "TCUserTool.h"

@interface TCHeightViewController ()<TXHRrettyRulerDelegate>{

    UILabel     *heightLabel;
    NSInteger    heightValue;
}

@end

@implementation TCHeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"身高";
    heightValue=160;
    
    [self initHeightView];
}


#pragma mark -- TXHRrettyRulerDelegate
-(void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView isBool:(BOOL)isbool{
     heightValue=rulerScrollView.rulerValue;
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ldcm",(long)heightValue]];
    [attributeStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0xff9d38"]} range:NSMakeRange(0, attributeStr.length-1)];
    heightLabel.attributedText=attributeStr;
}


#pragma mark -- Event Response
#pragma mark -- 下一步
- (void)nextButton{
    MyLog(@"height:%ld",heightValue);
    
    
    [[TCUserTool sharedTCUserTool] insertValue:[NSNumber numberWithInteger:heightValue] forKey:@"height"];
    TCWeightViewController *weightVC = [[TCWeightViewController alloc] init];
    [self.navigationController pushViewController:weightVC animated:YES];
}


#pragma mark --Private methods
#pragma mark -- 初始化界面
- (void)initHeightView{

    UIImageView *personImg = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2,kNavigationHeight+60, 80, 80)];
    personImg.image = [UIImage imageNamed:@"ic_login_height"];
    [self.view addSubview:personImg];
    
    heightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, personImg.bottom+20, kScreenWidth, 30)];
    heightLabel.textColor = [UIColor colorWithHexString:@"0xff9d38"];
    heightLabel.font = [UIFont systemFontOfSize:20];
    heightLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:heightLabel];
    
    UILabel *porpmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, heightLabel.bottom+10, kScreenWidth, 20)];
    porpmtLabel.text = @"滑动标尺选择";
    porpmtLabel.textColor = [UIColor grayColor];
    porpmtLabel.font = [UIFont systemFontOfSize:15];
    porpmtLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:porpmtLabel];
    
    TXHRrettyRuler *ruler=[[TXHRrettyRuler alloc] initWithFrame:CGRectMake(0,porpmtLabel.bottom+40, kScreenWidth, 120)];
    ruler.rulerDeletate=self;
    [ruler showRulerScrollViewWithCount:220 average:[NSNumber numberWithInteger:1] currentValue:heightValue-30 smallMode:YES mineCount:30];
    [self.view addSubview:ruler];
    
    heightLabel.text = @"160cm";
    
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
