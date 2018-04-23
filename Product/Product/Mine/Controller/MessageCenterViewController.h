//
//  MessageCenterViewController.h
//  Product
//
//  Created by Xlink on 15/12/3.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef enum : NSUInteger {
    messageTypeDeviceWork,
    messageTypeDeviceShare,
    messageTypeMeasurementResult,
    messageTypeFaultMessage,
} messageType;

@interface MessageCenterViewController : BaseViewController

//显示消息的类型
@property (assign, nonatomic) messageType type;


@end
