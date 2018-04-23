//
//  UnitSelectViewController.m
//  Product
//
//  Created by mk-imac2 on 2017/9/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "UnitSelectViewController.h"

@interface UnitSelectViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) NSArray * arrayData;

@property (nonatomic,strong) NSArray * arrayTitle;

@property (nonatomic,strong) UITableViewCell * oldSelectCell;


@end

@implementation UnitSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.baseTitle = @"计量单位";
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 64.0f, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
    }
    
    return _tableView;
}

-(NSArray *)arrayData
{
    if (_arrayData == nil) {
        _arrayData = [NSArray arrayWithObjects:@"g",@"ml",@"lb",@"oz", nil];
    }
    
    return _arrayData;
}

-(NSArray *)arrayTitle
{
    if (_arrayTitle == nil) {
        _arrayTitle = [NSArray arrayWithObjects:@"克（g）",@"毫升（ml）",@"磅（lb）",@"盎司（oz）", nil];
    }
    
    return _arrayTitle;
}


#pragma mark -
#pragma mark ==== UITableViewDelegate ====
#pragma mark -

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayTitle count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    cell.textLabel.text = self.arrayTitle[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if ([self.arrayData[indexPath.row] isEqualToString:self.strUnit]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.oldSelectCell = cell;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.strUnit isEqualToString:self.arrayData[indexPath.row]]) {
        return;
    }
    self.strUnit = self.arrayData[indexPath.row];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    if (self.oldSelectCell) {
        self.oldSelectCell.accessoryType = UITableViewCellAccessoryNone;
    }
    self.oldSelectCell = cell;
}

#pragma mark -
#pragma mark ==== Action ====
#pragma mark -

- (void)leftButtonAction{

    if (self.unitSelcetBlock) {
        self.unitSelcetBlock(self.strUnit);
    }
    [self.navigationController popViewControllerAnimated:YES];

}

@end
