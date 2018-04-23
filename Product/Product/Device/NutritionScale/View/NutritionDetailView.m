//
//  NutritionDetailView.m
//  Product
//
//  Created by Wzy on 1/9/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "NutritionDetailView.h"

@interface NutritionDetailView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIButton * btnClock;

@property (nonatomic,strong) UIView * bgView;

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) NSArray * arrayTitle;

@property (nonatomic,strong) NSMutableArray * arrayData;

@property (nonatomic,strong) TJYFoodDetailsModel * foodDetail;


@end

@implementation NutritionDetailView


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
    CGFloat viewWidth = 270.0f;
    CGFloat viewHeight = 300.0f;
    
    CGFloat viewTop = (SCREEN_HEIGHT - viewHeight) / 2.0f;
    
    self.btnClock = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnClock.frame = self.frame;
    self.btnClock.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.3f];
    [self.btnClock addTarget:self action:@selector(onBtnClock:) forControlEvents:UIControlEventTouchUpInside];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-viewWidth)/ 2, viewTop, viewWidth,viewHeight)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.layer.cornerRadius = 10.0;
    [self addSubview:self.bgView];
    
    self.tableView.frame = CGRectMake(0.0f, 0.0f, self.bgView.width, self.bgView.height);
    [self.bgView addSubview:self.tableView];

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


-(NSArray *)arrayTitle
{
    if (_arrayTitle == nil)
    {
        _arrayTitle=@[@"热量",@"碳水化合物",@"脂肪",@"蛋白质",@"膳食纤维",@"维生素A",@"维生素B1",@"维生素B2",@"维生素B3",@"维生素C",@"维生素E",@"胡萝卜素",@"胆固醇",@"钠",@"钙",@"铁",@"钾",@"锌",@"镁",@"铜",@"锰",@"磷",@"碘",@"硒"];
    }
    
    return _arrayTitle;
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
    return self.arrayData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];

    cell.textLabel.text = self.arrayTitle[indexPath.row];
    cell.detailTextLabel.text = self.arrayData[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



#pragma mark -
#pragma mark ==== onBtnAction ====
#pragma mark -


/**
 *  关闭
 */
-(void)onBtnClock:(id)sender
{
    [self closeAction];
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
    [self.bgView removeFromSuperview];
    [self removeFromSuperview];
}

-(void)nutritionDetailShowInView:(UIView *)view
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.bgView.layer addAnimation:animation forKey:@"NutritionDetailView"];
    [view addSubview:self];
    
    [self addSubview:self.btnClock];
    [self sendSubviewToBack:self.btnClock];
}

-(void)renderNutritionDetail:(TJYFoodDetailsModel *)foodModel
{
    self.foodDetail = foodModel;
    
    [self.arrayData addObject:[self handleNutrition:foodModel.energykcal unit:@"千卡"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.carbohydrate unit:@"克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.fat unit:@"克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.protein unit:@"克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.insolublefiber unit:@"克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.totalvitamin unit:@"微克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.thiamine unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.riboflavin unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.magnesium unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.vitaminC unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.vitaminE unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.carotene unit:@"微克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.cholesterol unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.sodium unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.calcium unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.iron unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.potassium unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.zinc unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.magnesium unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.copper unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.manganese unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.phosphorus unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.iodine unit:@"毫克"]];
    [self.arrayData addObject:[self handleNutrition:foodModel.selenium unit:@"微克"]];
    
    [self.tableView reloadData];

}

-(NSString *)handleNutrition:(CGFloat)type unit:(NSString *)strUnit
{
    CGFloat proportion = self.foodDetail.weight / 100.0f;
    
    CGFloat totol = proportion * type;

    NSString * content = @"";
    
    if(totol != 0)
    {
        content = [NSString stringWithFormat:@"%.0f%@",totol,strUnit];
    }
    else
    {
        content = [NSString stringWithFormat:@"--%@",strUnit];
    }
    
    return content;
}



@end
