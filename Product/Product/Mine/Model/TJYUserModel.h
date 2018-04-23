//
//  TJYUserModel.h
//  Product
//
//  Created by vision on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TJYUserModel : NSObject


@property (nonatomic, assign) NSInteger user_id;

@property (nonatomic, copy) NSString *user_token;

@property (nonatomic, assign) NSInteger sex;

@property (nonatomic, copy) NSString *mobile;

@property (nonatomic, copy) NSString *nick_name;

@property (nonatomic, copy) NSString *weight;

@property (nonatomic, copy) NSString *labour_intensity;

@property (nonatomic, copy) NSString *user_key;

@property (nonatomic, assign) NSInteger limited_time;

@property (nonatomic, copy) NSString *birthday;

@property (nonatomic, copy) NSString *height;

@property (nonatomic, copy) NSString *user_secret;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *photo;

@property (nonatomic, copy) NSString *token;

@property (nonatomic, assign) NSInteger age;


@end
