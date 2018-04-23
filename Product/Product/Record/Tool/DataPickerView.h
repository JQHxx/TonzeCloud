//
//  DataPickerView.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    DateTypeDate =0,
    DateTypeDateTime = 1 << 0
} DateType;

typedef enum : NSUInteger {
    DatePickerViewTypeNormal =0,
    DatePickerViewTypeBirthday = 1 << 0,
    DatePickerViewTypeFuture =2
} DatePickerViewType;

@class DatePickerView;

@protocol DatePickerViewDelegate <NSObject>

-(void)datePickerView:(DatePickerView *)pickerView didSelectDate:(NSString *)dateStr;

@end
@interface DataPickerView : UIView

@property (nonatomic,weak)id<DatePickerViewDelegate>pickerDelegate;

-(instancetype)initWithFrame:(CGRect)frame value:(NSString *)dateValue dateType:(DateType)type pickerType:(DatePickerViewType)pickerType title:(NSString *)title;

-(void)datePickerViewShowInView:(UIView *)view;


@end

