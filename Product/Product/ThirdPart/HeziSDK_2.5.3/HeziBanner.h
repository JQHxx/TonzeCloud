//
//  HeziBanner.h
//  ActivityBox
//
//  Created by ljcoder on 16/9/6.
//  Copyright © 2016年 sunnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeziShareModel.h"

typedef NS_ENUM(NSUInteger, HeziBannerType) {
    HeziBannerTypeDefault,
    HeziBannerTypeLaunch,// 启动图
};

@class HeziBanner;

@protocol HeziBannerOpenActivePageDelegate <NSObject>

@optional

/**
 请求数据，是否有错误回调
 @param heziBanner banner控件
 @param error 错误信息
 */
- (void)heziBanner:(HeziBanner *)heziBanner loadDataError:(NSError *)error;

/**
 点击Banner后，将要打开活动页，可以在此拦截点击事件

 @param heziBanner 当前Banner组件
 @param url 活动地址
 @param index 点击的下标，点击的是哪张图
 @return 返回YES，会继续打开活动页，返回NO，则会拦截打开活动页的动作
 */
- (BOOL)heziBannerWillOpenActivePage:(HeziBanner *)heziBanner activityURL:(NSString *)url didSelectedIndex:(NSInteger)index;

/**
 打开活动页后的回调

 @param heziBanner 当前Banner组件
 */
- (void)heziBannerDidOpenActivePage:(HeziBanner *)heziBanner;


/**
 打开活动页失败，活动地址为空时执行此回调

 @param heziBanner 当前Banner组件
 @param error 错误信息
 */
- (void)heziBanner:(HeziBanner *)heziBanner didOpenActivePageError:(NSError *)error;


/**
 关闭活动页的回调

 @param heziBanner 当前Banner组件
 */
- (void)heziBannerDidCloseActivePage:(HeziBanner *)heziBanner;


/**
 分享回调，会返回分享信息，具体分享的实现需要开发者自己实现

 @param heziBanner 当前Banner组件
 @param shareContent 分享信息，包括标题，分享图标，活动地址等
 @param activePage 活动视图控件
 */
- (void)heziBanner:(HeziBanner *)heziBanner share:(HeziShareModel *)shareContent activePage:(UIView *)activePage;

@end

@interface HeziBanner : UIView

/**
 *  初始化Banner
 *
 *  @param positionKey  必须，位置key，后台获取
 
 *  @param properties 属性参数 （ username 必须，APP当前操作用户，sex 可选，用户性别信息，mobile 可选，用户手机号码，nickname 可选，用户昵称，province 可选，用户所在省份，city 可选，用户所在城市，points 可选，用户当前积分）
 *  @param type Banner类型，分为默认类型和启动图类型，启动图类型需要设置自动消失时间。
 */
- (instancetype)initWithPositionKey:(NSString *)positionKey properties:(NSDictionary *)properties type:(HeziBannerType)type;


/**
 当模式为启动图时，设置启动图消失时间
 */
@property (assign, nonatomic) NSTimeInterval dismissTimeInterval;

/**
 *  设置banner positionKey, 使用其它init方法初始化后使用这个方法，在tableViewCell里面使用
 *
 *  @param positionKey  必须，位置key，后台获取
 
 *  @param properties 属性参数 （ username 必须，APP当前操作用户，sex 可选，用户性别信息，mobile 可选，用户手机号码，nickname 可选，用户昵称，province 可选，用户所在省份，city 可选，用户所在城市，points 可选，用户当前积分）
 */
- (void)setPositionKey:(NSString *)positionKey properties:(NSDictionary *)properties;

/**
 代理，点击事件和webView关闭代理
 */
@property (weak, nonatomic) id<HeziBannerOpenActivePageDelegate> delegate;

/**
 *  设置自动滚动和滚动时间
 *
 *  @param autoScroll 是否滚动
 *  @param duration   滚动间隔时间
 */
- (void)autoScroll:(BOOL)autoScroll duration:(CGFloat)duration;


/**
 设置默认图和显示模式

 @param placeholder  默认图
 @param contentMode 显示模式
 */
- (void)setPlaceholder:(UIImage *)placeholder model:(UIViewContentMode)contentMode;

@property (strong, nonatomic, readonly) UIPageControl *pageControl;

- (void)share:(void(^)(HeziShareModel *shareContent))shareBlock;

@end
