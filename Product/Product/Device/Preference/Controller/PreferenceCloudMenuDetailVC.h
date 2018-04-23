//
//  PreferenceCloudMenuDetailVC.h
//  Product
//
//  Created by 肖栋 on 17/5/11.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

@interface PreferenceCloudMenuDetailVC : BaseViewController
/// 点赞回调  islike -- 是否已点赞
@property (nonatomic, copy) void(^likeClickBlock)(BOOL islike);
/// 菜谱id
@property (nonatomic, assign) NSInteger menuid;

@property (nonatomic, strong) DeviceModel *model;
@end
