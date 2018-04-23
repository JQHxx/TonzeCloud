//
//  TJYHealthListModel.h
//  Product
//
//  Created by 肖栋 on 17/5/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//
/*
 "result": [
 {
 "assess_id": 87,
 "type": 0,
 "name": "方面名称414433",
 "brief": "",
 "score": 0,
 "sort": 1,
 "is_used": 1,
 "tset_num": 0,
 "add_time": "1494578321",
 "edit_time": "1494578321",
 "parent_id": 0,
 "image_url": null
 }
 ],
 */

#import <Foundation/Foundation.h>

@interface TJYHealthListModel : NSObject

@property(nonatomic ,strong)NSString *name;
@property(nonatomic ,strong)NSString *brief;
@property(nonatomic ,strong)NSString *image_url;
@property(nonatomic ,assign)NSInteger assess_id;

@end
