//
//  TJYHelper.m
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYHelper.h"

@implementation TJYHelper

singleton_implementation(TJYHelper);

-(void)setIsLoginSuccess:(BOOL)isLoginSuccess{
    _isLoginSuccess=isLoginSuccess;
    if (isLoginSuccess) {
        self.isSportsReload=self.isWeightReload=self.isBloodReload=self.isReloadUserInfo=self.isReloadHome=self.isReloadDeviceList=self.isRecordReload=YES;
    }
}

-(void)setIsSetUserInfoSuccess:(BOOL)isSetUserInfoSuccess{
    _isSetUserInfoSuccess=isSetUserInfoSuccess;
    if (isSetUserInfoSuccess) {
        self.isReloadHome=self.isRecordReload=self.isReloadDeviceList=self.isReloadUserInfo=YES;
    }
}

-(void)setIsAddressManagerReload:(BOOL)isAddressManagerReload{
    _isAddressManagerReload=isAddressManagerReload;
    if (isAddressManagerReload) {
        self.isAddressSelectedReload=YES;
    }
}

-(void)setIsAddressSelectedReload:(BOOL)isAddressSelectedReload{
    _isAddressSelectedReload=isAddressSelectedReload;
    if (isAddressSelectedReload) {
        self.isOrderAddressReload=YES;
    }
}


#pragma mark 劳动强度
-(NSArray *)laborInstensityArr{
    return @[@{@"title":@"休息状态",@"content":@"卧床等"},
             @{@"title":@"轻体力劳动",@"content":@"办公室职员、教师、售货员等静态生活方式的人士"},
             @{@"title":@"中体力劳动",@"content":@"学生、司机、家庭主妇等站着或走着工作的人士"},
             @{@"title":@"重体力劳动",@"content":@"建筑工人、林业工人、农民、运动员等以体力工作为主的人士"}];
}

