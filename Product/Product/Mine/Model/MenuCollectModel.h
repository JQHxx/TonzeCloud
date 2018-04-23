//
//  MenuCollectModel.h
//  Product
//
//  Created by vision on 17/5/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuCollectModel : NSObject


@property (nonatomic, assign) NSInteger reading_number;

@property (nonatomic, copy) NSString *target_type;

@property (nonatomic, assign) NSInteger like_number;

@property (nonatomic, copy) NSString *image_url;

@property (nonatomic, copy) NSString *abstract;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger target_id;
/// 是否为云菜谱
@property (nonatomic, assign) BOOL  is_yun;

@end
