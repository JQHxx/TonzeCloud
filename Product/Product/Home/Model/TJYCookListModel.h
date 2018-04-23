//
//  TJYCookListModel.h
//  Product
//
//  Created by zhuqinlu on 2017/5/3.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TJYCookListModel : NSObject

/// 菜谱名称
@property (nonatomic, copy) NSString *name ;
/// 菜谱id
@property (nonatomic, assign) NSInteger cook_id ;
/// 阅读量
@property (nonatomic, assign) NSInteger reading_number ;
/// 点赞数
@property (nonatomic, assign) NSInteger like_number ;
/// 是否为云菜谱 1是云菜谱，2是普通菜谱
@property (nonatomic, assign) NSInteger is_yun ;
/// 摘要
@property (nonatomic, copy) NSString *abstract ;
/// 是否收藏
@property (nonatomic, assign) NSInteger is_collect;
/// 是否点赞（0未点赞，1已点赞）
@property (nonatomic, assign) NSInteger is_like;
/// 菜谱图片
@property (nonatomic, copy) NSString *image_id_cover ;
/// 小贴士
@property (nonatomic, copy) NSString *remarks;

@property (nonatomic, assign) NSInteger tag_id;

@end