#pragma mark 推荐设备列表
-(NSArray *)recommandDeviceArr{
      return @[ @{@"name":@"云智能隔水炖16AIG",@"productID":WATER_COOKER_16AIG_PRODUCT_ID,@"image":@"equ_16a220",@"summary":@"\t云智能全自动隔水炖锅，1.6L容量，满足2人用量；隔水煲炖，内胆陶瓷烧制，一锅三胆；APP远程操控，72种养身食谱选择，随时随地一键预约；300W节能功率，24小时恒温，带来多重安全保护。专属降压粥、降压汤功能，高血压患者的食疗知音！",@"mainImage":@"main16AIG.jpg",@"product_id":@"260"},
              @{@"name":@"体质健康分析仪",@"productID":SCALE_PRODUCT_ID,@"image":@"equ_h_tzy",@"summary":@"\t身体质量数据，精准到每克体内含水量；隐藏式LED显示屏，节能省电；284㎜²超大秤面，25mm纤薄机身，防滑防侧翻，舒适感十足。APP云智能操控，无缝对接蓝牙4.0以上版本，提供云数据存储，自动生成每日数据曲线，量身定制个人营养膳食运动方案，塑造完美身材不再受困。",@"mainImage":@"equ_tzy_banner",@"product_id":@"177"},
              @{@"name":@"云智能私享壶",@"productID":CLOUD_KETTLE_PRODUCT_ID,@"image":@"equ_sxh220",@"summary":@"\t全自动加厚玻璃养身壶电热烧水煮咖啡煮花0.7L。Wifi智能连接，食谱推荐，自动控温，偏好功能双重操控。精心描绘，壶中天地。私享生活划破天际，邀您共饮一壶健康。",@"mainImage":@"ic_device_sxh",@"product_id":@"186"},
              @{@"name":@"云智能隔水炖",@"productID":WATER_COOKER_PRODUCT_ID,@"image":@"equ_gsd",@"summary":@"\t智能全自动隔水炖锅BB煮粥燕窝煲汤电炖蛊。智能养身食谱，APP远程操控，煮炖模式，智能控温，24小时预约。你还在用手机在拍美食照吗？机智的人已经学会用手机烹饪营养健康美食了，“天际云健康”技术用科技开启轻奢生活。",@"mainImage":@"ic_device_gsd",@"product_id":@"258"},
              @{@"name":@"云智能IH电饭煲",@"productID":ELECTRIC_COOKER_PRODUCT_ID,@"image":@"equ_dfb",@"summary":@"\t智能全自动家用IH电饭煲4L容量。APP远程操控，多模式选择，专业养身食谱，智能预约。随时发号施令，随时随地做美食，让烹饪变成一种享受。",@"mainImage":@"ic_device_dfb",@"product_id":@"191"},
              @{@"name":@"云智能自动烹饪锅",@"productID":COOKFOOD_COOKER_PRODUCT_ID,@"image":@"equ_prg220",@"summary":@"\t云智能自动烹饪锅，3.0L额定容量，食品级304不锈钢锅胆，自动炒菜，防糊防溢；智能控温、无烟少油；自动模拟厨师手法火候，12项自动烹饪设置；APP远程连接，海量健康食谱任你选。不会做饭怎么办？一锅包办，让你瞬间变健康大厨。",@"mainImage":@"mainCOOKER.jpg",@"product_id":@"259"},
              @{@"name":@"云智能电炖锅",@"productID":CLOUD_COOKER_PRODUCT_ID,@"image":@"equ_ddg",@"summary":@"\t智能全自动陶瓷煲汤电炖锅家用煮熬粥锅4L。偏好功能，智能养身食谱，APP远程操控，智能控温，多功能预约。联网wifi智能生活时时享，上班，逛街购物，照顾小孩，健身休闲，朋友聚会，加班开会。",@"mainImage":@"ic_device_ddg",@"product_id":@"189"},
             @{@"name":@"蓝牙智能血压计",@"productID":CLINK_BPM_PRODUCT_ID,@"image":@"equ_h_xyj",@"summary":@"\t超大液晶屏显示血压脉搏数据，精准到±3mmHg（0.4kpa）的误差，存储容量超前，自动记忆储存双组90次测量值，建立多人档案。专业固定臂带，可测上臂周长20-30cm，5分钟内无操作自动关机，省电高效。蓝牙连接，检测数据云存储，APP智能分析，健康问题看得见。",@"mainImage":@"equ_xyj_banner678",@"product_id":@"176"}];
}

