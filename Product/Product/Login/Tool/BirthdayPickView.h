//
//  BirthdayPickView.h
//  Product
//
//  Created by 肖栋 on 17/5/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    birthdayTypeDate =0,
    birthdayTypeDateTime = 1 << 0
} DateType;

typedef enum : NSUInteger {
    birthdayPickerViewTypeNormal =0,
    birthdayPickerViewTypeBirthday = 1 << 0
}  birthdayPickerViewType;

@class BirthdayPickView;

@protocol birthdayPickerViewDelegate <NSObject>

-(void)birthdayPickerView:(BirthdayPickView *)pickerView didSelectDate:(NSString *)dateStr;

@end
@interface BirthdayPickView : UIView

@property (nonatomic,weak)id<birthdayPickerViewDelegate>birthdayPickerViewDelegate;

-(instancetype)initWithFrame:(CGRect)frame birthdayValue:(NSString *)dateValue dateType:(DateType)type pickerType:(birthdayPickerViewType)pickerType;

-(void)birthdayPickerViewShowInView:(UIView *)view;
@end
