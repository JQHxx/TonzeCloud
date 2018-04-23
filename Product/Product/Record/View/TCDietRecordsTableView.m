//
//  TCDietRecordsTableView.m
//  TonzeCloud
//
//  Created by fei on 2017/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCDietRecordsTableView.h"
#import "DietRecordTableViewCell.h"
#import "TJYHelper.h"
@interface TCDietRecordsTableView (){
    NSMutableArray      *headTitles;
    NSMutableArray      *keysArray;
}

@end

@implementation TCDietRecordsTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self=[super initWithFrame:frame style:style];
    if (self) {
        self.delegate=self;
        self.dataSource=self;
        self.scrollEnabled=NO;
        self.showsVerticalScrollIndicator=NO;
        self.tableFooterView=[[UIView alloc] init];
        
        headTitles=[[NSMutableArray alloc] init];
        keysArray=[[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark -- Setters
-(void)setDietRecordsDict:(NSDictionary *)dietRecordsDict{
    _dietRecordsDict=dietRecordsDict;
    
    if (dietRecordsDict.count>0) {
        NSArray *keys=[dietRecordsDict allKeys];
        NSArray *periodArr=@[@"早餐",@"午餐",@"晚餐",@"加餐"];
        NSMutableArray *keysTempArr=[[NSMutableArray alloc] init];
        NSMutableArray *titlesTempArr=[[NSMutableArray alloc] init];
        for (NSString *periodStr in periodArr) {
            for (NSString *timeSlot in keys) {
                NSString *periodCh=[[TJYHelper alloc] getDietPeriodChNameWithPeriod:timeSlot];
                if ([periodCh isEqualToString:periodStr]) {
                    [keysTempArr addObject:timeSlot];
                    [titlesTempArr addObject:periodCh];
                }
            }
        }
        keysArray=keysTempArr;
        headTitles=titlesTempArr;
    }
    
}


#pragma mark -- UITableViewDelegate and UITableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return headTitles.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *dietList=[self.dietRecordsDict valueForKey:keysArray[section]];
    return dietList.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return headTitles[section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"DietRecordTableViewCell";
    DietRecordTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"DietRecordTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSArray *dietList=[self.dietRecordsDict valueForKey:keysArray[indexPath.section]];
    NSDictionary *foodDict=dietList[indexPath.row];
    [cell cellDisplayWithFoodDict:foodDict];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}




@end
