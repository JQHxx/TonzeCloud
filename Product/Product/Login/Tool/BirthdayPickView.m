//
//  BirthdayPickView.m
//  Product
//
//  Created by 肖栋 on 17/5/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BirthdayPickView.h"
@interface BirthdayPickView (){
    UIView       *rootView;
    NSString     *dateStr;
    DateType    _type;
}

@end
@implementation BirthdayPickView

-(instancetype)initWithFrame:(CGRect)frame birthdayValue:(NSString *)dateValue dateType:(DateType)type pickerType:(birthdayPickerViewType)pickerType{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        UIDatePicker  *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,20,kScreenWidth,200)];
        // 设置时区，中国在东八区
        picker.datePickerMode =type==birthdayTypeDate?UIDatePickerModeDate:UIDatePickerModeDateAndTime;
        [picker addTarget:self action:@selector(seletedBirthyDate:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:picker];
        
        rootView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        rootView.backgroundColor=[UIColor blackColor];
        rootView.alpha=0.3;
        
        _type=type;
        
        //设置当前时间
        dateStr=dateValue;
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        dateFormatter.dateFormat=type==birthdayTypeDate?@"yyyy-MM-dd":@"yyyy-MM-dd HH:mm";
        NSDate *date=[dateFormatter dateFromString:dateStr];
        [picker setDate:date animated:YES];
        
        //设置最大时间和最小时间
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *currentDate=[NSDate date];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        
        NSDate *maxDate;
        NSDate *minDate;
        if (pickerType==birthdayPickerViewTypeNormal) {
            maxDate=currentDate;
            [comps setYear:-10];
            minDate=[calendar dateByAddingComponents:comps toDate:currentDate options:0];
        }else if(pickerType==birthdayPickerViewTypeBirthday){
            [comps setYear:-7];
            maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
            minDate=[dateFormatter dateFromString:@"1930-01-01"];
            
        }
        [picker setMaximumDate:maxDate];
        [picker setMinimumDate:minDate];
        
    }
    return self;
}


-(void)birthdayPickerViewShowInView:(UIView *)view{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"datePickerView"];
    
    self.frame=CGRectMake(0,kAllHeight-self.height, kScreenWidth, self.height);
    [view addSubview:rootView];
    [view addSubview:self];
}

#pragma mark -- Event Response
#pragma mark 取消
-(void)cancelSelectPickView:(UIButton *)sender{
    [self dismissAction];
}

-(void)viewRemoveFromSuperview{
    [rootView removeFromSuperview];
    [self removeFromSuperview];
}

-(void)dismissAction{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"datePickerView"];
    
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3];
}
-(void)seletedBirthyDate:(UIDatePicker *)datePicker{
    NSDate *currentDate=datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat=_type==birthdayTypeDate?@"yyyy-MM-dd":@"yyyy-MM-dd HH:mm";
    dateStr = [formatter stringFromDate:currentDate];
    if (!kIsEmptyString(dateStr)) {
        if ([_birthdayPickerViewDelegate respondsToSelector:@selector(birthdayPickerView:didSelectDate:)]) {
            [_birthdayPickerViewDelegate birthdayPickerView:self didSelectDate:dateStr];
        }
    }
}

-(void)seletedAgeBirthyDate:(UIDatePicker *)datePicker{
    NSDate *currentDate=datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat=_type==birthdayTypeDate?@"yyyy-MM-dd":@"yyyy-MM-dd HH:mm";
    dateStr = [formatter stringFromDate:currentDate];
    if (!kIsEmptyString(dateStr)) {
        if ([_birthdayPickerViewDelegate respondsToSelector:@selector(birthdayPickerView:didSelectDate:)]) {
            [_birthdayPickerViewDelegate birthdayPickerView:self didSelectDate:dateStr];
        }
    }
    
}


@end
