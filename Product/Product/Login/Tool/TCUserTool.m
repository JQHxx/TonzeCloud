//
//  TCUserTool.m
//  TonzeCloud
//
//  Created by vision on 17/3/31.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCUserTool.h"

@implementation TCUserTool

singleton_implementation(TCUserTool)


-(void)insertValue:(id)value forKey:(NSString *)key{
    if (self.userDict==nil) {
        self.userDict=[[NSMutableDictionary alloc] init];
    }
    [self.userDict setValue:value forKey:key];
}

@end
