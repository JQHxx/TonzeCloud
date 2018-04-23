//
//  ArticleclassModel.h
//  Product
//
//  Created by zhuqinlu on 2017/5/2.
//  Copyright © 2017年 TianJi. All rights reserved.
//  文章分类列表

#import <Foundation/Foundation.h>

@interface TJYArticleclassModel : NSObject

/// 分类id
@property (nonatomic, strong) NSNumber *article_classification_id;

/// 文字分类名称
@property (nonatomic, copy) NSString *name ;

@end
