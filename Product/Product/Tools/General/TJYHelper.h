//
//  TJYHelper.h
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainDeviceInfo.h"

@interface TJYHelper : NSObject
singleton_interface(TJYHelper);

@property (nonatomic,assign)BOOL      isSetUserInfoSuccess;
@property (nonatomic,assign)BOOL      isReloadHome;         //更新首页
@property (nonatomic,assign)BOOL      isReloadArticle;      //更新文章
@property (nonatomic,assign)BOOL      isHistoryDiet;        //是否从历史纪录页面进入
@property (nonatomic,assign)BOOL      isSetDietTarget;      //设置目标摄入
@property (nonatomic,assign)BOOL      isAddFood;            //添加食物
@property (nonatomic,assign)BOOL      isDietReload;         //保存食物
@property (nonatomic,assign)BOOL      isHistoryDietReload;  //记录界面食物刷新
@property (nonatomic,assign)BOOL      isRecordDietReload;   //饮食界面食物刷新

@property (nonatomic,assign)BOOL      isRecordReload;       //刷新记录页面
@property (nonatomic,assign)BOOL      isWeightReload;       //保存体重
@property (nonatomic,assign)BOOL      isBloodReload;        //保存血压
@property (nonatomic,assign)BOOL      isSportsReload;       //添加运动
@property (nonatomic,assign)BOOL      isSportsHistoryReload;//刷新历史界面
@property (nonatomic,assign)BOOL      isSportsRecordReload; //刷新记录界面
@property (nonatomic,strong)NSArray   *laborInstensityArr;  //劳动强度
@property (nonatomic,strong)NSArray   *recommandDeviceArr;  //推荐设备列表
@property (nonatomic,strong)NSArray   *healthList;          //健康资讯题库
@property (nonatomic,strong)NSArray   *healthResult;        //健康咨询结果库

@property (nonatomic,assign)BOOL      isHealthScore;        //健康咨询刷新

@property (nonatomic,assign)BOOL      isLoginSuccess;       //登录成功
@property (nonatomic,assign)BOOL      isReloadUserInfo;     //重新获取用户信息
@property (nonatomic,assign)BOOL      isReloadDeviceList;   //重新获取用户列表
@property (nonatomic,assign)BOOL      isReloadLocalDevice;   //重新获取用户本地设备
@property (nonatomic,assign)BOOL      isRootWindowIn;

@property (nonatomic,assign)BOOL      isGotoWifiSet;        //跳转到系统设置wifi页
@property (nonatomic,assign)BOOL      isScaleDelete;        //删除体质秤

@property (nonatomic,assign)BOOL      isShowAnnouce;        //是否显示公告

@property (nonatomic,assign)BOOL      isSearchKeyboard;      //搜索键盘是否弹出
@property (nonatomic,assign)BOOL      isAddressManagerReload;//刷新地址列表
@property (nonatomic,assign)BOOL      isOrderListReload;     //刷新订单列表

@property (nonatomic,assign)BOOL      isAddressSelectedReload;  //选择收货地址地址刷新
@property (nonatomic,assign)BOOL      isOrderAddressReload;     //确认订单收货地址刷新

@property (nonatomic,assign)BOOL      isCartListReload;     //刷新购物车


@property (nonatomic,assign)BOOL      isPayOrderBack;       //支付订单返回

@property (nonatomic,strong)MainDeviceInfo *selectDevice;

/**
 * @brief  饮食
 * 判断当前时间是在哪个时间段（返回时间段名称）
 */
-(NSString *)getDietPeriodOfCurrentTime;

/**
 * @brief  饮食
 * 饮食时间段 英文转中文
 */
-(NSString *)getDietPeriodChNameWithPeriod:(NSString *)period;
/**
 * @brief  饮食
 * 饮食时间段 中文转英文
 */
-(NSString *)getDietPeriodEnNameWithPeriod:(NSString *)period;

/**
 *@bref 获取当前时间（年月日时分秒）
 */
-(NSString *)getCurrentDateTime;
/**
 *@bref 获取当前时间戳（毫秒为单位）
 */
-(NSString *)getNowTimeTimestamp;

/**
 *@bref 获取当天日期（年月日）
 */
-(NSString *)getCurrentDate;
/**
 *@bref 获取当前的年份
 */
- (NSString *)getCurrentYear;
/**
 *@bref 获取当前的月份
 */
