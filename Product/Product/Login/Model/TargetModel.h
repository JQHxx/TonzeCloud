//
//  TargetModel.h
//  Product
//
//  Created by vision on 17/5/11.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TargetModel : NSObject



@property (nonatomic, assign) NSInteger target_id;

@property (nonatomic, assign) BOOL isDefault;

@property (nonatomic, copy) NSString *brief;

@property (nonatomic, copy) NSString *target_name;

@property (nonatomic, copy) NSString *image_url;



@end
