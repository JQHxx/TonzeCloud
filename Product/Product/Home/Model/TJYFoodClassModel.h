//
//  TJYFoodClassModel.h
//  Product
//
//  Created by zhuqinlu on 2017/4/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//   食物分类列表模型 && 功效选择模型

#import <Foundation/Foundation.h>

@interface TJYFoodClassModel : NSObject

/// 添加时间
@property (nonatomic, strong )NSNumber  *add_time;
/// 编辑时间
@property (nonatomic, strong )NSNumber  *edit_time;
/// 食物id
@property (nonatomic,assign) NSInteger  id;
/// 图片id
@property (nonatomic, copy )NSString  *image_id;
/// 图片链接
@property (nonatomic, copy )NSString  *image_url;
/// 食物名称
@property (nonatomic, copy )NSString  *name;

@end
