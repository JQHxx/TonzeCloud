//
//  StorageAreaTableViewCell.m
//  Product
//
//  Created by vision on 17/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StorageAreaTableViewCell.h"

@interface StorageAreaTableViewCell (){
    UILabel    *foodNameLbl;
    UILabel    *weightLbl;
    UILabel    *experidLbl;
}

@end

@implementation StorageAreaTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        foodNameLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 12, kScreenWidth/3, 20)];
        foodNameLbl.textAlignment=NSTextAlignmentCenter;
        foodNameLbl.font=[UIFont systemFontOfSize:14];
        foodNameLbl.textColor=[UIColor colorWithHexString:@"#313131"];
        [self.contentView addSubview:foodNameLbl];
        
        weightLbl=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/3, 12, kScreenWidth/3, 20)];
        weightLbl.textAlignment=NSTextAlignmentCenter;
        weightLbl.font=[UIFont systemFontOfSize:14];
        weightLbl.textColor=[UIColor colorWithHexString:@"#626262"];
        [self.contentView addSubview:weightLbl];
        
        experidLbl=[[UILabel alloc] initWithFrame:CGRectMake(2*kScreenWidth/3, 12, kScreenWidth/3, 20)];
        experidLbl.textAlignment=NSTextAlignmentCenter;
        experidLbl.font=[UIFont systemFontOfSize:14];
        experidLbl.textColor=[UIColor colorWithHexString:@"#626262"];
        [self.contentView addSubview:experidLbl];
        
    }
    return self;
}

-(void)storageCellDisplayWithModel:(StorageModel *)storage{
    foodNameLbl.text=storage.item_name;
    weightLbl.text=[NSString stringWithFormat:@"%ld克",storage.weight];
    
    experidLbl.text=[[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",storage.overdue_time] format:@"yyyy-MM-dd"];
    
    NSString *currentDate=[[TJYHelper sharedTJYHelper] getCurrentDate];
    NSInteger currentTimesp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:currentDate format:@"yyyy-MM-dd"];
    experidLbl.textColor=storage.overdue_time<=currentTimesp?[UIColor colorWithHexString:@"#e60012"]:[UIColor colorWithHexString:@"#626262"];
    
}


@end
