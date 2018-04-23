//
//  GoodsFavoriteModel.h
//  Product
//
//  Created by 肖栋 on 18/1/10.
//  Copyright © 2018年 TianJi. All rights reserved.
//
/**
 "gnotify_id": "44",
 "goods_id": "80",
 "goods_name": "来，上车",
 "goods_price": "100.000",
 "price": 100,
 "goods_pic": {
 "s_url": "http://172.16.0.78/public/images/0a/90/11/c9433247cc3197736876fb636a843138bd794d89.jpg",
 "m_url": "http://172.16.0.78/public/images/a3/cc/f7/7a38b3c732aec032799948f83fa84510789d98bc.jpg",
 "l_url": "http://172.16.0.78/public/images/53/d2/e9/af6c29f95d95b423b45debaecf3131469f040a91.jpg"
 }
 */
#import <Foundation/Foundation.h>

@interface GoodsFavoriteModel : NSObject

@property (nonatomic ,copy)NSString   *goods_id;
@property (nonatomic ,copy)NSString   *goods_name;
@property (nonatomic ,assign)NSInteger gnotify_id;
@property (nonatomic ,assign)CGFloat   goods_price;
@property (nonatomic ,assign)NSInteger product_id;
@property (nonatomic ,assign)CGFloat   price;
@property (nonatomic ,strong)NSDictionary  *goods_pic;
@property (nonatomic ,copy)NSString   *is_del;

@end
