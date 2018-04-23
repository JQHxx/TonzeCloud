//
//  NotiModel.m
//  Product
//
//  Created by Xlink on 15/12/7.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "NotiModel.h"

@implementation NotiModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[NotiModel class]]) {
        return NO;
    }
    
    NotiModel *new = (NotiModel *)object;
    
    return [self.time isEqualToString:new.time] &&
    [self.deviceName isEqualToString:new.deviceName] &&
    [self.notiState isEqualToString:new.notiState] &&
    [self.deviceType isEqualToString:new.deviceType];
}

@end
