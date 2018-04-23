//
//  NSNotificationCenter+MainThread.m
//  SmartLink
//
//  Created by xtmac on 29/1/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "NSNotificationCenter+MainThread.h"

@implementation NSNotificationCenter (MainThread)

-(void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject{
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc] init];
    [parameter setObject:aName forKey:@"aName"];
    if (anObject) {
        [parameter setObject:anObject forKey:@"anObject"];
    }
    [self performSelectorOnMainThread:@selector(callPostNotificationOnMainThreadName:) withObject:parameter waitUntilDone:NO];
}

-(void)callPostNotificationOnMainThreadName:(NSDictionary*)parameter{
    NSString *aName = [parameter objectForKey:@"aName"];
    id anObject = [parameter objectForKey:@"anObject"];
    [self postNotificationName:aName object:anObject];
}

@end
