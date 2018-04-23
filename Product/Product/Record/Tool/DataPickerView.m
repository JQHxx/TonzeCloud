//
//  DataPickerView.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DataPickerView.h"
@interface DataPickerView (){
    UIView       *rootView;
    NSString     *dateStr;
    DateType    _type;
}

@end
@implementation DataPickerView

-(instancetype)initWithFrame:(CGRect)frame value:(NSString *)dateValue dateType:(DateType)type pickerType:(DatePickerViewType)pickerType title:(NSString *)title{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/4, 10, kScreenWidth/2, 20)];
        timeLabel.text =title;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:timeLabel];
        
        UIButton *cancelbtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelbtn setFrame:CGRectMake(0.0, 0.0, 80.0, 40.0)];
        [cancelbtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        cancelbtn.titleLabel.font=[UIFont systemFontOfSize:16.0f];
        [cancelbtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelbtn addTarget:self action:@selector(cancelSelectPickView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelbtn];
        
        UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [doneBtn setFrame:CGRectMake(kScreenWidth-80, 0.0, 80.0, 40.0)];
        [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        doneBtn.titleLabel.font=[UIFont systemFontOfSize:16.0f];
        [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(didSelectPickView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneBtn];
        
        UILabel *lineLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 1)];
        lineLabel.backgroundColor=kLineColor;
        [self addSubview:lineLabel];
        
        
        UIDatePicker  *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,40,kScreenWidth,200)];
        // 设置时区，中国在东八区
        picker.datePickerMode =type==DateTypeDate?UIDatePickerModeDate:UIDatePickerModeDateAndTime;
        [picker addTarget:self action:@selector(seletedBirthyDate:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:picker];
        
        rootView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        rootView.backgroundColor=[UIColor blackColor];
        rootView.alpha=0.3;
        
        _type=type;
        
        //设置当前时间
        dateStr=dateValue;
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        dateFormatter.dateFormat=type==DateTypeDate?@"yyyy-MM-dd":@"yyyy-MM-dd HH:mm";
        NSDate *date=[dateFormatter dateFromString:dateStr];
        [picker setDate:date animated:YES];
        
        //设置最大时间和最小时间
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *currentDate=[NSDate date];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        
        NSDate *maxDate;
        NSDate *minDate;
        if (pickerType==DatePickerViewTypeFuture) {
            //不设置最大最小时间
        }else{
            if (pickerType==DatePickerViewTypeNormal) {
                maxDate=currentDate;
                [comps setYear:-10];
                minDate=[calendar dateByAddingComponents:comps toDate:currentDate options:0];
            }else if(pickerType==DatePickerViewTypeBirthday){
                [comps setYear:-7];
                maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
                minDate=[dateFormatter dateFromString:@"1930-01-01"];
                
            }
            [picker setMaximumDate:maxDate];
            [picker setMinimumDate:minDate];
        }
    }
    return self;
}


-(void)datePickerViewShowInView:(UIView *)view{
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
#pragma mark 确定
-(void)didSelectPickView:(UIButton *)sender{
    [self dismissAction];
    if (!kIsEmptyString(dateStr)) {
        if ([_pickerDelegate respondsToSelector:@selector(datePickerView:didSelectDate:)]) {
            [_pickerDelegate datePickerView:self didSelectDate:dateStr];
        }
    }
}
-(void)seletedBirthyDate:(UIDatePicker *)datePicker{
    NSDate *currentDate=datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat=_type==DateTypeDate?@"yyyy-MM-dd":@"yyyy-MM-dd HH:mm";
    dateStr = [formatter stringFromDate:currentDate];
}

-(void)seletedAgeBirthyDate:(UIDatePicker *)datePicker{
    NSDate *currentDate=datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat=_type==DateTypeDate?@"yyyy-MM-dd":@"yyyy-MM-dd HH:mm";
    dateStr = [formatter stringFromDate:currentDate];
    if (!kIsEmptyString(dateStr)) {
        if ([_pickerDelegate respondsToSelector:@selector(datePickerView:didSelectDate:)]) {
            [_pickerDelegate datePickerView:self didSelectDate:dateStr];
        }
    }
    
}


@end
