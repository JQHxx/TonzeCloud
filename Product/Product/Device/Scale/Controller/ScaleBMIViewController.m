//
//  ScaleBMIViewController.m
//  Product
//
//  Created by vision on 17/5/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ScaleBMIViewController.h"
#import "IndexResultView.h"
#import "ScaleHelper.h"


@interface ScaleBMIViewController ()

@end

@implementation ScaleBMIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"指标说明";
    
    [self initScaleBMIView];
    
}

#pragma mark －- Private Methods
#pragma mark  初始化界面
-(void)initScaleBMIView{
    UILabel  *titleLbl=[[UILabel alloc] initWithFrame:CGRectMake(50, 84, kScreenWidth-100, 30)];
    titleLbl.text=@"BMI";
    titleLbl.font=[UIFont boldSystemFontOfSize:18];
    titleLbl.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:titleLbl];
    
    UILabel *formulaLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, titleLbl.bottom+10, kScreenWidth-80, 20)];
    formulaLbl.textAlignment=NSTextAlignmentCenter;
    formulaLbl.font=[UIFont systemFontOfSize:16];
    formulaLbl.text=@"BMI=体重(kg)÷身高²(m²)";
    [self.view addSubview:formulaLbl];
    
    UILabel *contentLbl=[[UILabel alloc] initWithFrame:CGRectZero];
    contentLbl.text=@"\t身体质量指数，国际上常用的衡量人体胖瘦程度以及是否健康的一个标准.";
    contentLbl.numberOfLines=0;
    contentLbl.font=[UIFont systemFontOfSize:14];
    CGFloat contentH=[contentLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth-40, CGFLOAT_MAX) withTextFont:contentLbl.font].height;
    contentLbl.frame=CGRectMake(20, formulaLbl.bottom+10, kScreenWidth-40, contentH+10);
    [self.view addSubview:contentLbl];
    
    UILabel *subContentLbl=[[UILabel alloc] initWithFrame:CGRectMake(20, contentLbl.bottom+10, kScreenWidth-40, 40)];
    subContentLbl.text=@"*使用范围有限，不能用于评价肌肉发达的成年人、儿童、孕妇、65岁以上的老人。";
    subContentLbl.font=[UIFont systemFontOfSize:12];
    subContentLbl.textColor=[UIColor blueColor];
    subContentLbl.numberOfLines=2;
    [self.view addSubview:subContentLbl];
    
    UILabel *valueLbl=[[UILabel alloc] initWithFrame:CGRectMake(20, subContentLbl.bottom+20, kScreenWidth-40, 20)];
    valueLbl.font=[UIFont boldSystemFontOfSize:16];
    valueLbl.text=[NSString stringWithFormat:@"%.1f",_scaleBMI];
    valueLbl.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:valueLbl];
    
    CGFloat pointX=[[ScaleHelper sharedScaleHelper] getBodyIndexValueXWithValue:valueLbl.text width:kScreenWidth-20 key:@"BMI"];
    UIImageView *pointerImageView=[[UIImageView alloc] initWithFrame:CGRectMake(pointX, valueLbl.bottom+10, 12, 20)];
    pointerImageView.image = [UIImage imageNamed:@"tzy_ic_pub_mark"];
    [self.view addSubview:pointerImageView];
    
    NSArray *arr=@[@"18.5",@"25.0",@"30.0"];
    CGFloat labW=(kScreenWidth-20)/4.0;
    for (NSInteger i=0; i<arr.count; i++) {
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake((i+1)*labW, valueLbl.bottom+10, 30, 20)];
        lab.font=[UIFont systemFontOfSize:10];
        lab.text=arr[i];
        lab.textAlignment=NSTextAlignmentCenter;
        [self.view addSubview:lab];
    }
    
    IndexResultView *indexView=[[IndexResultView alloc] initWithFrame:CGRectMake(10,valueLbl.bottom+15+17, kScreenWidth-20, 20)];
    indexView.key=@"BMI";
    [self.view addSubview:indexView];
    
    NSArray *resultArr=[[ScaleHelper sharedScaleHelper] getBodyIndexResultArrayWithKey:@"BMI"];
    NSInteger resultCount=resultArr.count;
    if (resultCount>0) {
        CGFloat lblWidth=(kScreenWidth-20)/resultCount;
        for (NSInteger i=0; i<resultArr.count; i++) {
            UILabel *resultLab=[[UILabel alloc] initWithFrame:CGRectMake(10+lblWidth*i, indexView.bottom+5, lblWidth, 20)];
            resultLab.text=resultArr[i];
            resultLab.textAlignment=NSTextAlignmentCenter;
            resultLab.font=[UIFont systemFontOfSize:12];
            resultLab.textColor=[UIColor colorWithHexString:@"#626262"];
            [self.view addSubview:resultLab];
        }
    }
    
    
    UILabel  *resultLabel=[[UILabel alloc] initWithFrame:CGRectZero];
    resultLabel.numberOfLines=0;
    resultLabel.font=[UIFont systemFontOfSize:14];
    NSString *resultStr=[[ScaleHelper sharedScaleHelper] getBMIStandardWithBmi:_scaleBMI];
    resultLabel.text=[[ScaleHelper sharedScaleHelper] getStandardContentWithResult:resultStr key:@"BMI"];
    CGFloat resultH=[resultLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-20, CGFLOAT_MAX) withTextFont:resultLabel.font].height;
    resultLabel.frame=CGRectMake(10, indexView.bottom+30, kScreenWidth-20, resultH+20);
    [self.view addSubview:resultLabel];
    
    
}



@end
