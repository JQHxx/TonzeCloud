//
//  SportRecordTableView.m
//  Product
//
//  Created by 肖栋 on 17/4/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SportRecordTableView.h"
#import "SportRecordTableViewCell.h"

@implementation SportRecordTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self=[super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor=[UIColor bgColor_Gray];
        
        self.delegate=self;
        self.dataSource=self;
        self.scrollEnabled=NO;
        self.showsVerticalScrollIndicator=NO;
        self.tableFooterView=[[UIView alloc] init];
    }
    return self;
    
}

#pragma mark -- Setters and Getters
#pragma mark 运动记录
-(void)setSportsRecordsArray:(NSMutableArray *)sportsRecordsArray{
    _sportsRecordsArray=sportsRecordsArray;
}


#pragma mark -- UITablbeViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sportsRecordsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"SportRecordTableViewCell";
    SportRecordTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"SportRecordTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    SportRecordModel *sportModel=self.sportsRecordsArray[indexPath.row];
    [cell cellDisplayWithModel:sportModel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

@end
