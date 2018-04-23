//
//  CartGoodsModel.h
//  Product
//
//  Created by vision on 17/12/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CartGoodsModel :NSObject


@property (nonatomic, copy  ) NSString  *weight;//重量

@property (nonatomic, copy  ) NSString  *time;//加入购物车时间

@property (nonatomic, copy  ) NSString  *obj_type;//商品类型

@property (nonatomic, copy  ) NSString  *url;//图片url

@property (nonatomic, copy  ) NSString  *member_id;

@property (nonatomic, copy  ) NSString  *image_default_id;//默认图片id

@property (nonatomic, copy  ) NSString  *obj_ident; //商品唯一标识

@property (nonatomic, copy  ) NSString  *brief;//简介

@property (nonatomic, copy  ) NSString  *name;//商品名称

@property (nonatomic, copy  ) NSString  *thumbnail_pic;//缩略图id

@property (nonatomic, copy  ) NSString  *spec_info;//规格

@property (nonatomic, copy  ) NSString  *mktprice;//市场价

@property (nonatomic, copy  ) NSString  *quantity;//数量

@property (nonatomic, strong) NSArray   *adjunct;

@property (nonatomic, assign) NSInteger product_id;//产品id

@property (nonatomic, assign) NSInteger valid;//是否失效 1有效 0无效

@property (nonatomic, assign) NSInteger goods_id;//商品id

@property (nonatomic, copy  ) NSString  *unit;//单位

@property (nonatomic, copy  ) NSString  *price;//销售价

@property (nonatomic, copy  ) NSString  *extends_params;

@property (nonatomic,assign ) NSInteger select_status;//是否选择 1已选 0未选

@property (nonatomic,assign ) BOOL      isEdited;//是否编辑

@property (nonatomic,assign ) NSInteger  store;

@end
