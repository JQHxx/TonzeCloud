//
//  DeviceMenuScaleView.m
//  Product
//
//  Created by 肖栋 on 17/5/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DeviceMenuScaleView.h"
#import "DeviceMenuTableViewCell.h"

@interface DeviceMenuScaleView ()<UITableViewDelegate,UITableViewDataSource>{
    
    UIView        *rootView;
    UITableView   *_tableView;
    NSMutableArray *deviceArray;
    NSMutableArray *menuFoodArray;
}

@end
@implementation DeviceMenuScaleView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        _tableView.tableFooterView=[[UIView alloc] init];

        rootView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        rootView.backgroundColor=[UIColor blackColor];
        rootView.alpha=0.3;
        rootView.userInteractionEnabled=YES;
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissScaleView)];
        [rootView addGestureRecognizer:tap];
    }
    return self;
}
#pragma mark UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return deviceArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier=@"DeviceMenuTableViewCell";
    
    DeviceMenuTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"DeviceMenuTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    DeviceModel *model=deviceArray[indexPath.row];
    cell.deviceTypeIV.image = [model tableViewIconImage];
    cell.deviceNameLbl.text = model.deviceName;
    if (model.isOnline) {
        [cell.deviceStateIV setImage:[UIImage imageNamed:@"在线icon"]];
        cell.deviceStateLbl.text=@"设备在线";
    }else{
        [cell.deviceStateIV setImage:[UIImage imageNamed:@"离线icon"]];
        cell.deviceStateLbl.text=@"设备离线";
    }
    [cell.deviceNameLbl sizeToFit];
    
    cell.deviceStateIV.frame = CGRectMake(CGRectGetMaxX(cell.deviceNameLbl.frame), cell.deviceStateIV.frame.origin.y, cell.deviceStateIV.frame.size.width, cell.deviceStateIV.frame.size.height);
    if (model.deviceType == COOKFOOD_KETTLE) {
        if ([NSString isPureInt:[model.State objectForKey:@"state"]]) {
            if ([[model.State objectForKey:@"state"] isEqualToString:@"0"]){
                cell.deviceProgressLbl.text=@"一键烹饪";
            }else {
                NSArray *foodArray = [[NSArray alloc] initWithObjects:@"三杯鸡",@"黄焖鸡",@"红烧鱼",@"红焖排骨",@"清炖鸡",@"老火汤",@"红烧肉",@"东坡肘子",@"口水鸡",@"滑香鸡",@"茄子煲",@"梅菜扣肉", nil];
                NSString *str =[model.State objectForKey:@"state"];
                cell.deviceProgressLbl.text=foodArray[[str intValue]-2];
            }
        }else{
            cell.deviceProgressLbl.text=[[model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]?[model.State objectForKey:@"name"]:[model.State objectForKey:@"state"];
        }
    } else {
        cell.deviceProgressLbl.text=[[model.State objectForKey:@"state"] isEqualToString:@"云菜谱"]?[model.State objectForKey:@"name"]:[model.State objectForKey:@"state"];
        
    }
    //根据title的文字长度确认状态deviceStateIV的位置
    [cell.deviceNameLbl setNumberOfLines:0];  //必须是这组值
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17],};
    CGSize textSize = [cell.deviceNameLbl.text boundingRectWithSize:CGSizeMake(100, 100) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;;
    cell.deviceNameLbl.frame = CGRectMake(cell.deviceNameLbl.frame.origin.x, cell.deviceNameLbl.frame.origin.y, textSize.width>150?150:textSize.width, textSize.height );
    cell.deviceStateIV.frame=CGRectMake(cell.deviceNameLbl.frame.origin.x+cell.deviceNameLbl.frame.size.width+5, cell.deviceStateIV.frame.origin.y, cell.deviceStateIV.frame.size.width, cell.deviceStateIV.frame.size.height);
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_DeviceMenuScaleViewDelegate respondsToSelector:@selector(DeviceMenuScaleViewView:model:menu:index:)]) {
        [_DeviceMenuScaleViewDelegate DeviceMenuScaleViewView:self model:deviceArray[indexPath.row] menu:menuFoodArray[indexPath.row] index:_index];
    }
    [self dismissScaleView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
#pragma mark -- Private Methods
#pragma mark 弹出界面
-(void)DeviceMenuScaleViewShowInView:(UIView *)view{

    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"TCScaleView"];
    
    self.frame=CGRectMake(0,kScreenHeight-self.height, kScreenWidth, self.height);
    [view addSubview:rootView];
    [view addSubview:self];

}
#pragma mark 关闭视图
-(void)dismissScaleView{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame=CGRectMake(0, kScreenHeight, kScreenWidth, self.height);
    } completion:^(BOOL finished) {
        [rootView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark -- setters and getters
- (void)setDataArray:(NSMutableArray *)dataArray{
    deviceArray = [[NSMutableArray alloc] init];
     deviceArray=dataArray;
    [_tableView reloadData];
}
- (void)setMenuArray:(NSMutableArray *)menuArray{
    
    menuFoodArray = [[NSMutableArray alloc] init];
    menuFoodArray=menuArray;
}
@end
