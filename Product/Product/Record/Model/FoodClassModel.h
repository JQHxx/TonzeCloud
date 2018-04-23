//
//  FoodClassModel.h
//  Product
//
//  Created by 肖栋 on 17/4/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoodClassModel : NSObject

@property (nonatomic, copy )NSString  *add_time;
@property (nonatomic, copy )NSString  *edit_time;
@property (nonatomic,strong)NSNumber  *id;
@property (nonatomic, copy )NSString  *image_id;
@property (nonatomic, copy )NSString  *image_url;
@property (nonatomic, copy )NSString  *name;

@end
