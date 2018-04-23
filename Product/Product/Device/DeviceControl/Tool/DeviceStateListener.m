//
//  DeviceAliveChecker.m
//  Product
//
//  Created by WuJiezhong on 16/6/16.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DeviceStateListener.h"
#import "DeviceStateCheckService.h"


@interface DeviceStateListener()

///mac对应设备
@property (nonatomic, strong) NSMutableDictionary *macToDeviceDict;

///mac对应监听器列表
//@property (nonatomic, strong) NSMutableDictionary *macToObseversDict;

///mac对应检查服务
@property (nonatomic, strong) NSMutableDictionary *macToServiceDict;

@property (nonatomic, strong) NSMutableDictionary *macToTagsDict;
//
@property (nonatomic, strong) NSMutableDictionary *tagToObseverDict;


@end

///检测设备是否离线的类
@implementation DeviceStateListener


+ (instancetype)sharedListener {
    static DeviceStateListener *listener;
    if (!listener) {
        listener = [[DeviceStateListener alloc] init];
        listener.macToDeviceDict  = @{}.mutableCopy;
        listener.macToTagsDict    = @{}.mutableCopy;
        listener.tagToObseverDict = @{}.mutableCopy;
        listener.macToServiceDict = @{}.mutableCopy;
    }
    return listener;
}

- (NSNumber *)listenForDevice:(DeviceModel *)device stateChangeHandler:(ListenerStateChanged)handler {
    self.macToDeviceDict[device.mac] = device;
    NSNumber *tag = [self tag];
    
    self.tagToObseverDict[tag] = handler;
    
    ///监听器回调
    NSMutableArray *tags = self.macToTagsDict[device.mac];
    if(!tags) {
        tags = @[].mutableCopy;
    }
    [tags addObject:tag];
    self.macToTagsDict[device.mac] = tags;
    
    //服务
    DeviceStateCheckService *service = self.macToServiceDict[device.mac];
    if(!service) { //服务不存在
        service = [[DeviceStateCheckService alloc] initWithDevice:device];
        self.macToServiceDict[device.mac] = service;
        __block __typeof(self) weakSelf = self;
        service.handler = ^(DeviceModel *device, NSInteger state, NSError *error) {
            NSArray *tags = weakSelf.macToTagsDict[device.mac];
            
            for(NSNumber *tag in tags) {
                ListenerStateChanged listener = weakSelf.tagToObseverDict[tag];
                if (listener && !listener(device, state, error)) {
                    //释放监听器
                    [weakSelf.tagToObseverDict removeObjectForKey:tag];
                }
            }
        };
    }
    
    [service start];    //启动服务
    
    return tag;
}

- (void)removeListener:(NSNumber *)tag {
    for (NSString *mac in self.macToTagsDict.allKeys) {
        for (NSNumber *curTag in self.macToTagsDict.mutableCopy[mac]) {
            if ([tag unsignedIntegerValue] == [curTag unsignedIntegerValue]) {
                [self.macToTagsDict[mac] removeObject:curTag];
                [self.tagToObseverDict removeObjectForKey:curTag];
                NSArray *tags = self.macToTagsDict[mac];
                if (tags.count == 0) {
                    [self.macToServiceDict[mac] stop];
                }
                return;
            }
        }
    }
}

- (void)removeDevice:(DeviceModel *)device {
    DeviceStateCheckService *service = self.macToServiceDict[device.mac];
    if (service) {
        [service stop];
        for (NSNumber *tag in self.macToTagsDict[device.mac]) {
            [self.tagToObseverDict removeObjectForKey:tag];
        }
        [self.macToTagsDict removeObjectForKey:device.mac];
        [self.macToServiceDict removeObjectForKey:device.mac];
        [self.macToDeviceDict removeObjectForKey:device.mac];
    }
}

- (void)removeAllDeviceStateCheckService{
    for (NSArray *tags in _macToTagsDict.allValues) {
        for (NSNumber *num in tags) {
            [self removeListener:num];
        }
    }

}

- (NSNumber *)tag {
    static NSUInteger _tag = 0;
    if (_tag == UINTMAX_MAX) {
        _tag = 0;
    }
    return @(_tag++);
}

@end
