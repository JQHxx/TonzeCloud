//
//  SportRecordTableView.h
//  Product
//
//  Created by 肖栋 on 17/4/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportRecordModel.h"

@class SportRecordTableView;
@protocol SportsRecordsTableViewDelegate <NSObject>

-(void)sportsRecordTableView:(SportRecordTableView *)tableView didSelectStepSportModel:(SportRecordModel *)stepModel;

@end

@interface SportRecordTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak)id<SportsRecordsTableViewDelegate>viewDelegate;

@property (nonatomic,strong)NSMutableArray *sportsRecordsArray;


@end
