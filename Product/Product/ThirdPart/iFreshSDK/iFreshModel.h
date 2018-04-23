//
//  iFreshModel.h
//  iFreshSDK
//
//  Created by zhang on 16/9/9.
//  Copyright © 2016年 taolei. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface iFreshModel : NSObject


// 蓝牙回调数值
@property (nonatomic, copy) NSString *value;



//(此属性SDK内部方法调用，使用SDK注意勿同名)
@property (nonatomic,copy) NSString *Unit;



/**
 * g转lb方法
 * weightvalue：传入的以g为单位的重量字符串
 */
- (NSString *)gTolb:(NSString *) weightValue;
/**
 * g转oz方法
 * weightvalue：传入的以g为单位的重量字符串
 */
- (NSString *)gTooz:(NSString *) weightVlaue;
/**
 * lb转g方法
 * weightvalue：传入的以lb为单位的重量字符串
 */
- (NSString *)lbTog:(NSString *) weightVlaue;
/**
 * oz转g方法
 * weightvalue：传入的以oz为单位的重量字符串
 */
- (NSString *)ozTog:(NSString *) weightValue;


@end
