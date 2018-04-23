#import "MathData.h"
#import <CoreLocation/CoreLocation.h>

static bool const isMetric = YES;
static float const metersInKM = 1000;
static float const metersInMile = 1609.344;

@implementation MathData

+ (NSString *)stringifyDistance:(float)meters
{
    float unitDivider;
    NSString *unitName;
    
    // metric
    if (isMetric) {
        unitName = @"公里";
        // 设置 kilometers
        unitDivider = metersInKM;
        // U.S.
    } else {
        unitName = @"米";
        // 设置 miles
        unitDivider = metersInMile;
    }
    float distance = meters/unitDivider;
    return [NSString stringWithFormat:@"%.2f%@", distance, unitName];
}

+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat
{
    int remainingSeconds = seconds;
    int hours = remainingSeconds / 3600;
    remainingSeconds = remainingSeconds - hours * 3600;
    int minutes = remainingSeconds / 60;
    remainingSeconds = remainingSeconds - minutes * 60;
    
    if (longFormat) {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%ihr %imin %isec", hours, minutes, remainingSeconds];
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%imin %isec", minutes, remainingSeconds];
        } else {
            return [NSString stringWithFormat:@"%isec", remainingSeconds];
        }
    } else {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, remainingSeconds];
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"00:%02i:%02i", minutes, remainingSeconds];
        } else {
            return [NSString stringWithFormat:@"00:00:%02i", remainingSeconds];
        }
    }
}

+ (NSString *)calculationAverageSpeedWithMeters:(float )metersKm time:(int)time{

    if (metersKm == 0 || time == 0) {
        return @"--";
    }
    CGFloat speed = metersKm/(time/60);
    NSString *speedStr =[NSString stringWithFormat:@"%.2f",speed];
    return speedStr;
}

+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds ifleft:(BOOL)left
{
    if (seconds == 0 || meters == 0) {
        return @"--";
    }
    NSString *unitName;
    float unitMultiplier;
    // metric
    if (isMetric) {
        unitName = @"分钟/公里";
        unitMultiplier = metersInKM;
    // U.S.
    } else {
        unitName = @"分钟/米";
        unitMultiplier = metersInMile;
    }
    
    if (left)
    {
        float avgPaceSecMeters = seconds / meters;
        int paceMin = (int) ((avgPaceSecMeters * unitMultiplier) / 60);
        int paceSec = (int) (avgPaceSecMeters * unitMultiplier - (paceMin*60));
    
        return [NSString stringWithFormat:@"%i:%02i%@", paceMin, paceSec, unitName];
    }else
    {
        CGFloat time = seconds/60;
        float total = meters/unitMultiplier;
        float avgPaceMetersSec = total/time;
        if (seconds > 60) {
           return [NSString stringWithFormat:@"%.2f",avgPaceMetersSec];
        }else{
            return @"0.00";
        }
    }
}

+ (float)valueifDistance:(float)meters Time:(int)seconds
{
    float speed = seconds/meters*40/6; //分钟／400米
    return PERSON_WEIGHT*30/speed*seconds/3600/1000;
    //跑步热量（kcal）＝体重（kg）×运动时间（小时）×指数K  指数K＝30÷速度（分钟/400米）
}

@end
