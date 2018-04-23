//
//  NSData+Extension.h
//  JinAnSecurity
//
//  Created by AllenKwok on 15/10/17.
//  Copyright © 2015年 JinAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Extension)
/**
 *  NSdata转为Byte数组
 */
+ (NSArray *)dataToByte:(NSData *)data;

/**
 *  十六进制表示的字符串转为NSData
 */
+ (NSData*)stringToData:(NSString *)hexString;

/**
 *  十六进制字符串转NSData
 *
 *  @param hexString 如@"FF1A0B7B"
 *
 *  @return NSData对象
 */
+ (instancetype)dataWithHexString:(NSString *)hexString;

- (NSString *)hexString;

@end
