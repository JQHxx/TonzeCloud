//
//  GoodsInfoModel.h
//  Product
//
//  Created by zhuqinlu on 2018/1/16.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsInfoModel : NSObject

/// 
@property (nonatomic, copy) NSString *goods_id;
///
@property (nonatomic ,strong) NSNumber *goods_num;
///
@property (nonatomic ,strong) NSArray *goods_pic;
///
@property (nonatomic, copy) NSString *Consignor;
///
@property (nonatomic, copy) NSString *Consignee;

@end
