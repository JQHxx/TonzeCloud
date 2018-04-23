//
//  MeasurementsModel.h
//  Product
//
//  Created by 梁家誌 on 16/8/24.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BPRecord;
@class BodyTempRecord;

typedef enum : NSUInteger {
    MeasurementType_Temp = 0,//体温计
    MeasurementType_BPMeter,//血压计
} MeasurementType;

@interface MeasurementsModel : NSObject

@property (strong, nonatomic) NSString *mac;

@property (strong, nonatomic) NSString *name;//(云)
@property (assign, nonatomic) NSInteger userId;//(云)
@property (strong, nonatomic) NSString *describe;//描述：高烧、轻度高压
@property (assign, nonatomic) NSInteger SBP;//高压(云)
@property (assign, nonatomic) NSInteger DBP;//低压(云)
@property (assign, nonatomic) NSInteger heartRate;//(云)
@property (assign, nonatomic) float temp;//(云)
@property (strong, nonatomic) NSString *date;//(云)
@property (strong, nonatomic) NSString *fromName;

@property (assign, nonatomic) MeasurementType type;

- (instancetype)initFromBPRecord:(BPRecord *)record;
- (instancetype)initFromBodyTempRecord:(BodyTempRecord *)record;

- (instancetype)initFromDict:(NSDictionary *)dict;

- (NSDictionary *)getDictionary;
- (NSDictionary *)getJSDictionary;

@end
