//
//  TonzeHelpTool.m
//  Product
//
//  Created by vision on 17/1/3.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#define kDietitian         @"dietitian"
#define kDietitianDetails  @"dietitianDetails"
#define kMenuDetails       @"menuDetails"
#define kFoodDetails       @"foodDetails"
#define kSportsDetails     @"sportsDetails"
#define kFoodSearch        @"foodSearch"
#define kReportDetails     @"reportDetails"
#define kMonitorDetails    @"monitorDetails"


#import "TonzeHelpTool.h"

@implementation TonzeHelpTool

singleton_implementation(TonzeHelpTool);


#pragma mark 获取缓存大小
-(double)getCachFileSize{
    NSString * cachPath = [ NSSearchPathForDirectoriesInDomains ( NSCachesDirectory , NSUserDomainMask , YES ) firstObject ];
    NSFileManager * manager = [ NSFileManager defaultManager ];
    if (![manager fileExistsAtPath :cachPath]) return 0 ;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :cachPath] objectEnumerator ];
    NSString * fileName;
    long long folderSize = 0 ;
    while ((fileName = [childFilesEnumerator nextObject ]) != nil ){
        NSString * fileAbsolutePath = [cachPath stringByAppendingPathComponent :fileName];
        folderSize += [ self fileSizeAtPath :fileAbsolutePath];
    }
    return folderSize/( 1024.0 * 1024.0 );
}

-(long long ) fileSizeAtPath:( NSString *) filePath{
    NSFileManager * manager = [ NSFileManager defaultManager ];
    if ([manager fileExistsAtPath :filePath]){
        return [[manager attributesOfItemAtPath :filePath error : nil ] fileSize ];
    }
    return 0 ;
}

#pragma mark 计算每日目标摄入
-(void)calculateDailyEnergyWithHeight:(NSInteger)height weight:(double)weight labor:(NSString *)laborIntensity{
    NSInteger calorie=0;
    double bmiValue=weight/(height/100)*(height/100);
    if (bmiValue>=24.0) {  //肥胖
        if ([laborIntensity isEqualToString:@"卧床"]) {
            calorie=70;
        }else if ([laborIntensity isEqualToString:@"轻体力劳动"]){
            calorie=90;
        }else if ([laborIntensity isEqualToString:@"中体力劳动"]){
            calorie=120;
        }else{
            calorie=140;
        }
    }else if (bmiValue<18.5){ //偏瘦
        if ([laborIntensity isEqualToString:@"卧床"]) {
            calorie=110;
        }else if ([laborIntensity isEqualToString:@"轻体力劳动"]){
            calorie=140;
        }else if ([laborIntensity isEqualToString:@"中体力劳动"]){
            calorie=160;
        }else{
            calorie=190;
        }
    }else{  //正常
        if ([laborIntensity isEqualToString:@"卧床"]) {
            calorie=90;
        }else if ([laborIntensity isEqualToString:@"轻体力劳动"]){
            calorie=120;
        }else if ([laborIntensity isEqualToString:@"中体力劳动"]){
            calorie=140;
        }else{
            calorie=160;
        }
    }
    NSInteger normalWeight=height-105;
    NSInteger tempEnergy=normalWeight*calorie;  //KJ
    NSInteger intakeEnergy=tempEnergy*0.239+0.5;
    [NSUserDefaultInfos putKey:kDailyEnergy andValue:[NSNumber numberWithInteger:intakeEnergy]];
}


-(NSInteger)getPersonAgeWithBirthdayString:(NSString *)birth{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //生日
    NSDate *birthDay = [dateFormatter dateFromString:birth];
    //当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [dateFormatter dateFromString:currentDateStr];
    
    NSTimeInterval time=[currentDate timeIntervalSinceDate:birthDay];
    NSInteger age = ((NSInteger)time)/(3600*24*365);
    return age;
}

@end