#pragma mark 饮食时间段 英文文转中文
-(NSString *)getDietPeriodChNameWithPeriod:(NSString *)period{
    NSString *periodCh=nil;
    if ([period isEqualToString:@"breakfast"]) {
        periodCh=@"早餐";
    }else if ([period isEqualToString:@"lunch"]){
        periodCh=@"午餐";
    }else if ([period isEqualToString:@"dinner"]){
        periodCh=@"晚餐";
    }else if ([period isEqualToString:@"supper"]){
        periodCh=@"加餐";
    }else{
        periodCh=@"";
    }
    return periodCh;
}
#pragma mark 饮食时间段 中文转英文
-(NSString *)getDietPeriodEnNameWithPeriod:(NSString *)period{
    NSString *periodEn=nil;
    if ([period isEqualToString:@"早餐"]) {
        periodEn=@"breakfast";
    }else if ([period isEqualToString:@"午餐"]){
        periodEn=@"lunch";
    }else if ([period isEqualToString:@"晚餐"]){
        periodEn=@"dinner";
    }else if ([period isEqualToString:@"加餐"]){
        periodEn=@"supper";
    }else{
        periodEn=@"";
    }
    return periodEn;
}
#pragma mark 饮食 判断当前时间是在哪个时间段（返回时间段名称）
-(NSString *)getDietPeriodOfCurrentTime{
    NSString *periodStr=nil;
    NSDate *currentDate = [NSDate date];
    if ([currentDate compare:[self getCustomDateWithHour:0]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:9]]==NSOrderedAscending){
        periodStr=@"早餐";
    }else if ([currentDate compare:[self getCustomDateWithHour:11]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:14]]==NSOrderedAscending){
        periodStr=@"午餐";
    }else if ([currentDate compare:[self getCustomDateWithHour:17]]==NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:20]]==NSOrderedAscending){
        periodStr=@"晚餐";
    }else{
        periodStr=@"加餐";
    }
    return periodStr;
}
#pragma mark  获取当前时间（年月日时分秒）
-(NSString *)getCurrentDateTime{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}
#pragma mark  获取当前时间戳（毫秒为单位）
-(NSString *)getNowTimeTimestamp{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}
#pragma mark  获取当天日期（年月日）
-(NSString *)getCurrentDate{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}
#pragma mark  获取当前年份
- (NSString *)getCurrentYear{
    NSDate *date =[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    NSString *currentMonth=[formatter stringFromDate:date];
    return currentMonth;
}
#pragma mark  获取当前月份
-(NSString *)getCurrentMonth{
    NSDate *date =[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM"];
    NSString *currentMonth=[formatter stringFromDate:date];
    return currentMonth;
}
#pragma mark -- 获取当月的天数
- (NSInteger)howManyDaysInThisYears:(NSInteger )years  month:(NSInteger)month{
        NSInteger year = years;
        if((month == 1)||(month == 3)||(month == 5)||(month == 7)||(month == 8)||(month == 10)||(month == 12))
            return 31 ;
        if((month == 4)||(month == 6)||(month == 9)||(month == 11))
            return 30;
        if((year%4 == 1)||(year%4 == 2)||(year%4 == 3))
        {
            return 28;
        }
        if(year%400 == 0)
            return 29;
        if(year%100 == 0)
            return 28;
        return 29;
}

#pragma mark  获取20天前日期（年月日）
-(NSString *)getSexDayDate{
    NSTimeInterval secondsPerDay = -19 * 24*60*60;
    NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormatter stringFromDate:curDate];
    return dateStr;
}
#pragma mark -- 获取之前日期（年月日）

-(NSString *)getLastDayDate:(NSInteger)page{
    NSTimeInterval secondsPerDay = -page* 24*60*60*365;
    NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormatter stringFromDate:curDate];
    return dateStr;
}
#pragma mark -- 获取年份时间（年月日）
-(NSString *)getLastYearDate:(NSInteger)page{
    NSTimeInterval secondsPerDay = -page* 24*60*60*365;
    NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormatter stringFromDate:curDate];
    return dateStr;
}


#pragma mark 获取days之前的日期(一周 6；20天 19)
-(NSString *)getLastWeekDateWithDays:(NSInteger)days{
    NSTimeInterval secondsPerDay = -days * 24*60*60;
    NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormatter stringFromDate:curDate];
    return dateStr;
}
#pragma mark 今天往前一段时间 如一周 days＝7，一个月days＝30
-(NSMutableArray *)getDateFromTodayWithDays:(NSInteger)days{
    NSMutableArray *dateArr = [[NSMutableArray alloc] init];
    for (NSInteger i = days-1; i >=0; i --) {
        //从现在开始的24小时
        NSTimeInterval secondsPerDay = -i * 24*60*60;
        NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"M/d"];
        NSString *dateStr = [dateFormatter stringFromDate:curDate];
        [dateArr addObject:dateStr];
    }
    return dateArr;
}

- (NSMutableArray *)getDataFromBeforeAndAfterDays{
    
    NSMutableArray *dateArr = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 3; i >=0; i --) {
        //从现在开始的24小时
        NSTimeInterval secondsPerDay = -i * 24*60*60;
        NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d"];
        NSString *dateStr = [dateFormatter stringFromDate:curDate];
        [dateArr addObject:dateStr];
    }
    
    for (NSInteger i =1; i <= 3; i++) {
        //从现在开始的24小时
        NSTimeInterval secondsPerDay = i * 24*60*60;
        NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d"];
        NSString *dateStr = [dateFormatter stringFromDate:curDate];
        [dateArr addObject:dateStr];
    }
    return dateArr;
}
#pragma mark --- 获取当月所有日期天数值
- (NSMutableArray *)getMonthDaysWithYears:(NSInteger )years month:(NSInteger )month{
    NSMutableArray *monthArray = [NSMutableArray array];
    NSInteger monthDays = [[TJYHelper sharedTJYHelper]howManyDaysInThisYears:years month:month];
    for (NSInteger i = 1; i < monthDays+1; i++) {
        [monthArray addObject:@(i)];
    }
    return monthArray;
}

