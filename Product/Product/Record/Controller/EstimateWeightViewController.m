//
//  EstimateWeightViewController.m
//  Product
//
//  Created by 肖栋 on 17/5/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "EstimateWeightViewController.h"
#import "FoodMenuView.h"
#import "EstimateWeightTableViewCell.h"

@interface EstimateWeightViewController ()<FoodMenuViewDelegate,UITableViewDelegate,UITableViewDataSource>{

    NSInteger       page;
    NSArray        *menuArray;
    NSArray        *dataArray;
    NSDictionary   *dict;
}
@property (nonatomic,strong)FoodMenuView      *menuView;          //菜单栏
@property (nonatomic,strong)UITableView       *foodTableView;     //食物列表
@end

@implementation EstimateWeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    self.baseTitle = @"估算重量";
    page = 0;
    [self initEstimateWeightView];
}
#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    dataArray = [dict objectForKey:menuArray[page]];
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdntifier=@"EstimateWeightTableViewCell";
    EstimateWeightTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdntifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"EstimateWeightTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    dataArray = [dict objectForKey:menuArray[page]];
    NSDictionary *dicta = dataArray[indexPath.row];
    NSLog(@"%@",[dicta objectForKey:@"image"]);
    cell.headImg.image = [UIImage imageNamed:[dicta objectForKey:@"image"]];
    cell.nameLabel.text =[dicta objectForKey:@"name"];
    cell.detailLabel.text =[dicta objectForKey:@"title"];

    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 160;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    headview.backgroundColor = [UIColor bgColor_Gray];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth-20, 40)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = @"以身高为165cm，体重为59.5kg的中等身材成年男性手作为参照物。";
    titleLabel.numberOfLines = 2;
    [headview addSubview:titleLabel];
    
    return headview;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 50;
}
#pragma mark  TCMenuViewDelegate
-(void)foodMenuView:(FoodMenuView *)menuView actionWithIndex:(NSInteger)index{
    page = index;
    [self.foodTableView reloadData];
}
#pragma mark -- Event Response
#pragma mark -- 左／右滑
-(void)swipEstimateWeight:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        page++;
        if (page>menuArray.count-1) {
            page=menuArray.count-1;
            return;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        page--;
        if (page<0) {
            page=0;
            return;
        }
    }
    UIButton *btn;
    for (UIView *view in self.menuView.rootScrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&(view.tag == page+100)) {
            btn = (UIButton*)view;
        }
    }
    [self.menuView changeFoodViewWithButton:btn];
}
#pragma mark -- 初始化界面
- (void)initEstimateWeightView{

    NSString *path=[[NSBundle mainBundle] pathForResource:@"EstimateWeight" ofType:@"plist"];
    dict=[[NSDictionary alloc] initWithContentsOfFile:path];
    menuArray = @[@"主食类",@"肉类",@"蔬菜类",@"水果类",@"坚果类",@"油脂类"];
    
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.foodTableView];
}
#pragma mark -- setters and getters
#pragma mark 菜单栏
-(FoodMenuView *)menuView{
    if (_menuView==nil) {
        _menuView=[[FoodMenuView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 40)];
        _menuView.backgroundColor = [UIColor whiteColor];
        _menuView.foodMenusArray = [menuArray mutableCopy];
        _menuView.delegate=self;
    }
    return _menuView;
}
#pragma mark 食物列表
-(UITableView *)foodTableView{
    if (_foodTableView==nil) {
        _foodTableView=[[UITableView alloc] initWithFrame:CGRectMake(0,self.menuView.bottom, kScreenWidth, kAllHeight-self.menuView.bottom) style:UITableViewStylePlain];
        _foodTableView.dataSource=self;
        _foodTableView.delegate=self;
        _foodTableView.showsVerticalScrollIndicator=NO;
        _foodTableView.tableFooterView=[[UIView alloc] init];
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipEstimateWeight:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_foodTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipEstimateWeight:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_foodTableView addGestureRecognizer:swipGestureRight];
    }
    return _foodTableView;
}

@end
