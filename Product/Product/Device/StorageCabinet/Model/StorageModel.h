//
//  StorageModel.h
//  Product
//
//  Created by 肖栋 on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StorageModel : NSObject

@property (nonatomic, copy) NSString *item_name;

@property (nonatomic, assign) NSInteger weight;

@property (nonatomic, assign) NSInteger overdue_time;

@property (nonatomic, assign) NSInteger locker_ingredient_id;


@end
