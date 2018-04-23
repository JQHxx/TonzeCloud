//
//  NSData+Extension.m
//  JinAnSecurity
//
//  Created by AllenKwok on 15/10/17.
//  Copyright © 2015年 JinAn. All rights reserved.
//

#import "NSData+Extension.h"

@implementation NSData (Extension)

+ (NSArray *)dataToByte:(NSData *)data{
    
    Byte *byte = (Byte *)[data bytes];
    
    NSMutableArray *mArr = [NSMutableArray array];
    
    for (int i = 0; i<data.length; i++) {
        
        [mArr addObject:@(byte[i])];
        
    }
    
    return mArr;
}

+ (NSData*)stringToData:(NSString *)hexString {
    
    NSUInteger len = hexString.length / 2;
    const char *hexCode = [hexString UTF8String];
    char * bytes = (char *)malloc(len);
    
    char *pos = (char *)hexCode;
    for (NSUInteger i = 0; i < hexString.length / 2; i++) {
        sscanf(pos, "%2hhx", &bytes[i]);
        pos += 2 * sizeof(char);
    }
    
    NSData * data = [[NSData alloc] initWithBytes:bytes length:len];
    
    free(bytes);
    return data;
}

+ (instancetype)dataWithHexString:(NSString *)hexString {
    NSString *strWithoutSpace = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [NSData stringToData:strWithoutSpace];
}

- (NSString *)hexString {
    NSMutableString *string = @"".mutableCopy;
    const Byte *bytes = [self bytes];
    for (int i=0; i<self.length; i++) {
        [string appendFormat:@"%02X ", bytes[i]];
    }
    return string;
}

@end