#pragma mark -- 某个时间点前多少天的日期
- (NSMutableArray *)getDataFromTodayWithTime:(NSString *)time days:(NSInteger)days{
    NSMutableArray *dateArr = [[NSMutableArray alloc] init];
    for (NSInteger i = days-1; i >=0; i --) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *myDate = [dateFormatter dateFromString:time];
        NSTimeInterval secondsPerDay = -i * 24*60*60;
        NSDate *newDate = [myDate dateByAddingTimeInterval:secondsPerDay];
        NSString *dateStr = [dateFormatter stringFromDate:newDate];
        NSString *data = [dateStr substringFromIndex:8];
        [dateArr addObject:data];
    }
    return dateArr;
}

- (NSString *)getAfterDayWithTime:(NSString *)time days:(NSInteger)days{
    if (days !=0) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSDate *myDate = [dateFormatter dateFromString:time];
        NSTimeInterval secondsPerDay = days * 24*60*60;
        NSDate *newDate = [myDate dateByAddingTimeInterval:secondsPerDay];
        NSString *dateStr = [dateFormatter stringFromDate:newDate];
        
        return dateStr;
    }else{
        return time;
    }
}

#pragma mark 今天往前一段时间2 如一周 days＝7，一个月days＝30
-(NSMutableArray *)getStringDateFromTodayWithDays:(NSInteger)days{
    NSMutableArray *dateArr = [[NSMutableArray alloc] init];
    for (NSInteger i = days-1; i >=0; i --) {
        //从现在开始的24小时
        NSTimeInterval secondsPerDay = -i * 24*60*60;
        NSDate *curDate = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd"];
        NSString *dateStr = [dateFormatter stringFromDate:curDate];
        [dateArr addObject:dateStr];
    }
    return dateArr;
}
#pragma mark 将某个时间转化成 时间戳
-(NSInteger)timeSwitchTimestamp:(NSString *)formatTime format:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime];    //将字符串按formatter转成nsdate
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];     //时间转时间戳的方法
    return timeSp;
}

#pragma mark ====== 订单倒计时 =======
- (NSTimeInterval)getOrderCountdownWithCreationTime:(NSString *)timeString{
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *data = [self timeWithTimeIntervalString:timeString format:@"yyyy-MM-dd HH:mm:ss"];
    // 截止时间date格式
    NSDate  *expireDate = [formater dateFromString:data];
    NSDate  *nowDate = [NSDate date];
    // 当前时间字符串格式
    NSString *nowDateStr = [formater stringFromDate:nowDate];
    // 当前时间date格式
    nowDate = [formater dateFromString:nowDateStr];
    NSTimeInterval maxTime = 120 * 60;
    NSTimeInterval timeInterval = maxTime - [nowDate timeIntervalSinceDate:expireDate];
    return timeInterval;
}

#pragma mark 时间戳转化为时间
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString format:(NSString *)format
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString integerValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

