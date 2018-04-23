//
//  TJYMenuDetailsVC.h
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

@interface TJYMenuDetailsVC : BaseViewController
/// 点赞回调  islike -- 是否已点赞
@property (nonatomic, copy) void(^likeClickBlock)(BOOL islike);
/// 菜谱id
@property (nonatomic, assign) NSInteger menuid;
/// 是否收藏
@property (nonatomic, assign) NSInteger is_Collecton;

@property (nonatomic, assign) BOOL is_Yun;

@end
