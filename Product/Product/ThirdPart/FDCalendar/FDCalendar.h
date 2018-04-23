//
//  FDCalendar.h
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  FDCalendarDelegate<NSObject>

-(void)calendarDidSelectDate:(NSString *)dateStr;

@end

@interface FDCalendar : UIView

@property (nonatomic,assign)id<FDCalendarDelegate>calendarDelegate;

- (instancetype)initWithCurrentDate:(NSDate *)date;

@end