#pragma mark -- private Methods
#pragma mark 生成当天的某个点
- (NSDate *)getCustomDateWithHour:(NSInteger)hour{
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    return [self getCustomDate:currentDate WithHour:hour];
}
#pragma mark 生成某一天的某个点
-(NSDate *)getCustomDate:(NSDate *)currentDate WithHour:(NSInteger)hour{
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}
#pragma mark 获取本周或上周的周一和周日的时间  "inedx 为代表前后几周"
- (NSDictionary *)getWeekTime:(NSInteger)index{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit
                                         fromDate:now];

    // 得到星期几
    // 1(星期天) 2(星期二) 3(星期三) 4(星期四) 5(星期五) 6(星期六) 7(星期天)
    NSInteger weekDay = [comp weekday];
    // 得到几号
    NSInteger day = [comp day];
    
    // 计算当前日期和这周的星期一和星期天差的天数
    long firstDiff,lastDiff;
    if (weekDay == 1) {
        firstDiff = 1;
        lastDiff = 0;
    }else{
        firstDiff = [calendar firstWeekday]+1 - weekDay-7*index;
        lastDiff = 8 - weekDay-7*index;
    }
    
    NSLog(@"firstDiff:%ld   lastDiff:%ld",firstDiff,lastDiff);
    
    // 在当前日期(去掉了时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSCalendarUnitYear|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek= [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek= [calendar dateFromComponents:lastDayComp];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy年MM月dd日"];
    MyLog(@"星期一开始 %@",[formater stringFromDate:firstDayOfWeek]);
    MyLog(@"当前 %@",[formater stringFromDate:now]);
    MyLog(@"星期天结束 %@",[formater stringFromDate:lastDayOfWeek]);
    NSDictionary *dict = @{@"firstday":[formater stringFromDate:firstDayOfWeek],@"lastday":[formater stringFromDate:lastDayOfWeek]};
    return dict;
}

#pragma mark 获取当前的年龄
-(NSInteger)getCurrentAgeWithBornDate:(NSString *)bornDate{
    NSDate *currentDate=[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [formatter dateFromString:bornDate];    //将字符串按formatter转成nsdate
    NSTimeInterval time=[currentDate timeIntervalSinceDate:date];
    return ((NSInteger)time)/(3600*24*365);
}

- (NSString *)featureWeekdayWithDate:(NSString *)featureDate{
    // 创建 格式 对象
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置 日期 格式 可以根据自己的需求 随时调整， 否则计算的结果可能为 nil
    formatter.dateFormat = @"yyyy-MM-dd";
    // 将字符串日期 转换为 NSDate 类型
    NSDate *endDate = [formatter dateFromString:featureDate];
    // 判断当前日期 和 未来某个时刻日期 相差的天数
    long days = [self daysFromDate:[NSDate date] toDate:endDate];
    // 将总天数 换算为 以 周 计算（假如 相差10天，其实就是等于 相差 1周零3天，只需要取3天，更加方便计算）
    long day = days >= 7 ? days % 7 : days;
    long week = [self getNowWeekday] + day;
    switch (week) {
        case 1:
            return @"日";
            break;
        case 2:
            return @"一";
            break;
        case 3:
            return @"二";
            break;
        case 4:
            return @"三";
            break;
        case 5:
            return @"四";
            break;
        case 6:
            return @"五";
            break;
        case 7:
            return @"六";
            break;
            
        default:
            break;
    }
    return nil;
}
/**
 *  计算2个日期相差天数
 *  startDate   起始日期
 *  endDate     截至日期
 */
-(NSInteger)daysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    // 话说在真机上需要设置区域，才能正确获取本地日期，天朝代码:zh_CN
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //得到相差秒数
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    int days = ((int)time)/(3600*24);
    int hours = ((int)time)%(3600*24)/3600;
    int minute = ((int)time)%(3600*24)/3600/60;
    if (days <= 0 && hours <= 0&&minute<= 0) {
        NSLog(@"0天0小时0分钟");
        return 0;
    }
    else {
        NSLog(@"%@",[[NSString alloc] initWithFormat:@"%i天%i小时%i分钟",days,hours,minute]);
        // 之所以要 + 1，是因为 此处的days 计算的结果 不包含当天 和 最后一天\
        （如星期一 和 星期四，计算机 算的结果就是2天（星期二和星期三），日常算，星期一——星期四相差3天，所以需要+1）\
        对于时分 没有进行计算 可以忽略不计
        return days + 1;
    }
}

