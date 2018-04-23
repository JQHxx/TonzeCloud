//
//  TJYBannerModel.h
//  Product
//
//  Created by zhuqinlu on 2017/4/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//   banner  广告栏模型

#import <Foundation/Foundation.h>

@interface TJYBannerModel : NSObject

@property (nonatomic,assign)NSInteger  id;
@property (nonatomic, copy) NSString *brief;
@property (nonatomic, copy) NSString *image_url;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, assign) NSInteger type;
/// 是否收藏
@property (nonatomic, assign) NSInteger  is_collection;


//广告页
@property (nonatomic,strong)NSNumber   *minutes;       //停留时长
@property (nonatomic,strong)NSNumber   *login_limit;   //是否需要登录

//公告
@property (nonatomic,strong)NSNumber   *num;           //公告每天弹出数
@property (nonatomic, copy )NSString   *desc_info;     //描述
@property (nonatomic, copy )NSString   *btn_name;      //按钮名称

@end
