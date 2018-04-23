//
//  TJYArticleModel.h
//  Product
//
//  Created by zhuqinlu on 2017/5/2.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TJYArticleModel : NSObject

@property (nonatomic,assign)NSInteger  id;

@property (nonatomic,assign)NSInteger  target_id;

@property (nonatomic, copy )NSString  *add_time;

@property (nonatomic, copy )NSString  *edit_time;

@property (nonatomic, copy )NSString  *sort;

@property (nonatomic, copy )NSString  *is_used;

@property (nonatomic, copy )NSString  *title;

@property (nonatomic, copy)NSString  *datatime;

@property (nonatomic, assign)NSInteger reading_number;

@property (nonatomic, copy)NSString  *content;

@property (nonatomic, copy)NSString  *classification_id;

@property (nonatomic, copy)NSString  *image_id;

@property (nonatomic, copy)NSString  *classification_name;

@property (nonatomic, copy)NSString  *image_url;

@property (nonatomic, copy)NSString  *type_name;

@property (nonatomic, copy) NSString *add_date ;

@property (nonatomic, assign) NSInteger article_management_id;
/// 是否收藏
@property (nonatomic, assign) BOOL  is_collection;

@end
