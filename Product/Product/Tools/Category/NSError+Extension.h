//
//  NSError+Extension.h
//  Product
//
//  Created by WuJiezhong on 16/5/25.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Extension)

+ (instancetype)errorWithDescription:(NSString *)description code:(NSInteger)code;

@end
