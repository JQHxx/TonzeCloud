//
//  FoodSelecedView.m
//  Product
//
//  Created by Wzy on 1/9/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "FoodSelecedView.h"
#import "NutritionFoodCell.h"
#import "NutritionFoodTool.h"
#import "FoodMenuScale.h"
#import "EstimateWeightViewController.h"

@interface FoodSelecedView ()<UITableViewDataSource,UITableViewDelegate,FoodMenuScaleViewDelegate>

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) UIButton * btnClock;

@property (nonatomic,strong) UIButton * btnWClock;

@property (nonatomic,strong) UIView * bgView;

@property (nonatomic,strong) NSMutableArray * arrayData;

@property (nonatomic,copy) FoodDeleteBlock foodBlock;

@end

@implementation FoodSelecedView


-(id)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initView];
    }
    return self;
}


/**
 *  实例化页面
 */
-(void)initView
{
    CGFloat viewWidth = SCREEN_WIDTH;
    CGFloat viewHeight = 60.0f * 3 + 30;
    
    CGFloat viewTop = SCREEN_HEIGHT - viewHeight - 49.0f;
    
    self.btnClock = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnClock.frame = CGRectMake(0.0f, 0.0f, self.width, self.height - 49.0f);
    self.btnClock.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.3f];
    [self.btnClock addTarget:self action:@selector(onBtnClock:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnWClock = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnWClock.frame = CGRectMake(0.0f, self.height - 49.0f, self.width, 49.0f);
    self.btnWClock.backgroundColor = [UIColor clearColor];
    [self.btnWClock addTarget:self action:@selector(onBtnClock:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnWClock];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-viewWidth)/ 2, viewTop, viewWidth,viewHeight)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.layer.cornerRadius = 10.0;
    [self addSubview:self.bgView];
    
    UIButton * btnClear =[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-60, 5, 50, 30)];
    [btnClear setTitle:@"清空" forState:UIControlStateNormal];
    [btnClear setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnClear addTarget:self action:@selector(onBtnClear:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:btnClear];
    
    self.tableView.frame = CGRectMake(0.0f, 30.0f, self.bgView.width, self.bgView.height - 30.0f);
    [self.bgView addSubview:self.tableView];
    
    [self.tableView registerClass:[NutritionFoodCell class] forCellReuseIdentifier:NSStringFromClass([NutritionFoodCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:@"NutritionFoodCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([NutritionFoodCell class])];
    
}

-(UITableView *)tableView
{
    if (_tableView == nil)
    {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

-(NSMutableArray *)arrayData
{
    if (_arrayData == nil)
    {
        _arrayData = [[NSMutableArray alloc] init];
    }
    
    return _arrayData;
}


#pragma mark -
#pragma mark ==== UITableView ====
#pragma mark -

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayData count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TJYFoodListModel * model = self.arrayData[indexPath.row];
    NutritionFoodCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NutritionFoodCell class])];
    
    [cell renderNutritionFoodCell:model foodBlock:^(TJYFoodListModel *food) {
        [self deleteFood:food];
    }];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TJYFoodListModel * model = self.arrayData[indexPath.row];

    FoodAddModel * food = [[FoodAddModel alloc] init];
    food.id = model.id;
    food.image_url = model.image_url;
    food.name = model.name;
    food.energykcal = model.energykcal;
    food.type = 1;

    food.weight = [NSNumber numberWithInteger:model.weight];
    
    
    FoodMenuScale *scaleView = nil;
    scaleView=[[FoodMenuScale alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300) model:food type:YES];
    scaleView.isShow = YES;
    scaleView.foodMenuScaleDelegate=self;
    [scaleView scaleViewShowInView:self];
}

#pragma mark -
#pragma mark ==== FoodMenuScaleViewDelegate ====
#pragma mark -

- (void)foodMenuScaleView:(FoodMenuScale *)scaleView didSelectFood:(FoodAddModel *)food{
    
    for (TJYFoodListModel * model in self.arrayData) {
        if (model.id == food.id) {
            model.weight = [food.weight floatValue];
            
            CGFloat proportion = model.weight / 100.0f;
            CGFloat energykcal = proportion * model.energykcal;
            model.totalkcal = energykcal;
            
            if (self.modifyBlock) {
                self.modifyBlock(model);
            }
            
            break;
        }
    }
    
    [self.tableView reloadData];
}

- (void)foodMenuScaleView:(FoodMenuScale *)scaleView
{
    if (self.selectToBlock) {
        self.selectToBlock(FoodSelectToTypeEstimate,nil);
    }
}

- (void)foodMenuNextScaleView:(FoodMenuScale *)scaleNextView didSelectFood:(FoodAddModel *)food{
    
    if (self.selectToBlock) {
        self.selectToBlock(FoodSelectToTypeDetail,food);
    }
}

#pragma mark -
#pragma mark ==== onBtnAction ====
#pragma mark -

/**
 *  删除
 */
-(void)deleteFood:(TJYFoodListModel *)food
{
    for (TJYFoodListModel * model in self.arrayData) {
        if (model.id == food.id) {
            [self.arrayData removeObject:food];
            break;
        }
    }

    [self.tableView reloadData];
    if([self.arrayData count] == 0)
    {
        [self closeAction];
    }
    if (self.foodBlock) {
        self.foodBlock(food,NO);
    }
}

/**
 *  关闭
 */
-(void)onBtnClock:(id)sender
{
    [self closeAction];
}

/**
 *  清空
 */
-(void)onBtnClear:(id)sender
{
    [self.arrayData removeAllObjects];
    [self.tableView reloadData];
    [self closeAction];

    if (self.foodBlock) {
        self.foodBlock(nil,YES);
    }
}

/**
 *  计算出总热量
 */
-(void)handleAddToFood
{

}


#pragma mark -
#pragma mark ==== Action ====
#pragma mark -


-(void)closeAction
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.bgView setAlpha:0.0f];
    [self.bgView.layer addAnimation:animation forKey:@"FoodSelecedView"];
    
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3f];
}

-(void)viewRemoveFromSuperview
{
    [self.btnClock removeFromSuperview];
    [self.btnWClock removeFromSuperview];
    [self.bgView removeFromSuperview];
    [self removeFromSuperview];
}

-(void)foodSelecedShowInView:(UIView *)view withArray:(NSMutableArray *)arrayData foodSelecedBlock:(FoodDeleteBlock)block;
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.bgView setAlpha:1.0f];
    [self.bgView.layer addAnimation:animation forKey:@"FoodSelecedView"];
    [view addSubview:self];

    [self addSubview:self.btnClock];
    [self sendSubviewToBack:self.btnClock];
    
    self.foodBlock = block;
    self.arrayData = [arrayData mutableCopy];
    [self.tableView reloadData];
}


@end
