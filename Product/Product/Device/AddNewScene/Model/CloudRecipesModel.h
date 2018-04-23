//
//  CloudRecipesModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudRecipesModel : NSObject

///摘要
@property (nonatomic, copy) NSString *abstract ;
/// 封面图
@property (nonatomic, copy) NSString *image_id_cover;
/// 1为云菜谱，2为普通菜谱
@property (nonatomic, assign) NSInteger is_yun ;
/// 点赞数
@property (nonatomic, assign) NSInteger like_number ;
/// 菜谱名
@property (nonatomic, copy) NSString *name ;
/// 阅读量
@property (nonatomic, assign) NSInteger reading_number ;
/// 菜谱id
@property (nonatomic, assign) NSInteger cook_id;
/// 是否点赞
@property (nonatomic, assign) BOOL  is_like;
/// 设备指令
@property (nonatomic, copy) NSString *code;
/// 功效（降压粥，降压汤）
@property (nonatomic, assign) NSInteger  tag_id;

@end
