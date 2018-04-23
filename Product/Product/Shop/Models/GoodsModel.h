//
//  GoodsModel.h
//  Product
//
//  Created by vision on 17/12/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsModel : NSObject

@property (nonatomic, assign ) NSInteger    goods_id;//商品id

@property (nonatomic, strong ) NSDictionary *brand;

@property (nonatomic, copy   ) NSString     *brief;//简介

@property (nonatomic, copy   ) NSString     *cat_name;

@property (nonatomic, copy   ) NSString     *goods_bn;

@property (nonatomic, copy   ) NSString     *goods_marketable;

@property (nonatomic, copy   ) NSString     *intro;     //详情

@property (nonatomic, copy   ) NSString     *nostore_sell;

@property (nonatomic, strong ) NSArray      *params;   //商品参数

@property (nonatomic, copy   ) NSString     *price;//价格

@property (nonatomic, copy   ) NSString     *mktprice;//原价

@property (nonatomic, copy   ) NSString     *product_bn;

@property (nonatomic, assign ) NSInteger    product_id;//产品id

@property (nonatomic, copy   ) NSString     *product_marketable;

@property (nonatomic, assign ) NSInteger    store;//库存

@property (nonatomic, copy   ) NSString     *title;//标题

@property (nonatomic, copy   ) NSString     *type_name;

@property (nonatomic, copy   ) NSString     *unit;

@property (nonatomic, assign ) NSInteger     quantity; //添加购物车数量

@property (nonatomic, copy   ) NSString     *spec_default_pic;

@property (nonatomic, strong ) NSArray      *promotion;

@property (nonatomic, strong ) NSArray      *props;//商品扩展参数

@property (nonatomic, strong ) NSArray      *spec;//规格集

@property (nonatomic, strong ) NSArray      *images;//图片集合

@property (nonatomic, copy   ) NSString     *image_default_id;

@property (nonatomic, strong ) NSDictionary *image_default; //封面图

@property (nonatomic, assign ) NSInteger     is_favorite;  //是否收藏



@end
