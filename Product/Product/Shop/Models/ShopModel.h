//
//  ShopModel.h
//  Product
//
//  Created by 肖栋 on 17/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//
/**
 "marketable": "true",
 "goods_id": "53",
 "bn": "001014",
 "name": "天际 BJHW180P 玻璃多功能养生壶分体电热水煮花茶壶正品  ",
 "brief": "1.8L容量 高硼硅壶体 多功能 养生茶壶 ",
 "image_default_id": "f6a4cfd042aa12d225b963922a1b6eaf",
 "comments_count": "0",
 "default_product_id": null,
 "price": null,
 "mktprice": 0,
 "store": 999999,
 "image": {
 "image_id": "f6a4cfd042aa12d225b963922a1b6eaf",
 "s_url": "/public/images/02/f2/d0/ba56c33215f17f27cfa78b47ee9063c09aa16f3b.jpg",
 "m_url": "/public/images/dd/0b/54/8c189445c4a15dccb8037714d05c91410a25074d.jpg",
 "l_url": "/public/images/81/5e/68/a4f74d47ff12e8ab71da82cf972a62d6153dde23.jpg"
 }
 }
 */
#import <Foundation/Foundation.h>

@interface ShopModel : NSObject

@property (nonatomic ,assign)NSInteger marketable;
//商品id
@property (nonatomic ,assign)NSInteger goods_id;

@property (nonatomic ,strong)NSString  *bn;
//商品名
@property (nonatomic ,strong)NSString  *name;
//商品简介
@property (nonatomic ,strong)NSString  *brief;
//默认图片id
@property (nonatomic ,strong)NSString  *image_default_id;
//评论数
@property (nonatomic ,assign)NSInteger comments_count;
//默认规格id(商品详情要用到)
@property (nonatomic ,assign)NSString *default_product_id;
//价格
@property (nonatomic ,assign)float price;
//市场价
@property (nonatomic ,assign)float mktprice;
//库存
@property (nonatomic ,assign)NSInteger store;
//图片
@property (nonatomic ,strong)NSDictionary  *image;

@property (nonatomic ,copy)NSString   *gnotify_id;
@end
