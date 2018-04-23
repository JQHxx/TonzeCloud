//
//  HeziTrigger.h
//  ActivityBox
//
//  Created by ljcoder on 17/2/13.
//  Copyright © 2017年 sunnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeziShareModel.h"

///----------------------------------------------------
/// @name 触发活动代理
///----------------------------------------------------
@class HeziTrigger;

@protocol HeziTriggerActivePageDelegate <NSObject>

@optional

- (BOOL)heziTriggerWillOpenActivePage:(HeziTrigger *)heziSDK activityURL:(NSString *)url;
- (void)heziTriggerDidOpenActivePage:(HeziTrigger *)heziSDK;
- (void)heziTriggerDidCloseActivePage:(HeziTrigger *)heziSDK;
- (void)heziTirgger:(HeziTrigger *)trigger triggerError:(NSError *)error;
- (void)heziTrigger:(HeziTrigger *)heziSDK share:(HeziShareModel *)shareContent activePage:(UIView *)activePage;

@end


///----------------------------------------------------
/// @name 触发活动
///----------------------------------------------------
@interface HeziTrigger : UIView

/**
 设置触发埋点

 @param event 触发的事件，可使用预设的事件，也可已定义
 @param info 用户信息，收集当前用户信息，供核对后台指定触发条件使用。
 比如只有广州地区，女性用户才能触发本次活动，我们会根据此参数来确定当前用户是否符合后台指定要求，决定是否触发活动
 @param view 浮窗图标的super view
 @param rootController rootController决定活动页是从哪个页面跳转的，一般为self即可
 @param delegate 触发活动代理
 @return 当前HeziTrigger对象
 */
+ (instancetype)trigger:(NSString *)event
               userInfo:(NSDictionary *)info
         showIconInView:(UIView *)view
         rootController:(UIViewController *)rootController
               delegate:(id<HeziTriggerActivePageDelegate>)delegate;


/**
 设置触发埋点
 
 @param event 触发的事件，可使用预设的事件，也可已定义
 @param info 用户信息，收集当前用户信息，供核对后台指定触发条件使用。
 比如只有广州地区，女性用户才能触发本次活动，我们会根据此参数来确定当前用户是否符合后台指定要求，决定是否触发活动
 @param view 浮窗图标的super view
 @param rootController rootController决定活动页是从哪个页面跳转的，一般为self即可
 @param uiEdgeInsets 设置图标的上下左右的偏移距离
 @param delegate 触发活动代理
 @return 当前HeziTrigger对象
 */
+ (instancetype)trigger:(NSString *)event
               userInfo:(NSDictionary *)info
         showIconInView:(UIView *)view
         rootController:(UIViewController *)rootController
           uiEdgeInsets:(UIEdgeInsets)edgeInsets
               delegate:(id<HeziTriggerActivePageDelegate>)delegate;

// ====================小图图标动效设置===========================
// 是否自动变为半透明,默认NO
@property (assign, nonatomic) BOOL shouldTranslucent;

// 是否自动靠边，默认NO
@property (assign, nonatomic) BOOL shouldBeside;

// 是否隐藏半个图标, 默认NO
@property (assign, nonatomic) BOOL shouldHidden;

/**
 移除浮窗
 */
- (void)dismiss;

@end




