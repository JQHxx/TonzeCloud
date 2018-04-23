//
//  TCDietRecordsTableView.h
//  TonzeCloud
//
//  Created by fei on 2017/2/19.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCDietRecordsTableView : UITableView<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic,strong)NSDictionary *dietRecordsDict;

@end
