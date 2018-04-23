//
//  TCBannerModel.h
//  TonzeCloud
//
//  Created by vision on 17/3/21.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCBannerModel : NSObject

@property (nonatomic,assign)NSInteger  type;
@property (nonatomic,assign)NSInteger  id;
@property (nonatomic, copy )NSString   *name;
@property (nonatomic, copy )NSString   *info;
@property (nonatomic, copy )NSString   *brief;
@property (nonatomic, copy )NSString   *image_url;

//广告页
@property (nonatomic,strong)NSNumber   *minutes;       //停留时长
@property (nonatomic,strong)NSNumber   *login_limit;   //是否需要登录

//公告
@property (nonatomic,strong)NSNumber   *num;           //公告每天弹出数
@property (nonatomic, copy )NSString   *desc_info;     //描述
@property (nonatomic, copy )NSString   *btn_name;      //按钮名称


@end
