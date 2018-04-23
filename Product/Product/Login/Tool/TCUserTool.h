//
//  TCUserTool.h
//  TonzeCloud
//
//  Created by vision on 17/3/31.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCUserTool : NSObject

singleton_interface(TCUserTool)

@property (nonatomic,strong)NSMutableDictionary *userDict;

-(void)insertValue:(id)value forKey:(NSString *)key;


@end