// 获取当前是星期几
- (NSInteger)getNowWeekday {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *now = [NSDate date];
    // 话说在真机上需要设置区域，才能正确获取本地日期，天朝代码:zh_CN
    calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    comps = [calendar components:unitFlags fromDate:now];
    return [comps weekday];
}
/// 获取当前时间前后三天对应的星期几
- (NSArray *)getWeekdays{
     NSArray *weekDays = [NSArray array];
    long week = [self getNowWeekday];
   
    switch (week) {
        case 1:
        {
            weekDays = @[@"四",@"五",@"六",@"日",@"一",@"二",@"三"];
        }
            break;
        case 2:
        {
            weekDays = @[@"五",@"六",@"日",@"一",@"二",@"三",@"四"];
        }break;
        case 3:
        {
            weekDays = @[@"六",@"日",@"一",@"二",@"三",@"四",@"五"];
        }break;
        case 4:
        {
            weekDays = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
        }break;
        case 5:
        {
             weekDays = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
        }break;
        case 6:
        {
             weekDays = @[@"二",@"三",@"四",@"五",@"六",@"日",@"一"];
        }break;
        case 7:
        {
            weekDays = @[@"三",@"四",@"五",@"六",@"日",@"一",@"二"];
        }break;
        default:
            break;
            
    }
    return weekDays;
}
/// 获取当前时间前一周对应星期几
- (NSArray *)getLastWeekdays{
    NSArray *weekDays = [NSArray array];
    long week = [self getNowWeekday];
    
    switch (week) {
        case 1:
        {
            weekDays = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
        }
            break;
        case 2:
        {
            weekDays = @[@"二",@"三",@"四",@"五",@"六",@"日",@"一"];
        }break;
        case 3:
        {
            weekDays = @[@"三",@"四",@"五",@"六",@"日",@"一",@"二"];
        }break;
        case 4:
        {
            weekDays = @[@"四",@"五",@"六",@"日",@"一",@"二",@"三"];
        }break;
        case 5:
        {
            weekDays = @[@"五",@"六",@"日",@"一",@"二",@"三",@"四"];
        }break;
        case 6:
        {
            weekDays = @[@"六",@"日",@"一",@"二",@"三",@"四",@"五"];
        }break;
        case 7:
        {
            weekDays = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
        }break;
        default:
            break;
            
    }
    return weekDays;
}
- (NSInteger)loadDeviceID:(NSString *)str{

    if ([str isEqualToString:@"1607d2afae93fc001607d2afae93fc01"]) {
        return 1;
    } else if([str isEqualToString:@"160fa2adcd1cb000160fa2adcd1cb001"]){
        return 2;
    } else if([str isEqualToString:@"160fa2ad504e6000160fa2ad504e6001"]){
        return 3;
    } else if([str isEqualToString:@"160fa2ad504ed800160fa2ad504ed801"]){
        return 4;
    } else if([str isEqualToString:@"160fa2ad4bf73800160fa2ad4bf73801"]){
        return 5;
    } else if([str isEqualToString:@"1607d2af9faabe001607d2af9faabe01"]){
        return 6;
    }
    return 0;
}

