
//
//  AndyDropDownList.m
//  Product
//
//  Created by zhuqinlu on 2017/4/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AndyDropDownList.h"
#import "TJYDownListMenuCell.h"

@interface AndyDropDownList ()<UITableViewDataSource,
UITableViewDelegate>

@property(nonatomic,strong)NSArray *arr;
@property(nonatomic,assign)CGFloat rowHeight;   // 行高
@property(nonatomic,strong)UIButton *button;    //从Controller传过来的控制器
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UIImageView *arrow;
@property(nonatomic,assign)NSInteger index;    //记录选中行
///
@property (nonatomic ,strong) UITapGestureRecognizer *tap;

@end
static NSString * const downListMenuCellId = @"JGDownListMenuCellId";

@implementation AndyDropDownList

- (id)initWithFrame:(CGRect)listFrame ListDataSource:(NSArray *)array rowHeight:(CGFloat)rowHeight view:(UIView *)v {
    if (self = [super initWithFrame:listFrame]) {
        self.arr = array;
        self.rowHeight = rowHeight;
        self.button = (UIButton *)v;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
//        [self.bgView addGestureRecognizer:tap];
        
    }
    return self;
}

-(UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kBodyHeight)];
        _bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _bgView.userInteractionEnabled = YES;
    }
    return _bgView;
}
-(UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth ,kBodyHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TJYDownListMenuCell class] forCellReuseIdentifier:downListMenuCellId];
    }
    return _tableView;
}
-(NSArray *)arr
{
    if (!_arr)
    {
        _arr = [[NSArray alloc] init];
    }
    return _arr;
}
-(UIImageView *)arrow
{
    if (!_arrow)
    {
        _arrow = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2 + 50, (self.rowHeight - 22)/2, 22, 22)];
        _arrow.image = [UIImage imageNamed:@"ic_pub_arrow"];
    }
    return _arrow;
}
/**
 *   显示下拉列表
 */
-(void)showList
{
    [self addSubview:self.bgView];
    [self addSubview:self.tableView];
    [self.tableView reloadData];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.bgView.alpha = 1;
        self.tableView.frame = CGRectMake(0, 0, kScreenWidth, _arr.count * self.rowHeight);
    }];
}
/**
 *  隐藏
 */
-(void)hiddenList
{
    [UIView animateWithDuration:0.25f animations:^{
        self.bgView.alpha = 0;
        [self removeFromSuperview];
    }];
}
/**
 *  隐藏
 */
- (void)tapClick{
    [self removeFromSuperview];
}

#pragma mark - UITableViewDelegateAndUITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TJYDownListMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:downListMenuCellId forIndexPath:indexPath];
    cell.titleLbl.text = [NSString stringWithFormat:@"%@统计",self.arr[indexPath.row]];
    
    if (self.index == indexPath.row)
    {
        if ([cell.titleLbl.text isEqualToString:self.button.titleLabel.text])
        {
            [cell addSubview:self.arrow];
        }
    }
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
#pragma mark ----------------UITableView  表的选中方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hiddenList];
    self.index = indexPath.row;
    if ([self.delegate respondsToSelector:@selector(dropDownListParame:)])
    {
        [self.delegate dropDownListParame:self.arr[indexPath.row]];
    }
    if ([self.delegate respondsToSelector:@selector(listIndex:)]) {
        [self.delegate listIndex:indexPath.row];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}
@end
