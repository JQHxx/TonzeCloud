//
//  NSError+Extension.m
//  Product
//
//  Created by WuJiezhong on 16/5/25.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "NSError+Extension.h"

@implementation NSError (Extension)


+ (instancetype)errorWithDescription:(NSString *)description code:(NSInteger)code {
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    [userInfo setObject:description forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"wjz" code:code userInfo:userInfo];
}

@end
