//
//  GoodsParameterTool.m
//  Product
//
//  Created by 肖栋 on 17/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "GoodsParameterTool.h"
#import "ShopParameterTableViewCell.h"

@interface GoodsParameterTool ()<UITableViewDelegate,UITableViewDataSource>{

    NSInteger  height;
    GoodsModel *shopModel;
}

@property (nonatomic,strong)UIView *backgroundView;

@end

@implementation GoodsParameterTool

-(instancetype)initWithHeight:(CGFloat)viewHeight goodsParameter:(GoodsModel *)model{
    self = [super init];
    if (self) {
        height = viewHeight;
        shopModel = model;
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, kScreenWidth, 20)];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.text = @"商品参数";
        [self addSubview:contentLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, kScreenWidth, 1)];
        lineLabel.backgroundColor = kLineColor;
        [self addSubview:lineLabel];
        
        UITableView *goodParmeterTab = [[UITableView alloc] initWithFrame:CGRectMake(0, 51, kScreenWidth, viewHeight-51-49) style:UITableViewStyleGrouped];
        goodParmeterTab.backgroundColor = [UIColor bgColor_Gray];
        goodParmeterTab.delegate = self;
        goodParmeterTab.dataSource = self;
        goodParmeterTab.tableFooterView = [[UIView alloc] init];
        [self addSubview:goodParmeterTab];
        
        UIButton *completeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, viewHeight-49, kScreenWidth, 49)];
        [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
        [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [completeBtn setBackgroundColor:[UIColor colorWithHexString:@"0xf39800"]];
        [completeBtn addTarget:self action:@selector(completeButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:completeBtn];
        
    }
    return self;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return shopModel.params.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *type_info = [shopModel.params[section] objectForKey:@"type_info"];
    return type_info.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"ShopParameterTableViewCell";
    ShopParameterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell==nil) {
        cell = [[ShopParameterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *type_info = [shopModel.params[indexPath.section] objectForKey:@"type_info"];
    [cell cellParameterDict:type_info[indexPath.row]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return shopModel.params.count>1?50:0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 0.01;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    headView.backgroundColor = [UIColor whiteColor];
    if (shopModel.params.count>1) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, kScreenWidth/2, 20)];
        titleLabel.text =  [shopModel.params[section] objectForKey:@"type_name"];
        titleLabel.font = [UIFont systemFontOfSize:16];
        [headView addSubview:titleLabel];

    }
    return headView;
}
#pragma mark -- 完成
- (void)completeButton{
    [self backViewHide];
}
#pragma mark -- Event Response
#pragma mark 视图隐藏
-(void)backViewHide{
    [UIView animateWithDuration: 0.25 animations:^{
        self.frame=CGRectMake(0, kScreenHeight, kScreenWidth, height);
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.backgroundView removeFromSuperview];
    }];
}
#pragma mark -- Public Methods
#pragma mark 显示
-(void)goodsParameterToolShow{
    [kKeyWindow addSubview:self.backgroundView];
    [kKeyWindow addSubview:self];
    self.frame=CGRectMake(0, kScreenHeight, kScreenWidth, height);
    [UIView animateWithDuration: 0.25 animations:^{
        self.backgroundView.alpha = 0.4;
        self.frame=CGRectMake(0, kScreenHeight-height, kScreenWidth, height);
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark 背景视图
-(UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(backViewHide)];
        [_backgroundView addGestureRecognizer: tap];
    }
    return _backgroundView;
}

@end
