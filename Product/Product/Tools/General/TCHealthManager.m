//
//  TCHealthManager.m
//  TonzeCloud
//
//  Created by vision on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCHealthManager.h"

@implementation TCHealthManager

singleton_implementation(TCHealthManager);

#pragma mark--检查是否支持获取健康数据
-(void)authorizeHealthKit:(void (^)(BOOL, NSError *))completion{
    if (kIOSVersion >= 8.0) {
        if (![HKHealthStore isHealthDataAvailable]) {
            NSDictionary *userInfo=[NSDictionary dictionaryWithObject:@"HealthKit is not available in this Device" forKey:@"error"];
            NSError *error=[NSError errorWithDomain:@"healthErrorDomain" code:2 userInfo:userInfo];
            if (completion!=nil) {
                completion(0,error);
            }
            return;
        }
        if ([HKHealthStore isHealthDataAvailable]) {
            HKHealthStore *healthStore=[[HKHealthStore alloc] init];
            /*
             组装需要读写的数据类型
             */
            NSSet *readDataTypes = [self dataTypesRead];
            /*
             注册需要读写的数据类型，也可以在“健康”APP中重新修改
             */
            [healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
                if (completion != nil) {
                    completion (1, nil);
                }
            }];
        }
    }else{
        NSDictionary *userInfo=[NSDictionary dictionaryWithObject:@"iOS系统低于8.0" forKey:@"error"];
        NSError *aError=[NSError errorWithDomain:@"healthErrorDomain" code:0 userInfo:userInfo];
        completion(0,aError);
    }
}


#pragma mark --读取步数
-(void)getStepCountWithDays:(NSInteger)days complete:(void (^)(NSMutableArray *, NSError *))completion{
    HKQuantityType *stepType=[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSortDescriptor *starTimeDescriptor=[[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *endTimeDescriptor=[[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    NSPredicate *predicate=[self predicateForDays:days-1];
    HKHealthStore *healthStore=[[HKHealthStore alloc] init];
    HKSampleQuery *query=[[HKSampleQuery alloc] initWithSampleType:stepType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[starTimeDescriptor,endTimeDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if (error) {
            MyLog(@"读取步数失败，error:%@",error.localizedDescription);
            completion(0,error);
        }else{
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for (NSInteger i=0; i<days; i++) {
                NSString *dateStr=[[TJYHelper sharedTJYHelper] getLastWeekDateWithDays:i];
                NSInteger totalSteps=0;
                for (HKQuantitySample *quantitySample in results) {
                    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
                    [dateFormat setDateFormat:@"yyyy-MM-dd"];//设定时间格式,这里可以设置成自己需要的格式
                    NSString *currentDateStr = [dateFormat stringFromDate:quantitySample.startDate];
                    if ([currentDateStr isEqualToString:dateStr]) {
                        HKQuantity *quatity=quantitySample.quantity;
                        HKUnit *stepUnit=[HKUnit countUnit];
                        double count=[quatity doubleValueForUnit:stepUnit];
                        totalSteps +=count;
                    }
                }
                NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:totalSteps],dateStr,nil];
                [tempArr addObject:dict];
            }
            MyLog(@"当天行走步数:%@",tempArr);
            completion(tempArr,nil);
        }
    }];
    [healthStore executeQuery:query];
}


#pragma mark --读取步行＋跑步距离
-(void)getDistance:(void (^)(double, NSError *))completion{
    HKQuantityType *distanceType=[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    NSSortDescriptor *timeSortDescriptor=[[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    NSPredicate *predicate=[self predicateForSamplesToday];
    HKHealthStore *healthStore=[[HKHealthStore alloc] init];
    HKSampleQuery *query=[[HKSampleQuery alloc] initWithSampleType:distanceType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if (error) {
            MyLog(@"读取距离失败，error:%@",error.localizedDescription);
            completion(0,error);
        }else{
            double totalDistance=0;
            for (HKQuantitySample *quantitySample in results) {
                HKQuantity *quatity=quantitySample.quantity;
                HKUnit *distanceUnit=[HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo];
                double distance=[quatity doubleValueForUnit:distanceUnit];
                totalDistance +=distance;
            }
            MyLog(@"当天行走距离:%f公里",totalDistance);
            completion(totalDistance,nil);
        }
    }];
    [healthStore executeQuery:query];
}


/*!
 *  @brief  写权限
 *  @return 集合
 */
- (NSSet *)dataTypesToWrite
{
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *temperatureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    return [NSSet setWithObjects:heightType, temperatureType, weightType,activeEnergyType,nil];
}

/*!
 *  @brief  读权限
 *  @return 集合
 */
- (NSSet *)dataTypesRead{
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    return [NSSet setWithObjects:stepCountType, distanceType,nil];
}


/*!
 *  @brief  当天时间段
 *
 *  @return 时间段
 */
-(NSPredicate *)predicateForSamplesToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}

/*!
 *  @brief  days到今天时间段
 *
 *  @return 时间段
 */
-(NSPredicate *)predicateForDays:(NSInteger)days{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *endDate = [NSDate date];
    
    NSDateComponents *components=[calendar components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:endDate];
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    
    NSDate *aDate=[calendar dateByAddingComponents:components toDate:endDate options:0];
    [components setHour:-days*24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *startDate=[calendar dateByAddingComponents:components toDate:aDate options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
    
}


@end
