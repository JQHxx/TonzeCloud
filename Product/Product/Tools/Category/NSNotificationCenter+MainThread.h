//
//  NSNotificationCenter+MainThread.h
//  SmartLink
//
//  Created by xtmac on 29/1/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (MainThread)

-(void)postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject;

@end
