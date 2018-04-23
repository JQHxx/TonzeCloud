//
//  MainDeviceInfo.m
//  JinAnSecurity
//
//  Created by AllenKwok on 15/10/20.
//  Copyright © 2015年 JinAn. All rights reserved.
//

#import "MainDeviceInfo.h"

@implementation MainDeviceInfo

- (void)setProductID:(NSString *)productID{
    
    _productID = productID;
    
    _joinDate = [NSUserDefaultInfos getCurrentDate];
}

@end
