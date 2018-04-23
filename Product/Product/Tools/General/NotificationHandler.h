//
//  NotificationHandler.h
//  Product
//
//  Created by Xlink on 15/12/14.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

static  UILocalNotification *notification = nil;
@interface NotificationHandler : NSObject

+(instancetype)shareHendler;

- (void)OnStart:(NSNotification *)noti;

-(void)initXlinkLocalNotification;

-(void)configNotification:(NSString *)alertBody;

- (void)makeToastWithConfigNotification:(NSString *)alertBody;
//分享
-(void)refuseShare;

-(void)acceptShare;

-(void)setNextRemindNoti;

-(void)cancelAllNoti;

-(void)insertRemindRecord;

@end