#pragma mark -- 获取最大时间
- (NSMutableArray *)loadMaxTime:(NSArray *)timeArray{
    
    NSMutableArray *array = [timeArray mutableCopy];
    
    array = (NSMutableArray *)[array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        if (obj1 == [NSNull null]) {
            obj1 = @"0000/00/00";
        }
        if (obj2 == [NSNull null]) {
            obj2 = @"0000/00/00";
        }
        NSDate *date1 = [formatter dateFromString:obj1];
        NSDate *date2 = [formatter dateFromString:obj2];
        NSComparisonResult result = [date1 compare:date2];
        return result == NSOrderedAscending;
    }];
    return array;
}
#pragma mark -- 获取设备图片名称
- (NSString *)loadDeviceImageView:(NSString *)deviceID{
    if ([deviceID isEqualToString:CLOUD_COOKER_PRODUCT_ID]) {
        return @"eq02.yundunguo";
    }else if ([deviceID isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]){
        return @"eq07.dianfangbao";
    }else if ([deviceID isEqualToString:WATER_COOKER_PRODUCT_ID]){
        return @"eq03.geshuidun";
    }else if ([deviceID isEqualToString:CLOUD_KETTLE_PRODUCT_ID]){
        return @"eq05.sixianghu";
    }else if ([deviceID isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]){
        return @"eq04.16a";
    }else if ([deviceID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]){
        return @"eq06.jiankangdachu";
    }else if ([deviceID isEqualToString:CABINETS_PRODUCT_ID]){
        return @"eq_chuwugui";
    }
    return nil;
}
#pragma mark -- 比较两个日期大小
- (NSInteger)compareDate:(NSString*)aDate withDate:(NSString*)bDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateA = [dateFormatter dateFromString:aDate];
    NSDate *dateB = [dateFormatter dateFromString:bDate];
    NSComparisonResult result = [dateA compare:dateB];
    if (result == NSOrderedDescending) {
        return 1;
    }
    else if (result == NSOrderedAscending){
        return -1;
    }
    return 0;
}
/**
 *
 *  获取设备的唯一标示uuid
 */
- (NSString *)deviceUUID{
    
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    return uuid;
}
#pragma mark -- 判断当前是不是在使用九宫格输入
-(BOOL)isNineKeyBoard:(NSString *)string
{
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)string.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:string].location != NSNotFound))
            return NO;
    }
    return YES;
}
#pragma mark -- 限制emoji表情输入
-(BOOL)strIsContainEmojiWithStr:(NSString*)str{
    __block BOOL returnValue =NO;
    [str enumerateSubstringsInRange:NSMakeRange(0, [str length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         const unichar hs = [substring characterAtIndex:0];
         if(0xd800<= hs && hs <=0xdbff){
             if(substring.length>1){
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs -0xd800) *0x400) + (ls -0xdc00) +0x10000;
                 if(0x1d000<= uc && uc <=0x1f77f){
                     returnValue =YES;
                 }
             }
         }
         else if(substring.length>1){
             const unichar ls = [substring characterAtIndex:1];
             if(ls ==0x20e3)
             {
                 returnValue =YES;
             }
         }else{
             // non surrogate
             if(0x2100<= hs && hs <=0x27ff&& hs !=0x263b)
             {
                 returnValue =YES;
             }
             else if(0x2B05<= hs && hs <=0x2b07)
             {
                 returnValue =YES;
             }
             else if(0x2934<= hs && hs <=0x2935)
             {
                 returnValue =YES;
             }
             else if(0x3297<= hs && hs <=0x3299)
             {
                 returnValue =YES;
             }
             else if(hs ==0xa9|| hs ==0xae|| hs ==0x303d|| hs ==0x3030|| hs ==0x2b55|| hs ==0x2b1c|| hs ==0x2b1b|| hs ==0x2b50|| hs ==0x231a)
             {
                 returnValue =YES;
             }
         }
     }];
    return returnValue;
}
#pragma mark -- 限制第三方键盘（常用的是搜狗键盘）的表情
- (BOOL)hasEmoji:(NSString*)string
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

#pragma mark ====== 判断当前时间是否在时间段内 (忽略年月日) =======
- (BOOL)judgeTimeByStartAndEnd:(NSString *)startTime withExpireTime:(NSString *)expireTime{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    // 时间格式,此处遇到过坑,建议时间HH大写,手机24小时进制和12小时禁止都可以完美格式化
    [dateFormat setDateFormat:@"HH:mm"];
    NSString * todayStr=[dateFormat stringFromDate:today];//将日期转换成字符串
    today=[ dateFormat dateFromString:todayStr];//转换成NSDate类型。日期置为方法默认日期
    //startTime格式为 02:22   expireTime格式为 12:44
    NSDate *start = [dateFormat dateFromString:startTime];
    NSDate *expire = [dateFormat dateFromString:expireTime];
    
    if ([today compare:start] == NSOrderedDescending && [today compare:expire] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

@end