- (NSString *)getCurrentMonth;
/**
 *  获取当月的天数
 * @years  年份
 * @Month  月份
*/
- (NSInteger)howManyDaysInThisYears:(NSInteger )years  month:(NSInteger)month;
/**
 *@bref 获取七天前日期（年月日）
 */
-(NSString *)getSexDayDate;
/**
 *@bref 获取之前日期（年月日）
 */
-(NSString *)getLastDayDate:(NSInteger)page;
/**
 *@bref 获取之前多少年的时间（年月日）
 */
-(NSString *)getLastYearDate:(NSInteger)page;
/**
 *@bref 获取days之前的日期(一周 6；20天 19)
 */
-(NSString *)getLastWeekDateWithDays:(NSInteger)days;
/**
 @brief 今天往前一段时间 如一周 days＝7，一个月days＝30  三个月 days＝90
 */
-(NSMutableArray *)getDateFromTodayWithDays:(NSInteger)days;
/**
 @brief 今天往前一段时间2 如一周 days＝7，一个月days＝30  三个月 days＝90
 */
-(NSMutableArray *)getStringDateFromTodayWithDays:(NSInteger)days;
/**
 @brief 某个时间点前多少天的日期 time:@"2016-04-05" 如一周 days＝7，一个月days＝30  三个月 days＝90
 */
- (NSMutableArray *)getDataFromTodayWithTime:(NSString *)time days:(NSInteger)days;
/**
 @brief 某个时间点前多少天的时间戳   time：1495382400 (时间戳 ) day= 1.2.4   
 */
- (NSString *)getAfterDayWithTime:(NSString *)time days:(NSInteger)days;
/**
 @brief  计算以当前日期为基准的前后3天天的日期，即一周日期值
 */
- (NSMutableArray *)getDataFromBeforeAndAfterDays;
// 获取当月所以日期日 (1.2.3....30)
- (NSMutableArray *)getMonthDaysWithYears:(NSInteger )years month:(NSInteger )month;
/**
 *@bref 将某个时间转化成 时间戳
 */
-(NSInteger)timeSwitchTimestamp:(NSString *)formatTime format:(NSString *)format;
/**
 *@bref 订单倒计时
 */
- (NSTimeInterval)getOrderCountdownWithCreationTime:(NSString *)timeString;

/**
 *@bref 时间戳转化为时间
 */
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString format:(NSString *)format;
/**
 *@bref 获取本周或上一周的周一和周末的时间
 */
- (NSDictionary *)getWeekTime:(NSInteger)index;

/**
 *  @bref  获取当前年龄
 */
-(NSInteger)getCurrentAgeWithBornDate:(NSString *)bornDate;
/***
* @bref  计算当前时间之后的天数对应的星期
*/
- (NSString *)featureWeekdayWithDate:(NSString *)featureDate;

/**
 *  计算2个日期相差天数
 *  startDate   起始日期
 *  endDate     截至日期
 */
-(NSInteger)daysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;

/// 获取当前是星期几
- (NSInteger)getNowWeekday;
/// 获取当前时间前后三天对应的星期几
- (NSArray *)getWeekdays;

/// 获取当前时间前一周对应星期几
- (NSArray *)getLastWeekdays;

    
/***
 * @bref  获取设备id
 */
- (NSInteger)loadDeviceID:(NSString *)str;
/***
 * @bref  获取最大时间
 */
- (NSMutableArray *)loadMaxTime:(NSArray *)timeArray;
/***
 * @bref  获取设备图片名称
 */
- (NSString *)loadDeviceImageView:(NSString *)deviceID;
/***
 * @bref  比较两个日期的大小
 */
- (NSInteger)compareDate:(NSString*)aDate withDate:(NSString*)bDate;
/**
 *
 *  获取设备的唯一标示uuid
 */
- (NSString *)deviceUUID;
/**
 *  判断当前是不是在使用九宫格输入
 */
-(BOOL)isNineKeyBoard:(NSString *)string;
/**
 *  限制emoji表情输入
 */
-(BOOL)strIsContainEmojiWithStr:(NSString*)str;
/**
 *  限制第三方键盘（常用的是搜狗键盘）的表情
 */
- (BOOL)hasEmoji:(NSString*)string;
/**
*  判断当前时间是否在时间段内 (忽略年月日)
*/
- (BOOL)judgeTimeByStartAndEnd:(NSString *)startTime withExpireTime:(NSString *)expireTime;

@end
