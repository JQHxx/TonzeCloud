//
//  OrderCountMode.h
//  Product
//
//  Created by zhuqinlu on 2018/1/13.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderCountMode : NSObject

/// 
@property (nonatomic, copy)  NSString *order_count;
///
@property (nonatomic, copy) NSString  *nopayed_count;
///
@property (nonatomic, copy) NSString  *nodelivery_count;
///
@property (nonatomic, copy) NSString  *noreceived_count;

@end
