//
//  SystemInfo.h
//  Scale
//
//  Created by Xlink on 15/11/12.
//  Copyright © 2015年 YiLai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemInfo : NSObject

+(NSDictionary *)GetSystemInfo;
+(NSString *)deviceIPAdress;
+(NSString*)getDeviceVersion;
+ (NSString *) localWiFiIPAddress;


#define MAXADDRS     32

extern char * if_names [ MAXADDRS ] ;
extern char * ip_names [ MAXADDRS ] ;
extern char * hw_addrs [ MAXADDRS ] ;
extern unsigned long ip_addrs [ MAXADDRS ] ;

// Function prototypes

void InitAddresses () ;
void FreeAddresses () ;
void GetIPAddresses () ;
void GetHWAddresses () ;


@end
