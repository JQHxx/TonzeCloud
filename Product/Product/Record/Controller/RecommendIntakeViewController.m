//
//  RecommendIntakeViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecommendIntakeViewController.h"
#import "DrawLine.h"

@interface RecommendIntakeViewController (){
    NSArray        *intakeGramsArray;
    NSArray         *cateArray;
}

@property (nonatomic,strong)UIView           *intakeView;
@property (nonatomic,strong)UILabel          *foodsTitleLabel;
@property (nonatomic,strong)UIView           *drawListView;

@end

@implementation RecommendIntakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"饮食指导";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    cateArray=@[@"蔬菜菌藻类",@"水果类",@"奶类",@"主食类",@"肉类",@"蛋类",@"大豆及制品",@"油脂类",@"坚果类"];
    NSString *path=[[NSBundle mainBundle] pathForResource:@"intakeFood" ofType:@"plist"];
    intakeGramsArray=[[NSArray alloc] initWithContentsOfFile:path];
    
    [self.view addSubview:self.intakeView];
    [self.view addSubview:self.foodsTitleLabel];
    [self.view addSubview:self.drawListView];
    
}

#pragma mark -- Setters and Getters
#pragma mark 摄入提示
-(UIView *)intakeView{
    if (_intakeView==nil) {
        _intakeView=[[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 50)];
        _intakeView.backgroundColor=[UIColor whiteColor];
        
        UILabel *intakeLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth-20, 30)];
        intakeLabel.font=[UIFont systemFontOfSize:18.0f];
        intakeLabel.textAlignment=NSTextAlignmentCenter;
        intakeLabel.textColor=[UIColor blackColor];
        [_intakeView addSubview:intakeLabel];
        
        NSString *tempStr=[NSString stringWithFormat:@"每日推荐摄入量为%ld千卡",(long)self.restEnergy];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:tempStr];
        NSRange range=NSMakeRange(8, attributeStr.length-10);
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        intakeLabel.attributedText=attributeStr;
    }
    return _intakeView;
}

-(UILabel *)foodsTitleLabel{
    if (_foodsTitleLabel==nil) {
        _foodsTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, self.intakeView.bottom+5, kScreenWidth-30, 30)];
        _foodsTitleLabel.text=@"一日膳食推荐摄入量";
        _foodsTitleLabel.font=[UIFont systemFontOfSize:14.0f];
        _foodsTitleLabel.textColor=[UIColor blackColor];
    }
    return _foodsTitleLabel;
}

-(UIView *)drawListView{
    if (_drawListView==nil) {
        _drawListView=[[UIView alloc] initWithFrame:CGRectMake(0, self.foodsTitleLabel.bottom, kScreenWidth, kScreenHeight-self.foodsTitleLabel.bottom)];
        _drawListView.backgroundColor=[UIColor whiteColor];
        
        DrawLine *drawLineView=[[DrawLine alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth-40, 300)];
        drawLineView.backgroundColor=[UIColor whiteColor];
        [_drawListView addSubview:drawLineView];
        
        CGFloat w=(kScreenWidth-40)/2;
        CGFloat h=drawLineView.height/(cateArray.count+1);
        
        NSArray *titles=@[@"分类",@"克数"];
        for (NSInteger i=0; i<titles.count; i++) {
            UILabel *lab=[[UILabel alloc] init];
            if (i==0) {
                lab.frame=CGRectMake(20,20,w-1, h);
            }else{
                lab.frame=CGRectMake(20+w, 20, w, h);
            }
            lab.backgroundColor=kSystemColor;
            lab.text=titles[i];
            lab.textColor = [UIColor whiteColor];
            lab.textAlignment=NSTextAlignmentCenter;
            lab.font=[UIFont systemFontOfSize:14];
            [_drawListView addSubview:lab];
        }
        
        
        for (NSInteger i=0; i<cateArray.count; i++) {
            UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, 20+h+i*h, w, h)];
            lab.text=cateArray[i];
            lab.textAlignment=NSTextAlignmentCenter;
            lab.font=[UIFont systemFontOfSize:14];
            [_drawListView addSubview:lab];
        }
        
        NSInteger copies=(double)self.restEnergy/90+0.5;
        NSArray *foodList=[[NSArray alloc] init];
        for (NSDictionary *dict in intakeGramsArray) {
            NSInteger number=[dict[@"number"] integerValue];
            if (copies==number) {
                foodList=[dict valueForKey:@"values"];
            }
        }
        for (NSInteger i=0; i<foodList.count; i++) {
            UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(20+w, 20+h+i*h, w, h)];
            lab.text=foodList[i];
            lab.textAlignment=NSTextAlignmentCenter;
            lab.font=[UIFont systemFontOfSize:14];
            [_drawListView addSubview:lab];
        }
        
    }
    return _drawListView;
}


@end
