//
//  NotiModel.h
//  Product
//
//  Created by Xlink on 15/12/7.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>


enum{
    AUTH_DEVICE=0,  //授权设备
    COMPLETE=1,     //操作完成
    ERROR=2,        //报警
    REMOVE_AUTH=3,  //解除授权
}TYPE_NOTI;

@interface NotiModel : NSObject

/**
 *  时间
 */
@property (nonatomic,copy)NSString *time;

/**
 *  title 用户名/设备名
*/
@property (nonatomic)NSString * notiTitle;
/**
 *  state
 */
@property (nonatomic,copy)NSString *notiState;
/**
 *  state
 */
@property (nonatomic,copy)NSString *notiType;
/**
 *  设备ID
 */
@property (nonatomic,copy)NSString *deviceID;
/**
 *  设备
 */
@property (nonatomic,copy)NSString *deviceName;

/**
 *  工作类型
 */
@property (nonatomic,copy)NSString *deviceType;

/**
 *  分享码
 */
@property (nonatomic,copy)NSString *invite_code;

@property (nonatomic,copy)NSNumber *from_id;

@end
