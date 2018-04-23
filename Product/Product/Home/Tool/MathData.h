#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define PERSON_WEIGHT ([[NSUserDefaults standardUserDefaults] objectForKey:@"weight"] == nil? 60 :([[NSUserDefaults standardUserDefaults] floatForKey:@"weight"]))

@interface MathData : NSObject

+ (NSString *)stringifyDistance:(float)meters;
+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;
/*
*  计算运动的速度
*   metersKm  运动里程 （公里）
*   time    时间
*   return   分钟/公里
*/
+ (NSString *)calculationAverageSpeedWithMeters:(float )metersKm time:(int)time;

+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds ifleft:(BOOL)left;
+ (float)valueifDistance:(float)meters Time:(int)seconds;

@end
