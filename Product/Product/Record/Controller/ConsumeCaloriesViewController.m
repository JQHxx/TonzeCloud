//
//  ConsumeCaloriesViewController.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ConsumeCaloriesViewController.h"

@interface ConsumeCaloriesViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray     *sportsArray;
}

@property (nonatomic,strong)UIView       *cosumeCaloriesView;
@property (nonatomic,strong)UILabel      *sportsTitleLabel;
@property (nonatomic,strong)UITableView  *sportsTableView;

@end
@implementation ConsumeCaloriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"运动指导";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"consumeSports" ofType:@"plist"];
    sportsArray=[[NSArray alloc] initWithContentsOfFile:path];
    
    [self.view addSubview:self.cosumeCaloriesView];
    [self.view addSubview:self.sportsTitleLabel];
    [self.view addSubview:self.sportsTableView];
    
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return sportsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"sportsCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.layoutMargins=UIEdgeInsetsZero;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSDictionary *dict=sportsArray[indexPath.row];
    cell.textLabel.text=dict[@"name"];
    NSInteger calorie=[dict[@"calorie"] integerValue];
    NSInteger minute=(60*self.surplusEnergy)/calorie;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%ld分钟",(long)minute];
    cell.imageView.image = [UIImage imageNamed:dict[@"image"]];
    return cell;
}

#pragma mark -- Setters and Getters
#pragma mark 消耗能量数
-(UIView *)cosumeCaloriesView{
    if (_cosumeCaloriesView==nil) {
        _cosumeCaloriesView=[[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 60)];
        _cosumeCaloriesView.backgroundColor=[UIColor whiteColor];
        
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth-20, 20)];
        titleLabel.font=[UIFont systemFontOfSize:16.0f];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        [_cosumeCaloriesView addSubview:titleLabel];
        
        NSString *tempStr=[NSString stringWithFormat:@"摄入已超目标%ld千卡",(long)self.surplusEnergy];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:tempStr];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:kSystemColor range:NSMakeRange(2, 2)];
        NSRange range=NSMakeRange(6, attributeStr.length-8);
        [attributeStr addAttribute:NSForegroundColorAttributeName value:kSystemColor range:range];
        titleLabel.attributedText=attributeStr;
        
        UILabel *subTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 35, kScreenWidth-20, 20)];
        subTitleLabel.font=[UIFont systemFontOfSize:13.0f];
        subTitleLabel.textAlignment=NSTextAlignmentCenter;
        subTitleLabel.textColor=[UIColor lightGrayColor];
        subTitleLabel.text=@"请消耗热量";
        [_cosumeCaloriesView addSubview:subTitleLabel];
    }
    return _cosumeCaloriesView;
}

#pragma mark  推荐运动标题
-(UILabel *)sportsTitleLabel{
    if (_sportsTitleLabel==nil) {
        _sportsTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, self.cosumeCaloriesView.bottom+5, kScreenWidth-30, 30)];
        _sportsTitleLabel.text=@"为您推荐运动计划";
        _sportsTitleLabel.font=[UIFont systemFontOfSize:14.0f];
        _sportsTitleLabel.textColor=[UIColor lightGrayColor];
    }
    return _sportsTitleLabel;
}

-(UITableView *)sportsTableView{
    if (_sportsTableView==nil) {
        _sportsTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, self.sportsTitleLabel.bottom, kScreenWidth, kScreenHeight-self.sportsTitleLabel.bottom) style:UITableViewStylePlain];
        _sportsTableView.backgroundColor=[UIColor bgColor_Gray];
        _sportsTableView.delegate=self;
        _sportsTableView.dataSource=self;
        _sportsTableView.tableFooterView=[[UIView alloc] init];
        _sportsTableView.showsVerticalScrollIndicator=NO;
        _sportsTableView.separatorInset=UIEdgeInsetsZero;
        _sportsTableView.layoutMargins=UIEdgeInsetsZero;
    }
    return _sportsTableView;
}


@end

