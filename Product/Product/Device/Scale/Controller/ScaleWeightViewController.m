//
//  ScaleWeightViewController.m
//  Product
//
//  Created by vision on 17/5/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ScaleWeightViewController.h"
#import "IndexResultView.h"
#import "ScaleHelper.h"
#import "TJYUserModel.h"

@interface ScaleWeightViewController ()

@end

@implementation ScaleWeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"指标说明";
    
    [self initScaleWeightView];
}

-(void)initScaleWeightView{
    UILabel  *titleLbl=[[UILabel alloc] initWithFrame:CGRectMake(50, 84, kScreenWidth-100, 30)];
    titleLbl.text=@"体重";
    titleLbl.font=[UIFont boldSystemFontOfSize:18];
    titleLbl.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:titleLbl];
    
    UILabel *formulaLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, titleLbl.bottom+10, kScreenWidth-80, 20)];
    formulaLbl.textAlignment=NSTextAlignmentCenter;
    formulaLbl.font=[UIFont systemFontOfSize:16];
    formulaLbl.text=@"理想体重=身高(cm）-105";
    [self.view addSubview:formulaLbl];
    
    UILabel *contentLbl=[[UILabel alloc] initWithFrame:CGRectZero];
    contentLbl.text=@"\t体重是衡量人体健康与否的重要参数，过瘦和过胖都不利于健康。";
    contentLbl.numberOfLines=0;
    contentLbl.font=[UIFont systemFontOfSize:14];
    CGFloat contentH=[contentLbl.text boundingRectWithSize:CGSizeMake(kScreenWidth-40, CGFLOAT_MAX) withTextFont:contentLbl.font].height;
    contentLbl.frame=CGRectMake(20, formulaLbl.bottom+10, kScreenWidth-40, contentH+10);
    [self.view addSubview:contentLbl];
    
    UILabel *valueLbl=[[UILabel alloc] initWithFrame:CGRectMake(20, contentLbl.bottom+20, kScreenWidth-40, 20)];
    valueLbl.font=[UIFont boldSystemFontOfSize:16];
    valueLbl.text=[NSString stringWithFormat:@"%.2fkg",_scaleWeight];
    valueLbl.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:valueLbl];
    
    TJYUserModel *user=[ScaleHelper sharedScaleHelper].scaleUser;
    NSInteger height=[user.height integerValue];
    double lowWeight=0.8*(height-105);
    double  highWeight=1.2*(height-105);
    NSArray *weightResultArr=@[@{@"min":@(30.0),@"max":@(lowWeight)}, @{@"min":@(lowWeight),@"max":@(highWeight)}, @{@"min":@(highWeight),@"max":@(150)}];
    
    CGFloat viewW=(kScreenWidth-20)/3.0;
    CGFloat pointX=0.0;
    for (NSInteger i=0; i<weightResultArr.count; i++) {
        NSDictionary *dict=weightResultArr[i];
        double maxValue=[dict[@"max"] doubleValue];
        double minValue=[dict[@"min"] doubleValue];
        if (_scaleWeight<=maxValue&&_scaleWeight>=minValue) {
            CGFloat progress=(_scaleWeight-minValue)/(maxValue-minValue);
            pointX=(i+progress)*viewW;
        }
    }
    UIImageView *pointerImageView=[[UIImageView alloc] initWithFrame:CGRectMake(pointX, valueLbl.bottom+10, 12, 20)];
    pointerImageView.image = [UIImage imageNamed:@"tzy_ic_pub_mark"];
    [self.view addSubview:pointerImageView];
    
    
    NSArray *arr=@[[NSString stringWithFormat:@"%.2f",0.8*(height-105)],[NSString stringWithFormat:@"%.2f",1.2*(height-105)]];
    CGFloat labW=(kScreenWidth-20)/3.0;
    for (NSInteger i=0; i<arr.count; i++) {
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake((i+1)*labW-20, valueLbl.bottom+10, 60, 20)];
        lab.font=[UIFont systemFontOfSize:10];
        lab.text=arr[i];
        lab.textAlignment=NSTextAlignmentCenter;
        [self.view addSubview:lab];
    }
    
    IndexResultView *indexView=[[IndexResultView alloc] initWithFrame:CGRectMake(10,valueLbl.bottom+15+17, kScreenWidth-20, 20)];
    indexView.key=@"weight";
    [self.view addSubview:indexView];
    
    NSArray *resultArr=[[ScaleHelper sharedScaleHelper] getBodyIndexResultArrayWithKey:@"weight"];
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
    NSString *resultStr=[[ScaleHelper sharedScaleHelper] getWeightStandardWithWeight:_scaleWeight];
    resultLabel.text=[[ScaleHelper sharedScaleHelper] getStandardContentWithResult:resultStr key:@"weight"];
    CGFloat resultH=[resultLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-20, CGFLOAT_MAX) withTextFont:resultLabel.font].height;
    resultLabel.frame=CGRectMake(10, indexView.bottom+30, kScreenWidth-20, resultH+20);
    [self.view addSubview:resultLabel];

}

@end
