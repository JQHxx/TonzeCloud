//
//  HeziSDKAppLinksModel.h
//  ActivityBox
//
//  Created by Gibson on 17/1/24.
//  Copyright © 2017年 sunnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeziSDKAppLinksModel : NSObject
@property(nonatomic,strong)NSString *token;//活动 token
@property(nonatomic,strong)NSString *sharerId;//分享者 id
@property(nonatomic,strong)NSDictionary *customeParams;//自定义参数信息
@property(nonatomic,strong)NSString *invitation;//是否邀请有礼类型

@end
